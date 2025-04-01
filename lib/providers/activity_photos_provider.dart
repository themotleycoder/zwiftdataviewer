import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/globals.dart' as globals;
import 'package:flutter_strava_api/globals.dart';
import 'package:flutter_strava_api/models/activity.dart';
import 'package:flutter_strava_api/strava.dart';

import '../secrets.dart';
import '../utils/database/database_init.dart';
import '../utils/repository/filerepository.dart';
import '../utils/repository/webrepository.dart';
import 'activity_select_provider.dart';

// Provider for activity photos
//
// This provider fetches photos associated with the currently selected activity.
// It uses either the file repository (in debug mode) or the web repository.
final photoActivitiesProvider =
    FutureProvider.autoDispose<List<PhotoActivity>>((ref) async {
  try {
    final FileRepository fileRepository = FileRepository();
    final WebRepository webRepository =
        WebRepository(strava: Strava(isInDebug, clientSecret), activityService: DatabaseInit.activityService);
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

// Provider for activity photo URLs
//
// This provider extracts the best available URL for each photo in the list.
// It tries to get the highest resolution available.
final activityPhotoUrlsProvider = FutureProvider.autoDispose
    .family<List<String>, List<PhotoActivity>>((ref, photos) async {
  final List<String> imagesUrls = [];

  try {
    if (photos.isEmpty) {
      if (kDebugMode) {
        print('No photos provided to activityPhotoUrlsProvider');
      }
      return imagesUrls;
    }

    for (int i = 0; i < photos.length; i++) {
      try {
        final PhotoActivity image = photos[i];
        
        // Skip photos with null or empty URLs
        if (image.urls == null || image.urls!.isEmpty) {
          if (kDebugMode) {
            print('Photo at index $i has null or empty URLs');
          }
          continue;
        }

        // Try to get the highest resolution available
        final Map<dynamic, dynamic> rawUrls = image.urls!;
        
        // List of resolutions to try, from highest to lowest
        final resolutions = ['1800', '1000', '600', '200', '100', '50', '25', '10', '5', '3', '2', '1', '0'];
        
        String? photoUrl;
        for (final resolution in resolutions) {
          if (rawUrls.containsKey(resolution) && 
              rawUrls[resolution] != null && 
              rawUrls[resolution] is String && 
              rawUrls[resolution].isNotEmpty) {
            photoUrl = rawUrls[resolution] as String;
            break;
          }
        }

        if (photoUrl != null && photoUrl.isNotEmpty) {
          imagesUrls.add(photoUrl);
        } else {
          if (kDebugMode) {
            print('No valid URL found for photo at index $i');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error processing photo at index $i: $e');
          print('Photo data: ${photos[i].urls}');
        }
        // Continue with other photos
        continue;
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error processing photo URLs: $e');
    }
  }

  return imagesUrls;
});
