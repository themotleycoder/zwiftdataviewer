import 'package:flutter/foundation.dart';
import 'package:flutter_strava_api/models/summary_activity.dart';
import 'package:zwiftdataviewer/models/extended_segment_effort.dart';
import 'package:zwiftdataviewer/utils/database/database_init.dart';
import 'package:zwiftdataviewer/utils/database/services/activity_service.dart';
import 'package:zwiftdataviewer/utils/database/services/segment_effort_service.dart';
import 'package:zwiftdataviewer/utils/supabase/supabase_database_service.dart';

/// Service for synchronizing activity data between SQLite and Supabase
class ActivitySyncService {
  final SupabaseDatabaseService _supabaseService = SupabaseDatabaseService();
  final ActivityService _sqliteActivityService = DatabaseInit.activityService;
  final SegmentEffortService _sqliteSegmentEffortService = DatabaseInit.segmentEffortService;

  /// Syncs activity details from SQLite to Supabase
  ///
  /// This method syncs activity details, photos, streams, and segment efforts
  /// for the specified activity from SQLite to Supabase.
  Future<void> syncActivityDetailsToSupabase(int activityId) async {
    try {
      // Sync activity details
      final activityDetail = await _sqliteActivityService.loadActivityDetail(activityId);
      if (activityDetail != null) {
        await _supabaseService.saveActivityDetail(activityDetail);
      }

      // Sync activity photos
      final photos = await _sqliteActivityService.loadActivityPhotos(activityId);
      if (photos.isNotEmpty) {
        await _supabaseService.saveActivityPhotos(activityId, photos);
      }

      // Sync activity streams
      final streams = await _sqliteActivityService.loadStreams(activityId);
      if (streams.streams?.isNotEmpty == true) {
        await _supabaseService.saveStreams(activityId, streams);
      }

      // Sync segment efforts
      final segmentEfforts = await _sqliteSegmentEffortService.getSegmentEffortsForActivity(activityId);
      if (segmentEfforts.isNotEmpty) {
        final efforts = segmentEfforts.map((e) => e.effort).toList();
        await _supabaseService.saveSegmentEfforts(activityId, efforts);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing details for activity $activityId to Supabase: $e');
      }
      // Continue with other activities even if one fails
    }
  }

  /// Syncs activities from SQLite to Supabase
  ///
  /// This method syncs activities and their details from SQLite to Supabase.
  Future<void> syncActivitiesToSupabase(List<SummaryActivity> activities) async {
    if (activities.isEmpty) {
      if (kDebugMode) {
        print('No activities to sync');
      }
      return;
    }

    if (kDebugMode) {
      print('Syncing ${activities.length} activities');
    }

    // Sync activities in chunks to avoid memory issues
    const chunkSize = 50;
    for (var i = 0; i < activities.length; i += chunkSize) {
      final end = (i + chunkSize < activities.length) ? i + chunkSize : activities.length;
      final chunk = activities.sublist(i, end);

      if (kDebugMode) {
        print('Syncing activities ${i + 1}-$end of ${activities.length}');
      }

      // Save activities to Supabase
      await _supabaseService.saveActivities(chunk);

      // Sync activity details, photos, streams, and segment efforts for each activity
      for (var activity in chunk) {
        await syncActivityDetailsToSupabase(activity.id);
      }
    }
  }

  /// Syncs activity details from Supabase to SQLite
  ///
  /// This method syncs activity details, photos, streams, and segment efforts
  /// for the specified activity from Supabase to SQLite.
  Future<void> syncActivityDetailsFromSupabase(int activityId) async {
    try {
      // Sync activity details
      final activityDetail = await _supabaseService.getActivityDetail(activityId);
      if (activityDetail != null) {
        await _sqliteActivityService.saveActivityDetail(activityDetail);
      }

      // Sync activity photos
      final photos = await _supabaseService.getActivityPhotos(activityId);
      if (photos.isNotEmpty) {
        await _sqliteActivityService.saveActivityPhotos(activityId, photos);
      }

      // Sync activity streams
      final streams = await _supabaseService.getStreams(activityId);
      if (streams != null && streams.streams?.isNotEmpty == true) {
        await _sqliteActivityService.saveStreams(activityId, streams);
      }

      // Sync segment efforts
      final segmentEfforts = await _supabaseService.getSegmentEffortsForActivity(activityId);
      if (segmentEfforts.isNotEmpty) {
        // Convert SegmentEffort to ExtendedSegmentEffort
        final extendedEfforts = segmentEfforts.map((effort) {
          return ExtendedSegmentEffort(
            activityId: activityId,
            effort: effort,
          );
        }).toList();
        
        // Save segment efforts to SQLite
        for (var extendedEffort in extendedEfforts) {
          await _sqliteSegmentEffortService.saveSegmentEfforts(
            activityId,
            [extendedEffort.effort],
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing details for activity $activityId: $e');
      }
      // Continue with other activities even if one fails
    }
  }

  /// Syncs activities from Supabase to SQLite
  ///
  /// This method syncs activities and their details from Supabase to SQLite.
  Future<void> syncActivitiesFromSupabase(List<SummaryActivity> activities) async {
    if (activities.isEmpty) {
      if (kDebugMode) {
        print('No activities to sync');
      }
      return;
    }

    if (kDebugMode) {
      print('Syncing ${activities.length} activities');
    }

    // Sync activities in chunks to avoid memory issues
    const chunkSize = 50;
    for (var i = 0; i < activities.length; i += chunkSize) {
      final end = (i + chunkSize < activities.length) ? i + chunkSize : activities.length;
      final chunk = activities.sublist(i, end);

      if (kDebugMode) {
        print('Syncing activities ${i + 1}-$end of ${activities.length}');
      }

      // Save activities to SQLite
      await _sqliteActivityService.saveActivities(chunk);

      // Sync activity details, photos, streams, and segment efforts for each activity
      for (var activity in chunk) {
        await syncActivityDetailsFromSupabase(activity.id);
      }
    }
  }
}
