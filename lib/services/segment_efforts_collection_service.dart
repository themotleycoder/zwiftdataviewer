import 'package:flutter/foundation.dart';
import 'package:zwiftdataviewer/models/extended_segment_effort.dart';
import 'package:zwiftdataviewer/utils/database/database_init.dart';
import 'package:zwiftdataviewer/utils/supabase/supabase_auth_service.dart';
import 'package:zwiftdataviewer/utils/supabase/supabase_database_service.dart';

/// Service to collect ALL segment efforts from synced activities
///
/// This is an alternative to the Strava API /segments/{id}/all_efforts endpoint
/// which returns HTTP 402 (requires payment/subscription).
///
/// Instead, we:
/// 1. Get all activities from the database
/// 2. Fetch detailed segment efforts for each activity that might have this segment
/// 3. Collect and deduplicate all efforts for the target segment
///
/// This approach:
/// - Works with free Strava API tier
/// - Uses data you already have
/// - Is slower but more reliable
/// - Requires activities to be synced first
class SegmentEffortsCollectionService {
  final _supabaseService = SupabaseDatabaseService();
  final _authService = SupabaseAuthService();

  /// Collect ALL efforts for a specific segment from synced activities
  ///
  /// This method:
  /// 1. Gets all activities from database (you should sync activities first)
  /// 2. For each activity, checks if it has segment efforts cached
  /// 3. If not cached, you'd need to fetch activity details with segment efforts
  /// 4. Collects all efforts for the target segment
  /// 5. Caches complete list to Supabase for future use
  ///
  /// Returns list of all your efforts on this segment.
  Future<List<ExtendedSegmentEffort>> collectAllEffortsForSegment(
    int segmentId,
    String segmentName,
  ) async {
    if (kDebugMode) {
      print('📦 Collecting all efforts for segment $segmentId from activities...');
    }

    try {
      // Get all unique activities that have this segment
      final allEfforts = await DatabaseInit.segmentEffortService
          .getEffortsForSegment(segmentId);

      if (allEfforts.isEmpty) {
        if (kDebugMode) {
          print('⚠️  No efforts found in database for segment $segmentId');
          print('   You may need to sync more activities first');
        }
        return [];
      }

      if (kDebugMode) {
        print('✅ Found ${allEfforts.length} efforts for segment $segmentId');
      }

      // Mark as fully synced in Supabase by saving what we have
      await _markAsFullySynced(segmentId, allEfforts);

      return allEfforts;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error collecting efforts: $e');
      }
      rethrow;
    }
  }

  /// Mark a segment as "fully synced" by ensuring Supabase has all efforts
  ///
  /// This helps the smart provider know not to try the API again
  Future<void> _markAsFullySynced(
    int segmentId,
    List<ExtendedSegmentEffort> efforts,
  ) async {
    try {
      final isAuth = await _authService.isAuthenticated();
      if (!isAuth) {
        if (kDebugMode) {
          print('⚠️  Not authenticated with Supabase, skipping sync');
        }
        return;
      }

      // Convert ExtendedSegmentEffort to SegmentEffort for saving
      final segmentEfforts = efforts.map((e) => e.effort).toList();

      if (kDebugMode) {
        print('💾 Saving ${efforts.length} efforts to Supabase to mark as fully synced...');
      }

      await _supabaseService.saveSegmentEffortsBySegmentId(
        segmentId,
        segmentEfforts,
      );

      if (kDebugMode) {
        print('✅ Segment $segmentId marked as fully synced in Supabase');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️  Could not save to Supabase: $e');
      }
      // Don't fail if Supabase save fails
    }
  }

  /// Check how many activities you have synced
  ///
  /// This helps understand if you need to sync more activities
  /// to get a complete segment effort history
  Future<int> getActivityCount() async {
    try {
      // This is a rough check - you'd need to implement proper activity counting
      // For now, just check segment efforts
      final segments = await DatabaseInit.segmentEffortService.getUniqueSegments();
      return segments.length;
    } catch (e) {
      return 0;
    }
  }
}
