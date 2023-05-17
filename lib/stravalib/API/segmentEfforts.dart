import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:zwiftdataviewer/stravalib/Models/fault.dart';
import 'package:zwiftdataviewer/stravalib/Models/segmentEffort.dart';
import 'package:zwiftdataviewer/stravalib/errorCodes.dart' as error;
import 'package:zwiftdataviewer/stravalib/globals.dart' as globals;

abstract class SegmentEfforts {
  Future<DetailedSegmentEffort> getSegmentEffortById(int segId) async {
    DetailedSegmentEffort returnSeg = DetailedSegmentEffort();

    var header = globals.createHeader();

    globals.displayInfo('Entering getSegmentEffortById');

    if (header.containsKey('88') == false) {
      final reqSeg =
          'https://www.strava.com/api/v3/segment_efforts/$segId';

      var rep = await http.get(Uri.parse(reqSeg), headers: header);

      if (rep.statusCode == 200) {
        globals.displayInfo(rep.statusCode.toString());
        if (rep.body != '[]') {
          globals.displayInfo('Segment info ${rep.body}');
          var jsonResponse = json.decode(rep.body);

          if (jsonResponse != null) {
            returnSeg = DetailedSegmentEffort.fromJson(jsonResponse);
            globals.displayInfo('${returnSeg.name}');
          }
        }
      } else {
        // No proper answer to the request
        returnSeg.fault =
            Fault(error.statusUnknownError, 'error ${rep.statusCode}');
      }
    } else {
      globals.displayInfo('Token not yet known');
      returnSeg.fault =
          Fault(error.statusTokenNotKnownYet, 'Token not yet known');
    }
    return returnSeg;
  }

  /// NOT YET WORKING
  ///
  /// scope needed:
  /// Multiple page request has not been tested yet
  ///
  Future<DetailedSegmentEffort> getEffortsbySegmentId(
      int segId, String startDateLocal, String endDateLocal) async {
    DetailedSegmentEffort returnSeg = DetailedSegmentEffort();

    var header = globals.createHeader();
    bool isRetrieveDone = false;
    int perPage = 50; // Nombre of segments retrieved by request
    int pageNumber = 1; // for debug purpose only

    globals.displayInfo('Entering getEffortsbySegmentId');

    if (header.containsKey('88') == false) {
      do {
        final reqSeg =
            'https://www.strava.com/api/v3/segment_efforts?segment_id=$segId&start_date_local=$startDateLocal&end_date_local=$endDateLocal&per_page=$perPage';

        var rep = await http.get(Uri.parse(reqSeg), headers: header);
        int nbSegments = 0;

        if (rep.statusCode == 200) {
          globals.displayInfo(rep.statusCode.toString());
          if (rep.body != '[]') {
            globals.displayInfo('Segment info ${rep.body}');
            var jsonResponse = json.decode(rep.body);

            if (jsonResponse != null) {
              jsonResponse.forEach((seg) {
                var detailedSegmentEffort =
                    DetailedSegmentEffort.fromJson(seg);
                globals.displayInfo('${detailedSegmentEffort.name}');
                // _listSummary.add(member);
                nbSegments++;
              });

              // Check if it is the last page
              globals.displayInfo(nbSegments.toString());
              if (nbSegments < perPage) {
                isRetrieveDone = true;
              } else {
                // Move to the next page
                pageNumber++;
              }

              DetailedSegmentEffort segEffort =
                  DetailedSegmentEffort.fromJson(jsonResponse[0]);
              globals.displayInfo(segEffort.name!);

              returnSeg = segEffort;
            } else {
              // The segment has been ridden by the athlete during the data range
              globals.displayInfo(
                  'Segment unknown to this athlete during date range');
              returnSeg.fault = Fault(error.statusSegmentNotRidden,
                  'Segment unknown to the athlete');
            }
          } else {
            globals.displayInfo('problem in getEffortsBySegmentId request');
            returnSeg.fault = Fault(
                error.statusUnknownError, 'Error in getEffortsbySegmentId');
          }
        }
      } while (!isRetrieveDone);
    } else {
      globals.displayInfo('Token not yet known');
      returnSeg.fault =
          Fault(error.statusTokenNotKnownYet, 'Token not yet known');
    }
    return returnSeg;
  }
}
