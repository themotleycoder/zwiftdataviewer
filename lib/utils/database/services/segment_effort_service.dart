import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_strava_api/models/segmentEffort.dart';
import 'package:sqflite/sqflite.dart';
import 'package:zwiftdataviewer/models/extended_segment_effort.dart';
import 'package:zwiftdataviewer/utils/database/database_helper.dart';
import 'package:zwiftdataviewer/utils/database/models/segment_effort_model.dart';

class SegmentEffortService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Get all segment efforts for an activity
  Future<List<ExtendedSegmentEffort>> getSegmentEffortsForActivity(int activityId) async {
    final db = await _databaseHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'segment_efforts',
      where: 'activity_id = ?',
      whereArgs: [activityId],
      orderBy: 'start_date ASC',
    );

    return List.generate(maps.length, (i) {
      final model = SegmentEffortModel.fromMap(maps[i]);
      final segmentEffort = model.toSegmentEffort();
      return ExtendedSegmentEffort(
        activityId: model.activityId,
        effort: segmentEffort,
      );
    });
  }

  // Get all efforts for a specific segment
  Future<List<ExtendedSegmentEffort>> getEffortsForSegment(int segmentId) async {
    final db = await _databaseHelper.database;
    
    if (kDebugMode) {
      print('Fetching segment efforts for segment ID: $segmentId');
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      'segment_efforts',
      where: 'segment_id = ?',
      whereArgs: [segmentId],
      orderBy: 'elapsed_time ASC', // Sort by fastest time first
    );
    
    if (kDebugMode) {
      print('Found ${maps.length} segment efforts for segment ID: $segmentId');
      
      // If no efforts found, check if the segment exists in the database
      if (maps.isEmpty) {
        final segmentCheck = await db.rawQuery(
          'SELECT COUNT(*) as count FROM segment_efforts WHERE segment_id = ?',
          [segmentId]
        );
        final count = Sqflite.firstIntValue(segmentCheck) ?? 0;
        print('Database query confirms ${count} segment efforts for segment ID: $segmentId');
        
        // Check total segment efforts in the database
        final totalCheck = await db.rawQuery('SELECT COUNT(*) as count FROM segment_efforts');
        final totalCount = Sqflite.firstIntValue(totalCheck) ?? 0;
        print('Total segment efforts in database: $totalCount');
        
        // Check if the segment_efforts table exists and has the expected schema
        final tableInfo = await db.rawQuery('PRAGMA table_info(segment_efforts)');
        print('segment_efforts table schema: ${tableInfo.length} columns');
      }
    }

    return List.generate(maps.length, (i) {
      final model = SegmentEffortModel.fromMap(maps[i]);
      final segmentEffort = model.toSegmentEffort();
      return ExtendedSegmentEffort(
        activityId: model.activityId,
        effort: segmentEffort,
      );
    });
  }

  // Get all efforts for a segment by name (useful for segments that might have different IDs)
  Future<List<ExtendedSegmentEffort>> getEffortsForSegmentByName(String segmentName) async {
    final db = await _databaseHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'segment_efforts',
      where: 'segment_name = ?',
      whereArgs: [segmentName],
      orderBy: 'elapsed_time ASC', // Sort by fastest time first
    );

    return List.generate(maps.length, (i) {
      final model = SegmentEffortModel.fromMap(maps[i]);
      final segmentEffort = model.toSegmentEffort();
      return ExtendedSegmentEffort(
        activityId: model.activityId,
        effort: segmentEffort,
      );
    });
  }

  // Get all unique segments
  Future<List<Map<String, dynamic>>> getUniqueSegments() async {
    final db = await _databaseHelper.database;
    
    // Query to get unique segments with their best times
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        segment_id, 
        segment_name, 
        MIN(elapsed_time) as best_time,
        COUNT(*) as effort_count,
        MAX(pr_rank) as best_pr_rank,
        AVG(average_grade) as average_grade,
        MAX(climb_category) as climb_category
      FROM segment_efforts
      GROUP BY segment_id
      ORDER BY segment_name ASC
    ''');

    return maps;
  }

  // Save segment efforts for an activity
  Future<void> saveSegmentEfforts(int activityId, List<SegmentEffort> efforts) async {
    if (efforts.isEmpty) {
      if (kDebugMode) {
        print('No segment efforts to save for activity $activityId');
      }
      return;
    }
    
    if (kDebugMode) {
      print('Saving ${efforts.length} segment efforts for activity $activityId');
      
      // Log some details about the first few efforts
      final maxToLog = efforts.length > 3 ? 3 : efforts.length;
      for (var i = 0; i < maxToLog; i++) {
        final effort = efforts[i];
        print('Effort $i: ID=${effort.id}, SegmentID=${effort.segment?.id}, Name=${effort.segment?.name}');
      }
    }
    
    final db = await _databaseHelper.database;
    
    // Check if the segment_efforts table exists
    if (kDebugMode) {
      final tableCheck = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='segment_efforts'"
      );
      print('segment_efforts table exists: ${tableCheck.isNotEmpty}');
      
      if (tableCheck.isNotEmpty) {
        // Check table schema
        final tableInfo = await db.rawQuery('PRAGMA table_info(segment_efforts)');
        print('segment_efforts table has ${tableInfo.length} columns');
      }
    }
    
    // Use a transaction for better data integrity
    await db.transaction((txn) async {
      try {
        // Delete existing segment efforts for this activity
        final deletedCount = await txn.delete(
          'segment_efforts',
          where: 'activity_id = ?',
          whereArgs: [activityId],
        );
        
        if (kDebugMode) {
          print('Deleted $deletedCount existing segment efforts for activity $activityId');
        }
        
        int successCount = 0;
        int errorCount = 0;
        
        // Insert new segment efforts one by one to better handle errors
        for (var i = 0; i < efforts.length; i++) {
          try {
            final effort = efforts[i];
            
            // Skip efforts with null segments
            if (effort.segment == null) {
              if (kDebugMode) {
                print('Skipping segment effort with null segment at index $i');
              }
              continue;
            }
            
            // Skip efforts with null segment IDs
            if (effort.segment!.id == null) {
              if (kDebugMode) {
                print('Skipping segment effort with null segment ID at index $i');
              }
              continue;
            }
            
            // Create the segment effort model
            final effortModel = SegmentEffortModel.fromSegmentEffort(activityId, effort);
            
            // Insert the segment effort
            final id = await txn.insert(
              'segment_efforts',
              effortModel.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            
            if (id > 0) {
              successCount++;
            }
            
            if (kDebugMode && i < 3) {  // Log details for first few efforts
              print('Saved segment effort ${effort.id} (segment ${effort.segment!.id}) for activity $activityId with DB ID $id');
            }
          } catch (e) {
            errorCount++;
            if (kDebugMode) {
              print('Error saving segment effort at index $i for activity $activityId: $e');
              try {
                print('Segment effort data: ${efforts[i].toJson()}');
              } catch (jsonError) {
                print('Could not convert segment effort to JSON: $jsonError');
              }
            }
            // Continue with other segment efforts
            continue;
          }
        }
        
        // Verify segment efforts were saved
        final count = Sqflite.firstIntValue(await txn.rawQuery(
          'SELECT COUNT(*) FROM segment_efforts WHERE activity_id = ?',
          [activityId],
        )) ?? 0;
        
        if (kDebugMode) {
          print('Saved $count segment efforts to database for activity $activityId');
          print('Success: $successCount, Errors: $errorCount');
          
          // Check total segment efforts in the database
          final totalCount = Sqflite.firstIntValue(await txn.rawQuery(
            'SELECT COUNT(*) FROM segment_efforts'
          )) ?? 0;
          print('Total segment efforts in database: $totalCount');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Transaction error saving segment efforts for activity $activityId: $e');
        }
        rethrow;
      }
    });
  }

  // Delete segment efforts for an activity
  Future<int> deleteSegmentEffortsForActivity(int activityId) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'segment_efforts',
      where: 'activity_id = ?',
      whereArgs: [activityId],
    );
  }

  // Get the best effort for a segment
  Future<ExtendedSegmentEffort?> getBestEffortForSegment(int segmentId) async {
    final db = await _databaseHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'segment_efforts',
      where: 'segment_id = ?',
      whereArgs: [segmentId],
      orderBy: 'elapsed_time ASC',
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    final model = SegmentEffortModel.fromMap(maps.first);
    final segmentEffort = model.toSegmentEffort();
    return ExtendedSegmentEffort(
      activityId: model.activityId,
      effort: segmentEffort,
    );
  }

  // Get segment efforts with pagination
  Future<List<ExtendedSegmentEffort>> getSegmentEffortsWithPagination(
    int segmentId, {
    int limit = 10,
    int offset = 0,
    String orderBy = 'elapsed_time ASC',
  }) async {
    final db = await _databaseHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'segment_efforts',
      where: 'segment_id = ?',
      whereArgs: [segmentId],
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );

    return List.generate(maps.length, (i) {
      final model = SegmentEffortModel.fromMap(maps[i]);
      final segmentEffort = model.toSegmentEffort();
      return ExtendedSegmentEffort(
        activityId: model.activityId,
        effort: segmentEffort,
      );
    });
  }

  // Get segment efforts count
  Future<int> getSegmentEffortsCount(int segmentId) async {
    final db = await _databaseHelper.database;
    
    final count = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM segment_efforts WHERE segment_id = ?',
      [segmentId],
    )) ?? 0;
    
    return count;
  }

  // Get segment efforts by date range
  Future<List<ExtendedSegmentEffort>> getSegmentEffortsByDateRange(
    int segmentId,
    String startDate,
    String endDate,
  ) async {
    final db = await _databaseHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'segment_efforts',
      where: 'segment_id = ? AND start_date BETWEEN ? AND ?',
      whereArgs: [segmentId, startDate, endDate],
      orderBy: 'start_date ASC',
    );

    return List.generate(maps.length, (i) {
      final model = SegmentEffortModel.fromMap(maps[i]);
      final segmentEffort = model.toSegmentEffort();
      return ExtendedSegmentEffort(
        activityId: model.activityId,
        effort: segmentEffort,
      );
    });
  }

  // Get segment efforts statistics
  Future<Map<String, dynamic>> getSegmentEffortsStatistics(int segmentId) async {
    final db = await _databaseHelper.database;
    
    final List<Map<String, dynamic>> stats = await db.rawQuery('''
      SELECT 
        COUNT(*) as count,
        MIN(elapsed_time) as best_time,
        AVG(elapsed_time) as average_time,
        MAX(elapsed_time) as worst_time,
        MIN(start_date) as first_attempt,
        MAX(start_date) as last_attempt,
        AVG(average_watts) as average_power,
        MAX(average_watts) as max_average_power,
        AVG(average_heartrate) as average_heartrate,
        MAX(average_heartrate) as max_average_heartrate
      FROM segment_efforts
      WHERE segment_id = ?
    ''', [segmentId]);

    if (stats.isEmpty) {
      return {};
    }

    return stats.first;
  }
}
