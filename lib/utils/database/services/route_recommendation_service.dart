import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:zwiftdataviewer/models/route_recommendation.dart';
import 'package:zwiftdataviewer/models/routedata.dart';
import 'package:zwiftdataviewer/models/user_route_interaction.dart';
import 'package:zwiftdataviewer/providers/routedataprovider.dart';
import 'package:zwiftdataviewer/utils/database/database_helper.dart';
import 'package:zwiftdataviewer/utils/repository/filerepository.dart';

/// Service class for managing route recommendations and user route interactions
/// in the local SQLite database. This serves as the local cache layer
/// for the route recommendation system.
class RouteRecommendationService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  /// Creates the necessary tables for route recommendations if they don't exist
  Future<void> createTables() async {
    final db = await _databaseHelper.database;
    
    // Create user_route_interactions table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_route_interactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        route_id INTEGER NOT NULL,
        activity_id INTEGER NOT NULL,
        athlete_id TEXT NOT NULL,
        completed_at TEXT NOT NULL,
        completion_time_seconds REAL,
        average_power REAL,
        average_heart_rate REAL,
        max_power REAL,
        max_heart_rate REAL,
        normalized_power REAL,
        intensity_factor REAL,
        training_stress_score REAL,
        average_speed REAL,
        max_speed REAL,
        elevation_gain REAL,
        perceived_effort TEXT,
        enjoyment_rating REAL,
        was_personal_record INTEGER DEFAULT 0,
        additional_metrics TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(activity_id, route_id)
      )
    ''');

    // Create route_recommendations table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS route_recommendations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        athlete_id TEXT NOT NULL,
        route_id INTEGER NOT NULL,
        confidence_score REAL NOT NULL,
        recommendation_type TEXT NOT NULL,
        reasoning TEXT NOT NULL,
        scoring_factors TEXT NOT NULL,
        generated_at TEXT NOT NULL,
        is_viewed INTEGER DEFAULT 0,
        is_completed INTEGER DEFAULT 0,
        expires_at TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(athlete_id, route_id, recommendation_type)
      )
    ''');

    // Create indexes for performance
    await db.execute('CREATE INDEX IF NOT EXISTS idx_user_route_interactions_athlete_id ON user_route_interactions(athlete_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_user_route_interactions_route_id ON user_route_interactions(route_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_user_route_interactions_completed_at ON user_route_interactions(completed_at)');
    
    await db.execute('CREATE INDEX IF NOT EXISTS idx_route_recommendations_athlete_id ON route_recommendations(athlete_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_route_recommendations_route_id ON route_recommendations(route_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_route_recommendations_confidence_score ON route_recommendations(confidence_score)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_route_recommendations_generated_at ON route_recommendations(generated_at)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_route_recommendations_expires_at ON route_recommendations(expires_at)');
  }

  // ==================== User Route Interactions ====================

  /// Inserts or updates a user route interaction
  Future<int> insertOrUpdateRouteInteraction(UserRouteInteraction interaction) async {
    final db = await _databaseHelper.database;
    final map = _routeInteractionToMap(interaction);
    
    return await db.insert(
      'user_route_interactions',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Gets all route interactions for a specific athlete
  Future<List<UserRouteInteraction>> getRouteInteractions(String athleteId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_route_interactions',
      where: 'athlete_id = ?',
      whereArgs: [athleteId],
      orderBy: 'completed_at DESC',
    );
    
    return maps.map((map) => _mapToRouteInteraction(map)).toList();
  }

  /// Gets route interactions for a specific route
  Future<List<UserRouteInteraction>> getRouteInteractionsForRoute(String athleteId, int routeId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_route_interactions',
      where: 'athlete_id = ? AND route_id = ?',
      whereArgs: [athleteId, routeId],
      orderBy: 'completed_at DESC',
    );
    
    return maps.map((map) => _mapToRouteInteraction(map)).toList();
  }

  /// Gets the most recent route interactions (last N activities)
  Future<List<UserRouteInteraction>> getRecentRouteInteractions(String athleteId, int limit) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_route_interactions',
      where: 'athlete_id = ?',
      whereArgs: [athleteId],
      orderBy: 'completed_at DESC',
      limit: limit,
    );
    
    return maps.map((map) => _mapToRouteInteraction(map)).toList();
  }

  /// Gets performance statistics for a specific route
  Future<Map<String, dynamic>?> getRoutePerformanceStats(String athleteId, int routeId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        COUNT(*) as completion_count,
        AVG(completion_time_seconds) as avg_completion_time,
        MIN(completion_time_seconds) as best_completion_time,
        AVG(average_power) as avg_power,
        MAX(max_power) as max_power_ever,
        AVG(intensity_factor) as avg_intensity_factor,
        AVG(enjoyment_rating) as avg_enjoyment_rating,
        SUM(CASE WHEN was_personal_record = 1 THEN 1 ELSE 0 END) as pr_count,
        MAX(completed_at) as last_completed_at
      FROM user_route_interactions 
      WHERE athlete_id = ? AND route_id = ?
    ''', [athleteId, routeId]);
    
    return result.isNotEmpty ? result.first : null;
  }

  // ==================== Route Recommendations ====================

  /// Inserts or updates route recommendations
  Future<void> insertOrUpdateRecommendations(List<RouteRecommendation> recommendations) async {
    final db = await _databaseHelper.database;
    
    await db.transaction((txn) async {
      for (final recommendation in recommendations) {
        final map = _routeRecommendationToMap(recommendation);
        await txn.insert(
          'route_recommendations',
          map,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  /// Gets active route recommendations for a specific athlete
  Future<List<RouteRecommendation>> getActiveRecommendations(String athleteId) async {
    final db = await _databaseHelper.database;
    final now = DateTime.now().toIso8601String();

    if (kDebugMode) {
      // Debug: Check total recommendations in DB
      final totalMaps = await db.query('route_recommendations');
      print('📊 Total recommendations in DB: ${totalMaps.length}');

      // Debug: Check recommendations for this athlete
      final athleteMaps = await db.query(
        'route_recommendations',
        where: 'athlete_id = ?',
        whereArgs: [athleteId],
      );
      print('📊 Recommendations for athlete $athleteId: ${athleteMaps.length}');

      // Debug: Check expired recommendations
      final expiredMaps = await db.query(
        'route_recommendations',
        where: 'athlete_id = ? AND expires_at IS NOT NULL AND expires_at <= ?',
        whereArgs: [athleteId, now],
      );
      print('📊 Expired recommendations: ${expiredMaps.length}');
      print('📊 Current time: $now');
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'route_recommendations',
      where: 'athlete_id = ? AND (expires_at IS NULL OR expires_at > ?)',
      whereArgs: [athleteId, now],
      orderBy: 'confidence_score DESC, generated_at DESC',
    );

    if (kDebugMode) {
      print('📊 Active (non-expired) recommendations: ${maps.length}');
    }

    return await _mapToRouteRecommendations(maps);
  }

  /// Gets top N recommendations for a specific athlete
  Future<List<RouteRecommendation>> getTopRecommendations(String athleteId, int limit) async {
    final db = await _databaseHelper.database;
    final now = DateTime.now().toIso8601String();

    final List<Map<String, dynamic>> maps = await db.query(
      'route_recommendations',
      where: 'athlete_id = ? AND (expires_at IS NULL OR expires_at > ?)',
      whereArgs: [athleteId, now],
      orderBy: 'confidence_score DESC, generated_at DESC',
      limit: limit,
    );

    return await _mapToRouteRecommendations(maps);
  }

  /// Marks a recommendation as viewed
  Future<void> markRecommendationAsViewed(int recommendationId) async {
    final db = await _databaseHelper.database;
    
    await db.update(
      'route_recommendations',
      {'is_viewed': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [recommendationId],
    );
  }

  /// Marks a recommendation as completed
  Future<void> markRecommendationAsCompleted(int recommendationId) async {
    final db = await _databaseHelper.database;
    
    await db.update(
      'route_recommendations',
      {'is_completed': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [recommendationId],
    );
  }

  /// Cleans up expired recommendations
  Future<int> cleanupExpiredRecommendations() async {
    final db = await _databaseHelper.database;
    final now = DateTime.now().toIso8601String();
    
    return await db.delete(
      'route_recommendations',
      where: 'expires_at < ? AND is_viewed = 0',
      whereArgs: [now],
    );
  }

  /// Deletes all recommendations for a specific athlete
  Future<int> deleteRecommendationsForAthlete(String athleteId) async {
    final db = await _databaseHelper.database;
    
    return await db.delete(
      'route_recommendations',
      where: 'athlete_id = ?',
      whereArgs: [athleteId],
    );
  }

  // ==================== Helper Methods ====================

  Map<String, dynamic> _routeInteractionToMap(UserRouteInteraction interaction) {
    return {
      'id': interaction.id,
      'route_id': interaction.routeId,
      'activity_id': interaction.activityId,
      'athlete_id': interaction.athleteId,
      'completed_at': interaction.completedAt.toIso8601String(),
      'completion_time_seconds': interaction.completionTimeSeconds,
      'average_power': interaction.averagePower,
      'average_heart_rate': interaction.averageHeartRate,
      'max_power': interaction.maxPower,
      'max_heart_rate': interaction.maxHeartRate,
      'normalized_power': interaction.normalizedPower,
      'intensity_factor': interaction.intensityFactor,
      'training_stress_score': interaction.trainingStressScore,
      'average_speed': interaction.averageSpeed,
      'max_speed': interaction.maxSpeed,
      'elevation_gain': interaction.elevationGain,
      'perceived_effort': interaction.perceivedEffort,
      'enjoyment_rating': interaction.enjoymentRating,
      'was_personal_record': interaction.wasPersonalRecord ? 1 : 0,
      'additional_metrics': interaction.additionalMetrics != null 
          ? jsonEncode(interaction.additionalMetrics) : null,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  UserRouteInteraction _mapToRouteInteraction(Map<String, dynamic> map) {
    return UserRouteInteraction(
      id: map['id'] as int?,
      routeId: map['route_id'] as int,
      activityId: map['activity_id'] as int,
      athleteId: map['athlete_id'] as String,
      completedAt: DateTime.parse(map['completed_at'] as String),
      completionTimeSeconds: map['completion_time_seconds'] as double?,
      averagePower: map['average_power'] as double?,
      averageHeartRate: map['average_heart_rate'] as double?,
      maxPower: map['max_power'] as double?,
      maxHeartRate: map['max_heart_rate'] as double?,
      normalizedPower: map['normalized_power'] as double?,
      intensityFactor: map['intensity_factor'] as double?,
      trainingStressScore: map['training_stress_score'] as double?,
      averageSpeed: map['average_speed'] as double?,
      maxSpeed: map['max_speed'] as double?,
      elevationGain: map['elevation_gain'] as double?,
      perceivedEffort: map['perceived_effort'] as String?,
      enjoymentRating: map['enjoyment_rating'] as double?,
      wasPersonalRecord: (map['was_personal_record'] as int?) == 1,
      additionalMetrics: map['additional_metrics'] != null 
          ? jsonDecode(map['additional_metrics'] as String) : null,
    );
  }

  Map<String, dynamic> _routeRecommendationToMap(RouteRecommendation recommendation) {
    return {
      'id': recommendation.id,
      'athlete_id': recommendation.athleteId,
      'route_id': recommendation.routeId,
      'confidence_score': recommendation.confidenceScore,
      'recommendation_type': recommendation.recommendationType,
      'reasoning': recommendation.reasoning,
      'scoring_factors': jsonEncode(recommendation.scoringFactors),
      'generated_at': recommendation.generatedAt.toIso8601String(),
      'is_viewed': recommendation.isViewed ? 1 : 0,
      'is_completed': recommendation.isCompleted ? 1 : 0,
      'expires_at': recommendation.generatedAt.add(const Duration(days: 30)).toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Maps a list of database records to RouteRecommendation objects with route data
  Future<List<RouteRecommendation>> _mapToRouteRecommendations(List<Map<String, dynamic>> maps) async {
    if (maps.isEmpty) return [];

    try {
      // Load all route data once - try Supabase first, then fall back to file
      Map<int, List<RouteData>> allRouteData;
      try {
        allRouteData = await loadRouteDataFromSupabase();
        debugPrint('_mapToRouteRecommendations - Loaded route data from Supabase');
      } catch (e) {
        debugPrint('_mapToRouteRecommendations - Failed to load from Supabase, trying file: $e');
        final repository = FileRepository();
        allRouteData = await repository.loadRouteData();
        debugPrint('_mapToRouteRecommendations - Loaded route data from file');
      }

      debugPrint('_mapToRouteRecommendations - Loaded route data for ${allRouteData.length} worlds');

      // Create TWO lookup maps: one by ID (for backward compatibility) and one by composite key (world+name)
      final Map<int, RouteData> routeMapById = {};
      final Map<String, RouteData> routeMapByKey = {}; // Key: "world|routeName"
      final Map<int, List<RouteData>> duplicatesByIdAll = {}; // Track ALL routes with same ID
      int duplicateCount = 0;

      // First pass: collect all routes with their IDs
      for (final entry in allRouteData.entries) {
        final worldRoutes = entry.value;
        for (final route in worldRoutes) {
          if (route.id != null) {
            if (!duplicatesByIdAll.containsKey(route.id!)) {
              duplicatesByIdAll[route.id!] = [];
            }
            duplicatesByIdAll[route.id!]!.add(route);
          }
        }
      }

      // Second pass: identify duplicates and build lookup maps
      for (final entry in allRouteData.entries) {
        final worldRoutes = entry.value;
        for (final route in worldRoutes) {
          // Add to ID map
          if (route.id != null) {
            if (routeMapById.containsKey(route.id!)) {
              duplicateCount++;
              final existing = routeMapById[route.id!]!;
              debugPrint('⚠️  DUPLICATE route ID ${route.id}: "${existing.routeName}" (${existing.world}) REPLACED BY "${route.routeName}" (${route.world})');
            }
            routeMapById[route.id!] = route;
          }

          // Add to composite key map (stable identifier)
          if (route.world != null && route.routeName != null) {
            final compositeKey = '${route.world}|${route.routeName}';
            routeMapByKey[compositeKey] = route;
          }
        }
      }

      // Log summary of duplicates
      if (duplicateCount > 0) {
        debugPrint('⚠️  Found $duplicateCount duplicate route IDs. Routes with same ID across worlds:');
        for (final entry in duplicatesByIdAll.entries) {
          if (entry.value.length > 1) {
            final worlds = entry.value.map((r) => '${r.world}:"${r.routeName}"').join(', ');
            debugPrint('   ID ${entry.key}: $worlds');
          }
        }
      }

      debugPrint('_mapToRouteRecommendations - Created route maps: ${routeMapById.length} by ID ($duplicateCount duplicates), ${routeMapByKey.length} by composite key');

      // Map each database record to a RouteRecommendation with populated routeData
      return maps.map((map) {
        final routeId = map['route_id'] as int;

        // Try to find route data by ID first
        RouteData? routeData = routeMapById[routeId];

        // If not found by ID, the route IDs might have changed due to re-scraping
        // Try to match by the route ID itself if it looks like it might be a route
        // NOTE: This is a fallback since route IDs are not stable across scraping sessions
        if (routeData == null) {
          // Check if any route has this as its actual ID (not the map key)
          for (final route in routeMapByKey.values) {
            if (route.id == routeId) {
              routeData = route;
              debugPrint('_mapToRouteRecommendations - Found route by matching ID field: $routeId -> ${route.routeName} (${route.world})');
              break;
            }
          }
        }

        if (routeData == null) {
          debugPrint('_mapToRouteRecommendations - WARNING: No route data found for route ID $routeId');
        } else {
          debugPrint('_mapToRouteRecommendations - ✓ Matched route ID $routeId -> "${routeData.routeName}" in ${routeData.world}');
        }

        return RouteRecommendation(
          id: map['id'] as int?,
          athleteId: map['athlete_id'] as String,
          routeId: routeId,
          confidenceScore: map['confidence_score'] as double,
          recommendationType: map['recommendation_type'] as String,
          reasoning: map['reasoning'] as String,
          scoringFactors: jsonDecode(map['scoring_factors'] as String) as Map<String, dynamic>,
          generatedAt: DateTime.parse(map['generated_at'] as String),
          isViewed: (map['is_viewed'] as int?) == 1,
          isCompleted: (map['is_completed'] as int?) == 1,
          routeData: routeData,
        );
      }).toList();
    } catch (e) {
      debugPrint('_mapToRouteRecommendations - ERROR loading route data: $e');
      // Return recommendations without route data
      return maps.map((map) {
        return RouteRecommendation(
          id: map['id'] as int?,
          athleteId: map['athlete_id'] as String,
          routeId: map['route_id'] as int,
          confidenceScore: map['confidence_score'] as double,
          recommendationType: map['recommendation_type'] as String,
          reasoning: map['reasoning'] as String,
          scoringFactors: jsonDecode(map['scoring_factors'] as String) as Map<String, dynamic>,
          generatedAt: DateTime.parse(map['generated_at'] as String),
          isViewed: (map['is_viewed'] as int?) == 1,
          isCompleted: (map['is_completed'] as int?) == 1,
          routeData: null,
        );
      }).toList();
    }
  }
}