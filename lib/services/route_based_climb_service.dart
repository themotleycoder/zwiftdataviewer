import 'package:flutter/foundation.dart';
import 'package:zwiftdataviewer/models/climb_analysis.dart';
import 'package:zwiftdataviewer/utils/zwift_koms.dart';

/// Service for analyzing climbs using Zwift route data instead of GPS elevation analysis
///
/// This service provides a simpler and more accurate approach for Zwift activities:
/// 1. Parses the activity name to identify the Zwift route
/// 2. Looks up the route in the database
/// 3. Returns climbs associated with that route/world
///
/// This approach is:
/// - Faster (no GPS processing)
/// - More accurate (uses official Zwift data)
/// - Simpler (uses hardcoded Zwift KOM data)
class RouteBasedClimbService {
  /// Analyzes an activity using route-based approach with official Zwift KOMs
  ///
  /// Returns null if:
  /// - Activity name doesn't match a known Zwift world
  /// - No climbs found for the world
  Future<ActivityClimbAnalysis?> analyzeActivityByRoute({
    required int activityId,
    required String activityName,
    DateTime? startDate,
  }) async {
    try {
      debugPrint('RouteBasedClimbService: Analyzing activity $activityId: "$activityName"');

      // Get climbs for this activity based on its name
      final zwiftClimbs = ZwiftKoms.getClimbsForActivity(activityName);

      if (zwiftClimbs.isEmpty) {
        debugPrint('RouteBasedClimbService: No climbs found for activity name');
        return null;
      }

      debugPrint('RouteBasedClimbService: Found ${zwiftClimbs.length} climbs for activity');

      // Convert ZwiftClimb objects to ClimbWithSegments
      final climbsWithSegments = zwiftClimbs
          .map((climb) => climb.toClimbWithSegments())
          .toList();

      // Calculate total elevation gain
      final totalElevationGain = zwiftClimbs.fold<double>(
        0.0,
        (sum, climb) => sum + climb.elevationGain,
      );

      return ActivityClimbAnalysis(
        activityId: activityId,
        totalClimbs: zwiftClimbs.length,
        totalElevationGain: totalElevationGain,
        climbs: climbsWithSegments,
        analyzedAt: DateTime.now(),
      );
    } catch (e, stackTrace) {
      debugPrint('RouteBasedClimbService: Error analyzing activity: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Checks if an activity name looks like a Zwift activity
  bool isZwiftActivity(String activityName) {
    final zwiftPrefixes = [
      'Watopia',
      'France',
      'Makuri Islands',
      'London',
      'New York',
      'Innsbruck',
      'Richmond',
      'Yorkshire',
      'Scotland',
      'Paris',
    ];

    activityName = activityName.trim();
    return zwiftPrefixes.any((prefix) => activityName.contains(prefix));
  }
}
