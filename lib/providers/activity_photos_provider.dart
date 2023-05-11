import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/stravalib/globals.dart' as globals;

import '../secrets.dart';
import '../stravalib/Models/activity.dart';
import '../stravalib/globals.dart';
import '../stravalib/strava.dart';
import '../utils/repository/filerepository.dart';
import '../utils/repository/webrepository.dart';
import 'activity_select_provider.dart';

class ActivityPhotosNotifier extends StateNotifier<List<PhotoActivity>> {
  ActivityPhotosNotifier() : super([]);

  final FileRepository? fileRepository = FileRepository();
  final WebRepository? webRepository =
  WebRepository(strava: Strava(isInDebug, secret));

  List<PhotoActivity> get activityPhotos => state;

  void setActivityPhotos(List<PhotoActivity> activityPhotos) {
    state = activityPhotos;
  }
}

final photoActivitiesProvider = FutureProvider.autoDispose<List<PhotoActivity>>((ref) async {
  final FileRepository fileRepository = FileRepository();
  final WebRepository webRepository =
  WebRepository(strava: Strava(isInDebug, secret));
  final activityId = ref
      .read(selectedActivityProvider)
      .id;

  if (globals.isInDebug) {
    return fileRepository.loadActivityPhotos(activityId!);
  } else {
    print('WOULD CALL WEB SVC NOW! - loadActivityPhotos');
    return webRepository.loadActivityPhotos(activityId!);
  }
});


final activityPhotoUrlsProvider = FutureProvider.autoDispose.family<List<String>, List<PhotoActivity>>((ref, photos) async {
  final List<String> imagesUrls = [];

  for (PhotoActivity image in photos) {
    String str = image.urls!["1800"] ??
        image.urls!["1000"] ??
        image.urls!["600"] ??
        image.urls!["200"] ??
        image.urls!["100"] ??
        image.urls!["50"] ??
        image.urls!["25"] ??
        image.urls!["10"] ??
        image.urls!["5"] ??
        image.urls!["3"] ??
        image.urls!["2"] ??
        image.urls!["1"] ??
        image.urls!["0"] ??
        "";
    imagesUrls
        .add(str); //.substring(0, str.lastIndexOf('-')) + "-768x419.jpg");
  }
  return imagesUrls;
});
