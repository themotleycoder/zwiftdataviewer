import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_strava_api/Models/summary_activity.dart';
import 'package:flutter_strava_api/globals.dart' as globals;

import 'package:flutter_strava_api/Models/activity.dart';

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
      //   state = cachedActivities;
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
    await cacheFile.writeAsString(jsonEncode(state));

    // if (newActivities.isNotEmpty) {
    //   final lastActivity = newActivities.last;
    //   final lastActivityDate = DateTime.parse(lastActivity.startDate.toString());
    //   final newLastActivityEpoch = lastActivityDate.millisecondsSinceEpoch ~/ 1000;
    //   await _storeLastActivityEpoch(newLastActivityEpoch);
    // }

    await _storeLastActivityEpoch(
        DateTime.now().millisecondsSinceEpoch ~/ 1000);
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

// final stravaActivitiesProvider =
//     StateNotifierProvider<ActivitiesNotifier, List<SummaryActivity>>((ref) {
//   final accessToken = globals.token.accessToken;
//   return ActivitiesNotifier(accessToken!);
// });

Future<List<SummaryActivity>> fetchStravaActivities() async {
  // final FileRepository repository = FileRepository();
  // DateTime? mostRecentActivityDate;
  const String baseUrl = 'https://www.strava.com/api/v3';
  DateTime? lastActivityDate = await getLastActivityDate();
  int afterTimestamp = 1420070400; //default is Thursday, January 1, 2015 12:00:00 AM
  List<SummaryActivity> cachedActivities = [];

  final accessToken = globals.token.accessToken;

  final cacheFile = await _getCacheFile();
  if (cacheFile.existsSync()) {
    final cacheData = await cacheFile.readAsString();
    cachedActivities =
    List.from(jsonDecode(cacheData))
        .map((activity) => SummaryActivity.fromJson(activity))
        .toList();
    //   state = cachedActivities;
    // lastActivityDate = cachedActivities[cachedActivities.length-1].startDate;
  }

  List<SummaryActivity> fetchedActivities = [];
  int page = 1;
  int perPage = 50;
  bool hasMorePages = true;

  // final lastActivityEpoch = await _getLastActivityEpoch();

  if (lastActivityDate != null) {
    afterTimestamp = lastActivityDate.millisecondsSinceEpoch ~/ 1000;
  }

  while (hasMorePages) {
    final url = Uri.parse(
        '$baseUrl/athlete/activities?page=$page&per_page=$perPage&after=$afterTimestamp');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final List<SummaryActivity> activities =
      List.from(jsonDecode(response.body))
          .map((activity) => SummaryActivity.fromJson(activity))
          .toList();
      final List<SummaryActivity> filteredActivities = activities
          .where((activity) => activity.type == ActivityType.VirtualRide)
          .toList();
      fetchedActivities.addAll(filteredActivities);

      if (activities.length < perPage) {
        hasMorePages = false;
      } else {
        page++;
      }


    } else {
      throw Exception('Failed to load athlete activities');
    }
  }

  // if (allActivities.isNotEmpty && mostRecentActivityDate == null) {
  //   mostRecentActivityDate = allActivities[0].startDate;
  // }


  // final newActivities = allActivities.where((activity) => !state.contains(activity)).toList();
  fetchedActivities = [...cachedActivities, ...fetchedActivities];
  await cacheFile.writeAsString(jsonEncode(fetchedActivities));

  //await _storeLastActivityEpoch(DateTime.now().millisecondsSinceEpoch ~/ 1000);
  //if (mostRecentActivityDate != null) {
    await saveLastActivityDate(fetchedActivities[fetchedActivities.length-1].startDate);
  //}
  final newActivities = fetchedActivities.reversed.toList();
  return newActivities;//await ActivitiesNotifier(accessToken!).loadActivities();
}

final stravaActivitiesProvider =
    FutureProvider<List<SummaryActivity>>((ref) async {
  return await fetchStravaActivities();
});

// Future<List<SummaryActivity>> fetchStravaActivities() async {
//   final lastActivityDate = await getLastActivityDate();
//   List<SummaryActivity> allActivities = [];
//   int page = 1;
//   final String accessToken = globals.token.accessToken!;
//   DateTime? mostRecentActivityDate;
//   bool hasMorePages = true;
//
//
//   List<SummaryActivity> cachedActivities = [];
//   final cacheFile = await _getCacheFile();
//   if (cacheFile.existsSync()) {
//     final cacheData = await cacheFile.readAsString();
//     cachedActivities =
//     List.from(jsonDecode(cacheData))
//         .map((activity) => SummaryActivity.fromJson(activity))
//         .toList();
//     //   state = cachedActivities;
//   }
//
//   while (hasMorePages) {
//     String apiUrl = 'https://www.strava.com/api/v3/athlete/activities';
//     List<String> parameters = [];
//
//     if (lastActivityDate != null) {
//       final afterTimestamp = lastActivityDate.millisecondsSinceEpoch ~/ 1000;
//       parameters.add('after=$afterTimestamp');
//     }
//
//     parameters.add('per_page=100');
//     parameters.add('page=$page');
//     apiUrl += '?${parameters.join('&')}';
//
//     final response = await http.get(Uri.parse(apiUrl),
//         headers: {'Authorization': 'Bearer $accessToken'});
//
//     if (response.statusCode == 200) {
//       final List<SummaryActivity> activities =
//           List.from(jsonDecode(response.body))
//               .map((activity) => SummaryActivity.fromJson(activity))
//               .toList();
//       if (activities.isEmpty) break;
//
//       if (activities.length < page) {
//         hasMorePages = false;
//       } else {
//         page++;
//       }
//
//       final List<SummaryActivity> filteredActivities = activities
//           .where((activity) => activity.type == ActivityType.VirtualRide)
//           .toList();
//       allActivities.addAll(filteredActivities);
//
//       if (
//           filteredActivities.isNotEmpty &&
//           mostRecentActivityDate == null) {
//         mostRecentActivityDate = filteredActivities[0].startDate;
//       }
//
//       allActivities.addAll(filteredActivities);
//       if (filteredActivities.isEmpty) break;
//       // page++;
//     } else {
//       throw Exception('Failed to load activities from Strava');
//     }
//   }
//
//   if (mostRecentActivityDate != null) {
//     await saveLastActivityDate(mostRecentActivityDate);
//   }
//
//   allActivities = [...cachedActivities, ...allActivities];
//   await cacheFile.writeAsString(jsonEncode(allActivities));
//
//   return allActivities;
//
//   return allActivities;
// }

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

Future<void> saveLastActivityDate(DateTime date) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('lastActivityDate', date.millisecondsSinceEpoch);
}

Future<DateTime?> getLastActivityDate() async {
  final prefs = await SharedPreferences.getInstance();
  final milliseconds = prefs.getInt('lastActivityDate');
  if (milliseconds != null) {
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }
  return null;
}
