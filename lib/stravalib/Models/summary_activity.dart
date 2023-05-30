import 'package:intl/intl.dart';
import 'package:zwiftdataviewer/stravalib/Models/athlete.dart';

import 'fault.dart';

class SummaryActivity {
  int resourceState;
  Athlete athlete; //Replace with the actual class
  String name;
  double distance;
  int movingTime;
  int elapsedTime;
  double totalElevationGain;
  String type;
  String sportType;
  int id;
  DateTime startDate;
  DateTime startDateLocal;
  String timezone;
  double utcOffset;
  String? locationCity;
  String? locationState;
  String locationCountry;
  int achievementCount;
  int kudosCount;
  int commentCount;
  int athleteCount;
  int photoCount;

  // dynamic map; //Replace with the actual class
  bool trainer;
  bool commute;
  bool manual;
  bool private;
  String visibility;
  bool flagged;
  String? gearId;
  LatLng startLatlng;
  LatLng endLatlng;
  double averageSpeed;
  double maxSpeed;
  double averageCadence;
  double averageWatts;
  int maxWatts;
  int weightedAverageWatts;
  double kilojoules;
  bool deviceWatts;
  bool hasHeartrate;
  double averageHeartrate;
  double maxHeartrate;
  bool heartrateOptOut;
  bool displayHideHeartrateOption;
  double elevHigh;
  double elevLow;
  int uploadId;
  String uploadIdStr;
  String externalId;
  bool fromAcceptedTag;
  int prCount;
  int totalPhotoCount;
  bool hasKudoed;
  Fault? fault;

  SummaryActivity({
    required this.resourceState,
    required this.athlete,
    required this.name,
    required this.distance,
    required this.movingTime,
    required this.elapsedTime,
    required this.totalElevationGain,
    required this.type,
    required this.sportType,
    required this.id,
    required this.startDate,
    required this.startDateLocal,
    required this.timezone,
    required this.utcOffset,
    this.locationCity,
    this.locationState,
    required this.locationCountry,
    required this.achievementCount,
    required this.kudosCount,
    required this.commentCount,
    required this.athleteCount,
    required this.photoCount,
    // required this.map,
    required this.trainer,
    required this.commute,
    required this.manual,
    required this.private,
    required this.visibility,
    required this.flagged,
    this.gearId,
    required this.startLatlng,
    required this.endLatlng,
    required this.averageSpeed,
    required this.maxSpeed,
    required this.averageCadence,
    required this.averageWatts,
    required this.maxWatts,
    required this.weightedAverageWatts,
    required this.kilojoules,
    required this.deviceWatts,
    required this.hasHeartrate,
    required this.averageHeartrate,
    required this.maxHeartrate,
    required this.heartrateOptOut,
    required this.displayHideHeartrateOption,
    required this.elevHigh,
    required this.elevLow,
    required this.uploadId,
    required this.uploadIdStr,
    required this.externalId,
    required this.fromAcceptedTag,
    required this.prCount,
    required this.totalPhotoCount,
    required this.hasKudoed,
  });

  factory SummaryActivity.fromJson(Map<String, dynamic> json) {
    return SummaryActivity(
      resourceState: json['resource_state'] ?? 0,
      athlete: Athlete.fromJson(json['athlete']),
      name: json['name'],
      distance: (json['distance'] ?? 0).toDouble(),
      movingTime: json['moving_time'],
      elapsedTime: json['elapsed_time'],
      totalElevationGain: (json['total_elevation_gain'] ?? 0).toDouble(),
      type: json['type'],
      sportType: json['sport_type'],
      id: json['id'],
      startDate: DateTime.parse(json['start_date']),
      startDateLocal: DateTime.parse(json['start_date_local']),
      //     startDate =
//         json['start_date'] != null ? _parseDate(json['start_date']) : null;
//     startDateLocal = json['start_date_local'] != null
//         ? _parseDate(json['start_date_local'])
//         : null;
      timezone: json['timezone'],
      utcOffset: (json['utc_offset'] ?? 0).toDouble(),
      locationCity: json['location_city'],
      locationState: json['location_state'],
      locationCountry: json['location_country'],
      achievementCount: json['achievement_count'],
      kudosCount: json['kudos_count'],
      commentCount: json['comment_count'],
      athleteCount: json['athlete_count'],
      photoCount: json['photo_count'],
      // map: json['map'],
      trainer: json['trainer'],
      commute: json['commute'],
      manual: json['manual'],
      private: json['private'],
      visibility: json['visibility'],
      flagged: json['flagged'],
      gearId: json['gear_id'],
      startLatlng: LatLng.fromJson(json['start_latlng']),
      endLatlng: LatLng.fromJson(json['end_latlng']),
      averageSpeed: (json['average_speed'] ?? 0).toDouble(),
      maxSpeed: (json['max_speed'] ?? 0).toDouble(),
      averageCadence: (json['average_cadence'] ?? 0).toDouble(),
      averageWatts: (json['average_watts'] ?? 0).toDouble(),
      maxWatts: json['max_watts'] ?? 0,
      weightedAverageWatts: json['weighted_average_watts'] ?? 0,
      kilojoules: (json['kilojoules'] ?? 0).toDouble(),
      deviceWatts: json['device_watts'] ?? false,
      hasHeartrate: json['has_heartrate'],
      averageHeartrate: (json['average_heartrate'] ?? 0).toDouble(),
      maxHeartrate: (json['max_heartrate'] ?? 0).toDouble(),
      heartrateOptOut: json['heartrate_opt_out'],
      displayHideHeartrateOption: json['display_hide_heartrate_option'],
      elevHigh: (json['elev_high'] ?? 0).toDouble(),
      elevLow: (json['elev_low'] ?? 0).toDouble(),
      uploadId: json['upload_id'],
      uploadIdStr: json['upload_id_str'],
      externalId: json['external_id'],
      fromAcceptedTag: json['from_accepted_tag'],
      prCount: json['pr_count'],
      totalPhotoCount: json['total_photo_count'],
      hasKudoed: json['has_kudoed'],
    );
  }

