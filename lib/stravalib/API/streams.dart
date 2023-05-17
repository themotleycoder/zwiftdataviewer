import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:zwiftdataviewer/stravalib/Models/fault.dart';

import '../errorCodes.dart' as error;
import '../globals.dart' as globals;

abstract class Streams {
  Future<StreamsDetailCollection> getStreamsByActivity(String id) async {
    StreamsDetailCollection returnStreams = StreamsDetailCollection();

    var _header = globals.createHeader();

    globals.displayInfo('Entering getStreamsByActivity');

    if (_header.containsKey('88') == false) {
      final String reqStreams =
          'https://www.strava.com/api/v3/activities/$id/streams?keys=time,watts_calc,altitude,heartrate,cadence,distance,grade_smooth&key_by_type=true';
      var rep = await http.get(Uri.parse(reqStreams), headers: _header);

      if (rep.statusCode == 200) {
        globals.displayInfo(rep.statusCode.toString());
        globals.displayInfo('Activity info ${rep.body}');
        final Map<String, dynamic> jsonResponse = json.decode(rep.body);
        // final StreamsDetail _streams = StreamsDetail.fromJson(jsonResponse);
        final StreamsDetailCollection _streams =
            StreamsDetailCollection.fromJson(jsonResponse);
        // globals.displayInfo(_streams.name);

        returnStreams = _streams;
      } else {
        globals.displayInfo('Activity not found');
      }
      returnStreams.fault =
          globals.errorCheck(rep.statusCode, rep.reasonPhrase);
    } else {
      globals.displayInfo('Token not yet known');
      returnStreams.fault =
          Fault(error.statusTokenNotKnownYet, 'Token not yet known');
    }

    return returnStreams;
  }
}

class StreamsDetail {
  Fault? fault;
  Stream? distance;
  Stream? time;
  Stream? altitude;
  Stream? heartrate;
  Stream? cadence;
  Stream? watts;
  Stream? gradeSmooth;

  StreamsDetail({
    Fault? fault,
    this.distance,
    this.altitude,
    this.heartrate,
    this.cadence,
    this.watts,
    this.gradeSmooth,
  }) : fault = Fault(88, '');

  StreamsDetail.fromJson(Map<String, dynamic> json) {
    distance = Stream.fromJson(json["distance"]);
    time = Stream.fromJson(json["time"]);
    altitude = Stream.fromJson(json["altitude"]);
    heartrate = Stream.fromJson(json["heartrate"]);
    cadence = Stream.fromJson(json["cadence"]);
    watts = Stream.fromJson(json["watts_calc"]);
    gradeSmooth = Stream.fromJson(json["grade_smooth"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    // data['id'] = this.id;

    return data;
  }
}

class Stream {
  String? seriesType;
  String? resoultion;
  List<dynamic>? data;

  Stream({this.seriesType, this.resoultion, this.data});

  Stream.fromJson(Map<String, dynamic> json) {
    seriesType = json['series_type'];
    resoultion = json['resoultion'];
    if (json['data'] != null) {
      data = json['data'];
    }
  }
}

class StreamsDetailCollection {
  Fault? fault;
  List<CombinedStreams>? streams;

  StreamsDetailCollection({
    Fault? fault,
    this.streams,
  });

  StreamsDetailCollection.fromJson(Map<String, dynamic> json) {
    Stream distance = Stream.fromJson(json["distance"]);
    Stream time = Stream.fromJson(json["time"]);
    Stream altitude = Stream.fromJson(json["altitude"]);
    Stream heartrate = Stream.fromJson(json["heartrate"]);
    Stream cadence = Stream.fromJson(json["cadence"]);
    Stream watts = Stream.fromJson(json["watts_calc"]);
    Stream gradeSmooth = Stream.fromJson(json["grade_smooth"]);
    streams = <CombinedStreams>[];
    if (distance.data != null) {
      final int size = distance.data!.length ?? 0;
      for (int x = 0; x < size; x += 10) {
        // distance.data?.forEach((x) {
        streams?.add(CombinedStreams(
            distance.data![x],
            time.data![x],
            altitude.data![x],
            heartrate.data![x],
            cadence.data![x],
            watts.data![x],
            gradeSmooth.data![x]));
      }
    }
  }
}

class CombinedStreams {
  double distance;
  int time;
  double altitude;
  int heartrate;
  int cadence;
  int watts;
  double gradeSmooth;

  CombinedStreams(this.distance, this.time, this.altitude, this.heartrate,
      this.cadence, this.watts, this.gradeSmooth);
}
