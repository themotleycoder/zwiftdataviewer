import 'package:flutter/widgets.dart';
import 'package:zwiftdataviewer/stravalib/API/streams.dart';
import 'package:zwiftdataviewer/stravalib/Models/activity.dart';
import 'package:zwiftdataviewer/stravalib/globals.dart' as globals;
import 'package:zwiftdataviewer/utils/repository/filerepository.dart';
import 'package:zwiftdataviewer/utils/repository/webrepository.dart';

class ActivityDetailDataModel extends ChangeNotifier {
  final WebRepository webRepository;
  final FileRepository fileRepository;
  DetailedActivity? _activityDetail;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  DetailedActivity? get activityDetail => _activityDetail;

  ActivityDetailDataModel({
    required this.webRepository,
    required this.fileRepository,
    // VisibilityFilter filter,
    DetailedActivity? activityDetail,
  });

  Future loadActivityDetail(int activityId) async {
    _isLoading = true;
    notifyListeners();
    if (globals.isInDebug) {
      fileRepository.loadActivityDetail(activityId).then((loadedActivity) {
        _activityDetail = loadedActivity;
        _isLoading = false;
        notifyListeners();
      });
    } else {
      print('WOULD CALL WEB SVC NOW! - loadActivityDetail');
      webRepository.loadActivityDetail(activityId).then((loadedActivity) {
        _activityDetail = loadedActivity;
        _isLoading = false;
        notifyListeners();
      });
    }
  }
}

class ActivitySelectDataModel extends ChangeNotifier {
  CombinedStreams? stream;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  CombinedStreams? get selectedStream => stream;

  setSelectedSeries(CombinedStreams selectedSeries) {
    this.stream = selectedSeries;
    notifyListeners();
  }
}

class LapSelectDataModel extends ChangeNotifier {
  Laps? lap;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Laps? get selectedLap => lap;

  setSelectedLap(Laps laps) {
    this.lap = laps;
    notifyListeners();
  }
}

class LapSummaryObject with ChangeNotifier {
  final int lap;
  int count = 0;
  double distance;
  int time;
  double altitude;
  // double heartrate;
  double cadence;
  double watts;
  double speed;
  final Color color;

  LapSummaryObject(this.lap, this.count, this.distance, this.time, this.altitude,
      this.cadence, this.watts, this.speed, this.color);
}