  Map<String, dynamic> toJson() => {
        'resource_state': resourceState,
        'athlete': athlete.toJson(),
        'name': name,
        'distance': distance,
        'moving_time': movingTime,
        'elapsed_time': elapsedTime,
        'total_elevation_gain': totalElevationGain,
        'type': type,
        'sport_type': sportType,
        'id': id,
        'start_date': startDate.toIso8601String(),
        'start_date_local': startDateLocal.toIso8601String(),
        'timezone': timezone,
        'utc_offset': utcOffset,
        'location_city': locationCity,
        'location_state': locationState,
        'location_country': locationCountry,
        'achievement_count': achievementCount,
        'kudos_count': kudosCount,
        'comment_count': commentCount,
        'athlete_count': athleteCount,
        'photo_count': photoCount,
        // 'map': map,
        'trainer': trainer,
        'commute': commute,
        'manual': manual,
        'private': private,
        'visibility': visibility,
        'flagged': flagged,
        'gear_id': gearId,
        'start_latlng': startLatlng.toJson(),
        'end_latlng': endLatlng.toJson(),
        'average_speed': averageSpeed,
        'max_speed': maxSpeed,
        'average_cadence': averageCadence,
        'average_watts': averageWatts,
        'max_watts': maxWatts,
        'weighted_average_watts': weightedAverageWatts,
        'kilojoules': kilojoules,
        'device_watts': deviceWatts,
        'has_heartrate': hasHeartrate,
        'average_heartrate': averageHeartrate,
        'max_heartrate': maxHeartrate,
        'heartrate_opt_out': heartrateOptOut,
        'display_hide_heartrate_option': displayHideHeartrateOption,
        'elev_high': elevHigh,
        'elev_low': elevLow,
        'upload_id': uploadId,
        'upload_id_str': uploadIdStr,
        'external_id': externalId,
        'from_accepted_tag': fromAcceptedTag,
        'pr_count': prCount,
        'total_photo_count': totalPhotoCount,
        'has_kudoed': hasKudoed,
      };

  DateTime _parseDate(String dateTimeToParse) {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateFormat timeFormat = DateFormat.Hms();

    List<String> dateTimeSplit = dateTimeToParse.split("T");
    List<String> timeSplit = dateTimeSplit[1].split("Z");
    DateTime date = dateFormat.parse(dateTimeSplit[0]);
    DateTime time = timeFormat.parse(timeSplit[0]);
    return DateTime(
        date.year, date.month, date.day, time.hour, time.minute, time.second);
  }
}

SummaryActivity emptyActivity = SummaryActivity(
  resourceState: 1,
  athlete: Athlete(
    id: 0,
    resourceState: 0,
  ),
  name: '',
  distance: 0,
  movingTime: 0,
  elapsedTime: 0,
  totalElevationGain: 0,
  type: 'Bike',
  // workoutType: 'VirtualRide',
  id: 123456789,
  externalId: '0',
  uploadId: 0,
  startDate: DateTime.now(),
  startDateLocal: DateTime.now(),
  timezone: 'UTC',
  utcOffset: 0,
  locationCity: null,
  locationState: null,
  locationCountry: '',
  startLatlng: LatLng(lat: 0, lng: 0),
  endLatlng: LatLng(lat: 0, lng: 0),
  achievementCount: 0,
  kudosCount: 0,
  commentCount: 0,
  athleteCount: 1,
  photoCount: 0,
  trainer: false,
  commute: false,
  manual: false,
  private: false,
  visibility: 'everyone',
  flagged: false,
  gearId: null,
  fromAcceptedTag: false,
  averageSpeed: 2.78,
  maxSpeed: 5.55,
  averageCadence: 0,
  averageWatts: 0,
  weightedAverageWatts: 0,
  kilojoules: 0,
  deviceWatts: true,
  hasHeartrate: false,
  averageHeartrate: 0.0,
  maxHeartrate: 0.0,
  heartrateOptOut: false,
  displayHideHeartrateOption: false,
  elevHigh: 0,
  elevLow: 0,
  prCount: 0,
  totalPhotoCount: 0,
  hasKudoed: false,
  sportType: 'cycling',
  maxWatts: 0,
  uploadIdStr: '',
);

class LatLng {
  double lat;
  double lng;

  LatLng({required this.lat, required this.lng});

  factory LatLng.fromJson(List<dynamic> json) {
    return LatLng(
      lat: json[0],
      lng: json[1],
    );
  }

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
      };
}
