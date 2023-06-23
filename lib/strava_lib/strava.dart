import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'API/Oauth.dart';
import 'API/activities.dart';
import 'API/athletes.dart';
import 'API/clubs.dart';
import 'API/races.dart';
import 'API/segmentEfforts.dart';
import 'API/segments.dart';
import 'API/streams.dart';
import 'API/upload.dart';
import 'Models/fault.dart';
import 'Models/gear.dart';
import 'errorCodes.dart' as error;
import 'globals.dart' as globals;

/// Initialize the Strava API
///  clientID: ID of your Strava app
/// redirectURL: url that will be called after Strava authorize your app
/// prompt: to choose to ask Strava always to authenticate or only when needed (with 'auto')
/// scope: Strava scope check https://developers.strava.com/docs/oauth-updates/
class Strava
    with
        Upload,
        Activities,
        Auth,
        Clubs,
        Segments,
        SegmentEfforts,
        Athletes,
        Races,
        Streams {
  String? secret;

  /// Initialize the Strava class
  /// Needed to call Strava API
  ///
  /// secretKey is the key found in strava settings my Application (secret key)
  /// Set isIndebug to true to get debug print in strava API
  Strava(bool isInDebug, String secretKey) {
    globals.isInDebug = isInDebug;
    secret = secretKey;
  }

  /// Scope needed: any
  /// Give answer only if id is related to logged athlete
  ///
  Future<Gear> getGearById(String id) async {
    Gear returnGear = Gear();

    globals.displayInfo('Entering getGearById');

    var header = globals.createHeader();

    if (header.containsKey('88') == false) {
      // final reqGear = 'https://www.strava.com/api/v3/gear/' + id;
      final Uri reqGear = Uri.parse('https://www.strava.com/api/v3/gear/$id');
      var rep = await http.get(reqGear, headers: header);

      if (rep.statusCode == 200) {
        globals.displayInfo(rep.statusCode.toString());
        globals.displayInfo(' ${rep.body}');
        final Map<String, dynamic> jsonResponse = json.decode(rep.body);

        Gear gear = Gear.fromJson(jsonResponse);
        gear.fault = Fault(88, '');
        globals.displayInfo(gear.description!);
        gear.fault?.statusCode = error.statusOk;
        returnGear = gear;
      } else {
        globals.displayInfo('Problem in getGearById');
      }
      returnGear.fault = globals.errorCheck(rep.statusCode, rep.reasonPhrase);
    }

    return returnGear;
  }

  void dispose() {
    onCodeReceived.close();
  }
}
