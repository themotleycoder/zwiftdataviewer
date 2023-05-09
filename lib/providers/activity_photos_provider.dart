import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/stravalib/globals.dart' as globals;

import '../secrets.dart';
import '../stravalib/Models/activity.dart';
import '../stravalib/globals.dart';
import '../stravalib/strava.dart';
import '../utils/repository/filerepository.dart';
import '../utils/repository/webrepository.dart';

class ActivityPhotosNotifier extends StateNotifier<List<PhotoActivity>> {
  ActivityPhotosNotifier() : super([]);

  final FileRepository? fileRepository = FileRepository();
  final WebRepository? webRepository =
      WebRepository(strava: Strava(isInDebug, secret));

  List<PhotoActivity> get activityPhotos => state;

  void setActivityPhotos(List<PhotoActivity> activityPhotos) {
    state = activityPhotos;
  }

  // final WebRepository webRepository;
  // final FileRepository fileRepository;
  // List<PhotoActivity>? _photoDetails;

  // bool _isLoading = false;
  //
  // bool get isLoading => _isLoading;
  //
  // List<PhotoActivity>? get activityPhotos => _photoDetails;
  //
  // ActivityPhotosDataModel({
  //   required this.webRepository,
  //   required this.fileRepository,
  // });

  Future loadActivityPhotos(int activityId) async {
    // _isLoading = true;
    // notifyListeners();
    if (globals.isInDebug) {
      fileRepository?.loadActivityPhotos(activityId).then((loadedPhotos) {
        setActivityPhotos(loadedPhotos);
        // notifyListeners();
      });
    } else {
      print('WOULD CALL WEB SVC NOW! - loadActivityPhotos');
      webRepository?.loadActivityPhotos(activityId).then((loadedPhotos) {
        setActivityPhotos(loadedPhotos);
        // notifyListeners();
      });
    }
  }

  List<String> createUrls(DetailedActivity detailedActivity) {
    List<String> imagesUrls = [
      detailedActivity.photos!.primary!.urls!.s600.toString()
    ];

    if (activityPhotos != null && activityPhotos.length > 1) {
      imagesUrls = [];
      for (PhotoActivity image in activityPhotos) {
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
    }
    return imagesUrls;
  }
}

final activityPhotosProvider =
    StateNotifierProvider<ActivityPhotosNotifier, List<PhotoActivity>>((ref) {
  return ActivityPhotosNotifier();
});
