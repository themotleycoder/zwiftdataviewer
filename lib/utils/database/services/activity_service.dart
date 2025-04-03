import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_strava_api/api/streams.dart';
import 'package:flutter_strava_api/models/activity.dart';
import 'package:flutter_strava_api/models/summary_activity.dart';
import 'package:sqflite/sqflite.dart';
import 'package:zwiftdataviewer/utils/database/database_helper.dart';
import 'package:zwiftdataviewer/utils/database/database_init.dart';
import 'package:zwiftdataviewer/utils/database/models/activity_model.dart';
import 'package:zwiftdataviewer/utils/repository/activitesrepository.dart';
import 'package:zwiftdataviewer/utils/repository/streamsrepository.dart';

class ActivityService implements ActivitiesRepository, StreamsRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Activities
  Future<List<SummaryActivity>> getActivities(int beforeDate, int afterDate) async {
    final db = await _databaseHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'activities',
      where: 'start_date BETWEEN ? AND ?',
      whereArgs: [
        DateTime.fromMillisecondsSinceEpoch(afterDate * 1000).toIso8601String(),
        DateTime.fromMillisecondsSinceEpoch(beforeDate * 1000).toIso8601String(),
      ],
      orderBy: 'start_date DESC',
    );

    return List.generate(maps.length, (i) {
      return ActivityModel.fromMap(maps[i]).toSummaryActivity();
    });
  }

  // Activity Details
  Future<DetailedActivity?> getActivityDetail(int activityId) async {
    final db = await _databaseHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'activity_details',
      where: 'id = ?',
      whereArgs: [activityId],
    );

    if (maps.isEmpty) {
      return null;
    }

    return ActivityDetailModel.fromMap(maps.first).toDetailedActivity();
  }

  Future<void> saveActivityDetail(DetailedActivity activity) async {
    final db = await _databaseHelper.database;
    
    final activityDetailModel = ActivityDetailModel.fromDetailedActivity(activity);
    
    await db.insert(
      'activity_details',
      activityDetailModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    // Extract and save segment efforts if available
    if (activity.segmentEfforts != null && activity.segmentEfforts!.isNotEmpty) {
      try {
        await DatabaseInit.segmentEffortService.saveSegmentEfforts(
          activity.id!,
          activity.segmentEfforts!,
        );
        
        if (kDebugMode) {
          print('Saved ${activity.segmentEfforts!.length} segment efforts for activity ${activity.id}');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error saving segment efforts for activity ${activity.id}: $e');
        }
        // Continue even if saving segment efforts fails
      }
    }
  }

  // Activity Photos
  Future<List<PhotoActivity>> getActivityPhotos(int activityId) async {
    try {
      final db = await _databaseHelper.database;
      
      final List<Map<String, dynamic>> maps = await db.query(
        'activity_photos',
        where: 'activity_id = ?',
        whereArgs: [activityId],
      );

      if (maps.isEmpty) {
        return [];
      }

      final List<PhotoActivity> photos = [];
      
      for (var i = 0; i < maps.length; i++) {
        try {
          // Validate that the map contains the expected data
          if (maps[i]['json_data'] == null || maps[i]['photo_id'] == null || maps[i]['activity_id'] == null) {
            if (kDebugMode) {
              print('Invalid photo data in database for activity $activityId: ${maps[i]}');
            }
            continue; // Skip this photo
          }
          
          final photo = ActivityPhotoModel.fromMap(maps[i]).toPhotoActivity();
          photos.add(photo);
        } catch (e) {
          if (kDebugMode) {
            print('Error converting photo data for activity $activityId: $e');
            print('Photo data: ${maps[i]}');
          }
          // Continue with other photos
          continue;
        }
      }

      return photos;
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving photos from database for activity $activityId: $e');
      }
      return []; // Return empty list on error
    }
  }

  Future<void> saveActivityPhotos(int activityId, List<PhotoActivity> photos) async {
    if (photos.isEmpty) {
      if (kDebugMode) {
        print('No photos to save for activity $activityId');
      }
      return;
    }
    
    if (kDebugMode) {
      print('Saving ${photos.length} photos for activity $activityId');
    }
    
    final db = await _databaseHelper.database;
    
    // Use a transaction for better data integrity
    await db.transaction((txn) async {
      try {
        // Delete existing photos for this activity
        await txn.delete(
          'activity_photos',
          where: 'activity_id = ?',
          whereArgs: [activityId],
        );
        
        if (kDebugMode) {
          print('Deleted existing photos for activity $activityId');
        }
        
        // Insert new photos one by one to better handle errors
        for (var i = 0; i < photos.length; i++) {
          try {
            final photo = photos[i];
            
            // Skip photos with null IDs
            if (photo.id == null) {
              if (kDebugMode) {
                print('Skipping photo with null ID at index $i');
              }
              continue;
            }
            
            // Create the photo model
            final photoModel = ActivityPhotoModel.fromPhotoActivity(activityId, photo);
            
            // Insert the photo
            await txn.insert(
              'activity_photos',
              photoModel.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            
            if (kDebugMode) {
              print('Saved photo ${photo.id} for activity $activityId');
            }
          } catch (e) {
            if (kDebugMode) {
              print('Error saving photo at index $i for activity $activityId: $e');
              print('Photo data: ${photos[i].toJson()}');
            }
            // Continue with other photos
            continue;
          }
        }
        
        // Verify photos were saved
        final count = Sqflite.firstIntValue(await txn.rawQuery(
          'SELECT COUNT(*) FROM activity_photos WHERE activity_id = ?',
          [activityId],
        )) ?? 0;
        
        if (kDebugMode) {
          print('Saved $count photos to database for activity $activityId');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Transaction error saving photos for activity $activityId: $e');
        }
        rethrow;
      }
    });
  }

  // Activity Streams
  Future<StreamsDetailCollection?> getStreams(int activityId) async {
    final db = await _databaseHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'activity_streams',
      where: 'activity_id = ?',
      whereArgs: [activityId],
    );

    if (maps.isEmpty) {
      return null;
    }

    return ActivityStreamModel.fromMap(maps.first).toStreamsDetailCollection();
  }

  Future<void> saveStreams(int activityId, StreamsDetailCollection streams) async {
    final db = await _databaseHelper.database;
    final streamModel = ActivityStreamModel.fromStreamsDetailCollection(activityId, streams);
    
    // Use a transaction for better data integrity
    await db.transaction((txn) async {
      // Delete existing streams for this activity
      await txn.delete(
        'activity_streams',
        where: 'activity_id = ?',
        whereArgs: [activityId],
      );

      // Insert new streams
      await txn.insert(
        'activity_streams',
        streamModel.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  // ActivitiesRepository implementation
  @override
  Future<List<SummaryActivity?>?> loadActivities(int beforeDate, int afterDate) async {
    return await getActivities(beforeDate, afterDate);
  }

  @override
  Future<DetailedActivity?> loadActivityDetail(int activityId) async {
    return await getActivityDetail(activityId);
  }

  @override
  Future<List<PhotoActivity>> loadActivityPhotos(int activityId) async {
    return await getActivityPhotos(activityId);
  }

  @override
  Future saveActivities(List<SummaryActivity> activities) async {
    await _saveActivitiesToDb(activities);
  }

  Future<void> _saveActivitiesToDb(List<SummaryActivity> activities) async {
    final db = await _databaseHelper.database;
    
    // Use a transaction for better data integrity
    await db.transaction((txn) async {
      final batch = txn.batch();

      for (var activity in activities) {
        try {
          final activityModel = ActivityModel.fromSummaryActivity(activity);
          batch.insert(
            'activities',
            activityModel.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        } catch (e) {
          if (kDebugMode) {
            print('Error saving activity ${activity.id}: $e');
          }
          // Continue with other activities even if one fails
          continue;
        }
      }

      await batch.commit(noResult: true);
    });
  }
  
  // Bulk operations with transaction support
  Future<void> bulkSaveActivities(List<SummaryActivity> activities) async {
    if (activities.isEmpty) return;
    
    final db = await _databaseHelper.database;
    final Completer<void> completer = Completer<void>();
    
    try {
      await db.transaction((txn) async {
        var batch = txn.batch(); // Changed from final to var
        int count = 0;
        
        for (var activity in activities) {
          try {
            final activityModel = ActivityModel.fromSummaryActivity(activity);
            batch.insert(
              'activities',
              activityModel.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            
            count++;
            // Commit in chunks of 50 to avoid transaction too large errors
            if (count % 50 == 0) {
              await batch.commit(noResult: true);
              // Create a new batch
              batch = txn.batch();
            }
          } catch (e) {
            if (kDebugMode) {
              print('Error in bulk save for activity ${activity.id}: $e');
            }
            // Continue with other activities
            continue;
          }
        }
        
        // Commit any remaining operations
        if (count % 50 != 0) {
          await batch.commit(noResult: true);
        }
      });
      
      completer.complete();
    } catch (e) {
      if (kDebugMode) {
        print('Transaction failed: $e');
      }
      completer.completeError(e);
    }
    
    return completer.future;
  }
  
  // Delete activities with transaction support
  Future<int> deleteActivities(List<int> activityIds) async {
    if (activityIds.isEmpty) return 0;
    
    final db = await _databaseHelper.database;
    int deletedCount = 0;
    
    await db.transaction((txn) async {
      for (var id in activityIds) {
        final count = await txn.delete(
          'activities',
          where: 'id = ?',
          whereArgs: [id],
        );
        deletedCount += count;
      }
    });
    
    return deletedCount;
  }

  // StreamsRepository implementation
  @override
  Future<StreamsDetailCollection> loadStreams(int activityId) async {
    final streams = await getStreams(activityId);
    return streams ?? StreamsDetailCollection();
  }
}
