import 'package:flutter/foundation.dart';
import 'package:flutter_strava_api/models/summary_activity.dart';
import 'package:zwiftdataviewer/models/user_route_interaction.dart';
import 'package:zwiftdataviewer/utils/database/services/activity_service.dart';
import 'package:zwiftdataviewer/utils/database/services/route_recommendation_service.dart';
import 'package:zwiftdataviewer/utils/supabase/supabase_auth_service.dart';

/// Service to migrate existing activity data into route interactions
/// 
/// This service analyzes existing Strava activities and creates UserRouteInteraction
/// records based on activity names, distances, and performance metrics.
class RouteInteractionMigrationService {
  final ActivityService _activityService;
  final RouteRecommendationService _routeService;
  final SupabaseAuthService _authService;

  RouteInteractionMigrationService()
      : _activityService = ActivityService(),
        _routeService = RouteRecommendationService(),
        _authService = SupabaseAuthService();

  /// Migrates existing activity data to create route interactions
  Future<int> migrateActivitiesToRouteInteractions() async {
    try {
      final athleteId = _authService.currentAthleteId?.toString();
      if (athleteId == null) {
        if (kDebugMode) {
          debugPrint('No athlete ID found for migration');
        }
        return 0;
      }

      if (kDebugMode) {
        debugPrint('Starting route interaction migration for athlete $athleteId');
      }

      // Get recent activities from the database (last 3 months)
      final now = DateTime.now();
      final threeMonthsAgo = now.subtract(const Duration(days: 90));
      final activities = await _activityService.getActivities(
        (now.millisecondsSinceEpoch / 1000).round(),
        (threeMonthsAgo.millisecondsSinceEpoch / 1000).round(),
      );
      if (activities.isEmpty) {
        if (kDebugMode) {
          debugPrint('No activities found for migration');
        }
        return 0;
      }

      if (kDebugMode) {
        debugPrint('Found ${activities.length} activities to analyze');
      }

      int migratedCount = 0;
      final seenActivityIds = <int>{};

      // Process activities in batches to avoid memory issues
      const batchSize = 50;
      for (int i = 0; i < activities.length; i += batchSize) {
        final batch = activities.skip(i).take(batchSize);
        
        for (final activity in batch) {
          // Skip if we've already processed this activity
          if (seenActivityIds.contains(activity.id)) {
            continue;
          }
          seenActivityIds.add(activity.id);

          final interaction = await _createRouteInteractionFromActivity(
            activity, 
            athleteId
          );
          
          if (interaction != null) {
            try {
              await _routeService.insertOrUpdateRouteInteraction(interaction);
              migratedCount++;

              if (kDebugMode && migratedCount % 10 == 0) {
                debugPrint('Migrated $migratedCount route interactions...');
              }
            } catch (e) {
              if (kDebugMode) {
                debugPrint('Error inserting route interaction for activity ${activity.id}: $e');
              }
            }
          }
        }
      }

      if (kDebugMode) {
        debugPrint('Migration completed: $migratedCount route interactions created');
      }

      return migratedCount;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error during route interaction migration: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return 0;
    }
  }

