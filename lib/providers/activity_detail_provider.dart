import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/models/activity.dart';
import 'package:flutter_strava_api/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'activity_select_provider.dart';

class StravaActivityDetailsNotifier extends StateNotifier<DetailedActivity> {
  final String _baseUrl = 'https://www.strava.com/api/v3';
  final String _accessToken;

  StravaActivityDetailsNotifier(this._accessToken, int activityId)
      : super(DetailedActivity());

  Future<void> loadActivityDetails(int activityId) async {
    final cacheFile = await _getCacheFile();
    if (cacheFile.existsSync()) {
      final cachedData = await cacheFile.readAsString();
      final List activityDetails = jsonDecode(cachedData);
      for (var activityDetail in activityDetails) {
        if (activityDetail['id'].toString() == activityId.toString()) {
          state = DetailedActivity.fromJson(activityDetail);
          return;
        }
      }
      // final DetailedActivity activityDetail = activityDetails.firstWhere(
      //   (element) => element['id'].toString() == activityId.toString(),
      //   // orElse: () => DetailedActivity(),
      // );
      if (state.id != null) {
        // state = activityDetail;
        return;
      }
    }

    final url = Uri.parse('$_baseUrl/activities/$activityId');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    if (response.statusCode == 200) {
      // final activityDetail = jsonDecode(response.body);
      final DetailedActivity activityDetail =
          DetailedActivity.fromJson(json.decode(response.body));
      state = activityDetail;
      await _saveActivityDetailToCache(json.decode(response.body));
    } else {
      throw Exception('Failed to load activity details');
    }
  }

  Future<File> _getCacheFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/strava_activity_details_cache.json');
  }

  Future<void> _saveActivityDetailToCache(
      Map<String, dynamic> activityDetail) async {
    final cacheFile = await _getCacheFile();
    if (cacheFile.existsSync()) {
      final cachedData = await cacheFile.readAsString();
      final activityDetails = jsonDecode(cachedData);
      activityDetails.add(activityDetail);
      await cacheFile.writeAsString(jsonEncode(activityDetails));
    } else {
      await cacheFile.writeAsString(jsonEncode([activityDetail]));
    }
  }
}

final stravaActivityDetailsProvider =
    StateNotifierProvider<StravaActivityDetailsNotifier, DetailedActivity>(
        (ref) {
  var activityId = ref.watch(selectedActivityProvider).id;
  final accessToken = globals.token.accessToken;
  return StravaActivityDetailsNotifier(accessToken!, activityId);
});

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

// final activityDetailFromStreamProvider =
//     FutureProvider.autoDispose.family<DetailedActivity, int>((ref, id) async {
//   final FileRepository fileRepository = FileRepository();
//   final WebRepository webRepository =
//       WebRepository(strava: Strava(isInDebug, secret));
//
//   var retVal = DetailedActivity();
//
//   if (globals.isInDebug) {
//     retVal = await fileRepository.loadActivityDetail(id);
//   } else {
//     if (kDebugMode) {
//       print('CALL WEB SVC NOW! - loadActivityDetail');
//     }
//     retVal = await webRepository.loadActivityDetail(id);
//     ref.read(activityDetailProvider.notifier).setActivityDetail(retVal);
//   }
//
//   return retVal;
// });

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
