import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:zwiftdataviewer/models/ConfigDataModel.dart';
import 'package:zwiftdataviewer/stravalib/Models/activity.dart';
import 'package:zwiftdataviewer/stravalib/globals.dart';
import 'package:zwiftdataviewer/stravalib/globals.dart' as globals;
import 'package:zwiftdataviewer/stravalib/strava.dart';
import 'package:zwiftdataviewer/utils/constants.dart' as constants;
import 'package:zwiftdataviewer/utils/files.dart' as fileUtils;
import 'package:zwiftdataviewer/utils/repository/filerepository.dart';
import 'package:zwiftdataviewer/utils/repository/webrepository.dart';
import 'package:zwiftdataviewer/utils/worlddata.dart';

// class ActivitiesDataModel extends ChangeNotifier {
//   List<SummaryActivity>? _activities = [];
//   Strava? _strava;
//   final FileRepository? fileRepository;
//   final WebRepository? webRepository;
//
//   bool _isLoading = false;
//   bool _isLoadingDetail = false;
//
//   bool get isLoading => _isLoading;
//
//   bool get isLoadingDetail => _isLoadingDetail;
//
//   List<SummaryActivity>? get activities => _activities;
//
//   GuestWorldId _filter = GuestWorldId.all;
//   constants.DateFilter _dateFilter = constants.DateFilter.all;
//
//   GuestWorldId get filter => _filter;
//
//   constants.DateFilter get dateFilter => _dateFilter;
//
//   set filter(GuestWorldId filter) {
//     _filter = filter;
//     notifyListeners();
//   }
//
//   set dateFilter(constants.DateFilter filter) {
//     _dateFilter = filter;
//     notifyListeners();
//   }
//
//   StreamController<List<SummaryActivity>> _activitiesController =
//   StreamController<List<SummaryActivity>>.broadcast();
//
//   Stream<List<SummaryActivity>> get activitiesStream => _activitiesController.stream;
//
//   ActivitiesDataModel({
//     required this.fileRepository,
//     required this.webRepository,
//     List<SummaryActivity>? activities,
//     Strava? strava,
//   });
//
//   void addActivities(List<SummaryActivity> activities) {
//     _activities = activities;
//     _activitiesController.add(_activities!);
//     notifyListeners();
//   }
//
//   Future loadActivities([context]) {
//     _isLoading = true;
//     notifyListeners();
//     return fileRepository!
//         .loadActivities(constants.defaultDataDate, constants.defaultDataDate)
//         .then((loadedActivities) {
//       _activities!.addAll(loadedActivities);
//       _activitiesController.add(_activities!);
//       _isLoading = false;
//       notifyListeners();
//     }).then((loadedActivities) {
//       if (_activities!.isEmpty) {
//         _isLoading = true;
//         notifyListeners();
//       }
//       ConfigData configData;
//       final ConfigDataModel configDataModel =
//       Provider.of<ConfigDataModel>(context, listen: false);
//       if (configDataModel.configData == null) {
//         configData = ConfigData();
//         configData.lastSyncDate = constants.defaultDataDate;
//         configData.isMetric = false;
//       } else {
//         configData = configDataModel.configData!;
//       }
//
//       final int beforeDate = (DateTime.now().millisecondsSinceEpoch);
//       final int afterDate = constants.defaultDataDate;
//       configData.lastSyncDate;
//
//       if (!isInDebug) {
//         webRepository!
//             .loadActivities(beforeDate, afterDate)
//             .then((webloadedActivities) {
//           if (webloadedActivities != null && webloadedActivities.length > 0) {
//             _activities = webloadedActivities.cast<SummaryActivity>();
//             _activitiesController.add(_activities!);
//             final int startDate =
//                 webloadedActivities[webloadedActivities.length - 1]!
//                     .startDateLocal!
//                     .millisecondsSinceEpoch;
//             final int elapsedTime =
//                 webloadedActivities[webloadedActivities.length - 1]!
//                     .elapsedTime! *
//                     1000;
//             fileRepository!.saveActivities(_activities!);
//             configData.lastSyncDate = startDate + elapsedTime;
//             configDataModel.configData = configData;
//             notifyListeners();
//             _isLoading = false;
//           }
//         });
//       } else {
//         print('WOULD CALL WEB SVC NOW! - loadActivities');
//       }
//     }).catchError((err) {
//       _isLoading = false;
//       notifyListeners();
//     });
//   }
//
//   List<SummaryActivity> get filteredActivities {
//     return _activities!.where((activity) {
//       if (_filter != GuestWorldId.all) {
//         return worldsData[_filter]?.name == activity.name;
//       } else {
//         return true;
//       }
//     }).toList();
//   }
//
//   List<SummaryActivity> get dateFilteredActivities {
//     DateTime startDate;
//     return _activities!.where((activity) {
//       switch (_dateFilter) {
//         case constants.DateFilter.year:
//           startDate = DateTime.now().subtract(new Duration(days: 365));
//           return activity.startDate!.isAfter(startDate);
//         case constants.DateFilter.month:
//           startDate = DateTime.now().subtract(new Duration(days: 30));
//           return activity.startDate!.isAfter(startDate);
//         case constants.DateFilter.week:
//           startDate = DateTime.now().subtract(new Duration(days: 7));
//           return activity.startDate!.isAfter(startDate);
//         default:
//           return true;
//       }
//     }).toList();
//   }
//
//   SummaryActivity activityById(int id) {
//     return _activities!
//         .firstWhere((it) => it.id == id, orElse: () => SummaryActivity());
//   }
//
//   Future<DetailedActivity> loadActivityDetail(int activityId) async {
//     notifyListeners();
//     DetailedActivity activity;
//     if (globals.isInDebug) {
//       activity = DetailedActivity.fromJson(
//           await fileUtils.fetchLocalJsonData("activity_test.json"));
//     } else {
//       print('WOULD CALL WEB SVC NOW! - loadActivityDetail');
//       activity = await _strava!.getActivityById(activityId.toString());
//     }
//     return activity;
//   }
//
//   void dispose() {
//     _activitiesController.close();
//     super.dispose();
//   }
// }