  /// Creates a UserRouteInteraction from a SummaryActivity
  Future<UserRouteInteraction?> _createRouteInteractionFromActivity(
    SummaryActivity activity,
    String athleteId,
  ) async {
    try {
      // Only process Zwift activities (virtual rides)
      // trainer is either 0 (false) or 1 (true) as an integer
      if ((activity.trainer as int?) != 1) {
        return null;
      }

      // Extract route information from activity name if possible
      final routeId = _extractRouteIdFromActivityName(activity.name);

      // Parse completion date, handling nullable fields
      final dateString = (activity.startDate as String?) ??
                         (activity.startDateLocal as String?) ??
                         DateTime.now().toIso8601String();
      final completedAt = DateTime.parse(dateString);

      if (routeId == null) {
        // For now, we'll use a hash of the activity name as a pseudo-route ID
        // This allows grouping similar activities together
        final nameHash = (activity.name as String?)?.hashCode.abs() ?? 0;
        // Use modulo to keep route IDs in a reasonable range (1-1000)
        final pseudoRouteId = (nameHash % 1000) + 1;

        return UserRouteInteraction(
          routeId: pseudoRouteId,
          activityId: activity.id,
          athleteId: athleteId,
          completedAt: completedAt,
          completionTimeSeconds: (activity.movingTime as num?)?.toDouble() ?? (activity.elapsedTime as num?)?.toDouble(),
          averagePower: (activity.averageWatts as num?)?.toDouble(),
          averageHeartRate: (activity.averageHeartrate as num?)?.toDouble(),
          maxPower: (activity.maxWatts as num?)?.toDouble(),
          maxHeartRate: (activity.maxHeartrate as num?)?.toDouble(),
          averageSpeed: activity.averageSpeed as double?,
          maxSpeed: activity.maxSpeed as double?,
          elevationGain: activity.totalElevationGain as double?,
          perceivedEffort: _mapIntensityToEffort((activity.averageWatts as num?)?.toDouble()),
          wasPersonalRecord: false, // We don't have this info from existing data
        );
      } else {
        return UserRouteInteraction(
          routeId: routeId,
          activityId: activity.id,
          athleteId: athleteId,
          completedAt: completedAt,
          completionTimeSeconds: (activity.movingTime as num?)?.toDouble() ?? (activity.elapsedTime as num?)?.toDouble(),
          averagePower: (activity.averageWatts as num?)?.toDouble(),
          averageHeartRate: (activity.averageHeartrate as num?)?.toDouble(),
          maxPower: (activity.maxWatts as num?)?.toDouble(),
          maxHeartRate: (activity.maxHeartrate as num?)?.toDouble(),
          averageSpeed: activity.averageSpeed as double?,
          maxSpeed: activity.maxSpeed as double?,
          elevationGain: activity.totalElevationGain as double?,
          perceivedEffort: _mapIntensityToEffort((activity.averageWatts as num?)?.toDouble()),
          wasPersonalRecord: false,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error creating route interaction for activity ${activity.id}: $e');
      }
      return null;
    }
  }

  /// Attempts to extract a route ID from the activity name
  /// This is a heuristic approach - you may need to customize based on your naming patterns
  int? _extractRouteIdFromActivityName(String? activityName) {
    if (activityName == null) return null;

    // Look for common Zwift route naming patterns
    // Examples: "Watopia Figure 8", "London Loop", "New York KQOM", etc.
    
    // Simple mapping of common route names to IDs
    final routeNameMappings = {
      // Watopia routes
      'hilly route': 1,
      'flat route': 2,
      'figure 8': 3,
      'volcano circuit': 4,
      'mountain route': 5,
      'jungle circuit': 6,
      'big foot hills': 7,
      'ocean lava cliffside loop': 8,
      
      // London routes  
      'london loop': 101,
      'surrey hills': 102,
      'box hill': 103,
      'london 8': 104,
      
      // New York routes
      'nyc': 201,
      'kqom': 202,
      'central park': 203,
      
      // Richmond routes
      'richmond': 301,
      'uci': 302,
      
      // Innsbruck routes
      'innsbruck': 401,
      'kom': 402,
    };

    final lowerName = activityName.toLowerCase();
    
    for (final entry in routeNameMappings.entries) {
      if (lowerName.contains(entry.key)) {
        return entry.value;
      }
    }
    
    return null;
  }

  /// Maps power intensity to perceived effort
  String? _mapIntensityToEffort(double? averagePower) {
    if (averagePower == null) return null;
    
    // These are rough estimates - adjust based on your user base
    if (averagePower < 150) return 'easy';
    if (averagePower < 200) return 'moderate';  
    if (averagePower < 250) return 'hard';
    return 'very_hard';
  }

  /// Checks if migration has already been performed
  Future<bool> hasMigrationBeenPerformed() async {
    try {
      final athleteId = _authService.currentAthleteId?.toString();
      if (athleteId == null) return false;
      
      final interactions = await _routeService.getRouteInteractions(athleteId);
      return interactions.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}