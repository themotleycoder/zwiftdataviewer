import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_strava_api/api/streams.dart';
import 'package:flutter_strava_api/models/activity.dart';
import 'package:flutter_strava_api/models/segmentEffort.dart';
import 'package:flutter_strava_api/models/summary_activity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zwiftdataviewer/utils/database/models/activity_model.dart';
import 'package:zwiftdataviewer/utils/supabase/supabase_auth_service.dart';
import 'package:zwiftdataviewer/utils/supabase/supabase_config.dart';

/// Service for interacting with Supabase database
///
/// This service provides methods for storing and retrieving data from Supabase.
/// It mirrors the functionality of the SQLite database service.
class SupabaseDatabaseService {
  static final SupabaseDatabaseService _instance = SupabaseDatabaseService._internal();
  final SupabaseAuthService _authService = SupabaseAuthService();
  
  // Authentication state cache
  bool? _isAuthenticatedCache;
  DateTime? _lastAuthCheck;
  int? _cachedAthleteId;
  
  // Cache expiration duration (check auth every 5 minutes)
  static const Duration _authCacheExpiration = Duration(minutes: 5);

  // Singleton pattern
  factory SupabaseDatabaseService() => _instance;

  SupabaseDatabaseService._internal();

  /// Gets the Supabase client
  SupabaseClient get _client => SupabaseConfig.client;
  
