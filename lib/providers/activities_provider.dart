import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:zwiftdataviewer/strava_lib/Models/summary_activity.dart';
import 'package:zwiftdataviewer/strava_lib/globals.dart' as globals;

import '../strava_lib/Models/activity.dart';

class ActivitiesNotifier extends StateNotifier<List<SummaryActivity>> {
  final String _baseUrl = 'https://www.strava.com/api/v3';
  final String _accessToken;

  ActivitiesNotifier(this._accessToken) : super([]);

  Future<void> loadActivities({int perPage = 50}) async {
    final cacheFile = await _getCacheFile();
    if (cacheFile.existsSync()) {
      final cacheData = await cacheFile.readAsString();
      final List<SummaryActivity> cachedActivities =
          List.from(jsonDecode(cacheData))
              .map((activity) => SummaryActivity.fromJson(activity))
              .toList();
      state = cachedActivities;
    }

    List<SummaryActivity> allActivities = [];
    int page = 1;
    bool hasMorePages = true;

    final lastActivityEpoch = await _getLastActivityEpoch();

    while (hasMorePages) {
      final url = Uri.parse(
          '$_baseUrl/athlete/activities?page=$page&per_page=$perPage&after=$lastActivityEpoch');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      if (response.statusCode == 200) {
        final List<SummaryActivity> activities =
            List.from(jsonDecode(response.body))
                .map((activity) => SummaryActivity.fromJson(activity))
                .toList();
        final List<SummaryActivity> filteredActivities = activities
            .where((activity) => activity.type == ActivityType.VirtualRide)
            .toList();
        allActivities.addAll(filteredActivities);

        if (activities.length < perPage) {
          hasMorePages = false;
        } else {
          page++;
        }
      } else {
        throw Exception('Failed to load athlete activities');
      }
    }

    final newActivities =
        allActivities.where((activity) => !state.contains(activity)).toList();
    state = [...state, ...newActivities];

    if (newActivities.isNotEmpty) {
      final lastActivity = newActivities.last;
      final lastActivityDate = DateTime.parse(lastActivity.startDate.toString());
      final newLastActivityEpoch = lastActivityDate.millisecondsSinceEpoch ~/ 1000;
      await _storeLastActivityEpoch(newLastActivityEpoch);
    } else {
      await _storeLastActivityEpoch(DateTime.now().millisecondsSinceEpoch ~/ 1000);
    }

    await cacheFile.writeAsString(jsonEncode(state));
  }

  Future<File> _getCacheFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/strava_activities_cache.json');
  }

  Future<int> _getLastActivityEpoch() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/last_activity_epoch.txt');

    if (file.existsSync()) {
      final contents = await file.readAsString();
      return int.parse(contents);
    } else {
      return 1420070400; //default is Thursday, January 1, 2015 12:00:00 AM
    }
  }

  Future<void> _storeLastActivityEpoch(int lastActivityEpoch) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/last_activity_epoch.txt');
    await file.writeAsString('$lastActivityEpoch');
  }
}

final stravaActivitiesProvider =
    StateNotifierProvider<ActivitiesNotifier, List<SummaryActivity>>((ref) {
  final accessToken = globals.token.accessToken;
  return ActivitiesNotifier(accessToken!);
});
