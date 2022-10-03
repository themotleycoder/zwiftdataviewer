import 'package:zwiftdataviewer/stravalib/Models/athlete.dart';

import 'fault.dart';

class DetailedSegmentEffort {
  Fault? fault;
  int? id;
  int? resourceState;
  String? name;
  ActivityEffort? activity;
  Athlete? athlete;
  int? elapsedTime;
  String? startDate;
  String? startDateLocal;
  double? distance;
  int? movingTime;
  int? startIndex;
  int? endIndex;
  bool? deviceWatts;
  double? averageWatts;
  SegmentEffort? segment;

  int? komRank;
  int? prRank;
  List<dynamic>? achievements; // could be a list of something

  DetailedSegmentEffort({
    Fault? fault,
    this.id,
    this.resourceState,
    this.name,
    this.activity,
    this.athlete,
    this.elapsedTime,
    this.startDate,
    this.startDateLocal,
    this.distance,
    this.movingTime,
    this.startIndex,
    this.endIndex,
    this.deviceWatts,
    this.averageWatts,
    this.segment,
    this.komRank,
    this.prRank,
    this.achievements,
  });

  DetailedSegmentEffort.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    resourceState = json['resource_state'];
    name = json['name'];
    activity = ActivityEffort.fromJson(json['activity']);
    athlete = Athlete.fromJson(json['athlete']);
    elapsedTime = json['elapsed_time'];
    startDate = json['start_date'];
    startDateLocal = json['start_date_local'];
    distance = json['distance'];
    movingTime = json['moving_time'];
    startIndex = json['start_index'];
    endIndex = json['end_index'];
    deviceWatts = json['device_watts'];
    averageWatts = json['average_watts'];
    segment = SegmentEffort.fromJson(json['segment']);
    komRank = json['kom_rank'];
    prRank = json['pr_rank'];
    achievements = json['achievements'] ?? '0';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['resource_state'] = this.resourceState;
    data['name'] = this.name;
    data['activity_type'] = this.activity;
    data['athlete'] = this.athlete;
    data['elapsed_time'] = this.elapsedTime;
    data['start_date'] = this.startDate;
    data['start_date_local'] = this.startDateLocal;
    data['distance'] = this.distance;

    data['moving_time'] = this.movingTime;
    data['start_index'] = this.startIndex;
    data['end_index'] = this.endIndex;
    data['device_watts'] = this.deviceWatts;
    data['average_watts'] = this.averageWatts;
    data['segment'] = this.segment;
    data['kom_rank'] = this.komRank;
    data['pr_rank'] = this.prRank;
    data['achievements'] = this.averageWatts;
    return data;
  }
}

class SegmentEffort {
  Fault? fault;
  int? id;
  int? resourceState;
  String? name;
  String? activityType;
  double? distance;
  double? averageGrade;
  double? maximumGrade;
  double? elevationHigh;
  double? elevationLow;
  List<double>? startLatlng;
  List<double>? endLatlng;
  double? startLatitude;
  double? startLongitude;
  double? endLatitude;
  double? endLongitude;
  int? climbCategory;
  String? city;
  String? state;
  String? country;
  bool? private;
  bool? hazardous;
  bool? starred;
  int? elapsedTime;
  int? movingTime;
  String? startDate;
  String? startDateLocal;
  AthleteEffort? athlete;
  ActivityEffort? activity;
  int? startIndex;
  int? endIndex;
  double? averageCadence;
  bool? deviceWatts;
  double? averageWatts;
  double? averageHeartrate;
  double? maxHeartrate;
  int? prRank;
  List? achievements;
  bool? hidden;
  Segment? segment;

//   {
//     "id": 2722611526101492964,
//     "resource_state": 2,
//     "name": "Pooper Scooper",
//     "activity": {
//         "id": 3816851577,
//         "resource_state": 1
//     },
//     "athlete": {
//         "id": 5187165,
//         "resource_state": 1
//     },
//     "elapsed_time": 114,
//     "moving_time": 114,
//     "start_date": "2020-07-26T22:23:26Z",
//     "start_date_local": "2020-07-26T15:23:26Z",
//     "distance": 1020.3,
//     "start_index": 0,
//     "end_index": 114,
//     "average_cadence": 93.2,
//     "device_watts": true,
//     "average_watts": 179.6,
//     "average_heartrate": 131.3,
//     "max_heartrate": 142.0,
//     "segment": {
//         "id": 19360689,
//         "resource_state": 2,
//         "name": "Pooper Scooper",
//         "activity_type": "VirtualRide",
//         "distance": 1020.3,
//         "average_grade": 0.1,
//         "maximum_grade": 3.1,
//         "elevation_high": 4.4,
//         "elevation_low": 1.4,
//         "start_latlng": [
//             -11.63842,
//             166.948893
//         ],
//         "end_latlng": [
//             -11.636699,
//             166.95537
//         ],
//         "start_latitude": -11.63842,
//         "start_longitude": 166.948893,
//         "end_latitude": -11.636699,
//         "end_longitude": 166.95537,
//         "climb_category": 0,
//         "city": null,
//         "state": "Temotu Province",
//         "country": "Solomon Islands",
//         "private": false,
//         "hazardous": false,
//         "starred": false
//     },
//     "pr_rank": null,
//     "achievements": [],
//     "hidden": false
// },

