import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/globals.dart' as globals;
import 'package:flutter_strava_api/models/activity.dart';
import 'package:flutter_strava_api/models/summary_activity.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for Strava activities
///
/// This provider fetches activities from Strava API and caches them locally.
/// It returns a list of SummaryActivity objects sorted by date (newest first).
final stravaActivitiesProvider =
    FutureProvider<List<SummaryActivity>>((ref) async {
  try {
    return await fetchStravaActivities();
  } catch (e, stackTrace) {
    debugPrint('Error in stravaActivitiesProvider: $e');
    debugPrint(stackTrace.toString());
    rethrow;
  }
});

/// Fetches Strava activities from API or cache
///
/// This function first checks for cached activities, then fetches new activities
/// from the Strava API that occurred after the last known activity date.
/// It filters for VirtualRide activities only and combines with cached activities.
/// Implements retry logic for network errors.
Future<List<SummaryActivity>> fetchStravaActivities() async {
  const String baseUrl = 'https://www.strava.com/api/v3';
  DateTime? lastActivityDate = await getLastActivityDate();
  int afterTimestamp = 1420070400; // Default: Jan 1, 2015
  List<SummaryActivity> cachedActivities = [];
  final accessToken = globals.token.accessToken;

  if (accessToken == null) {
    throw Exception('No access token available');
  }

  try {
    // Load cached activities
    final cacheFile = await _getCacheFile();
    if (cacheFile.existsSync()) {
      final cacheData = await cacheFile.readAsString();
      cachedActivities = List.from(jsonDecode(cacheData))
          .map((activity) => SummaryActivity.fromJson(activity))
          .toList();
    }

    // Set timestamp for API request
    if (lastActivityDate != null) {
      afterTimestamp = lastActivityDate.millisecondsSinceEpoch ~/ 1000;
    }

    // Fetch new activities
    List<SummaryActivity> fetchedActivities = [];
    int page = 1;
    int perPage = 50;
    bool hasMorePages = true;

    while (hasMorePages) {
      try {
        final url = Uri.parse(
            '$baseUrl/athlete/activities?page=$page&per_page=$perPage&after=$afterTimestamp');
        
        // Use retry mechanism for network requests
        final response = await _retryHttpRequest(
          () => http.get(
            url,
            headers: {'Authorization': 'Bearer $accessToken'},
          ),
        );

        if (response.statusCode == 200) {
          final List<SummaryActivity> activities =
              List.from(jsonDecode(response.body))
                  .map((activity) => SummaryActivity.fromJson(activity))
                  .toList();
          final List<SummaryActivity> filteredActivities = activities
              .where((activity) => activity.type == ActivityType.VirtualRide)
              .toList();
          fetchedActivities.addAll(filteredActivities);

          if (activities.length < perPage) {
            hasMorePages = false;
          } else {
            page++;
          }
        } else {
          debugPrint('HTTP error: ${response.statusCode} - ${response.body}');
          throw Exception(
              'Failed to load athlete activities: ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('Error fetching page $page: $e');
        // If we've already fetched some activities, we can stop and use what we have
        if (fetchedActivities.isNotEmpty) {
          debugPrint('Using partial results (${fetchedActivities.length} activities)');
          hasMorePages = false;
        } else {
          // If we haven't fetched any activities yet, rethrow to use cached data
          rethrow;
        }
      }
    }

    // Combine and save activities
    List<SummaryActivity> allActivities = [
      ...cachedActivities,
      ...fetchedActivities
    ];

    // Remove duplicates (in case we're re-fetching some activities)
    final Map<String, SummaryActivity> uniqueActivities = {};
    for (var activity in allActivities) {
      uniqueActivities[activity.id.toString()] = activity;
    }
    allActivities = uniqueActivities.values.toList();

    if (allActivities.isNotEmpty) {
      try {
        await cacheFile.writeAsString(jsonEncode(allActivities));
        await saveLastActivityDate(allActivities.last.startDate);
      } catch (e) {
        debugPrint('Error saving cache: $e');
        // Continue even if saving cache fails
      }
    }

    // Return activities sorted by date (newest first)
    return allActivities.reversed.toList();
  } catch (e) {
    debugPrint('Error in fetchStravaActivities: $e');
    // If there's an error but we have cached data, return it
    if (cachedActivities.isNotEmpty) {
      debugPrint('Returning ${cachedActivities.length} cached activities');
      return cachedActivities.reversed.toList();
    }
    rethrow; // Otherwise rethrow the error
  }
}

/// Retry an HTTP request with exponential backoff
///
/// This function will retry the HTTP request up to [maxRetries] times
/// with exponential backoff between retries.
Future<http.Response> _retryHttpRequest(
  Future<http.Response> Function() requestFn, {
  int maxRetries = 3,
}) async {
  int retryCount = 0;
  Duration delay = const Duration(seconds: 1);
  
  while (true) {
    try {
      return await requestFn();
    } catch (e) {
      retryCount++;
      if (retryCount >= maxRetries) {
        debugPrint('Max retries reached ($maxRetries)');
        rethrow;
      }
      
      // Log the error and retry after delay
      debugPrint('Network error (attempt $retryCount/$maxRetries): $e');
      debugPrint('Retrying after ${delay.inSeconds} seconds...');
      
      await Future.delayed(delay);
      // Exponential backoff: 1s, 2s, 4s, etc.
      delay *= 2;
    }
  }
}

/// Gets the cache file for storing activities
Future<File> _getCacheFile() async {
  final directory = await getApplicationDocumentsDirectory();
  return File('${directory.path}/strava_activities_cache.json');
}

/// Saves the date of the most recent activity
Future<void> saveLastActivityDate(DateTime date) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('lastActivityDate', date.millisecondsSinceEpoch);
}

/// Gets the date of the most recent activity
Future<DateTime?> getLastActivityDate() async {
  final prefs = await SharedPreferences.getInstance();
  final milliseconds = prefs.getInt('lastActivityDate');
  if (milliseconds != null) {
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }
  return null;
}
