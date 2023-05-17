// races.dart

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../Models/fault.dart';
import '../Models/runningRace.dart';
import '../errorCodes.dart' as error;
import '../globals.dart' as globals;

abstract class Races {
  /// getRunningRacebyId
  ///
  /// Scope needed: none
  ///
  /// Answer has route_ids [int]
  Future<RunningRace> getRunningRaceById(String id) async {
    RunningRace returnRace = RunningRace();

    globals.displayInfo('Entering getRunningRaceById');

    var header = globals.createHeader();

    if (header.containsKey('88') == false) {
      final reqRace = 'https://www.strava.com/api/v3/running_races/$id';

      var rep = await http.get(Uri.parse(reqRace), headers: header);
      if (rep.statusCode == 200) {
        globals.displayInfo('Race info ${rep.body}');
        final Map<String, dynamic> jsonResponse = json.decode(rep.body);

        if (jsonResponse != null) {
          returnRace = RunningRace.fromJson(jsonResponse);
        } else {
          globals.displayInfo('problem in getRunningRaceById request');
        }
      }
      returnRace.fault = globals.errorCheck(rep.statusCode, rep.reasonPhrase);
    } else {
      globals.displayInfo('Token not yet known');
      returnRace.fault =
          Fault(error.statusTokenNotKnownYet, 'Token not yet known');
    }

    return returnRace;
  }

  /// Scope needed: none
  /// Answer has NO route_ids for the moment
  Future<List<RunningRace>> getRunningRaces(String year) async {
    List<RunningRace> returnListRaces = <RunningRace>[];

    globals.displayInfo('Entering getRunningRaces');

    var header = globals.createHeader();

    if (header.containsKey('88') == false) {
      final reqList =
          'https://www.strava.com/api/v3/running_races?year=$year';

      var rep = await http.get(Uri.parse(reqList), headers: header);
      if (rep.statusCode == 200) {
        // globals.displayInfo('List races info ${rep.body}');
        var jsonResponse = json.decode(rep.body);

        if (jsonResponse != null) {
          List<RunningRace> listRaces = <RunningRace>[];

          jsonResponse.forEach((element) {
            var race = RunningRace.fromJson(element);
            globals.displayInfo(
                '${race.name} ,  ${race.startDateLocal}    ${race.id}');
            listRaces.add(race);
          });

          returnListRaces = listRaces;
        } else {
          globals.displayInfo('problem in getRunningRaces request');
        }
      }
      returnListRaces[0].fault =
          globals.errorCheck(rep.statusCode, rep.reasonPhrase);
    } else {
      globals.displayInfo('Token not yet known');
      returnListRaces[0].fault =
          Fault(error.statusTokenNotKnownYet, 'Token not yet known');
    }
    return returnListRaces;
  }
}