  SegmentEffort({
    Fault? fault,
    this.id,
    this.resourceState,
    this.name,
    this.activityType,
    this.distance,
    this.averageGrade,
    this.maximumGrade,
    this.elevationHigh,
    this.elevationLow,
    this.startLatlng,
    this.endLatlng,
    this.startLatitude,
    this.startLongitude,
    this.endLatitude,
    this.endLongitude,
    this.climbCategory,
    this.city,
    this.state,
    this.country,
    this.private,
    this.hazardous,
    this.starred,
    this.elapsedTime,
    this.movingTime,
    this.startDate,
    this.startDateLocal,
    this.startIndex,
    this.endIndex,
    this.averageCadence,
    this.deviceWatts,
    this.averageWatts,
    this.averageHeartrate,
    this.maxHeartrate,
  });

  SegmentEffort.fromJson(Map<String, dynamic> json) {
    // id = json['id'];
    // resourceState = json['resource_state'];
    // name = json['name'];
    // activityType = json['activity_type'];
    // distance = json['distance'];
    // averageGrade = json['average_grade'];
    // maximumGrade = json['maximum_grade'];
    // elevationHigh = json['elevation_high'];
    // elevationLow = json['elevation_low'];
    // startLatlng = (json['start_latlng'] != null)
    //     ? json['start_latlng'].cast<double>()
    //     : [globals.defaultStartLatlng, globals.defaultEndlatlng];
    // endLatlng = (json['end_latlng'] != null)
    //     ? json['end_latlng'].cast<double>()
    //     : [globals.defaultStartLatlng, globals.defaultEndlatlng];
    // startLatlng =
    //     json['start_latlng'] == null ? [] : json['start_latlng'].cast<double>();
    // endLatlng =
    //     json['end_latlng'] == null ? [] : json['end_latlng'].cast<double>();
    // startLatitude = json['start_latitude'];
    // startLongitude = json['start_longitude'];
    // endLatitude = json['end_latitude'];
    // endLongitude = json['end_longitude'];
    // climbCategory = json['climb_category'];
    // city = json['city'];
    // state = json['state'];
    // country = json['country'];
    // private = json['private'];
    // hazardous = json['hazardous'];
    // starred = json['starred'];
    // elapsedTime = json['elapsed_time'];
    // movingTime = json['moving_time'];
    // startDate = json['start_date'];
    // startDateLocal = json['start_date_local'];

    id = json['id'];
    resourceState = json['resource_state'];
    name = json['name": "Pooper Scooper'];
    activity = ActivityEffort.fromJson(json['activity']);
    athlete = AthleteEffort.fromJson(json['athlete']);
    elapsedTime = json['elapsed_time'];
    movingTime = json['moving_time'];
    startDate = json['start_date'];
    startDateLocal = json['start_date_local'];
    distance = json['distance'];
    startIndex = json['start_index'];
    endIndex = json['end_index'];
    averageCadence = json['average_cadence'];
    deviceWatts = json['device_watts'];
    averageWatts = json['average_watts'];
    averageHeartrate = json['average_heartrate'];
    maxHeartrate = json['max_heartrate'];
    segment = Segment.fromJson(json['segment']);
    prRank = json['pr_rank'];
    achievements = json['achievements'];
    hidden = json['hidden'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['resource_state'] = this.resourceState;
    data['name'] = this.name;
    data['activity_type'] = this.activityType;
    data['distance'] = this.distance;
    data['average_grade'] = this.averageGrade;
    data['maximum_grade'] = this.maximumGrade;
    data['elevation_high'] = this.elevationHigh;
    data['elevation_low'] = this.elevationLow;
    data['start_latlng'] = this.startLatlng;
    data['end_latlng'] = this.endLatlng;
    data['start_latitude'] = this.startLatitude;
    data['start_longitude'] = this.startLongitude;
    data['end_latitude'] = this.endLatitude;
    data['end_longitude'] = this.endLongitude;
    data['climb_category'] = this.climbCategory;
    data['city'] = this.city;
    data['state'] = this.state;
    data['country'] = this.country;
    data['private'] = this.private;
    data['hazardous'] = this.hazardous;
    data['starred'] = this.starred;
    data['elapsed_time'] = this.elapsedTime;
    data['moving_time'] = this.movingTime;
    data['start_date'] = this.startDate;
    data['start_date_local'] = this.startDateLocal;
    data['segment'] = this.segment!.toJson();

    return data;
  }

// Segment parseSegment(Map<String, dynamic> json) {
//   Segment segment = new Segment();
//   segment.id = json['id'];
//   segment.resourceState = json['resource_state'];
//   segment.name = json['name'];
//   segment.activityType = json['activity_type'];
//   segment.distance = json['distance'];
//   segment.averageGrade = json['average_grade'];
//   segment.maximumGrade = json['maximum_grade'];
//   segment.elevationHigh = json['elevation_high'];
//   segment.elevationLow = json['elevation_low'];
//   // "start_latlng": [
//   //     -11.63842,
//   //     166.948893
//   // ],
//   // "end_latlng": [
//   //     -11.636699,
//   //     166.95537
//   // ],
//   segment.startLatitude = json['start_latitude'];
//   segment.startLongitude = json['start_longitude'];
//   segment.endLatitude = json['end_latitude'];
//   segment.endLongitude = json['end_longitude'];
//   segment.climbCategory = json['climb_category'];
//   segment.city = json['city'];
//   segment.state = json['state'];
//   segment.country = json['country'];
//   segment.private = json['private'];
//   segment.hazardous = json['hazardous'];
//   segment.starred = json['starred'];
//   return segment;
// }
}

class ActivityEffort {
  int? id;
  int? resourceState;

