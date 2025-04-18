import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/globals.dart' as globals;
import 'package:flutter_strava_api/models/activity.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:zwiftdataviewer/utils/database/database_init.dart';

import 'activity_select_provider.dart';

// Provider for detailed activity information
//
// This provider fetches and manages detailed information about the currently
// selected activity. It uses the Strava API and local caching.
final stravaActivityDetailsProvider =
    StateNotifierProvider<StravaActivityDetailsNotifier, DetailedActivity>(
        (ref) {
  // Watch the selected activity to rebuild this provider when it changes
  final selectedActivity = ref.watch(selectedActivityProvider);
  final activityId = selectedActivity.id;
  final accessToken = globals.token.accessToken;
  
  if (accessToken == null) {
    throw Exception('No access token available');
  }
  
  return StravaActivityDetailsNotifier(accessToken, activityId);
});

// Notifier for detailed activity information
//
// This class manages the state of a detailed activity, including fetching
// from the API and caching.
class StravaActivityDetailsNotifier extends StateNotifier<DetailedActivity> {
  final String _baseUrl = 'https://www.strava.com/api/v3';
  final String _accessToken;

  StravaActivityDetailsNotifier(this._accessToken, int activityId)
      : super(DetailedActivity()) {
    if (activityId > 0) {
      loadActivityDetails(activityId);
    }
  }

  // Loads detailed activity information
  //
  // This method first checks the database for the activity details.
  // If not found in the database, it checks the cache.
  // If not found in the cache, it fetches from the Strava API and saves to both database and cache.
  Future<void> loadActivityDetails(int activityId) async {
    if (activityId <= 0) return;

    try {
      // First check the database
      DetailedActivity? dbActivityDetail;
      try {
        final activityService = DatabaseInit.activityService;
        dbActivityDetail = await activityService.loadActivityDetail(activityId);
        
        if (dbActivityDetail != null) {
          if (kDebugMode) {
            print('Activity detail loaded from database: $activityId');
          }
          state = dbActivityDetail;
          return;
        }
      } catch (dbError) {
        // If database access fails, continue to cache/API
        if (kDebugMode) {
          print('Error accessing database for activity $activityId: $dbError');
        }
        // Don't rethrow, continue to cache/API
      }

      // Check cache if not found in database
      try {
        final cacheFile = await _getCacheFile();
        if (cacheFile.existsSync()) {
          try {
            final cachedData = await cacheFile.readAsString();
            if (cachedData.isNotEmpty) {
              try {
                final List activityDetails = jsonDecode(cachedData);
                for (var activityDetail in activityDetails) {
                  if (activityDetail != null && 
                      activityDetail is Map<String, dynamic> && 
                      activityDetail.containsKey('id') && 
                      activityDetail['id'].toString() == activityId.toString()) {
                    try {
                      state = DetailedActivity.fromJson(activityDetail);
                      
                      // Save to database for future use
                      try {
                        final activityService = DatabaseInit.activityService;
                        await activityService.saveActivityDetail(state);
                        if (kDebugMode) {
                          print('Cached activity detail saved to database: $activityId');
                        }
                      } catch (e) {
                        if (kDebugMode) {
                          print('Error saving cached activity detail to database: $e');
                        }
                        // Continue even if saving to database fails
                      }
                      
                      return;
                    } catch (parseError) {
                      if (kDebugMode) {
                        print('Error parsing cached activity detail: $parseError');
                      }
                      // Continue to next cached activity or API if parsing fails
                    }
                  }
                }
              } catch (jsonError) {
                if (kDebugMode) {
                  print('Error decoding cached data: $jsonError');
                }
                // Continue to API if JSON decoding fails
              }
            }
          } catch (readError) {
            if (kDebugMode) {
              print('Error reading cache file: $readError');
            }
            // Continue to API if reading cache fails
          }
        }
      } catch (cacheError) {
        if (kDebugMode) {
          print('Error accessing cache: $cacheError');
        }
        // Continue to API if cache access fails
      }

      // Fetch from API if not in database or cache
      try {
        if (kDebugMode) {
          print('Fetching activity detail from API: $activityId');
        }
        
        final url = Uri.parse('$_baseUrl/activities/$activityId');
        final response = await http.get(
          url,
          headers: {'Authorization': 'Bearer $_accessToken'},
        );

        if (response.statusCode == 200) {
          try {
            final responseBody = response.body;
            if (responseBody.isEmpty) {
              throw Exception('Empty response body');
            }
            
            final dynamic jsonData = json.decode(responseBody);
            if (jsonData == null || jsonData is! Map<String, dynamic>) {
              throw Exception('Invalid JSON response: not a map');
            }
            
            final DetailedActivity activityDetail = DetailedActivity.fromJson(jsonData);
            state = activityDetail;
            
            // Save to database
            try {
              final activityService = DatabaseInit.activityService;
              await activityService.saveActivityDetail(activityDetail);
              if (kDebugMode) {
                print('Activity detail saved to database: $activityId');
              }
            } catch (dbSaveError) {
              if (kDebugMode) {
                print('Error saving activity detail to database: $dbSaveError');
              }
              // Continue even if saving to database fails
            }
              
            // Also save to cache for backward compatibility
            try {
              await _saveActivityDetailToCache(jsonData);
            } catch (cacheSaveError) {
              if (kDebugMode) {
                print('Error saving activity detail to cache: $cacheSaveError');
              }
              // Continue even if saving to cache fails
            }
          } catch (parseError) {
            if (kDebugMode) {
              print('Error parsing API response: $parseError');
            }
            throw Exception('Failed to parse activity details: $parseError');
          }
        } else {
          if (kDebugMode) {
            print('API error: ${response.statusCode} - ${response.body}');
          }
          throw Exception(
              'Failed to load activity details: ${response.statusCode}');
        }
      } catch (apiError) {
        if (kDebugMode) {
          print('Error fetching from API: $apiError');
        }
        rethrow; // Rethrow to be caught by the outer try-catch
      }
    } catch (e) {
      // If we already have some data, keep it
      if (state.id != null) {
        return;
      }
      if (kDebugMode) {
        print('Error loading activity details: $e');
      }
      rethrow;
    }
  }

