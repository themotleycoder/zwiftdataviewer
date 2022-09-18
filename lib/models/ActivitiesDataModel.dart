import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:zwiftdataviewer/models/ConfigDataModel.dart';
import 'package:zwiftdataviewer/stravalib/Models/activity.dart';
import 'package:zwiftdataviewer/stravalib/globals.dart';
import 'package:zwiftdataviewer/stravalib/strava.dart';
import 'package:zwiftdataviewer/stravalib/globals.dart' as globals;
import 'package:zwiftdataviewer/utils/files.dart' as fileUtils;
import 'package:zwiftdataviewer/utils/constants.dart' as constants;
import 'package:zwiftdataviewer/utils/worlddata.dart';
import 'package:zwiftdataviewer/utils/repository/filerepository.dart';
import 'package:zwiftdataviewer/utils/repository/webrepository.dart';

class ActivitiesDataModel extends ChangeNotifier {
  List<SummaryActivity>? _activities = [];
  Strava? _strava;
  final FileRepository? fileRepository;
  final WebRepository? webRepository;
  // final ConfigData config;

  bool _isLoading = false;
  bool _isLoadingDetail = false;

  bool get isLoading => _isLoading;
  bool get isLoadingDetail => _isLoadingDetail;

  List<SummaryActivity>? get activities => _activities;

  GuestWorldId? _filter;
  constants.DateFilter? _dateFilter;

  GuestWorldId get filter => _filter!;
  constants.DateFilter get dateFilter => _dateFilter!;

  set filter(GuestWorldId filter) {
    _filter = filter;
    notifyListeners();
  }

  set dateFilter(constants.DateFilter filter) {
    _dateFilter = filter;
    notifyListeners();
  }

  ActivitiesDataModel({
    required this.fileRepository,
    required this.webRepository,
    // @required this.config,
    List<SummaryActivity>? activities,
    Strava? strava,
  });

  void addActivities(List<SummaryActivity> activities) {
    _activities = activities;
    notifyListeners();
  }

  Future loadActivities([context]) {
    _isLoading = true;
    notifyListeners();
    return fileRepository!
        .loadActivities(constants.defaultDataDate, constants.defaultDataDate)
        .then((loadedActivities) {
      _activities!.addAll(loadedActivities);
      _isLoading = false;
      notifyListeners();
    }).then((loadedActivities) {
      if (_activities!.isEmpty) {
        _isLoading = true;
        notifyListeners();
      }
      ConfigData configData;
      final ConfigDataModel configDataModel =
          Provider.of<ConfigDataModel>(context, listen: false);
      if (configDataModel == null || configDataModel.configData == null) {
        configData = new ConfigData();
        configData.lastSyncDate = constants.defaultDataDate;
        configData.isMetric = false;
      } else {
        configData = configDataModel.configData!;
      }

      final int beforeDate = (DateTime.now().millisecondsSinceEpoch);
      final int afterDate = constants.defaultDataDate;
      //configData.lastSyncDate;

      if (!isInDebug) {
        webRepository!
            .loadActivities(beforeDate, afterDate)
            .then((webloadedActivities) {
          if (webloadedActivities != null && webloadedActivities.length > 0) {
            _activities = webloadedActivities.cast<SummaryActivity>();
            final int startDate =
                webloadedActivities[webloadedActivities.length - 1]!
                    .startDateLocal!
                    .millisecondsSinceEpoch;
            final int elapsedTime =
                webloadedActivities[webloadedActivities.length - 1]!
                        .elapsedTime! *
                    1000;
            // _activities.addAll(webloadedActivities);
            fileRepository!.saveActivities(_activities!);
            configData.lastSyncDate = startDate + elapsedTime;
            configDataModel.configData = configData;
            notifyListeners();
            _isLoading = false;
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
      if (_filter != null && _filter != GuestWorldId.all) {
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
}