  /// Checks if the user is authenticated with Supabase
  /// 
  /// This method uses a cache to reduce the number of authentication checks.
  /// It only checks authentication if the cache is empty or expired.
  Future<bool> _checkAuthentication() async {
    final now = DateTime.now();
    
    // Use cached value if available and not expired
    if (_isAuthenticatedCache != null && 
        _lastAuthCheck != null &&
        now.difference(_lastAuthCheck!) < _authCacheExpiration) {
      return _isAuthenticatedCache!;
    }
    
    // Check authentication and update cache
    try {
      final isAuthenticated = await _authService.isAuthenticated();
      _isAuthenticatedCache = isAuthenticated;
      _lastAuthCheck = now;
      
      // Cache athlete ID if authenticated
      if (isAuthenticated) {
        _cachedAthleteId = _authService.currentAthleteId;
      }
      
      return isAuthenticated;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking authentication: $e');
      }
      // Clear cache on error
      _isAuthenticatedCache = false;
      _lastAuthCheck = now;
      _cachedAthleteId = null;
      return false;
    }
  }
  
  /// Gets the current athlete ID
  /// 
  /// This method uses a cache to reduce the number of calls to the auth service.
  Future<int?> _getAthleteId() async {
    // Ensure we're authenticated first
    final isAuthenticated = await _checkAuthentication();
    if (!isAuthenticated) {
      return null;
    }
    
    // Use cached value if available
    if (_cachedAthleteId != null) {
      return _cachedAthleteId;
    }
    
    // Get from auth service and cache
    _cachedAthleteId = _authService.currentAthleteId;
    return _cachedAthleteId;
  }

  /// Gets activities from Supabase
  ///
  /// This method fetches activities from Supabase that occurred between the
  /// specified dates. It returns a list of SummaryActivity objects.
  Future<List<SummaryActivity>> getActivities(int beforeDate, int afterDate) async {
    try {
      // Ensure we're authenticated using cached check
      final isAuthenticated = await _checkAuthentication();
      if (!isAuthenticated) {
        throw Exception('Not authenticated with Supabase');
      }

      // Convert timestamps to ISO8601 strings
      final beforeDateStr = DateTime.fromMillisecondsSinceEpoch(beforeDate * 1000).toIso8601String();
      final afterDateStr = DateTime.fromMillisecondsSinceEpoch(afterDate * 1000).toIso8601String();

      // Get the current athlete ID using cached value
      final athleteId = await _getAthleteId();
      if (athleteId == null) {
        throw Exception('No athlete ID available');
      }

      // Query Supabase for activities
      final response = await _client
          .from('zw_activities')
          .select()
          .eq('athlete_id', athleteId)
          .gte('start_date', afterDateStr)
          .lte('start_date', beforeDateStr)
          .order('start_date', ascending: false);

      if (response == null) {
        return [];
      }

      // Convert response to SummaryActivity objects
      return List.generate(response.length, (i) {
        try {
          final Map<String, dynamic> activityMap = response[i];
          return ActivityModel.fromMap(activityMap).toSummaryActivity();
        } catch (e) {
          if (kDebugMode) {
            print('Error converting activity at index $i: $e');
          }
          // Skip this activity
          return null;
        }
      }).whereType<SummaryActivity>().toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting activities from Supabase: $e');
      }
      rethrow;
    }
  }

  /// Gets activity details from Supabase
  ///
  /// This method fetches activity details from Supabase for the specified
  /// activity ID. It returns a DetailedActivity object.
  Future<DetailedActivity?> getActivityDetail(int activityId) async {
    try {
      // Ensure we're authenticated using cached check
      final isAuthenticated = await _checkAuthentication();
      if (!isAuthenticated) {
        throw Exception('Not authenticated with Supabase');
      }

      // Get the current athlete ID using cached value
      final athleteId = await _getAthleteId();
      if (athleteId == null) {
        throw Exception('No athlete ID available');
      }

      // Query Supabase for activity details
      final response = await _client
          .from('zw_activity_details')
          .select()
          .eq('id', activityId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      // Convert response to DetailedActivity object
      return ActivityDetailModel.fromMap(response).toDetailedActivity();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting activity detail from Supabase: $e');
      }
      return null;
    }
  }

  /// Saves activity details to Supabase
  ///
  /// This method saves activity details to Supabase for the specified
  /// activity. It also extracts and saves segment efforts if available.
  Future<void> saveActivityDetail(DetailedActivity activity) async {
    try {
      // Ensure we're authenticated using cached check
      final isAuthenticated = await _checkAuthentication();
      if (!isAuthenticated) {
        throw Exception('Not authenticated with Supabase');
      }

      // Get the current athlete ID using cached value
      final athleteId = await _getAthleteId();
      if (athleteId == null) {
        throw Exception('No athlete ID available');
      }

      // Convert activity to ActivityDetailModel
      final activityDetailModel = ActivityDetailModel.fromDetailedActivity(activity);

      // Save activity details to Supabase
      await _client
          .from('zw_activity_details')
          .upsert(activityDetailModel.toMap());

      // Extract and save segment efforts if available
      if (activity.segmentEfforts != null && activity.segmentEfforts!.isNotEmpty) {
        try {
          await saveSegmentEfforts(activity.id!, activity.segmentEfforts!);
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
    } catch (e) {
      if (kDebugMode) {
        print('Error saving activity detail to Supabase: $e');
      }
      rethrow;
    }
  }

  /// Gets activity photos from Supabase
  ///
  /// This method fetches activity photos from Supabase for the specified
  /// activity ID. It returns a list of PhotoActivity objects.
  Future<List<PhotoActivity>> getActivityPhotos(int activityId) async {
    try {
      // Ensure we're authenticated using cached check
      final isAuthenticated = await _checkAuthentication();
      if (!isAuthenticated) {
        throw Exception('Not authenticated with Supabase');
      }

      // Get the current athlete ID using cached value
      final athleteId = await _getAthleteId();
      if (athleteId == null) {
        throw Exception('No athlete ID available');
      }

      // Query Supabase for activity photos
      final response = await _client
          .from('zw_activity_photos')
          .select()
          .eq('activity_id', activityId);

      if (response == null || response.isEmpty) {
        return [];
      }

      // Convert response to PhotoActivity objects
      final List<PhotoActivity> photos = [];
      for (var i = 0; i < response.length; i++) {
        try {
          // Validate that the map contains the expected data
          if (response[i]['json_data'] == null || 
              response[i]['photo_id'] == null || 
              response[i]['activity_id'] == null) {
            if (kDebugMode) {
              print('Invalid photo data in Supabase for activity $activityId: ${response[i]}');
            }
            continue; // Skip this photo
          }

          final photo = ActivityPhotoModel.fromMap(response[i]).toPhotoActivity();
          photos.add(photo);
        } catch (e) {
          if (kDebugMode) {
            print('Error converting photo data for activity $activityId: $e');
            print('Photo data: ${response[i]}');
          }
          // Continue with other photos
          continue;
        }
      }

      return photos;
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving photos from Supabase for activity $activityId: $e');
      }
      return []; // Return empty list on error
    }
  }

  /// Saves activity photos to Supabase
  ///
  /// This method saves activity photos to Supabase for the specified
  /// activity. It deletes existing photos for the activity first.
  Future<void> saveActivityPhotos(int activityId, List<PhotoActivity> photos) async {
    if (photos.isEmpty) {
      if (kDebugMode) {
        print('No photos to save for activity $activityId');
      }
      return;
    }

    try {
      // Ensure we're authenticated using cached check
      final isAuthenticated = await _checkAuthentication();
      if (!isAuthenticated) {
        throw Exception('Not authenticated with Supabase');
      }

      // Get the current athlete ID using cached value
      final athleteId = await _getAthleteId();
      if (athleteId == null) {
        throw Exception('No athlete ID available');
      }

      if (kDebugMode) {
        print('Saving ${photos.length} photos for activity $activityId');
      }

      // Delete existing photos for this activity
      await _client
          .from('zw_activity_photos')
          .delete()
          .eq('activity_id', activityId);

      if (kDebugMode) {
        print('Deleted existing photos for activity $activityId');
      }

      // Insert new photos
      int successCount = 0;
      int errorCount = 0;

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
          await _client
              .from('zw_activity_photos')
              .upsert(photoModel.toMap());

          successCount++;

          if (kDebugMode) {
            print('Saved photo ${photo.id} for activity $activityId');
          }
        } catch (e) {
          errorCount++;
          if (kDebugMode) {
            print('Error saving photo at index $i for activity $activityId: $e');
            print('Photo data: ${photos[i].toJson()}');
          }
          // Continue with other photos
          continue;
        }
      }

      if (kDebugMode) {
        print('Saved $successCount photos to Supabase for activity $activityId');
        print('Success: $successCount, Errors: $errorCount');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving photos to Supabase for activity $activityId: $e');
      }
      rethrow;
    }
  }

  /// Gets activity streams from Supabase
  ///
  /// This method fetches activity streams from Supabase for the specified
  /// activity ID. It returns a StreamsDetailCollection object.
  Future<StreamsDetailCollection?> getStreams(int activityId) async {
    try {
      // Ensure we're authenticated using cached check
      final isAuthenticated = await _checkAuthentication();
      if (!isAuthenticated) {
        throw Exception('Not authenticated with Supabase');
      }

      // Get the current athlete ID using cached value
      final athleteId = await _getAthleteId();
      if (athleteId == null) {
        throw Exception('No athlete ID available');
      }

      // Query Supabase for activity streams
      final response = await _client
          .from('zw_activity_streams')
          .select()
          .eq('activity_id', activityId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      // Convert response to StreamsDetailCollection object
      return ActivityStreamModel.fromMap(response).toStreamsDetailCollection();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting streams from Supabase: $e');
      }
      return null;
    }
  }

  /// Saves activity streams to Supabase
  ///
  /// This method saves activity streams to Supabase for the specified
  /// activity. It deletes existing streams for the activity first.
  Future<void> saveStreams(int activityId, StreamsDetailCollection streams) async {
    try {
      // Ensure we're authenticated using cached check
      final isAuthenticated = await _checkAuthentication();
      if (!isAuthenticated) {
        throw Exception('Not authenticated with Supabase');
      }

      // Get the current athlete ID using cached value
      final athleteId = await _getAthleteId();
      if (athleteId == null) {
        throw Exception('No athlete ID available');
      }

      // Convert streams to ActivityStreamModel
      final streamModel = ActivityStreamModel.fromStreamsDetailCollection(activityId, streams);

      // Delete existing streams for this activity
      await _client
          .from('zw_activity_streams')
          .delete()
          .eq('activity_id', activityId);

      // Insert new streams
      await _client
          .from('zw_activity_streams')
          .upsert(streamModel.toMap());
    } catch (e) {
      if (kDebugMode) {
        print('Error saving streams to Supabase: $e');
      }
      rethrow;
    }
  }

  /// Saves activities to Supabase
  ///
  /// This method saves activities to Supabase. It upserts each activity.
  Future<void> saveActivities(List<SummaryActivity> activities) async {
    if (activities.isEmpty) return;

    try {
      // Ensure we're authenticated using cached check
      final isAuthenticated = await _checkAuthentication();
      if (!isAuthenticated) {
        throw Exception('Not authenticated with Supabase');
      }

      // Get the current athlete ID using cached value
      final athleteId = await _getAthleteId();
      if (athleteId == null) {
        throw Exception('No athlete ID available');
      }

      // Convert activities to ActivityModel objects
      final List<Map<String, dynamic>> activityMaps = [];
      for (var activity in activities) {
        try {
          final activityModel = ActivityModel.fromSummaryActivity(activity);
          activityMaps.add(activityModel.toMap());
        } catch (e) {
          if (kDebugMode) {
            print('Error converting activity ${activity.id}: $e');
          }
          // Continue with other activities even if one fails
          continue;
        }
      }

      // Save activities to Supabase in chunks to avoid request size limits
      const chunkSize = 50;
      for (var i = 0; i < activityMaps.length; i += chunkSize) {
        final end = (i + chunkSize < activityMaps.length) ? i + chunkSize : activityMaps.length;
        final chunk = activityMaps.sublist(i, end);

        await _client
            .from('zw_activities')
            .upsert(chunk);

        if (kDebugMode) {
          print('Saved ${chunk.length} activities to Supabase (${i + 1}-$end of ${activityMaps.length})');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving activities to Supabase: $e');
      }
      rethrow;
    }
  }

  /// Saves segment efforts to Supabase
  ///
  /// This method saves segment efforts to Supabase for the specified
  /// activity. It deletes existing segment efforts for the activity first.
  Future<void> saveSegmentEfforts(int activityId, List<SegmentEffort> efforts) async {
    if (efforts.isEmpty) {
      if (kDebugMode) {
        print('No segment efforts to save for activity $activityId');
      }
      return;
    }

    try {
      // Ensure we're authenticated using cached check
      final isAuthenticated = await _checkAuthentication();
      if (!isAuthenticated) {
        throw Exception('Not authenticated with Supabase');
      }

      // Get the current athlete ID using cached value
      final athleteId = await _getAthleteId();
      if (athleteId == null) {
        throw Exception('No athlete ID available');
      }

      if (kDebugMode) {
        print('Saving ${efforts.length} segment efforts for activity $activityId');
      }

      // Delete existing segment efforts for this activity
      await _client
          .from('zw_segment_efforts')
          .delete()
          .eq('activity_id', activityId);

      if (kDebugMode) {
        print('Deleted existing segment efforts for activity $activityId');
      }

      // Insert new segment efforts
      int successCount = 0;
      int errorCount = 0;

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
          // Note: We need to import the segment_effort_model.dart file
          // For now, we'll create a simple Map with the necessary fields
          final Map<String, dynamic> effortMap = {
            'activity_id': activityId,
            'segment_id': effort.segment!.id,
            'segment_name': effort.segment!.name,
            'elapsed_time': effort.elapsedTime,
            'moving_time': effort.movingTime,
            'start_date': effort.startDate,
            'start_date_local': effort.startDateLocal,
            'distance': effort.distance,
            'start_index': effort.startIndex,
            'end_index': effort.endIndex,
            'average_watts': effort.averageWatts,
            'average_cadence': effort.averageCadence,
            'average_heartrate': effort.averageHeartrate,
            'max_heartrate': effort.maxHeartrate,
            'pr_rank': effort.prRank,
            'hidden': effort.hidden == true ? 1 : 0,
            'json_data': jsonEncode(effort.toJson()),
          };

          // Insert the segment effort
          await _client
              .from('zw_segment_efforts')
              .upsert(effortMap);

          successCount++;

          if (kDebugMode && i < 3) {  // Log details for first few efforts
            print('Saved segment effort ${effort.id} (segment ${effort.segment!.id}) for activity $activityId');
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
        }
      }

      if (kDebugMode) {
        print('Saved $successCount segment efforts to Supabase for activity $activityId');
        print('Success: $successCount, Errors: $errorCount');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving segment efforts to Supabase: $e');
      }
      rethrow;
    }
  }


  /// Gets segment efforts for an activity from Supabase
  ///
  /// This method fetches segment efforts from Supabase for the specified
  /// activity ID. It returns a list of SegmentEffort objects.
  Future<List<SegmentEffort>> getSegmentEffortsForActivity(int activityId) async {
    try {
      // Ensure we're authenticated using cached check
      final isAuthenticated = await _checkAuthentication();
      if (!isAuthenticated) {
        throw Exception('Not authenticated with Supabase');
      }

      // Get the current athlete ID using cached value
      final athleteId = await _getAthleteId();
      if (athleteId == null) {
        throw Exception('No athlete ID available');
      }

      // Query Supabase for segment efforts
      final response = await _client
          .from('zw_segment_efforts')
          .select()
          .eq('activity_id', activityId)
          .order('start_date', ascending: true);

      if (response == null || response.isEmpty) {
        return [];
      }

      // Convert response to SegmentEffort objects
      final List<SegmentEffort> efforts = [];
      for (var i = 0; i < response.length; i++) {
        try {
          final Map<String, dynamic> effortMap = response[i];
          if (effortMap['json_data'] != null) {
            final Map<String, dynamic> jsonData = jsonDecode(effortMap['json_data']);
            final effort = SegmentEffort.fromJson(jsonData);
            efforts.add(effort);
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error converting segment effort at index $i: $e');
          }
          // Skip this effort
          continue;
        }
      }

      return efforts;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting segment efforts from Supabase: $e');
      }
      return [];
    }
  }

  /// Deletes activities from Supabase
  ///
  /// This method deletes activities from Supabase with the specified IDs.
  /// It returns the number of activities deleted.
  Future<int> deleteActivities(List<int> activityIds) async {
    if (activityIds.isEmpty) return 0;

    try {
      // Ensure we're authenticated using cached check
      final isAuthenticated = await _checkAuthentication();
      if (!isAuthenticated) {
        throw Exception('Not authenticated with Supabase');
      }

      // Get the current athlete ID using cached value
      final athleteId = await _getAthleteId();
      if (athleteId == null) {
        throw Exception('No athlete ID available');
      }

      int deletedCount = 0;
      for (var id in activityIds) {
        // Delete the activity
        final response = await _client
            .from('zw_activities')
            .delete()
            .eq('id', id)
            .eq('athlete_id', athleteId);

        // Increment the deleted count
        if (response != null) {
          deletedCount++;
        }
      }

      return deletedCount;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting activities from Supabase: $e');
      }
      return 0;
    }
  }
}
