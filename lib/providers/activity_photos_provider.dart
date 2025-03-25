import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/globals.dart' as globals;
import 'package:flutter_strava_api/globals.dart';
import 'package:flutter_strava_api/models/activity.dart';
import 'package:flutter_strava_api/strava.dart';
import 'package:path_provider/path_provider.dart';

import '../secrets.dart';
import '../utils/repository/filerepository.dart';
import '../utils/repository/webrepository.dart';
import 'activity_select_provider.dart';

/// Provider for activity photos
///
/// This provider fetches photos associated with the currently selected activity.
/// It uses either the file repository (in debug mode) or the web repository.
final photoActivitiesProvider =
    FutureProvider.autoDispose<List<PhotoActivity>>((ref) async {
  try {
    final FileRepository fileRepository = FileRepository();
    final cacheDir = await getApplicationDocumentsDirectory();
    final cache = Cache(cacheDir.path);
    final WebRepository webRepository =
        WebRepository(strava: Strava(isInDebug, clientSecret), cache: cache);
    final activityId = ref.read(selectedActivityProvider).id;

    if (activityId <= 0) {
      return [];
    }

    if (globals.isInDebug) {
      return fileRepository.loadActivityPhotos(activityId);
    } else {
      return webRepository.loadActivityPhotos(activityId);
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error loading activity photos: $e');
    }
    return []; // Return empty list on error
  }
});

/// Provider for activity photo URLs
///
/// This provider extracts the best available URL for each photo in the list.
/// It tries to get the highest resolution available.
final activityPhotoUrlsProvider = FutureProvider.autoDispose
    .family<List<String>, List<PhotoActivity>>((ref, photos) async {
  final List<String> imagesUrls = [];

  try {
    for (PhotoActivity image in photos) {
      if (image.urls == null) continue;

      // Try to get the highest resolution available
      String str = image.urls!['1800'] ??
          image.urls!['1000'] ??
          image.urls!['600'] ??
          image.urls!['200'] ??
          image.urls!['100'] ??
          image.urls!['50'] ??
          image.urls!['25'] ??
          image.urls!['10'] ??
          image.urls!['5'] ??
          image.urls!['3'] ??
          image.urls!['2'] ??
          image.urls!['1'] ??
          image.urls!['0'] ??
          '';

      if (str.isNotEmpty) {
        imagesUrls.add(str);
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error processing photo URLs: $e');
    }
  }

  return imagesUrls;
});
