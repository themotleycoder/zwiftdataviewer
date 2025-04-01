import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/api/streams.dart';
import 'package:flutter_strava_api/globals.dart' as globals;
import 'package:flutter_strava_api/globals.dart';
import 'package:flutter_strava_api/strava.dart';

import '../secrets.dart';
import '../utils/database/database_init.dart';
import '../utils/database/services/activity_service.dart';
import '../utils/repository/filerepository.dart';
import '../utils/repository/webrepository.dart';

/// Provider for activity streams data
///
/// This provider fetches stream data (time series data) for a specific activity.
/// It uses either the file repository (in debug mode) or the web repository.
/// The provider is auto-disposed when no longer needed and takes an activity ID parameter.
final streamsProvider = FutureProvider.autoDispose
    .family<StreamsDetailCollection, int>((ref, id) async {
  if (id <= 0) {
    return StreamsDetailCollection(); // Return empty collection for invalid ID
  }

  try {
    final FileRepository fileRepository = FileRepository();
    final WebRepository webRepository =
        WebRepository(strava: Strava(isInDebug, clientSecret), activityService: DatabaseInit.activityService);

    if (globals.isInDebug) {
      return await fileRepository.loadStreams(id);
    } else {
      return await webRepository.loadStreams(id);
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error in streamsProvider: $e');
    }
    // Return an empty StreamsDetailCollection in case of error
    return StreamsDetailCollection();
  }
});
