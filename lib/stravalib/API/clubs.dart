// clubs.dart
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:zwiftdataviewer/stravalib/Models/summary_activity.dart';

import '../Models/club.dart';
import '../Models/fault.dart';
import '../Models/summaryAthlete.dart';
import '../errorCodes.dart' as error;
import '../globals.dart' as globals;

abstract class Clubs {
  ///  Scope needed:
  /// id of the club
  /// No need to be member of the club
  Future<List<SummaryAthlete>> getClubMembersById(String id) async {
    List<SummaryAthlete> returnListMembers = <SummaryAthlete>[];
    int pageNumber = 1;
    int perPage = 30; // Number of activities retrieved per http request
    bool isRetrieveDone = false;
    List<SummaryAthlete> listSummary = <SummaryAthlete>[];

    globals.displayInfo('Entering getClubMembersById');

    var header = globals.createHeader();

    if (header.containsKey('88') == false) {
      do {
        String reqList = "https://www.strava.com/api/v3/clubs/" +
            id +
            '/members?page=$pageNumber&per_page=$perPage';

        var rep = await http.get(Uri.parse(reqList), headers: header);
        int nbMembers = 0;

        if (rep.statusCode == 200) {
          globals.displayInfo(rep.statusCode.toString());
          globals.displayInfo('List members info ${rep.body}');
          var jsonResponse = json.decode(rep.body);

          if (jsonResponse != null) {
            jsonResponse.forEach((summ) {
              var member = SummaryAthlete.fromJson(summ);
              globals.displayInfo(
                  '${member.lastname} ,  ${member.firstname},  admin:${member.admin}');
              listSummary.add(member);
              nbMembers++;
            });

            // Check if it is the last page
            globals.displayInfo(nbMembers.toString());
            if (nbMembers < perPage) {
              isRetrieveDone = true;
            } else {
              // Move to the next page
              pageNumber++;
            }

            globals.displayInfo(listSummary.toString());
            returnListMembers = listSummary;
          }
        } else {
          globals.displayInfo('Problem in getClubMembersById request');
        }

        returnListMembers[0].fault =
            globals.errorCheck(rep.statusCode, rep.reasonPhrase);
      } while (!isRetrieveDone);
    } else {
      globals.displayInfo('Token not yet known');
      returnListMembers[0].fault =
          Fault(error.statusTokenNotKnownYet, 'Token not yet known');
    }

    return returnListMembers;
  }

  /// scope
  ///
  Future<Club?> getClubById(String id) async {
    Club? returnClub;

    var header = globals.createHeader();

    if (header.containsKey('88') == false) {
      final reqClub = 'https://www.strava.com/api/v3/clubs/$id';
      var rep = await http.get(Uri.parse(reqClub), headers: header);

      if (rep.statusCode == 200) {
        globals.displayInfo(rep.statusCode.toString());
        globals.displayInfo('Club info ${rep.body}');
        final Map<String, dynamic> jsonResponse = json.decode(rep.body);

        Club club = Club.fromJson(jsonResponse);
        globals.displayInfo(club.name!);

        returnClub = club;
      } else {
        globals.displayInfo('problem in getClubById request');
        // Todo add an error code
      }
      returnClub?.fault = globals.errorCheck(rep.statusCode, rep.reasonPhrase);
    } else {
      globals.displayInfo('Token not yet known');
      returnClub?.fault =
          Fault(error.statusTokenNotKnownYet, 'Token not yet known');
    }

    return returnClub;
  }

  /// Need to be member of the club
  ///
  Future<List<SummaryActivity>> getClubActivitiesById(String id) async {
    List<SummaryActivity> returnSummary = <SummaryActivity>[];

    var header = globals.createHeader();
    int pageNumber = 1;
    int perPage = 20; // Number of activities retrieved per http request
    bool isRetrieveDone = false;
    List<SummaryActivity> listSummary = <SummaryActivity>[];

    if (header.containsKey('88') == false) {
      do {
        String reqClub =
            'https://www.strava.com/api/v3/clubs/$id/activities?page=$pageNumber&per_page=$perPage';
        var rep = await http.get(Uri.parse(reqClub), headers: header);
        int nbActvity = 0;

        if (rep.statusCode == 200) {
          globals.displayInfo(rep.statusCode.toString());
          // globals.displayInfo('Club activity ${rep.body}');
          var jsonResponse = json.decode(rep.body);

          if (jsonResponse != null) {
            jsonResponse.forEach((summ) {
              var activity = SummaryActivity.fromJson(summ);
              globals.displayInfo(
                  '------ ${activity.name} ,  ${activity.distance},  ${activity.id}');
              listSummary.add(activity);
              nbActvity++;
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
            returnSummary = listSummary;
          }
        } else {
          globals.displayInfo('problem in getClubActivitiesById request');
          globals.displayInfo('answer ${rep.body}');
          returnSummary[0].fault =
              globals.errorCheck(rep.statusCode, rep.reasonPhrase);
        }

        returnSummary[0].fault =
            globals.errorCheck(rep.statusCode, rep.reasonPhrase);
      } while (!isRetrieveDone);
    } else {
      globals.displayInfo('Token not yet known');
      returnSummary[0].fault =
          Fault(error.statusTokenNotKnownYet, 'Token not yet known');
    }

    return returnSummary;
  }
}