  // Gets the cache file for storing activity details
  Future<File> _getCacheFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/strava_activity_details_cache.json');
  }

  // Saves activity details to the cache
  Future<void> _saveActivityDetailToCache(
      Map<String, dynamic> activityDetail) async {
    try {
      final cacheFile = await _getCacheFile();
      List activityDetails = [];

      if (cacheFile.existsSync()) {
        final cachedData = await cacheFile.readAsString();
        activityDetails = jsonDecode(cachedData);
      }

      // Check if activity already exists in cache
      bool exists = false;
      for (int i = 0; i < activityDetails.length; i++) {
        if (activityDetails[i]['id'].toString() ==
            activityDetail['id'].toString()) {
          activityDetails[i] = activityDetail; // Update existing
          exists = true;
          break;
        }
      }

      if (!exists) {
        activityDetails.add(activityDetail); // Add new
      }

      await cacheFile.writeAsString(jsonEncode(activityDetails));
    } catch (e) {
      // Just log the error, don't fail the whole operation for a cache issue
      if (kDebugMode) {
        print('Error saving to cache: $e');
      }
    }
  }
}

// Provider for the current activity detail
//
// This provider is used to store and access the current activity detail
// throughout the app.
final activityDetailProvider =
    StateNotifierProvider<ActivityDetailNotifier, DetailedActivity>((ref) {
  return ActivityDetailNotifier();
});

// Notifier for activity detail
//
// This class manages the state of the current activity detail.
class ActivityDetailNotifier extends StateNotifier<DetailedActivity> {
  ActivityDetailNotifier() : super(DetailedActivity());

  // Gets the current activity detail
  DetailedActivity get activityDetail => state;

  // Sets the current activity detail
  void setActivityDetail(DetailedActivity activityDetail) {
    state = activityDetail;
  }
}

// Represents a lap summary
//
// This class contains summary information about a lap, including distance,
// time, altitude, cadence, watts, and speed.
class LapSummaryObject {
  final int lap;
  int count = 0;
  double distance;
  int time;
  double altitude;
  double cadence;
  double watts;
  double speed;
  final Color color;

  LapSummaryObject(this.lap, this.count, this.distance, this.time,
      this.altitude, this.cadence, this.watts, this.speed, this.color);
}
