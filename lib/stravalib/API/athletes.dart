// athletes.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:zwiftdataviewer/stravalib/Models/summary_activity.dart';

import '../../secrets.dart';
import '../Models/activity.dart';
import '../Models/detailedAthlete.dart';
import '../Models/fault.dart';
import '../Models/stats.dart';
import '../Models/token.dart';
import '../Models/zone.dart';
import '../errorCodes.dart' as error;
import '../globals.dart' as globals;
import '../strava.dart';

abstract class Athletes {
  Future<DetailedAthlete> updateLoggedInAthlete(double weight) async {
    DetailedAthlete returnAthlete = DetailedAthlete();

    var header = globals.createHeader();

    if (header.containsKey('88') == false) {
      final reqAthlete = "https://www.strava.com/api/v3/athlete?weight=$weight";
      globals.displayInfo('update $reqAthlete');
      var rep = await http.put(Uri.parse(reqAthlete), headers: header);

      if (rep.statusCode == 200) {
        globals.displayInfo('Athlete info ${rep.body}');
        final Map<String, dynamic> jsonResponse = json.decode(rep.body);

        DetailedAthlete athlete = DetailedAthlete.fromJson(jsonResponse);
        globals.displayInfo(' athlete ${athlete.firstname}, ${athlete.weight}');

        returnAthlete = athlete;
      } else {
        globals.displayInfo(
            'problem in updateLoggedInAthlete request , ${returnAthlete.fault?.statusCode}  ${rep.body}');
      }

      returnAthlete.fault =
          globals.errorCheck(rep.statusCode, rep.reasonPhrase!);
    }

    return returnAthlete;
  }

  ///
  ///
  /// Give activiy stats of the loggedInAthlete
  ///
  Future<Stats> getStats(int id) async {
    Stats returnStats = Stats();
    int pageNumber = 1;
    int perPage = 50;

    var header = globals.createHeader();

    if (header.containsKey('88') == false) {
      final String reqStats =
          'https://www.strava.com/api/v3/athletes/$id/stats?page=$pageNumber&per_page=$perPage;';

      var rep = await http.get(Uri.parse(reqStats), headers: header);

      if (rep.statusCode == 200) {
        // globals.displayInfo('getStats ${rep.body}');
        final Map<String, dynamic> jsonResponse = json.decode(rep.body);

        if (jsonResponse != null) {
          returnStats = Stats.fromJson(jsonResponse);

          globals.displayInfo(
              '${returnStats.ytdRideTotals!.distance} ,  ${returnStats.recentRideTotals?.elapsedTime}');
          returnStats.fault =
              globals.errorCheck(rep.statusCode, rep.reasonPhrase);
        } else {
          String msg = 'json answer is empty';
          returnStats.fault = globals.errorCheck(error.statusJsonIsEmpty, msg);
          globals.displayInfo(msg);
        }
      }
    } else {
      const String msg = 'problem in getStats request, header is empty';
      returnStats.fault = globals.errorCheck(error.statusTokenNotKnownYet, msg);
      globals.displayInfo(msg);
    }

    return returnStats;
  }

  /// Provide zones heart rate or power for the logged athlete
  ///
  /// scope needed: profile:read_all
  ///
  ///
  Future<Zone> getLoggedInAthleteZones() async {
    Zone returnZone = Zone();

    globals.displayInfo('Entering getLoggedInAthleteZones');

    var header = globals.createHeader();

    if (header.containsKey('88') == false) {
      const String reqAthlete = 'https://www.strava.com/api/v3/athlete/zones';
      var rep = await http.get(Uri.parse(reqAthlete), headers: header);

      if (rep.statusCode == 200) {
        globals.displayInfo('Zone info ${rep.body}');
        final Map<String, dynamic> jsonResponse = json.decode(rep.body);

        Zone zone = Zone();
        zone = Zone.fromJson(jsonResponse);
        returnZone = zone;
      } else {
        globals.displayInfo(
            'problem in getLoggedInAthlete request ,   ${rep.body}');
      }
      returnZone.fault = globals.errorCheck(rep.statusCode, rep.reasonPhrase);
    }

    return returnZone;
  }

  ///
  /// scope needed: profile:read_all scope
  ///
  /// return: see status value in strava class
  Future<DetailedAthlete> getLoggedInAthlete() async {
    DetailedAthlete returnAthlete = DetailedAthlete();
    returnAthlete.fault = Fault(88, '');

    var header = globals.createHeader();

    if (header.containsKey('88') == false) {
      const String reqAthlete = 'https://www.strava.com/api/v3/athlete';
      var rep = await http.get(Uri.parse(reqAthlete), headers: header);

      if (rep.statusCode == 200) {
        globals.displayInfo(rep.statusCode.toString());
        globals.displayInfo('Athlete info ${rep.body}');
        final Map<String, dynamic> jsonResponse = json.decode(rep.body);

        final DetailedAthlete athlete = DetailedAthlete.fromJson(jsonResponse);
        globals
            .displayInfo(' athlete ${athlete.firstname}, ${athlete.lastname}');

        returnAthlete = athlete;
      } else {
        globals.displayInfo(
            'problem in getLoggedInAthlete request , ${returnAthlete.fault?.statusCode}  ${rep.body}');
      }

      returnAthlete.fault =
          globals.errorCheck(rep.statusCode, rep.reasonPhrase);
    } else {
      globals.displayInfo('Token not yet known');
      returnAthlete.fault =
          Fault(error.statusTokenNotKnownYet, 'Token not yet known');
    }

    return returnAthlete;
  }

