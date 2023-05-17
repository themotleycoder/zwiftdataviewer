
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ConfigDataModel.dart';
import '../secrets.dart';
import '../stravalib/Models/activity.dart';
import '../stravalib/globals.dart';
import '../stravalib/strava.dart';
import '../utils/repository/filerepository.dart';
import '../utils/repository/webrepository.dart';

class ActivitiesNotifier extends StateNotifier<List<SummaryActivity>> {
  ActivitiesNotifier() : super([]);

  // final Strava strava = Strava(isInDebug, secret);
  final FileRepository? fileRepository = FileRepository();
  final WebRepository? webRepository = WebRepository(strava: Strava(isInDebug, secret));

  get activities => state;

  void addActivity(SummaryActivity activity) {
    state = [...state, activity];
  }

  void addActivities(List<SummaryActivity> activities) {
    state = [...state, ...activities];
  }

  void removeActivity(SummaryActivity activity) {
    state = state.where((element) => element.id != activity.id).toList();
  }

  void updateActivity(SummaryActivity activity) {
    state = state
        .map((element) => element.id == activity.id ? activity : element)
        .toList();
  }

  void clearActivities() {
    state = [];
  }

  void setActivities(List<SummaryActivity> activities) {
    state = activities;
  }

  SummaryActivity activityById(int id) {
    return state.firstWhere((activity) => activity.id == id);
  }

  Future<void> loadActivities() async {
    var afterDate =
        await getAfterParameter(); //   configData.getAfterParameter();
    //afterDate = 1680307200; //test date Saturday, April 1, 2023 12:00:00 AM
    //now
    final beforeDate = (DateTime.now().millisecondsSinceEpoch / 1000).round();

    //notifyListeners();
    return fileRepository!
        .loadActivities(beforeDate, afterDate!)
        .then((loadedActivities) {
      setActivities(loadedActivities);
      // _activitiesController.add(_activities!);
      //_isLoading = false;
      //notifyListeners();
    }).then((loadedActivities) {
      if (activities!.isEmpty) {
        //_isLoading = true;
        //notifyListeners();
      }

      //final int beforeDate = (DateTime.now().millisecondsSinceEpoch);
      // final int afterDate = constants.defaultDataDate;
      //configData.lastSyncDate;

      if (!isInDebug) {
        webRepository!
            .loadActivities(
                (DateTime.now().millisecondsSinceEpoch / 1000).round(),
                afterDate)
            .then((webloadedActivities) {
          if (webloadedActivities != null && webloadedActivities.isNotEmpty) {
            if (activities!.isNotEmpty) {
              webloadedActivities
                  .addAll(activities as Iterable<SummaryActivity>);
              storeAfterParameter(beforeDate);
            }

            setActivities(webloadedActivities.cast<SummaryActivity>().toList());
            // _activities = webloadedActivities.cast<SummaryActivity>();

            fileRepository!.saveActivities(activities!);
            // configData.lastSyncDate = beforeDate;
            // configDataModel.configData = configData;
            //notifyListeners();
            //isLoading = false;
            // if (_activities!=null) {

            // }
          }
        });
      } else {
        print('WOULD CALL WEB SVC NOW! - loadActivities');
      }
    }).catchError((err) {
      err.toString();
      //_isLoading = false;
      //notifyListeners();
    });
  }
}

final activitiesProvider =
    StateNotifierProvider<ActivitiesNotifier, List<SummaryActivity>>((ref) {
  return ActivitiesNotifier();
});
