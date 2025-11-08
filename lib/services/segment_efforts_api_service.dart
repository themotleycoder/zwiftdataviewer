import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_strava_api/globals.dart' as globals;
import 'package:flutter_strava_api/models/segmentEffort.dart';
import 'package:http/http.dart' as http;
import 'package:zwiftdataviewer/utils/database/database_init.dart';
import 'package:zwiftdataviewer/utils/supabase/supabase_auth_service.dart';
import 'package:zwiftdataviewer/utils/supabase/supabase_database_service.dart';

/// Service for fetching segment efforts from Strava API
///
/// This service handles pagination, retry logic, and caching of segment efforts
/// following the hybrid cache-aside pattern used throughout the app.
class SegmentEffortsApiService {
  static const String _baseUrl = 'https://www.strava.com/api/v3';
  final SupabaseDatabaseService _supabaseService = SupabaseDatabaseService();
  final SupabaseAuthService _authService = SupabaseAuthService();

  /// Fetches all segment efforts for the authenticated athlete on a specific segment
  ///
  /// This method:
  /// 1. Fetches all efforts from Strava API with pagination
  /// 2. Caches results in Supabase (if online and authenticated)
  /// 3. Caches results in SQLite for offline access
  ///
  /// Returns a list of SegmentEffort objects, sorted by date (newest first).
  /// Throws an exception if authentication fails or network errors occur.
  Future<List<SegmentEffort>> fetchAllPersonalSegmentEfforts(
    int segmentId,
  ) async {
    final accessToken = globals.token.accessToken;

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception(
          'No valid Strava access token available. Please authenticate with Strava.');
    }

    // Check connectivity before attempting to fetch
    bool hasConnectivity = await _checkConnectivity();
    if (!hasConnectivity) {
      throw Exception(
          'No internet connection available. Please check your network settings.');
    }

    // Fetch all efforts with pagination
    List<SegmentEffort> fetchedEfforts = [];
    int page = 1;
    int perPage = 50; // Strava API default max
    bool hasMorePages = true;

    debugPrint('Fetching personal segment efforts for segment $segmentId...');

