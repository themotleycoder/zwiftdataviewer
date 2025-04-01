import 'package:flutter/foundation.dart';
import 'package:flutter_strava_api/api/streams.dart';
import 'package:flutter_strava_api/models/activity.dart';
import 'package:flutter_strava_api/models/summary_activity.dart';
import 'package:flutter_strava_api/strava.dart';
import 'package:zwiftdataviewer/utils/database/services/activity_service.dart';
import 'package:zwiftdataviewer/utils/repository/activitesrepository.dart';
import 'package:zwiftdataviewer/utils/repository/streamsrepository.dart';

import '../../secrets.dart';

class WebRepository implements ActivitiesRepository, StreamsRepository {
  final Strava strava;
  final ActivityService activityService;

  WebRepository({required this.strava, required this.activityService});

  @override
  Future<List<SummaryActivity>> loadActivities(
      int beforeDate, int afterDate) async {
    try { 
      await _ensureAuthenticated();
      final cachedActivities = await activityService.loadActivities(beforeDate, afterDate);
      if (cachedActivities != null && cachedActivities.isNotEmpty) {
        return cachedActivities.whereType<SummaryActivity>().toList();
      }
      final activities = await strava.getLoggedInAthleteActivities(
          beforeDate, afterDate, null);
      await activityService.saveActivities(activities);
      return activities;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading activities: $e');
      }
      rethrow;
    }
  }

  @override
  Future<DetailedActivity> loadActivityDetail(int activityId) async {
    try {
      await _ensureAuthenticated();
      final cachedActivity = await activityService.loadActivityDetail(activityId);
      if (cachedActivity != null) {
        return cachedActivity;
      }
      final activity = await strava.getActivityById(activityId.toString());
      await activityService.saveActivityDetail(activity);
      return activity;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading activity detail: $e');
      }
      rethrow;
    }
  }

  @override
  Future<List<PhotoActivity>> loadActivityPhotos(int activityId) async {
    try {
      await _ensureAuthenticated();
      
      // Debug: Check if the activity has photos according to the activity data
      try {
        final activity = await loadActivityDetail(activityId);
        if (kDebugMode) {
          print('Activity $activityId has ${activity.totalPhotoCount} photos according to activity data');
          print('Activity photos property: ${activity.photos}');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error checking activity photo count: $e');
        }
      }
      
      // Check database first
      try {
        final cachedPhotos = await activityService.loadActivityPhotos(activityId);
        if (cachedPhotos.isNotEmpty) {
          if (kDebugMode) {
            print('Loaded ${cachedPhotos.length} photos from database for activity $activityId');
            if (cachedPhotos.isNotEmpty) {
              print('First cached photo: ${cachedPhotos.first.toJson()}');
            }
          }
          
          // Validate each photo has valid URLs
          final validCachedPhotos = cachedPhotos.where((photo) {
            return photo.urls != null && photo.urls!.isNotEmpty;
          }).toList();
          
          if (validCachedPhotos.isNotEmpty) {
            return validCachedPhotos;
          } else {
            if (kDebugMode) {
              print('Cached photos for activity $activityId have invalid URLs, fetching from API');
            }
            // If all cached photos have invalid URLs, continue to API
          }
        } else {
          if (kDebugMode) {
            print('No photos found in database for activity $activityId, fetching from API');
          }
        }
      } catch (dbError) {
        if (kDebugMode) {
          print('Error loading photos from database for activity $activityId: $dbError');
        }
        // Continue to API if database access fails
      }
      
      // Fetch from API
      try {
        if (kDebugMode) {
          print('Fetching photos from API for activity $activityId');
        }
        
        final photos = await strava.getPhotosFromActivityById(activityId);
        
        if (kDebugMode) {
          print('API returned ${photos.length} photos for activity $activityId');
          if (photos.isNotEmpty) {
            print('First photo from API: ${photos.first.toJson()}');
          } else {
            print('No photos returned from API for activity $activityId');
          }
        }
        
        // Filter out photos with null IDs or null URLs
        final validPhotos = <PhotoActivity>[];
        
        for (var photo in photos) {
          // Check if the photo has a valid ID
          final hasValidId = photo.id != null;
          
          // Check if the photo has valid URLs
          final hasValidUrls = photo.urls != null && photo.urls!.isNotEmpty;
          
          final isValid = hasValidId && hasValidUrls;
          
          if (isValid) {
            validPhotos.add(photo);
          } else {
            if (kDebugMode) {
              print('Skipping invalid photo: ${photo.toJson()}');
              if (!hasValidId) print('  - Invalid ID: ${photo.id}');
              if (!hasValidUrls) print('  - Invalid URLs: ${photo.urls}');
            }
          }
        }
        
        if (kDebugMode) {
          print('Found ${validPhotos.length} valid photos for activity $activityId');
        }
        
        if (validPhotos.isNotEmpty) {
          // Only save valid photos to database
          try {
            if (kDebugMode) {
              print('Saving ${validPhotos.length} valid photos to database for activity $activityId');
            }
            
            // Clear existing photos first to avoid duplicates
            await activityService.saveActivityPhotos(activityId, validPhotos);
            
            // Verify photos were saved
            final savedPhotos = await activityService.loadActivityPhotos(activityId);
            if (kDebugMode) {
              print('Verified ${savedPhotos.length} photos saved to database for activity $activityId');
            }
            
            return validPhotos;
          } catch (saveError) {
            if (kDebugMode) {
              print('Error saving photos to database for activity $activityId: $saveError');
            }
            // Continue even if saving fails
            return validPhotos;
          }
        } else {
          if (kDebugMode) {
            print('No valid photos found in API response for activity $activityId');
          }
          return []; // Return empty list if no valid photos
        }
      } catch (apiError) {
        if (kDebugMode) {
          print('Error fetching photos from API for activity $activityId: $apiError');
        }
        return []; // Return empty list on API error
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading activity photos for activity $activityId: $e');
      }
      return []; // Return empty list on any other error
    }
  }

  @override
  Future<StreamsDetailCollection> loadStreams(int activityId) async {
    try {
      await _ensureAuthenticated();
      final cachedStreams = await activityService.loadStreams(activityId);
      if (cachedStreams.streams != null && cachedStreams.streams!.isNotEmpty) {
        return cachedStreams;
      }
      final streams = await strava.getStreamsByActivity(activityId.toString());
      await activityService.saveStreams(activityId, streams);
      return streams;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading streams: $e');
      }
      // Return an empty StreamsDetailCollection instead of rethrowing
      return StreamsDetailCollection();
    }
  }

  @override
  Future<void> saveActivities(List<SummaryActivity> activities) async {
    await activityService.saveActivities(activities);
  }

  Future<void> _ensureAuthenticated() async {
    if (!strava.isAuthenticated()) {
      final isAuthOk = await strava.oauth(
        clientId,
        'activity:write,activity:read_all,profile:read_all,profile:write',
        clientSecret,
        'auto',
      );
      if (!isAuthOk) {
        throw Exception('Authentication failed');
      }
    }
  }
}
