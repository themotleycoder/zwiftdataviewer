import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/models/extended_segment_effort.dart';
import 'package:zwiftdataviewer/utils/database/database_init.dart';

// Provider for all unique segments
final uniqueSegmentsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    return await DatabaseInit.segmentEffortService.getUniqueSegments();
  } catch (e) {
    if (kDebugMode) {
      print('Error loading unique segments: $e');
    }
    return [];
  }
});

// Provider for the selected segment ID
final selectedSegmentIdProvider = StateProvider<int?>((ref) => null);

// Provider for segment efforts for the selected segment
final segmentEffortsProvider = FutureProvider<List<ExtendedSegmentEffort>>((ref) async {
  final segmentId = ref.watch(selectedSegmentIdProvider);
  
  if (segmentId == null) {
    return [];
  }
  
  try {
    final efforts = await DatabaseInit.segmentEffortService.getEffortsForSegment(segmentId);
    
    return efforts;
  } catch (e) {
    return [];
  }
});

// Provider for segment efforts by name
final segmentEffortsByNameProvider = FutureProvider.family<List<ExtendedSegmentEffort>, String>((ref, segmentName) async {
  try {
    return await DatabaseInit.segmentEffortService.getEffortsForSegmentByName(segmentName);
  } catch (e) {
    return [];
  }
});

// Provider for segment efforts for a specific activity
final activitySegmentEffortsProvider = FutureProvider.family<List<ExtendedSegmentEffort>, int>((ref, activityId) async {
  try {
    return await DatabaseInit.segmentEffortService.getSegmentEffortsForActivity(activityId);
  } catch (e) {
    return [];
  }
});

// Provider for the best effort for a segment
final bestSegmentEffortProvider = FutureProvider.family<ExtendedSegmentEffort?, int>((ref, segmentId) async {
  try {
    return await DatabaseInit.segmentEffortService.getBestEffortForSegment(segmentId);
  } catch (e) {
    return null;
  }
});

// Provider for segment efforts statistics
final segmentEffortsStatisticsProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, segmentId) async {
  try {
    return await DatabaseInit.segmentEffortService.getSegmentEffortsStatistics(segmentId);
  } catch (e) {
    return {};
  }
});

// Class to hold pagination parameters
class PaginationParams {
  final int segmentId;
  final int limit;
  final int offset;
  final String orderBy;

  PaginationParams({
    required this.segmentId,
    this.limit = 10,
    this.offset = 0,
    this.orderBy = 'elapsed_time ASC',
  });
}

// Provider for segment efforts with pagination
final paginatedSegmentEffortsProvider = FutureProvider.family<List<ExtendedSegmentEffort>, PaginationParams>(
  (ref, params) async {
    try {
      return await DatabaseInit.segmentEffortService.getSegmentEffortsWithPagination(
        params.segmentId,
        limit: params.limit,
        offset: params.offset,
        orderBy: params.orderBy,
      );
    } catch (e) {
      return [];
    }
  }
);

// Provider for segment efforts count
final segmentEffortsCountProvider = FutureProvider.family<int, int>((ref, segmentId) async {
  try {
    return await DatabaseInit.segmentEffortService.getSegmentEffortsCount(segmentId);
  } catch (e) {
    return 0;
  }
});

// Class to hold date range parameters
class DateRangeParams {
  final int segmentId;
  final String startDate;
  final String endDate;

  DateRangeParams({
    required this.segmentId,
    required this.startDate,
    required this.endDate,
  });
}

// Provider for segment efforts by date range
final segmentEffortsByDateRangeProvider = FutureProvider.family<List<ExtendedSegmentEffort>, DateRangeParams>(
  (ref, params) async {
    try {
      return await DatabaseInit.segmentEffortService.getSegmentEffortsByDateRange(
        params.segmentId,
        params.startDate,
        params.endDate,
      );
    } catch (e) {
      return [];
    }
  }
);
