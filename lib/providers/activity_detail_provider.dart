import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/stravalib/Models/activity.dart';
import 'package:zwiftdataviewer/stravalib/globals.dart' as globals;
import 'package:zwiftdataviewer/utils/repository/filerepository.dart';
import 'package:zwiftdataviewer/utils/repository/webrepository.dart';

import '../secrets.dart';
import '../stravalib/globals.dart';
import '../stravalib/strava.dart';

class ActivityDetailNotifier extends StateNotifier<DetailedActivity> {
  ActivityDetailNotifier() : super(DetailedActivity());

  DetailedActivity get activityDetail => state;

  void setActivityDetail(DetailedActivity activityDetail) {
    state = activityDetail;
  }
}

final activityDetailProvider =
    StateNotifierProvider<ActivityDetailNotifier, DetailedActivity>((ref) {
  return ActivityDetailNotifier();
});


final activityDetailFromStreamProvider =
    FutureProvider.autoDispose.family<DetailedActivity, int>((ref, id) async {
  final FileRepository fileRepository = FileRepository();
  final WebRepository webRepository =
      WebRepository(strava: Strava(isInDebug, secret));

  var retVal = DetailedActivity();

  if (globals.isInDebug) {
    retVal = await fileRepository.loadActivityDetail(id);
  } else {
    if (kDebugMode) {
      print('CALL WEB SVC NOW! - loadActivityDetail');
    }
    retVal = await webRepository.loadActivityDetail(id);
    ref.read(activityDetailProvider.notifier).setActivityDetail(retVal);
  }

  return retVal;
});

class LapSelectDataModel extends ChangeNotifier {
  Laps? lap;

  final bool _isLoading = false;

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
