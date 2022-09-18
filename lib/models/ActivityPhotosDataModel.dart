import 'package:flutter/widgets.dart';
import 'package:zwiftdataviewer/stravalib/Models/activity.dart';
import 'package:zwiftdataviewer/stravalib/globals.dart' as globals;
import 'package:zwiftdataviewer/utils/repository/filerepository.dart';
import 'package:zwiftdataviewer/utils/repository/webrepository.dart';

class ActivityPhotosDataModel extends ChangeNotifier {
  final WebRepository webRepository;
  final FileRepository fileRepository;
  List<PhotoActivity>? _photoDetails;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<PhotoActivity>? get activityPhotos => _photoDetails;

  ActivityPhotosDataModel({
    required this.webRepository,
    required this.fileRepository,
  });

  Future loadActivityPhotos(int activityId) async {
    _isLoading = true;
    notifyListeners();
    if (globals.isInDebug) {
      fileRepository.loadActivityPhotos(activityId).then((loadedPhotos) {
        _photoDetails = loadedPhotos;
        notifyListeners();
      });
    } else {
      print('WOULD CALL WEB SVC NOW! - loadActivityPhotos');
      webRepository.loadActivityPhotos(activityId).then((loadedPhotos) {
        _photoDetails = loadedPhotos;
        notifyListeners();
      });
    }
  }
}