  ///
  /// scope needed: profile: activity:read_all
  /// parameters:
  /// before: since time epoch in seconds
  /// after: since time epoch in seconsd
  ///
  /// return: a list of activities related to the logged athlete
  ///  null if the authentication has not been done before
  ///
  Future<List<SummaryActivity>> getLoggedInAthleteActivities(
      int before, int after, String? filterByActivityType) async {
    List<SummaryActivity> returnActivities = <SummaryActivity>[];

    var header = globals.createHeader();
    int pageNumber = 1;
    int perPage = 50; // Number of activities retrieved per http request
    bool isRetrieveDone = false;
    List<SummaryActivity> listSummary = <SummaryActivity>[];

    globals.displayInfo('Entering getLoggedInAthleteActivities');

    if (header.containsKey('88') == false) {
      do {
        final String reqActivities =
            'https://www.strava.com/api/v3/athlete/activities'
            '?before=$before&after=$after&page=$pageNumber&per_page=$perPage';

        var rep = await http.get(Uri.parse(reqActivities), headers: header);
        int nbActvity = 0;

        if (rep.statusCode == 200) {
          globals.displayInfo(rep.statusCode.toString());
          globals.displayInfo('Activities info ${rep.body}');
          // final Map<String, dynamic> jsonResponse = json.decode(rep.body);
          var jsonResponse = json.decode(rep.body);

          if (jsonResponse != null) {
            jsonResponse.forEach((summ) {
              if (null == filterByActivityType ||
                  filterByActivityType == summ["type"]) {
                var activity = SummaryActivity.fromJson(summ);
                globals.displayInfo(
                    '${activity.name} ,  ${activity.distance},  ${activity.id}');

                if (activity.type == ActivityType.VirtualRide) {
                  listSummary.add(activity);
                }

                nbActvity++;
              }
            });

            // Check if it is the last page
            globals.displayInfo(nbActvity.toString());
            if (nbActvity < perPage) {
              isRetrieveDone = true;
            } else {
              // Move to the next page
              pageNumber++;
            }

            globals.displayInfo(listSummary.toString());
            returnActivities = listSummary;
          } else {
            globals.displayInfo(
                // 'problem in getLoggedInAthleteActivities , ${returnActivities[Ø].fault.statusCode}  ${rep.body}');
                'problem in getLoggedInAthleteActivities ,  ${rep.body}');
          }

          globals.errorCheck(rep.statusCode, rep.reasonPhrase);
        } else {
          // Answer is not correct
          globals.displayInfo('return code is NOT 200');
          globals.displayInfo(rep.statusCode.toString());
          return [];
        }
      } while (!isRetrieveDone);
    } else {
      globals.displayInfo('Token not yet known');
      return [];
    }

    return returnActivities;
  }
}

Future<File> get _localActivityFile async {
  final path = await 'assets/testjson/';
  return File('$path/activities.json');
}

final activitiesFileProvider =
    FutureProvider.autoDispose<List<SummaryActivity>>((ref) async {
  List<SummaryActivity> activities = <SummaryActivity>[];
  final file = await _localActivityFile;
  try {
    final String jsonStr =
        await rootBundle.loadString('assets/testjson/activities_test.json');
    final jsonResponse = json.decode(jsonStr);
    for (var obj in jsonResponse) {
      activities.add(SummaryActivity.fromJson(obj));
    }
  } catch (e) {
    print('file load error$e.toString()');
  }
  return activities;
});

final activitiesWebProvider = FutureProvider.autoDispose
    .family<List<SummaryActivity>, DateTuple>((ref, dateRange) async {
// final activitiesProvider = FutureProvider.autoDispose<List<SummaryActivity>, DateTuple<DateTime?, DateTime?>>((ref, dateRange) async {
//   final accessToken = 'YOUR_ACCESS_TOKEN';
  // final perPage = 10;
  // final page = ref.watch(pageProvider);
  final before = dateRange.before;
  final after = dateRange.after;
  await getClient();
  var header = globals.createHeader();
  String url =
      'https://www.strava.com/api/v3/athlete/activities'; //?per_page=$perPage&page=$page';
  if (before != null) {
    url += '&before=${before}';
  }
  if (after != null) {
    url += '&after=${after}';
  }
  final response = await http.get(
    Uri.parse(url),
    headers: header,
  );
  if (response.statusCode == 200) {
    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.map((json) => SummaryActivity.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load activities: ${response.statusCode}');
  }
});

final pageProvider = StateProvider<int>((ref) => 1);

class DateTuple {
  final int before;
  final int after;

  DateTuple(this.before, this.after);
}

Future<Token?> getClient() async {
  bool isAuthOk = false;
  final Strava strava = Strava(globals.isInDebug, secret);

  // strava = Strava(globals.isInDebug, secret);
  const prompt = 'auto';

  isAuthOk = await strava.oauth(
      clientId,
      'activity:write,activity:read_all,profile:read_all,profile:write',
      secret,
      prompt);

  if (isAuthOk) {
    Token storedToken = await strava.getStoredToken();
    return storedToken;
  }

  return null;
}
