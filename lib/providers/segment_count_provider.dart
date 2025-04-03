import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/utils/database/database_init.dart';

// Provider for the count of unique segments
final segmentCountProvider = FutureProvider<int>((ref) async {
  try {
    final segments = await DatabaseInit.segmentEffortService.getUniqueSegments();
    return segments.length;
  } catch (e) {
    if (kDebugMode) {
      print('Error loading segment count: $e');
    }
    return 0;
  }
});