  ActivityEffort({
    this.id,
    this.resourceState,
  });

  ActivityEffort.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    resourceState = json['resource_state'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['resource_state'] = this.resourceState;

    return data;
  }
}

class AthleteEffort {
  int? id;
  int? resourceState;

  AthleteEffort({
    this.id,
    this.resourceState,
  });

  AthleteEffort.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    resourceState = json['resource_state'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['resource_state'] = this.resourceState;

    return data;
  }
}

class Segment {
  int? id;
  int? resourceState;
  String? name;
  String? activityType;
  double? distance;
  double? averageGrade;
  double? maximumGrade;
  double? elevationHigh;
  double? elevationLow;

  //         "start_latlng": [
  //             -11.63842,
  //             166.948893
  //         ],
  //         "end_latlng": [
  //             -11.636699,
  //             166.95537
  //         ],
  double? startLatitude;
  double? startLongitude;
  double? endLatitude;
  double? endLongitude;
  int? climbCategory;
  String? city;
  String? state;
  String? country;
  bool? private;
  bool? hazardous;
  bool? starred;

  Segment({
    this.id,
    this.resourceState,
    this.name,
    this.activityType,
    this.distance,
    this.averageGrade,
    this.maximumGrade,
    this.elevationHigh,
    this.elevationLow,
    //         "start_latlng": [
    //             -11.63842,
    //             166.948893
    //         ],
    //         "end_latlng": [
    //             -11.636699,
    //             166.95537
    //         ],
    this.startLatitude,
    this.startLongitude,
    this.endLatitude,
    this.endLongitude,
    this.climbCategory,
    this.city,
    this.state,
    this.country,
    this.private,
    this.hazardous,
    this.starred,
  });

  Segment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    resourceState = json['resource_state'];
    name = json['name'];
    activityType = json['activity_type'];
    distance = json['distance'];
    averageGrade = json['average_grade'];
    maximumGrade = json['maximum_grade'];
    elevationHigh = json['elevation_high'];
    elevationLow = json['elevation_low'];
    // "start_latlng": [
    //     -11.63842,
    //     166.948893
    // ],
    // "end_latlng": [
    //     -11.636699,
    //     166.95537
    // ],
    startLatitude = json['start_latitude'];
    startLongitude = json['start_longitude'];
    endLatitude = json['end_latitude'];
    endLongitude = json['end_longitude'];
    climbCategory = json['climb_category'];
    city = json['city'];
    state = json['state'];
    country = json['country'];
    private = json['private'];
    hazardous = json['hazardous'];
    starred = json['starred'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['resource_state'] = resourceState;
    data['name'] = name;
    data['activity_type'] = activityType;
    data['distance'] = distance;
    data['average_grade'] = averageGrade;
    data['maximum_grade'] = maximumGrade;
    data['elevation_high'] = elevationHigh;
    data['elevation_low'] = elevationLow;
    // "start_latlng": [
    //     -11.63842,
    //     166.948893
    // ],
    // "end_latlng": [
    //     -11.636699,
    //     166.95537
    // ],
    data['start_latitude'] = startLatitude;
    data['start_longitude'] = startLongitude;
    data['end_latitude'] = endLatitude;
    data['end_longitude'] = endLongitude;
    data['climb_category'] = climbCategory;
    data['city'] = city;
    data['state'] = state;
    data['country'] = country;
    data['private'] = private;
    data['hazardous'] = hazardous;
    data['starred'] = starred;

    return data;
  }
}
