import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/models/climb_analysis.dart';
import 'package:zwiftdataviewer/services/activity_climb_analysis_service.dart';
import 'package:zwiftdataviewer/services/route_based_climb_service.dart';
import 'package:zwiftdataviewer/utils/database/database_init.dart';
import 'package:zwiftdataviewer/utils/supabase/supabase_auth_service.dart';
import 'package:zwiftdataviewer/utils/supabase/supabase_database_service.dart';

/// Provider for climb analysis service
final climbAnalysisServiceProvider = Provider<ActivityClimbAnalysisService>((ref) {
  return ActivityClimbAnalysisService();
});

/// Provider for route-based climb service
final routeBasedClimbServiceProvider = Provider<RouteBasedClimbService>((ref) {
  return RouteBasedClimbService();
});

/// Provider for getting climb analysis for a specific activity
///
/// This provider follows the hybrid cache-aside pattern:
/// 1. Check SQLite cache first
/// 2. If not found and online, check Supabase
/// 3. If not found anywhere, perform analysis
/// 4. Store results in both SQLite and Supabase
final climbAnalysisProvider = FutureProvider.family<ActivityClimbAnalysis?, int>(
  (ref, activityId) async {
    try {
      // Step 1: Check SQLite cache
      final sqliteAnalysis = await DatabaseInit.climbAnalysisService
          .getClimbAnalysisByActivityId(activityId);

      if (sqliteAnalysis != null) {
        if (kDebugMode) {
          debugPrint('Climb analysis found in SQLite for activity $activityId');
        }
        return sqliteAnalysis;
      }

      // Step 2: Check Supabase if authenticated
      final authService = SupabaseAuthService();
      final isAuthenticated = await authService.isAuthenticated();

      if (isAuthenticated) {
        final supabaseService = SupabaseDatabaseService();
        final supabaseAnalysis = await supabaseService.getClimbAnalysis(activityId);

        if (supabaseAnalysis != null) {
          if (kDebugMode) {
            debugPrint('Climb analysis found in Supabase for activity $activityId');
          }

          // Cache in SQLite
          await DatabaseInit.climbAnalysisService
              .saveClimbAnalysis(supabaseAnalysis);

          return supabaseAnalysis;
        }
      }

      // Step 3: Analysis not found anywhere - perform analysis
      if (kDebugMode) {
        debugPrint('No cached analysis found, analyzing activity $activityId');
      }

      // Try to get activity details to check if it's a Zwift activity
      ActivityClimbAnalysis? analysis;

      try {
        // Get activity details from SQLite to check the name
        final activityService = DatabaseInit.activityService;
        final activity = await activityService.getActivityById(activityId);

        if (activity != null && activity.name != null) {
          final routeService = ref.read(routeBasedClimbServiceProvider);

          // Check if it's a Zwift activity
          if (routeService.isZwiftActivity(activity.name)) {
            if (kDebugMode) {
              debugPrint('Detected Zwift activity, using route-based analysis');
            }

            // Try route-based analysis first
            analysis = await routeService.analyzeActivityByRoute(
              activityId: activityId,
              activityName: activity.name,
              startDate: activity.startDate,
            );

            if (analysis != null) {
              if (kDebugMode) {
                debugPrint('Route-based analysis successful for activity $activityId');
              }
            } else {
              if (kDebugMode) {
                debugPrint('Route-based analysis returned null, falling back to GPS analysis');
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Error trying route-based analysis: $e');
        // Fall through to GPS-based analysis
      }

      // If route-based analysis didn't work or wasn't applicable, use GPS-based
      if (analysis == null) {
        if (kDebugMode) {
          debugPrint('Using GPS-based elevation analysis');
        }
        final analysisService = ref.read(climbAnalysisServiceProvider);
        analysis = await analysisService.analyzeActivity(activityId);
      }

      // Step 4: Store results
      // Save to SQLite
      await DatabaseInit.climbAnalysisService.saveClimbAnalysis(analysis);

      // Save to Supabase if authenticated
      if (isAuthenticated) {
        try {
          final supabaseService = SupabaseDatabaseService();
          await supabaseService.saveClimbAnalysis(analysis);
        } catch (e) {
          debugPrint('Failed to save climb analysis to Supabase: $e');
          // Continue even if Supabase save fails
        }
      }

      return analysis;
    } catch (e, stackTrace) {
      debugPrint('Error in climbAnalysisProvider for activity $activityId: $e');
      debugPrint('Stack trace: $stackTrace');
      // Return null instead of throwing to allow UI to handle gracefully
      return null;
    }
  },
);

/// Provider for forcing re-analysis of an activity
///
/// This deletes cached results and performs a fresh analysis.
/// Use this when you want to recalculate climbs (e.g., after changing parameters).
final reanalyzeActivityProvider = FutureProvider.family<ActivityClimbAnalysis?, int>(
  (ref, activityId) async {
    try {
      // Delete existing analysis from caches
      await DatabaseInit.climbAnalysisService.deleteClimbAnalysis(activityId);

      final authService = SupabaseAuthService();
      final isAuthenticated = await authService.isAuthenticated();

      if (isAuthenticated) {
        try {
          final supabaseService = SupabaseDatabaseService();
          await supabaseService.deleteClimbAnalysis(activityId);
        } catch (e) {
          debugPrint('Failed to delete climb analysis from Supabase: $e');
        }
      }

      // Perform fresh analysis
      // Try to get activity details to check if it's a Zwift activity
      ActivityClimbAnalysis? analysis;

      try {
        // Get activity details from SQLite to check the name
        final activityService = DatabaseInit.activityService;
        final activity = await activityService.getActivityById(activityId);

        if (activity != null && activity.name != null) {
          final routeService = ref.read(routeBasedClimbServiceProvider);

          // Check if it's a Zwift activity
          if (routeService.isZwiftActivity(activity.name)) {
            if (kDebugMode) {
              debugPrint('Reanalyzing Zwift activity, using route-based analysis');
            }

            // Try route-based analysis first
            analysis = await routeService.analyzeActivityByRoute(
              activityId: activityId,
              activityName: activity.name,
              startDate: activity.startDate,
            );
          }
        }
      } catch (e) {
        debugPrint('Error trying route-based reanalysis: $e');
        // Fall through to GPS-based analysis
      }

      // If route-based analysis didn't work or wasn't applicable, use GPS-based
      if (analysis == null) {
        final analysisService = ref.read(climbAnalysisServiceProvider);
        analysis = await analysisService.analyzeActivity(activityId);
      }

      // Save new results
      await DatabaseInit.climbAnalysisService.saveClimbAnalysis(analysis);

      if (isAuthenticated) {
        try {
          final supabaseService = SupabaseDatabaseService();
          await supabaseService.saveClimbAnalysis(analysis);
        } catch (e) {
          debugPrint('Failed to save climb analysis to Supabase: $e');
        }
      }

      return analysis;
    } catch (e, stackTrace) {
      debugPrint('Error in reanalyzeActivityProvider for activity $activityId: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  },
);

/// Provider for checking if an activity has been analyzed
final hasClimbAnalysisProvider = FutureProvider.family<bool, int>(
  (ref, activityId) async {
    try {
      return await DatabaseInit.climbAnalysisService.hasClimbAnalysis(activityId);
    } catch (e) {
      debugPrint('Error checking if activity $activityId has climb analysis: $e');
      return false;
    }
  },
);

/// Provider for getting climb analysis statistics
final climbAnalysisStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    return await DatabaseInit.climbAnalysisService.getStatistics();
  } catch (e) {
    debugPrint('Error getting climb analysis statistics: $e');
    return {};
  }
});