class SummaryActivitySelectDataModel extends ChangeNotifier {
  SummaryActivity? activity;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  SummaryActivity? get selectedActivity => activity;

  setSelectedActivity(SummaryActivity activity) {
    this.activity = activity;
    notifyListeners();
  }
}

class ActivitiesDataModel extends ChangeNotifier {
  List<SummaryActivity>? _activities = [];
  Strava? _strava;
  final FileRepository? fileRepository;
  final WebRepository? webRepository;

  bool _isLoading = false;
  bool _isLoadingDetail = false;

  bool get isLoading => _isLoading;

  bool get isLoadingDetail => _isLoadingDetail;

  List<SummaryActivity>? get activities => _activities;

  GuestWorldId _filter = GuestWorldId.all;
  constants.DateFilter _dateFilter = constants.DateFilter.all;

  GuestWorldId get filter => _filter;

  constants.DateFilter get dateFilter => _dateFilter;

  set filter(GuestWorldId filter) {
    _filter = filter;
    notifyListeners();
  }

  set dateFilter(constants.DateFilter filter) {
    _dateFilter = filter;
    notifyListeners();
  }

  // final StreamController<List<SummaryActivity>> _activitiesController =
  //     StreamController<List<SummaryActivity>>.broadcast();

  // Stream<List<SummaryActivity>> get activitiesStream =>
  //     _activitiesController.stream;

  ActivitiesDataModel({
    required this.fileRepository,
    required this.webRepository,
    List<SummaryActivity>? activities,
    required BuildContext context,
    Strava? strava,
  }) {
    loadActivities(context);
  }

  void addActivities(List<SummaryActivity> activities) {
    _activities = activities;
    // _activitiesController.add(_activities!);
    notifyListeners();
  }

