import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:zwiftdataviewer/models/climb_analysis.dart';
import 'package:zwiftdataviewer/utils/database/database_helper.dart';
import 'package:zwiftdataviewer/utils/database/models/climb_analysis_model.dart';

/// Service for storing and retrieving climb analysis results from SQLite
///
/// This service manages the climb_analysis table which caches analysis results
/// to avoid re-analyzing activities unnecessarily.
class ClimbAnalysisService {
  static const String tableName = 'climb_analysis';
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  /// Creates the climb_analysis table
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        activity_id INTEGER NOT NULL UNIQUE,
        total_climbs INTEGER NOT NULL,
        total_elevation_gain REAL NOT NULL,
        analyzed_at TEXT NOT NULL,
        json_data TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create index on activity_id for faster lookups
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_climb_analysis_activity_id
      ON $tableName (activity_id)
    ''');

    debugPrint('Climb analysis table created successfully');
  }

  /// Saves or updates a climb analysis result
  Future<void> saveClimbAnalysis(ActivityClimbAnalysis analysis) async {
    try {
      final db = await _databaseHelper.database;
      final model = ClimbAnalysisModel.fromActivityClimbAnalysis(analysis);

      // Validate before saving
      model.validate();

      // Use INSERT OR REPLACE to handle upserts
      await db.insert(
        tableName,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      debugPrint('Saved climb analysis for activity ${analysis.activityId}');
    } catch (e) {
      debugPrint('Error saving climb analysis: $e');
      rethrow;
    }
  }

  /// Retrieves a climb analysis result by activity ID
  Future<ActivityClimbAnalysis?> getClimbAnalysisByActivityId(
    int activityId,
  ) async {
    try {
      final db = await _databaseHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'activity_id = ?',
        whereArgs: [activityId],
        limit: 1,
      );

      if (maps.isEmpty) {
        debugPrint('No climb analysis found for activity $activityId');
        return null;
      }

      final model = ClimbAnalysisModel.fromMap(maps.first);
      return model.toActivityClimbAnalysis();
    } catch (e) {
      debugPrint('Error retrieving climb analysis: $e');
      return null;
    }
  }

  /// Checks if a climb analysis exists for an activity
  Future<bool> hasClimbAnalysis(int activityId) async {
    try {
      final db = await _databaseHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        columns: ['id'],
        where: 'activity_id = ?',
        whereArgs: [activityId],
        limit: 1,
      );

      return maps.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking climb analysis existence: $e');
      return false;
    }
  }

  /// Deletes a climb analysis result by activity ID
  Future<void> deleteClimbAnalysis(int activityId) async {
    try {
      final db = await _databaseHelper.database;

      await db.delete(
        tableName,
        where: 'activity_id = ?',
        whereArgs: [activityId],
      );

      debugPrint('Deleted climb analysis for activity $activityId');
    } catch (e) {
      debugPrint('Error deleting climb analysis: $e');
      rethrow;
    }
  }

  /// Retrieves all climb analyses (for debugging/testing)
  Future<List<ActivityClimbAnalysis>> getAllClimbAnalyses() async {
    try {
      final db = await _databaseHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        orderBy: 'analyzed_at DESC',
      );

      return maps
          .map((map) => ClimbAnalysisModel.fromMap(map).toActivityClimbAnalysis())
          .toList();
    } catch (e) {
      debugPrint('Error retrieving all climb analyses: $e');
      return [];
    }
  }

  /// Gets the count of stored analyses
  Future<int> getAnalysisCount() async {
    try {
      final db = await _databaseHelper.database;

      final result = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      debugPrint('Error getting analysis count: $e');
      return 0;
    }
  }

  /// Clears all climb analyses (for debugging/testing)
  Future<void> clearAllAnalyses() async {
    try {
      final db = await _databaseHelper.database;

      await db.delete(tableName);

      debugPrint('Cleared all climb analyses');
    } catch (e) {
      debugPrint('Error clearing climb analyses: $e');
      rethrow;
    }
  }

  /// Gets climb analyses for multiple activity IDs
  Future<Map<int, ActivityClimbAnalysis>> getClimbAnalysesByActivityIds(
    List<int> activityIds,
  ) async {
    try {
      if (activityIds.isEmpty) return {};

      final db = await _databaseHelper.database;

      // Build IN clause
      final placeholders = List.filled(activityIds.length, '?').join(',');

      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'activity_id IN ($placeholders)',
        whereArgs: activityIds,
      );

      final result = <int, ActivityClimbAnalysis>{};
      for (final map in maps) {
        final model = ClimbAnalysisModel.fromMap(map);
        final analysis = model.toActivityClimbAnalysis();
        result[analysis.activityId] = analysis;
      }

      return result;
    } catch (e) {
      debugPrint('Error retrieving climb analyses by IDs: $e');
      return {};
    }
  }

  /// Gets summary statistics across all analyses
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final db = await _databaseHelper.database;

      final result = await db.rawQuery('''
        SELECT
          COUNT(*) as total_activities,
          SUM(total_climbs) as total_climbs,
          SUM(total_elevation_gain) as total_elevation_gain,
          AVG(total_climbs) as avg_climbs_per_activity,
          AVG(total_elevation_gain) as avg_elevation_per_activity
        FROM $tableName
      ''');

      if (result.isEmpty) {
        return {
          'total_activities': 0,
          'total_climbs': 0,
          'total_elevation_gain': 0.0,
          'avg_climbs_per_activity': 0.0,
          'avg_elevation_per_activity': 0.0,
        };
      }

      return result.first;
    } catch (e) {
      debugPrint('Error getting statistics: $e');
      return {};
    }
  }
}
