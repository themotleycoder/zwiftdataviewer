import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/globals.dart' as globals;
import 'package:flutter_strava_api/models/activity.dart';
import 'package:flutter_strava_api/models/summary_activity.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zwiftdataviewer/utils/repository/hybrid_activities_repository.dart';

// Provider for Strava activities
//
// This provider fetches activities from Strava API and stores them in the SQLite database.
// It returns a list of SummaryActivity objects sorted by date (newest first).
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

// Provider for database activities
//
// This provider fetches activities from the database (Supabase when online, SQLite when offline).
// It returns a list of SummaryActivity objects sorted by date (newest first).
final databaseActivitiesProvider =
    FutureProvider.family<List<SummaryActivity>, DateRange>((ref, dateRange) async {
  try {
    final hybridRepo = HybridActivitiesRepository();
    final activities = await hybridRepo.loadActivities(
      dateRange.before.millisecondsSinceEpoch ~/ 1000,
      dateRange.after.millisecondsSinceEpoch ~/ 1000,
    );
    return activities?.whereType<SummaryActivity>().toList() ?? [];
  } catch (e, stackTrace) {
    debugPrint('Error in databaseActivitiesProvider: $e');
    debugPrint(stackTrace.toString());
    return [];
  }
});

// Date range for querying activities
class DateRange {
  final DateTime before;
  final DateTime after;

  DateRange({
    required this.before,
    required this.after,
  });

  // Creates a date range for the last 90 days
  factory DateRange.last90Days() {
    final now = DateTime.now();
    return DateRange(
      before: now,
      after: now.subtract(const Duration(days: 90)),
    );
  }

  // Creates a date range for all time
  factory DateRange.allTime() {
    return DateRange(
      before: DateTime.now(),
      after: DateTime(2015, 1, 1), // Default: Jan 1, 2015
    );
  }
}

// Fetches Strava activities from API and stores them in the database
//
// This function fetches activities from the Strava API that occurred after the last known activity date.
// It filters for VirtualRide activities only and stores them in the database.
// Implements retry logic for network errors.
Future<List<SummaryActivity>> fetchStravaActivities() async {
  const String baseUrl = 'https://www.strava.com/api/v3';
  DateTime? lastActivityDate = await getLastActivityDate();
  int afterTimestamp = 1420070400; // Default: Jan 1, 2015
  final accessToken = globals.token.accessToken;

  if (accessToken == null) {
    throw Exception('No access token available');
  }

  try {
    // Check if token is valid
    if (accessToken.isEmpty) {
      throw Exception('No valid Strava access token available. Please authenticate with Strava.');
    }
    
    // Set timestamp for API request
    if (lastActivityDate != null) {
      afterTimestamp = lastActivityDate.millisecondsSinceEpoch ~/ 1000;
    }

    // Check connectivity before attempting to fetch activities
    bool hasConnectivity = await _checkConnectivity();
    if (!hasConnectivity) {
      throw Exception('No internet connection available. Please check your network settings.');
    }

    // Fetch activities
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
              .where((activity) => activity.type == ActivityType.VirtualRide || activity.type == ActivityType.Ride)
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
          // If we haven't fetched any activities yet, rethrow
          rethrow;
        }
      }
    }

    // Store fetched activities in the database
    if (fetchedActivities.isNotEmpty) {
      try {
        // Use the hybrid repository to save activities
        final hybridRepo = HybridActivitiesRepository();
        
        // Save activities to the database (both SQLite and Supabase if online)
        await hybridRepo.saveActivities(fetchedActivities);
        
        // Update last activity date
        if (fetchedActivities.isNotEmpty) {
          await saveLastActivityDate(fetchedActivities.first.startDate);
        }
        
        debugPrint('Saved ${fetchedActivities.length} activities to database');
      } catch (e) {
        debugPrint('Error saving activities to database: $e');
        // Continue even if saving to database fails
      }
    }

    // Sort activities by date (newest first)
    fetchedActivities.sort((a, b) => b.startDate.compareTo(a.startDate));

    return fetchedActivities;
  } catch (e) {
    debugPrint('Error in fetchStravaActivities: $e');
    rethrow;
  }
}

// Check if the device has internet connectivity
//
// Returns true if the device has internet connectivity, false otherwise.
// This checks both WiFi and mobile data connections.
Future<bool> _checkConnectivity() async {
  try {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      debugPrint('No internet connectivity detected');
      return false;
    }
    
    // Additional check: try to actually reach a reliable host
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      debugPrint('Cannot reach internet despite connectivity status');
      return false;
    }
    
    return false;
  } catch (e) {
    debugPrint('Error checking connectivity: $e');
    return false;
  }
}

// Retry an HTTP request with exponential backoff
//
// This function will retry the HTTP request up to [maxRetries] times
// with exponential backoff between retries. It also checks for internet
// connectivity before each retry.
Future<http.Response> _retryHttpRequest(
  Future<http.Response> Function() requestFn, {
  int maxRetries = 3,
}) async {
  int retryCount = 0;
  Duration delay = const Duration(seconds: 1);
  
  while (true) {
    try {
      // Check connectivity before making the request
      bool hasConnectivity = await _checkConnectivity();
      if (!hasConnectivity) {
        throw const SocketException(
          'No internet connection available. Please check your network settings.',
        );
      }
      
      final response = await requestFn();
      
      // Handle HTTP status codes
      if (response.statusCode == 401) {
        // Unauthorized - token expired or invalid
        throw Exception('Strava authentication expired. Please re-authenticate.');
      } else if (response.statusCode == 403) {
        // Forbidden - likely API access revoked or rate limited
        debugPrint('Strava API returned 403 Forbidden: ${response.body}');
        if (response.body.contains('Request blocked')) {
          throw Exception('Strava API request blocked. This may be due to API rate limiting or changes in Strava\'s API policies.');
        } else {
          throw Exception('Strava API access denied (403 Forbidden). Your API access may have been revoked or rate limited.');
        }
      }
      
      return response;
    } catch (e) {
      retryCount++;
      if (retryCount >= maxRetries) {
        debugPrint('Max retries reached ($maxRetries)');
        rethrow;
      }
      
      // Provide more specific error messages based on error type
      String errorMessage = 'Network error';
      if (e is SocketException) {
        if (e.message.contains('Failed host lookup')) {
          errorMessage = 'DNS resolution failed. Cannot reach Strava servers.';
        } else if (e.osError == 7) {
          errorMessage = 'No internet connection available.';
        } else {
          errorMessage = 'Connection error: ${e.message}';
        }
      } else if (e is TimeoutException) {
        errorMessage = 'Request timed out. Server may be slow or unreachable.';
      } else if (e is http.ClientException) {
        errorMessage = 'HTTP client error: ${e.message}';
      } else if (e.toString().contains('403')) {
        errorMessage = 'Strava API access denied. Your API credentials may need to be updated.';
      }
      
      // Log the error and retry after delay
      debugPrint('Network error (attempt $retryCount/$maxRetries): $errorMessage - $e');
      debugPrint('Retrying after ${delay.inSeconds} seconds...');
      
      await Future.delayed(delay);
      // Exponential backoff: 1s, 2s, 4s, etc.
      delay *= 2;
    }
  }
}

// Saves the date of the most recent activity
Future<void> saveLastActivityDate(DateTime date) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('lastActivityDate', date.millisecondsSinceEpoch);
}

// Gets the date of the most recent activity
Future<DateTime?> getLastActivityDate() async {
  final prefs = await SharedPreferences.getInstance();
  final milliseconds = prefs.getInt('lastActivityDate');
  if (milliseconds != null) {
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }
  return null;
}
