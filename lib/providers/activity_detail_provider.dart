import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/stravalib/API/streams.dart';
import 'package:zwiftdataviewer/stravalib/Models/activity.dart';
import 'package:zwiftdataviewer/stravalib/globals.dart' as globals;
import 'package:zwiftdataviewer/utils/repository/filerepository.dart';
import 'package:zwiftdataviewer/utils/repository/webrepository.dart';

import '../secrets.dart';
import '../stravalib/globals.dart';
import '../stravalib/strava.dart';

// class ActivityDetailDataModel extends ChangeNotifier {


class ActivityDetailNotifier extends StateNotifier<DetailedActivity> {
  ActivityDetailNotifier() : super(DetailedActivity());


  final FileRepository? fileRepository = FileRepository();
  final WebRepository? webRepository = WebRepository(
      strava: Strava(isInDebug, secret));

  DetailedActivity get activityDetail => state;

  void setActivityDetail(DetailedActivity activityDetail) {
    state = activityDetail;
  }

  // ActivityDetailDataModel({
  // required this.webRepository,
  // required this.fileRepository,
  // // VisibilityFilter filter,
  // DetailedActivity? activityDetail,
  // });

  Future loadActivityDetail(int activityId) async {
    // _isLoading = true;
    // notifyListeners();
    if (globals.isInDebug) {
      fileRepository?.loadActivityDetail(activityId).then((loadedActivity) {
        setActivityDetail(loadedActivity!);
        // _isLoading = false;
        // notifyListeners();
      });
    } else {
      print('WOULD CALL WEB SVC NOW! - loadActivityDetail');
      webRepository?.loadActivityDetail(activityId).then((loadedActivity) {
        setActivityDetail(loadedActivity!);
        //_isLoading = false;
        //notifyListeners();
      });
    }
  }
}

final activityDetailProvider =
StateNotifierProvider<ActivityDetailNotifier, DetailedActivity>((ref) {
  return ActivityDetailNotifier();
});


class CombinedStreamsNotifier extends StateNotifier<CombinedStreams> {
  CombinedStreamsNotifier() : super(CombinedStreams(0, 0, 0, 0, 0, 0, 0));

// class ActivitySelectDataModel extends ChangeNotifier {
//   CombinedStreams? stream;
//
//   bool _isLoading = false;
//
//   bool get isLoading => _isLoading;

  CombinedStreams? get selectedStream => state;

  setSelectedStream(CombinedStreams selectedStream) {
    state = selectedStream;
  }
}

final combinedStreamsProvider =
StateNotifierProvider<CombinedStreamsNotifier, CombinedStreams>((ref) {
  return CombinedStreamsNotifier();
});

class LapSelectDataModel extends ChangeNotifier {
  Laps? lap;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Laps? get selectedLap => lap;

  setSelectedLap(Laps laps) {
    lap = laps;
    notifyListeners();
  }
}

class LapSummaryObject with ChangeNotifier {
  final int lap;
  int count = 0;
  double distance;
  int time;
  double altitude;
  double cadence;
  double watts;
  double speed;
  final Color color;

  LapSummaryObject(this.lap, this.count, this.distance, this.time,
      this.altitude, this.cadence, this.watts, this.speed, this.color);
}
