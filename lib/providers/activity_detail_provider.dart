import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/globals.dart' as globals;
import 'package:flutter_strava_api/models/activity.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'activity_select_provider.dart';

/// Provider for detailed activity information
///
/// This provider fetches and manages detailed information about the currently
/// selected activity. It uses the Strava API and local caching.
final stravaActivityDetailsProvider =
    StateNotifierProvider<StravaActivityDetailsNotifier, DetailedActivity>(
        (ref) {
  var activityId = ref.watch(selectedActivityProvider).id;
  final accessToken = globals.token.accessToken;
  if (accessToken == null) {
    throw Exception('No access token available');
  }
  return StravaActivityDetailsNotifier(accessToken, activityId);
});

/// Notifier for detailed activity information
///
/// This class manages the state of a detailed activity, including fetching
/// from the API and caching.
class StravaActivityDetailsNotifier extends StateNotifier<DetailedActivity> {
  final String _baseUrl = 'https://www.strava.com/api/v3';
  final String _accessToken;

  StravaActivityDetailsNotifier(this._accessToken, int activityId)
      : super(DetailedActivity()) {
    if (activityId > 0) {
      loadActivityDetails(activityId);
    }
  }

  /// Loads detailed activity information
  ///
  /// This method first checks the cache for the activity details. If not found,
  /// it fetches the details from the Strava API and caches them.
  Future<void> loadActivityDetails(int activityId) async {
    if (activityId <= 0) return;
    
    try {
      // Check cache first
      final cacheFile = await _getCacheFile();
      if (cacheFile.existsSync()) {
        final cachedData = await cacheFile.readAsString();
        final List activityDetails = jsonDecode(cachedData);
        for (var activityDetail in activityDetails) {
          if (activityDetail['id'].toString() == activityId.toString()) {
            state = DetailedActivity.fromJson(activityDetail);
            return;
          }
        }
      }

      // Fetch from API if not in cache
      final url = Uri.parse('$_baseUrl/activities/$activityId');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      if (response.statusCode == 200) {
        final DetailedActivity activityDetail =
            DetailedActivity.fromJson(json.decode(response.body));
        state = activityDetail;
        await _saveActivityDetailToCache(json.decode(response.body));
      } else {
        throw Exception('Failed to load activity details: ${response.statusCode}');
      }
    } catch (e) {
      // If we already have some data, keep it
      if (state.id != null) {
        return;
      }
      print('Error loading activity details: $e');
      rethrow;
    }
  }

  /// Gets the cache file for storing activity details
  Future<File> _getCacheFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/strava_activity_details_cache.json');
  }

  /// Saves activity details to the cache
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
        if (activityDetails[i]['id'].toString() == activityDetail['id'].toString()) {
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
      print('Error saving to cache: $e');
    }
  }
}

/// Provider for the current activity detail
///
/// This provider is used to store and access the current activity detail
/// throughout the app.
final activityDetailProvider =
    StateNotifierProvider<ActivityDetailNotifier, DetailedActivity>((ref) {
  return ActivityDetailNotifier();
});

/// Notifier for activity detail
///
/// This class manages the state of the current activity detail.
class ActivityDetailNotifier extends StateNotifier<DetailedActivity> {
  ActivityDetailNotifier() : super(DetailedActivity());

  /// Gets the current activity detail
  DetailedActivity get activityDetail => state;

  /// Sets the current activity detail
  void setActivityDetail(DetailedActivity activityDetail) {
    state = activityDetail;
  }
}

/// Represents a lap summary
///
/// This class contains summary information about a lap, including distance,
/// time, altitude, cadence, watts, and speed.
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