  Future loadActivities([context]) async {
    _isLoading = true;

    // ConfigData configData;
    // final ConfigDataModel configDataModel = Provider.of<ConfigDataModel>(context, listen: false);
    // if (configDataModel.configData == null) {
    //   configData = ConfigData();
    //   configData.lastSyncDate = constants.defaultDataDate;
    //   configData.isMetric = false;
    // } else {
    //   configData = configDataModel.configData!;
    // }

    //after
    var afterDate = await getAfterParameter();//   configData.getAfterParameter();
    //afterDate = 1680307200; //test date Saturday, April 1, 2023 12:00:00 AM
    //now
    final beforeDate = (DateTime.now().millisecondsSinceEpoch / 1000).round();

    notifyListeners();
    return fileRepository!
        .loadActivities(beforeDate, afterDate!)
        .then((loadedActivities) {
      _activities!.addAll(loadedActivities);
      // _activitiesController.add(_activities!);
      _isLoading = false;
      notifyListeners();
    }).then((loadedActivities) {
      if (_activities!.isEmpty) {
        _isLoading = true;
        notifyListeners();
      }

      //final int beforeDate = (DateTime.now().millisecondsSinceEpoch);
      // final int afterDate = constants.defaultDataDate;
      //configData.lastSyncDate;

      if (!isInDebug) {
        webRepository!
            .loadActivities(
                (DateTime.now().millisecondsSinceEpoch / 1000).round(),
                afterDate!)
            .then((webloadedActivities) {
          if (webloadedActivities != null && webloadedActivities.isNotEmpty) {
            if (_activities!.isNotEmpty) {
              webloadedActivities.addAll(
                  _activities as Iterable<SummaryActivity>);
              storeAfterParameter(beforeDate);
            }
            _activities = webloadedActivities.cast<SummaryActivity>();

            fileRepository!.saveActivities(_activities!);
            // configData.lastSyncDate = beforeDate;
            // configDataModel.configData = configData;
            notifyListeners();
            _isLoading = false;
            // if (_activities!=null) {

            // }
          }
        });
      } else {
        print('WOULD CALL WEB SVC NOW! - loadActivities');
      }
    }).catchError((err) {
      _isLoading = false;
      notifyListeners();
    });
  }

  List<SummaryActivity> get filteredActivities {
    return _activities!.where((activity) {
      if (_filter != GuestWorldId.all) {
        return worldsData[_filter]?.name == activity.name;
      } else {
        return true;
      }
    }).toList();
  }

  List<SummaryActivity> get dateFilteredActivities {
    DateTime startDate;
    return _activities!.where((activity) {
      switch (_dateFilter) {
        case constants.DateFilter.year:
          startDate = DateTime.now().subtract(new Duration(days: 365));
          return activity.startDate!.isAfter(startDate);
        case constants.DateFilter.month:
          startDate = DateTime.now().subtract(new Duration(days: 30));
          return activity.startDate!.isAfter(startDate);
        case constants.DateFilter.week:
          startDate = DateTime.now().subtract(new Duration(days: 7));
          return activity.startDate!.isAfter(startDate);
        default:
          return true;
      }
    }).toList();
  }

  SummaryActivity activityById(int id) {
    return _activities!
        .firstWhere((it) => it.id == id, orElse: () => SummaryActivity());
  }

  Future<DetailedActivity> loadActivityDetail(int activityId) async {
    notifyListeners();
    DetailedActivity activity;
    if (globals.isInDebug) {
      activity = DetailedActivity.fromJson(
          await fileUtils.fetchLocalJsonData("activity_test.json"));
    } else {
      print('WOULD CALL WEB SVC NOW! - loadActivityDetail');
      activity = await _strava!.getActivityById(activityId.toString());
    }
    return activity;
  }

  void dispose() {
    // _activitiesController.close();
    super.dispose();
  }
}

enum ActivityLoadingStatus {
  loading,
  loadedFromLocal,
  loadingFromWeb,
  loadedFromWeb,
  done,
}
