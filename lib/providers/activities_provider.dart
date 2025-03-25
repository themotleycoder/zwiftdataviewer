import 'dart:convert';
import 'dart:io';

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
  return await fetchStravaActivities();
});

/// Fetches Strava activities from API or cache
///
/// This function first checks for cached activities, then fetches new activities
/// from the Strava API that occurred after the last known activity date.
/// It filters for VirtualRide activities only and combines with cached activities.
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
      final url = Uri.parse(
          '$baseUrl/athlete/activities?page=$page&per_page=$perPage&after=$afterTimestamp');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $accessToken'},
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
        throw Exception('Failed to load athlete activities: ${response.statusCode}');
      }
    }

    // Combine and save activities
    List<SummaryActivity> allActivities = [...cachedActivities, ...fetchedActivities];
    
    if (allActivities.isNotEmpty) {
      await cacheFile.writeAsString(jsonEncode(allActivities));
      await saveLastActivityDate(allActivities.last.startDate);
    }
    
    // Return activities sorted by date (newest first)
    return allActivities.reversed.toList();
  } catch (e) {
    // If there's an error but we have cached data, return it
    if (cachedActivities.isNotEmpty) {
      return cachedActivities.reversed.toList();
    }
    rethrow; // Otherwise rethrow the error
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