    while (hasMorePages) {
      try {
        final url = Uri.parse(
            '$_baseUrl/segments/$segmentId/all_efforts?page=$page&per_page=$perPage');

        // Use retry mechanism for network requests
        final response = await _retryHttpRequest(
          () => http.get(
            url,
            headers: {'Authorization': 'Bearer $accessToken'},
          ),
        );

        if (response.statusCode == 200) {
          final List<dynamic> effortsJson = jsonDecode(response.body);

          final List<SegmentEffort> efforts = effortsJson
              .map((json) => SegmentEffort.fromJson(json))
              .toList();

          fetchedEfforts.addAll(efforts);

          debugPrint('Fetched ${efforts.length} efforts from page $page');

          // Stop pagination when API returns fewer items than requested
          if (efforts.length < perPage) {
            hasMorePages = false;
          } else {
            page++;
          }
        } else {
          debugPrint('HTTP error: ${response.statusCode} - ${response.body}');
          throw Exception(
              'Failed to load segment efforts: ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('Error fetching page $page: $e');
        // If we've already fetched some efforts, we can stop and use what we have
        if (fetchedEfforts.isNotEmpty) {
          debugPrint(
              'Using partial results (${fetchedEfforts.length} efforts)');
          hasMorePages = false;
        } else {
          // If we haven't fetched any efforts yet, rethrow
          rethrow;
        }
      }
    }

    debugPrint('Total efforts fetched: ${fetchedEfforts.length}');

    // Cache the results following hybrid cache-aside pattern
    if (fetchedEfforts.isNotEmpty) {
      await _cacheSegmentEfforts(segmentId, fetchedEfforts);
    }

    // Sort efforts by date (newest first)
    // Handle nullable startDate
    fetchedEfforts.sort((a, b) {
      final aDate = a.startDate ?? '';
      final bDate = b.startDate ?? '';
      return bDate.compareTo(aDate);
    });

    return fetchedEfforts;
  }

  /// Cache segment efforts in both Supabase and SQLite
  ///
  /// Follows the hybrid cache-aside pattern:
  /// - Tries Supabase first if online and authenticated
  /// - Always caches in SQLite for offline access
  Future<void> _cacheSegmentEfforts(
    int segmentId,
    List<SegmentEffort> efforts,
  ) async {
    // Efforts are already SegmentEffort objects from the API
    final segmentEfforts = efforts;

    try {
      // Try to save to Supabase if authenticated
      if (await _shouldUseSupabase()) {
        try {
          debugPrint('Caching ${efforts.length} efforts to Supabase...');
          await _supabaseService.saveSegmentEffortsBySegmentId(
            segmentId,
            segmentEfforts,
          );
          debugPrint('Successfully cached to Supabase');
        } catch (e) {
          debugPrint('Error caching to Supabase: $e');
          // Continue to SQLite cache even if Supabase fails
        }
      }

      // Always save to SQLite for offline access
      debugPrint('Caching ${efforts.length} efforts to SQLite...');
      await _saveToCacheBySegmentId(segmentId, segmentEfforts);
      debugPrint('Successfully cached to SQLite');
    } catch (e) {
      debugPrint('Error caching segment efforts: $e');
      // Don't throw - caching failure shouldn't stop the operation
    }
  }

  /// Save efforts to SQLite cache by segment ID
  ///
  /// This saves all efforts for a segment, replacing any existing cached efforts
  /// for that segment. Each effort is linked to its activity_id.
  Future<void> _saveToCacheBySegmentId(
    int segmentId,
    List<SegmentEffort> efforts,
  ) async {
    try {
      // Group efforts by activity_id
      final effortsByActivity = <int, List<SegmentEffort>>{};
      for (var effort in efforts) {
        final activityId = effort.activity?.id;
        if (activityId != null) {
          effortsByActivity.putIfAbsent(activityId, () => []).add(effort);
        }
      }

      // Save efforts for each activity
      for (var entry in effortsByActivity.entries) {
        await DatabaseInit.segmentEffortService.saveSegmentEfforts(
          entry.key,
          entry.value,
        );
      }
    } catch (e) {
      debugPrint('Error saving to SQLite cache: $e');
      rethrow;
    }
  }

  /// Check if Supabase should be used for caching
  Future<bool> _shouldUseSupabase() async {
    try {
      final isAuth = await _authService.isAuthenticated();
      return isAuth;
    } catch (e) {
      return false;
    }
  }

  /// Check if the device has internet connectivity
  ///
  /// Returns true if the device has internet connectivity, false otherwise.
  /// This checks both WiFi and mobile data connections.
  Future<bool> _checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
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

  /// Retry an HTTP request with exponential backoff
  ///
  /// This function will retry the HTTP request up to [maxRetries] times
  /// with exponential backoff between retries. It also checks for internet
  /// connectivity before each retry.
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
          throw Exception(
              'Strava authentication expired. Please re-authenticate.');
        } else if (response.statusCode == 403) {
          // Forbidden - likely API access revoked or rate limited
          debugPrint('Strava API returned 403 Forbidden: ${response.body}');
          if (response.body.contains('Request blocked')) {
            throw Exception(
                'Strava API request blocked. This may be due to API rate limiting or changes in Strava\'s API policies.');
          } else {
            throw Exception(
                'Strava API access denied (403 Forbidden). Your API access may have been revoked or rate limited.');
          }
        } else if (response.statusCode == 404) {
          // Not found - segment doesn't exist or no efforts available
          throw Exception(
              'Segment not found or you have no efforts on this segment.');
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
          } else if (e.osError?.errorCode == 7) {
            errorMessage = 'No internet connection available.';
          } else {
            errorMessage = 'Connection error: ${e.message}';
          }
        } else if (e is TimeoutException) {
          errorMessage =
              'Request timed out. Server may be slow or unreachable.';
        } else if (e is http.ClientException) {
          errorMessage = 'HTTP client error: ${e.message}';
        } else if (e.toString().contains('403')) {
          errorMessage =
              'Strava API access denied. Your API credentials may need to be updated.';
        }

        // Log the error and retry after delay
        debugPrint(
            'Network error (attempt $retryCount/$maxRetries): $errorMessage - $e');
        debugPrint('Retrying after ${delay.inSeconds} seconds...');

        await Future.delayed(delay);
        // Exponential backoff: 1s, 2s, 4s, etc.
        delay *= 2;
      }
    }
  }
}
