import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_strava_api/globals.dart' as globals;
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:http/http.dart' as http;
import 'package:zwiftdataviewer/models/climb_analysis.dart';
import 'package:zwiftdataviewer/utils/geospatial/geospatial_utils.dart';

/// Service for analyzing climbs in activities
class ActivityClimbAnalysisService {
  static const String _baseUrl = 'https://www.strava.com/api/v3';

  // Climb detection parameters
  static const double minGradient = 2.0; // Minimum sustained gradient (%)
  static const double minDistance = 250.0; // Minimum climb distance (meters)
  static const double minElevationGain = 25.0; // Minimum elevation gain (meters)
  static const double mergeThresholdMeters = 200.0; // Merge climbs separated by < 200m descent
  static const int smoothingWindowMeters = 100; // Smooth grade data over 100m windows

  // Segment matching parameters
  static const double overlapThreshold = 60.0; // Minimum overlap percentage for matching
  static const double segmentProximityMeters = 50.0; // Distance threshold for overlap calculation

  /// Main entry point: Analyzes an activity and returns climb analysis
  Future<ActivityClimbAnalysis> analyzeActivity(int activityId) async {
    debugPrint('Starting climb analysis for activity $activityId');

    try {
      // Step 1: Fetch activity streams
      final streams = await _fetchActivityStreams(activityId);

      // Step 2: Detect climbs from elevation data
      final climbs = _detectClimbs(streams);

      if (climbs.isEmpty) {
        debugPrint('No climbs detected for activity $activityId');
        return ActivityClimbAnalysis(
          activityId: activityId,
          totalClimbs: 0,
          totalElevationGain: 0.0,
          climbs: [],
          analyzedAt: DateTime.now(),
        );
      }

      debugPrint('Detected ${climbs.length} climbs');

      // Step 3 & 4: Match segments to each climb
      final climbsWithSegments = await _matchSegmentsToClimbs(climbs);

      // Step 5: Create analysis result
      final totalElevationGain = climbs.fold<double>(
        0.0,
        (sum, climb) => sum + climb.elevationGain,
      );

      final analysis = ActivityClimbAnalysis(
        activityId: activityId,
        totalClimbs: climbs.length,
        totalElevationGain: totalElevationGain,
        climbs: climbsWithSegments,
        analyzedAt: DateTime.now(),
      );

      debugPrint('Analysis complete: ${analysis.totalClimbs} climbs, ${analysis.totalElevationGain}m gain');

      return analysis;
    } catch (e, stackTrace) {
      debugPrint('Error analyzing activity $activityId: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Fetches activity streams from Strava API
  Future<Map<String, List<dynamic>>> _fetchActivityStreams(int activityId) async {
    final accessToken = globals.token.accessToken;

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('No valid Strava access token available. Please authenticate with Strava.');
    }

    // Check connectivity
    if (!await _checkConnectivity()) {
      throw Exception('No internet connection available. Please check your network settings.');
    }

    // Request these stream types: latlng, altitude, distance, grade_smooth
    final streamTypes = ['latlng', 'altitude', 'distance', 'grade_smooth'];
    final url = Uri.parse(
      '$_baseUrl/activities/$activityId/streams?keys=${streamTypes.join(',')}&key_by_type=true',
    );

    debugPrint('Fetching streams for activity $activityId');

    final response = await _retryHttpRequest(
      () => http.get(
        url,
        headers: {'Authorization': 'Bearer $accessToken'},
      ),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> streamsJson = jsonDecode(response.body);
      final streams = <String, List<dynamic>>{};

      // Parse each stream type
      for (final streamType in streamTypes) {
        if (streamsJson.containsKey(streamType)) {
          final streamData = streamsJson[streamType];
          if (streamData is Map && streamData.containsKey('data')) {
            streams[streamType] = streamData['data'] as List<dynamic>;
          }
        }
      }

      // Validate we have required streams
      if (!streams.containsKey('altitude') || !streams.containsKey('distance')) {
        throw Exception('Activity does not contain required elevation data');
      }

      debugPrint('Successfully fetched streams: ${streams.keys.join(', ')}');
      return streams;
    } else {
      throw Exception('Failed to fetch activity streams: ${response.statusCode}');
    }
  }

  /// Detects climbs from activity streams
  List<DetectedClimb> _detectClimbs(Map<String, List<dynamic>> streams) {
    final altitudes = streams['altitude']!.map((a) => (a as num).toDouble()).toList();
    final distances = streams['distance']!.map((d) => (d as num).toDouble()).toList();
    final latlngs = streams['latlng'] != null
        ? streams['latlng']!
            .map((ll) => gmaps.LatLng(
                  (ll[0] as num).toDouble(),
                  (ll[1] as num).toDouble(),
                ))
            .toList()
        : <gmaps.LatLng>[];

    if (altitudes.length != distances.length) {
      throw Exception('Altitude and distance streams have different lengths');
    }

    // Calculate grades if not provided
    List<double> grades;
    if (streams.containsKey('grade_smooth')) {
      grades = streams['grade_smooth']!.map((g) => (g as num).toDouble()).toList();
    } else {
      grades = _calculateGrades(altitudes, distances);
    }

    // Smooth grades over specified window
    final smoothedGrades = _smoothGradesOverDistance(grades, distances, smoothingWindowMeters.toDouble());

    // Identify climb sections
    final climbSections = _identifyClimbSections(
      altitudes,
      distances,
      smoothedGrades,
      latlngs,
    );

    // Merge close climbs
    final mergedClimbs = _mergeClimbs(climbSections, altitudes);

    debugPrint('Detected ${climbSections.length} raw climbs, merged to ${mergedClimbs.length}');

    return mergedClimbs;
  }

  /// Calculates grade percentages from altitude and distance
  List<double> _calculateGrades(List<double> altitudes, List<double> distances) {
    List<double> grades = [0.0];

    for (int i = 1; i < altitudes.length; i++) {
      final dAlt = altitudes[i] - altitudes[i - 1];
      final dDist = distances[i] - distances[i - 1];

      if (dDist > 0) {
        grades.add((dAlt / dDist) * 100.0);
      } else {
        grades.add(0.0);
      }
    }

    return grades;
  }

  /// Smooths grade data over a specified distance window
  List<double> _smoothGradesOverDistance(
    List<double> grades,
    List<double> distances,
    double windowMeters,
  ) {
    List<double> smoothed = [];

    for (int i = 0; i < grades.length; i++) {
      final centerDist = distances[i];
      final windowStart = centerDist - windowMeters / 2;
      final windowEnd = centerDist + windowMeters / 2;

      double sum = 0.0;
      int count = 0;

      for (int j = 0; j < grades.length; j++) {
        if (distances[j] >= windowStart && distances[j] <= windowEnd) {
          sum += grades[j];
          count++;
        }
      }

      smoothed.add(count > 0 ? sum / count.toDouble() : grades[i]);
    }

    return smoothed;
  }

  /// Identifies climb sections based on gradient and distance criteria
  List<DetectedClimb> _identifyClimbSections(
    List<double> altitudes,
    List<double> distances,
    List<double> grades,
    List<gmaps.LatLng> latlngs,
  ) {
    List<DetectedClimb> climbs = [];
    int? climbStart;
    double climbElevationGain = 0.0;
    double maxGradient = 0.0;
    int potentialClimbs = 0;
    int rejectedByDistance = 0;
    int rejectedByElevation = 0;

    debugPrint('Climb detection: Processing ${grades.length} data points');
    debugPrint('Criteria: minGradient=$minGradient%, minDistance=${minDistance}m, minElevation=${minElevationGain}m');

    for (int i = 0; i < grades.length; i++) {
      final grade = grades[i];

      if (grade >= minGradient) {
        // Start or continue a climb
        if (climbStart == null) {
          climbStart = i;
          climbElevationGain = 0.0;
          maxGradient = grade;
          debugPrint('Potential climb started at index $i (distance: ${distances[i].toStringAsFixed(0)}m, grade: ${grade.toStringAsFixed(1)}%)');
        }

        // Update climb stats
        if (i > 0) {
          final elevChange = altitudes[i] - altitudes[i - 1];
          if (elevChange > 0) {
            climbElevationGain += elevChange;
          }
        }

        if (grade > maxGradient) {
          maxGradient = grade;
        }
      } else {
        // End a climb
        if (climbStart != null) {
          potentialClimbs++;
          final climbDistance = distances[i - 1] - distances[climbStart];

          debugPrint('Potential climb ended: distance=${climbDistance.toStringAsFixed(0)}m, elevation=${climbElevationGain.toStringAsFixed(1)}m');

          // Check if climb meets minimum criteria
          if (climbDistance >= minDistance && climbElevationGain >= minElevationGain) {
            final climbPoints = latlngs.isNotEmpty
                ? latlngs.sublist(climbStart, i)
                : <gmaps.LatLng>[];

            if (climbPoints.isNotEmpty) {
              final avgGradient = (climbElevationGain / climbDistance) * 100.0;

              debugPrint('✓ Climb ACCEPTED: ${climbDistance.toStringAsFixed(0)}m, ${climbElevationGain.toStringAsFixed(1)}m gain, ${avgGradient.toStringAsFixed(1)}% avg');

              climbs.add(DetectedClimb(
                startIndex: climbStart,
                endIndex: i - 1,
                distance: climbDistance,
                elevationGain: climbElevationGain,
                avgGradient: avgGradient,
                maxGradient: maxGradient,
                points: climbPoints,
                bounds: GeoBounds.fromPoints(climbPoints),
              ));
            }
          } else {
            if (climbDistance < minDistance) {
              rejectedByDistance++;
              debugPrint('✗ Climb REJECTED (distance): ${climbDistance.toStringAsFixed(0)}m < ${minDistance}m');
            }
            if (climbElevationGain < minElevationGain) {
              rejectedByElevation++;
              debugPrint('✗ Climb REJECTED (elevation): ${climbElevationGain.toStringAsFixed(1)}m < ${minElevationGain}m');
            }
          }

          climbStart = null;
        }
      }
    }

    // Handle climb that goes to the end of the activity
    if (climbStart != null) {
      potentialClimbs++;
      final i = grades.length - 1;
      final climbDistance = distances[i] - distances[climbStart];

      debugPrint('Potential climb at end: distance=${climbDistance.toStringAsFixed(0)}m, elevation=${climbElevationGain.toStringAsFixed(1)}m');

      if (climbDistance >= minDistance && climbElevationGain >= minElevationGain) {
        final climbPoints = latlngs.isNotEmpty
            ? latlngs.sublist(climbStart, i + 1)
            : <gmaps.LatLng>[];

        if (climbPoints.isNotEmpty) {
          final avgGradient = (climbElevationGain / climbDistance) * 100.0;

          debugPrint('✓ Climb ACCEPTED (at end): ${climbDistance.toStringAsFixed(0)}m, ${climbElevationGain.toStringAsFixed(1)}m gain, ${avgGradient.toStringAsFixed(1)}% avg');

          climbs.add(DetectedClimb(
            startIndex: climbStart,
            endIndex: i,
            distance: climbDistance,
            elevationGain: climbElevationGain,
            avgGradient: avgGradient,
            maxGradient: maxGradient,
            points: climbPoints,
            bounds: GeoBounds.fromPoints(climbPoints),
          ));
        }
      } else {
        if (climbDistance < minDistance) {
          rejectedByDistance++;
          debugPrint('✗ Climb REJECTED (distance): ${climbDistance.toStringAsFixed(0)}m < ${minDistance}m');
        }
        if (climbElevationGain < minElevationGain) {
          rejectedByElevation++;
          debugPrint('✗ Climb REJECTED (elevation): ${climbElevationGain.toStringAsFixed(1)}m < ${minElevationGain}m');
        }
      }
    }

    debugPrint('Climb detection summary: $potentialClimbs potential, ${climbs.length} accepted, $rejectedByDistance rejected by distance, $rejectedByElevation rejected by elevation');

    return climbs;
  }

  /// Merges climbs that are separated by less than the threshold descent
  List<DetectedClimb> _mergeClimbs(
    List<DetectedClimb> climbs,
    List<double> altitudes,
  ) {
    if (climbs.length <= 1) return climbs;

    List<DetectedClimb> merged = [];
    DetectedClimb? currentClimb = climbs[0];

    for (int i = 1; i < climbs.length; i++) {
      final nextClimb = climbs[i];

      // Check descent between climbs
      final descentStart = currentClimb!.endIndex;
      final descentEnd = nextClimb.startIndex;

      if (descentEnd > descentStart) {
        final elevationAtStart = altitudes[descentStart];
        final elevationAtEnd = altitudes[descentEnd];
        final descent = elevationAtStart - elevationAtEnd;

        // Merge if descent is less than threshold
        if (descent < mergeThresholdMeters) {
          final mergedPoints = [...currentClimb.points, ...nextClimb.points];
          final totalDistance = currentClimb.distance + nextClimb.distance;
          final totalElevationGain = currentClimb.elevationGain + nextClimb.elevationGain;
          final avgGradient = (totalElevationGain / totalDistance) * 100.0;
          final maxGradient = currentClimb.maxGradient > nextClimb.maxGradient
              ? currentClimb.maxGradient
              : nextClimb.maxGradient;

          currentClimb = DetectedClimb(
            startIndex: currentClimb.startIndex,
            endIndex: nextClimb.endIndex,
            distance: totalDistance,
            elevationGain: totalElevationGain,
            avgGradient: avgGradient,
            maxGradient: maxGradient,
            points: mergedPoints,
            bounds: GeoBounds.fromPoints(mergedPoints),
          );

          continue;
        }
      }

      // No merge, add current climb and move to next
      merged.add(currentClimb);
      currentClimb = nextClimb;
    }

    // Add the last climb
    merged.add(currentClimb!);

    return merged;
  }

  /// Matches Strava segments to detected climbs
  Future<List<ClimbWithSegments>> _matchSegmentsToClimbs(
    List<DetectedClimb> climbs,
  ) async {
    List<ClimbWithSegments> result = [];

    for (final climb in climbs) {
      debugPrint('Matching segments for climb ${climb.distance}m, ${climb.elevationGain}m gain');

      try {
        final segments = await _querySegmentsForClimb(climb);
        final matchedSegments = await _matchSegmentsToClimb(climb, segments);

        result.add(ClimbWithSegments(
          climb: climb,
          segments: matchedSegments,
        ));

        debugPrint('Found ${matchedSegments.length} matching segments');
      } catch (e) {
        debugPrint('Error matching segments for climb: $e');
        // Continue with empty segments list
        result.add(ClimbWithSegments(
          climb: climb,
          segments: [],
        ));
      }

      // Rate limiting: delay between requests
      await Future.delayed(const Duration(milliseconds: 500));
    }

    return result;
  }

  /// Queries Strava segments/explore API for a climb's bounding box
  Future<List<Map<String, dynamic>>> _querySegmentsForClimb(
    DetectedClimb climb,
  ) async {
    final accessToken = globals.token.accessToken;

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('No valid Strava access token available');
    }

    // Build bounding box with small margin
    final bounds = {
      'minLat': climb.bounds.minLat,
      'maxLat': climb.bounds.maxLat,
      'minLng': climb.bounds.minLng,
      'maxLng': climb.bounds.maxLng,
    };

    final expandedBounds = GeospatialUtils.expandBounds(bounds, marginDegrees: 0.005);

    // Query segments/explore API with categorized climbs only
    final url = Uri.parse(
      '$_baseUrl/segments/explore?'
      'bounds=${expandedBounds['minLat']},${expandedBounds['minLng']},${expandedBounds['maxLat']},${expandedBounds['maxLng']}'
      '&activity_type=riding'
      '&min_cat=0&max_cat=4',
    );

    debugPrint('Querying segments: $url');

    final response = await _retryHttpRequest(
      () => http.get(
        url,
        headers: {'Authorization': 'Bearer $accessToken'},
      ),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> result = jsonDecode(response.body);
      final segments = result['segments'] as List<dynamic>? ?? [];

      return segments.map((s) => s as Map<String, dynamic>).toList();
    } else {
      debugPrint('Failed to query segments: ${response.statusCode}');
      return [];
    }
  }

  /// Matches segments to a climb based on polyline overlap
  Future<List<MatchedSegment>> _matchSegmentsToClimb(
    DetectedClimb climb,
    List<Map<String, dynamic>> segments,
  ) async {
    List<MatchedSegment> matched = [];

    for (final segmentJson in segments) {
      try {
        final polylineEncoded = segmentJson['points'] as String?;
        if (polylineEncoded == null || polylineEncoded.isEmpty) {
          continue;
        }

        // Decode segment polyline
        final segmentPoints = GeospatialUtils.decodePolyline(polylineEncoded);

        // Calculate overlap percentage
        final overlapPct = GeospatialUtils.calculateBidirectionalOverlap(
          climb.points,
          segmentPoints,
          thresholdMeters: segmentProximityMeters,
        );

        // Only include segments with sufficient overlap
        if (overlapPct >= overlapThreshold) {
          matched.add(MatchedSegment(
            segmentId: segmentJson['id'] as int,
            name: segmentJson['name'] as String,
            overlapPercentage: overlapPct,
            climbCategory: segmentJson['climb_category'] as int?,
            distance: (segmentJson['distance'] as num).toDouble(),
            avgGrade: (segmentJson['avg_grade'] as num).toDouble(),
            elevationGain: (segmentJson['elev_difference'] as num).toDouble(),
            maxGrade: segmentJson['max_grade'] != null
                ? (segmentJson['max_grade'] as num).toDouble()
                : null,
            athleteEffortCount: segmentJson['effort_count'] as int?,
            athletePrTime: segmentJson['pr_time'] as int?,
            polyline: polylineEncoded,
          ));
        }
      } catch (e) {
        debugPrint('Error processing segment ${segmentJson['id']}: $e');
        continue;
      }
    }

    // Sort by overlap percentage (descending)
    matched.sort((a, b) => b.overlapPercentage.compareTo(a.overlapPercentage));

    return matched;
  }

  /// Check connectivity
  Future<bool> _checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return false;
      }

      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          return true;
        }
      } on SocketException catch (_) {
        return false;
      }

      return false;
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      return false;
    }
  }

  /// Retry HTTP request with exponential backoff
  Future<http.Response> _retryHttpRequest(
    Future<http.Response> Function() requestFn, {
    int maxRetries = 3,
  }) async {
    int retryCount = 0;
    Duration delay = const Duration(seconds: 1);

    while (true) {
      try {
        if (!await _checkConnectivity()) {
          throw const SocketException('No internet connection available');
        }

        final response = await requestFn();

        if (response.statusCode == 401) {
          throw Exception('Strava authentication expired. Please re-authenticate.');
        } else if (response.statusCode == 403) {
          throw Exception('Strava API access denied (403)');
        } else if (response.statusCode == 429) {
          // Rate limited - wait longer
          debugPrint('Rate limited, waiting 60 seconds...');
          await Future.delayed(const Duration(seconds: 60));
          continue;
        }

        return response;
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          rethrow;
        }

        debugPrint('Request error (attempt $retryCount/$maxRetries): $e');
        debugPrint('Retrying after ${delay.inSeconds} seconds...');

        await Future.delayed(delay);
        delay *= 2;
      }
    }
  }
}
