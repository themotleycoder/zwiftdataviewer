// Activity

import 'package:intl/intl.dart';
import 'package:zwiftdataviewer/stravalib/Models/athlete.dart';
import 'package:zwiftdataviewer/stravalib/Models/segmentEffort.dart';

import '../globals.dart' as globals;
import 'fault.dart';
import 'gear.dart';

class DetailedActivity {
  Fault? fault;
  int? id;
  int? resourceState;
  String? externalId;
  int? uploadId;
  Athlete? athlete;
  String? name;
  double? distance = 0.0;
  int? movingTime = 0;
  int? elapsedTime = 0;
  double? totalElevationGain = 0.0;
  String? type;
  String? startDate;
  String? startDateLocal;
  String? timezone;
  double? utcOffset;
  List<double>? startLatlng;
  List<double>? endLatlng;
  double? startLatitude;
  double? startLongitude;
  int? achievementCount;
  int? kudosCount;
  int? commentCount;
  int? athleteCount;
  int? photoCount;
  Carte? map;
  bool? trainer;
  bool? commute;
  bool? manual;
  bool? private;
  bool? flagged;
  String? gearId;
  bool? fromAcceptedTag;
  double? averageSpeed;
  double? maxSpeed;
  double? averageCadence;
  int? averageTemp;
  double? averageWatts;
  int? weightedAverageWatts;
  double? kilojoules;
  bool? deviceWatts;
  bool? hasHeartrate;
  double? averageHeartrate;
  double? maxHeartrate;
  int? maxWatts;
  double? elevHigh;
  double? elevLow;
  int? prCount;
  int? totalPhotoCount;
  bool? hasKudoed;
  int? workoutType;
  double? sufferScore;
  String? description;
  double? calories;
  List<SegmentEffort>? segmentEfforts;
  List<SplitsMetric>? splitsMetric;
  List<Laps>? laps;
  Gear? gear;
  String? partnerBrandTag;
  Photos? photos;
  List<HighlightedKudosers>? highlightedKudosers;
  String? deviceName;
  String? embedToken;
  bool? segmentLeaderboardOptOut;
  bool? leaderboardOptOut;

  DetailedActivity(
      {Fault? fault,
      this.id,
      this.resourceState,
      this.externalId,
      this.uploadId,
      this.athlete,
      this.name,
      this.distance,
      this.movingTime,
      this.elapsedTime,
      this.totalElevationGain,
      this.type,
      this.startDate,
      this.startDateLocal,
      this.timezone,
      this.utcOffset,
      this.startLatlng,
      this.endLatlng,
      this.startLatitude,
      this.startLongitude,
      this.achievementCount,
      this.kudosCount,
      this.commentCount,
      this.athleteCount,
      this.photoCount,
      this.map,
      this.trainer,
      this.commute,
      this.manual,
      this.private,
      this.flagged,
      this.gearId,
      this.fromAcceptedTag,
      this.averageSpeed,
      this.maxSpeed,
      this.averageCadence,
      this.averageTemp,
      this.averageWatts,
      this.weightedAverageWatts,
      this.kilojoules,
      this.deviceWatts,
      this.hasHeartrate,
      this.averageHeartrate,
      this.maxHeartrate,
      this.maxWatts,
      this.elevHigh,
      this.elevLow,
      this.prCount,
      this.totalPhotoCount,
      this.hasKudoed,
      this.workoutType,
      this.sufferScore,
      this.description,
      this.calories,
      this.segmentEfforts,
      this.splitsMetric,
      this.laps,
      this.gear,
      this.partnerBrandTag,
      this.photos,
      this.highlightedKudosers,
      this.deviceName,
      this.embedToken,
      this.segmentLeaderboardOptOut,
      this.leaderboardOptOut})
      : fault = Fault(88, '');

  DetailedActivity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    resourceState = json['resource_state'] ?? 0;
    externalId = json['external_id'];
    uploadId = json['upload_id'];
    athlete =
        json['athlete'] != null ? Athlete.fromJson(json['athlete']) : null;
    name = json['name'];
    distance = json['distance'];
    movingTime = json['moving_time'];
    elapsedTime = json['elapsed_time'];
    totalElevationGain = json['total_elevation_gain'].toDouble();
    type = json['type'];
    startDate = json['start_date'];
    startDateLocal = json['start_date_local'];
    timezone = json['timezone'];
    utcOffset = json['utc_offset'];
    // startLatlng = json['start_latlng'].cast<double>();
    startLatlng = (json['start_latlng'] != null)
        ? json['start_latlng'].cast<double>()
        : [globals.defaultStartLatlng, globals.defaultEndlatlng];

    // endLatlng = json['end_latlng'].cast<double>();
    endLatlng = (json['end_latlng'] != null)
        ? json['end_latlng'].cast<double>()
        : [globals.defaultStartLatlng, globals.defaultEndlatlng];

    startLatitude = json['start_latitude'];
    startLongitude = json['start_longitude'];
    achievementCount = json['achievement_count'];
    kudosCount = json['kudos_count'];
    commentCount = json['comment_count'];
    athleteCount = json['athlete_count'];
    photoCount = json['photo_count'];
    map = json['map'] != null ? Carte.fromJson(json['map']) : null;
    trainer = json['trainer'];
    commute = json['commute'];
    manual = json['manual'];
    private = json['private'];
    flagged = json['flagged'];
    gearId = json['gear_id'];
    fromAcceptedTag = json['from_accepted_tag'];
    averageSpeed = json['average_speed'];
    maxSpeed = json['max_speed'];
    averageCadence = json['average_cadence'];
    averageTemp = json['average_temp'];
    averageWatts = json['average_watts'];
    weightedAverageWatts = json['weighted_average_watts'];
    kilojoules = json['kilojoules'];
    deviceWatts = json['device_watts'];
    hasHeartrate = json['has_heartrate'];
    averageHeartrate = json['average_heartrate'];
    maxHeartrate = json['max_heartrate'];
    maxWatts = json['max_watts'];
    elevHigh = json['elev_high'];
    elevLow = json['elev_low'];
    prCount = json['pr_count'];
    totalPhotoCount = json['total_photo_count'];
    hasKudoed = json['has_kudoed'];
    workoutType = json['workout_type'] ?? 10; //
    sufferScore = json['suffer_score'];
    description = json['description'];
    calories = (json['calories']).toDouble();
    if (json['segment_efforts'] != null) {
      segmentEfforts = <SegmentEffort>[];
      json['segment_efforts'].forEach((v) {
        segmentEfforts?.add(SegmentEffort.fromJson(v));
      });
    }
    if (json['splits_metric'] != null) {
      splitsMetric = <SplitsMetric>[];
      json['splits_metric'].forEach((v) {
        splitsMetric?.add(SplitsMetric.fromJson(v));
      });
    }
    if (json['laps'] != null) {
      laps = <Laps>[];
      json['laps'].forEach((v) {
        laps?.add(Laps.fromJson(v));
      });
    }
    gear = json['gear'] != null ? Gear.fromJson(json['gear']) : null;
    partnerBrandTag = json['partner_brand_tag'];
    photos = json['photos'] != null ? Photos.fromJson(json['photos']) : null;
    if (json['highlighted_kudosers'] != null) {
      highlightedKudosers = <HighlightedKudosers>[];
      json['highlighted_kudosers'].forEach((v) {
        highlightedKudosers?.add(HighlightedKudosers.fromJson(v));
      });
    }
    deviceName = json['device_name'];
    embedToken = json['embed_token'];
    segmentLeaderboardOptOut = json['segment_leaderboard_opt_out'];
    leaderboardOptOut = json['leaderboard_opt_out'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['resource_state'] = resourceState;
    data['external_id'] = externalId;
    data['upload_id'] = uploadId;
    if (athlete != null) {
      data['athlete'] = athlete?.toJson();
    }
    data['name'] = name;
    data['distance'] = distance;
    data['moving_time'] = movingTime;
    data['elapsed_time'] = elapsedTime;
    data['total_elevation_gain'] = totalElevationGain;
    data['type'] = type;
    data['start_date'] = startDate;
    data['start_date_local'] = startDateLocal;
    data['timezone'] = timezone;
    data['utc_offset'] = utcOffset;
    data['start_latlng'] = startLatlng;
    data['end_latlng'] = endLatlng;
    data['start_latitude'] = startLatitude;
    data['start_longitude'] = startLongitude;
    data['achievement_count'] = achievementCount;
    data['kudos_count'] = kudosCount;
    data['comment_count'] = commentCount;
    data['athlete_count'] = athleteCount;
    data['photo_count'] = photoCount;
    if (map != null) {
      data['map'] = map?.toJson();
    }
    data['trainer'] = trainer;
    data['commute'] = commute;
    data['manual'] = manual;
    data['private'] = private;
    data['flagged'] = flagged;
    data['gear_id'] = gearId;
    data['from_accepted_tag'] = fromAcceptedTag;
    data['average_speed'] = averageSpeed;
    data['max_speed'] = maxSpeed;
    data['average_cadence'] = averageCadence;
    data['average_temp'] = averageTemp;
    data['average_watts'] = averageWatts;
    data['weighted_average_watts'] = weightedAverageWatts;
    data['kilojoules'] = kilojoules;
    data['device_watts'] = deviceWatts;
    data['has_heartrate'] = hasHeartrate;
    data['average_heartrate'] = averageHeartrate;
    data['max_heartrate'] = maxHeartrate;
    data['max_watts'] = maxWatts;
    data['elev_high'] = elevHigh;
    data['elev_low'] = elevLow;
    data['pr_count'] = prCount;
    data['total_photo_count'] = totalPhotoCount;
    data['has_kudoed'] = hasKudoed;
    data['workout_type'] = workoutType;
    data['suffer_score'] = sufferScore;
    data['description'] = description;
    data['calories'] = calories;
    if (segmentEfforts != null) {
      data['segment_efforts'] = segmentEfforts?.map((v) => v.toJson()).toList();
    }
    if (splitsMetric != null) {
      data['splits_metric'] = splitsMetric?.map((v) => v.toJson()).toList();
    }
    if (laps != null) {
      data['laps'] = laps?.map((v) => v.toJson()).toList();
    }
    if (gear != null) {
      data['gear'] = gear?.toJson();
    }
    data['partner_brand_tag'] = partnerBrandTag;
    if (photos != null) {
      data['photos'] = photos?.toJson();
    }
    if (highlightedKudosers != null) {
      data['highlighted_kudosers'] =
          highlightedKudosers?.map((v) => v.toJson()).toList();
    }
    data['device_name'] = deviceName;
    data['embed_token'] = embedToken;
    data['segment_leaderboard_opt_out'] = segmentLeaderboardOptOut;
    data['leaderboard_opt_out'] = leaderboardOptOut;
    return data;
  }
}

class Carte {
  String? id;
  String? polyline;
  int? resourceState;
  String? summaryPolyline;

  Carte({this.id, this.polyline, this.resourceState, this.summaryPolyline});

  Carte.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    polyline = json['polyline'];
    resourceState = json['resource_state'];
    summaryPolyline = json['summary_polyline'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['polyline'] = polyline;
    data['resource_state'] = resourceState;
    data['summary_polyline'] = summaryPolyline;
    return data;
  }
}

/*
class SegmentEfforts {
  int id;
  int resourceState;
  String name;
  Activity activity;
  Athlete athlete;
  int elapsedTime;
  int movingTime;
  String startDate;
  String startDateLocal;
  double distance;
  int startIndex;
  int endIndex;
  double averageCadence;
  bool deviceWatts;
  double averageWatts;
  Segment segment;
  int komRank;
  int prRank;

  List<String> achievements;
  bool hidden;

  SegmentEfforts(
      {this.id,
      this.resourceState,
      this.name,
      this.activity,
      this.athlete,
      this.elapsedTime,
      this.movingTime,
      this.startDate,
      this.startDateLocal,
      this.distance,
      this.startIndex,
      this.endIndex,
      this.averageCadence,
      this.deviceWatts,
      this.averageWatts,
      this.segment,
      this.komRank,
      this.prRank,
      this.achievements,
      this.hidden});

  SegmentEfforts.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    resourceState = json['resource_state'];
    name = json['name'];
    activity = json['activity'] != null
        ? new Activity.fromJson(json['activity'])
        : null;
    athlete =
        json['athlete'] != null ? new Athlete.fromJson(json['athlete']) : null;
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
    segment =
        json['segment'] != null ? new Segment.fromJson(json['segment']) : null;
    komRank = json['kom_rank'];
    prRank = json['pr_rank'];
 
    // if (json['achievements'] != null) {
      // achievements = new List<Null>();
      // json['achievements'].forEach((v) {
        // achievements.add(new Null.fromJson(v));
      // });
    // }
 
    hidden = json['hidden'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['resource_state'] = this.resourceState;
    data['name'] = this.name;
    if (this.activity != null) {
      data['activity'] = this.activity.toJson();
    }
    if (this.athlete != null) {
      data['athlete'] = this.athlete.toJson();
    }
    data['elapsed_time'] = this.elapsedTime;
    data['moving_time'] = this.movingTime;
    data['start_date'] = this.startDate;
    data['start_date_local'] = this.startDateLocal;
    data['distance'] = this.distance;
    data['start_index'] = this.startIndex;
    data['end_index'] = this.endIndex;
    data['average_cadence'] = this.averageCadence;
    data['device_watts'] = this.deviceWatts;
    data['average_watts'] = this.averageWatts;
    if (this.segment != null) {
      data['segment'] = this.segment.toJson();
    }
    data['kom_rank'] = this.komRank;
    data['pr_rank'] = this.prRank;
    /***
    if (this.achievements != null) {
      data['achievements'] = this.achievements.map((v) => v.toJson()).toList();
    }
  ****/
    data['hidden'] = this.hidden;
    return data;
  }
}

*****/

class Activity {
  int? id;
  int? resourceState;

  Activity({this.id, this.resourceState});

  Activity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    resourceState = json['resource_state'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['resource_state'] = resourceState;
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

  Segment(
      {this.id,
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
      this.starred});

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
    startLatlng = json['start_latlng'].cast<double>();
    endLatlng = json['end_latlng'].cast<double>();
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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['resource_state'] = resourceState;
    data['name'] = name;
    data['activity_type'] = activityType;
    data['distance'] = distance;
    data['average_grade'] = averageGrade;
    data['maximum_grade'] = maximumGrade;
    data['elevation_high'] = elevationHigh;
    data['elevation_low'] = elevationLow;
    data['start_latlng'] = startLatlng;
    data['end_latlng'] = endLatlng;
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

class SplitsMetric {
  double? distance;
  int? elapsedTime;
  double? elevationDifference;
  int? movingTime;
  int? split;
  double? averageSpeed;
  int? paceZone;

  SplitsMetric(
      {this.distance,
      this.elapsedTime,
      this.elevationDifference,
      this.movingTime,
      this.split,
      this.averageSpeed,
      this.paceZone});

  SplitsMetric.fromJson(Map<String, dynamic> json) {
    distance = json['distance'];
    elapsedTime = json['elapsed_time'];
    elevationDifference = json['elevation_difference'];
    movingTime = json['moving_time'];
    split = json['split'];
    averageSpeed = json['average_speed'];
    paceZone = json['pace_zone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['distance'] = distance;
    data['elapsed_time'] = elapsedTime;
    data['elevation_difference'] = elevationDifference;
    data['moving_time'] = movingTime;
    data['split'] = split;
    data['average_speed'] = averageSpeed;
    data['pace_zone'] = paceZone;
    return data;
  }
}

class Laps {
  int? id;
  int? resourceState;
  String? name;
  Activity? activity;
  AthleteEffort? athlete;
  int? elapsedTime;
  int? movingTime;
  String? startDate;
  String? startDateLocal;
  double? distance;
  int? startIndex;
  int? endIndex;
  double? totalElevationGain;
  double? averageSpeed;
  double? maxSpeed;
  double? averageCadence;
  bool? deviceWatts;
  double? averageWatts;
  int? lapIndex;
  int? split;

  Laps(
      {this.id,
      this.resourceState,
      this.name,
      this.activity,
      this.athlete,
      this.elapsedTime,
      this.movingTime,
      this.startDate,
      this.startDateLocal,
      this.distance,
      this.startIndex,
      this.endIndex,
      this.totalElevationGain,
      this.averageSpeed,
      this.maxSpeed,
      this.averageCadence,
      this.deviceWatts,
      this.averageWatts,
      this.lapIndex,
      this.split});

  Laps.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    resourceState = json['resource_state'];
    name = json['name'];
    activity =
        json['activity'] != null ? Activity.fromJson(json['activity']) : null;
    athlete = json['athlete'] != null
        ? AthleteEffort.fromJson(json['athlete'])
        : null;
    elapsedTime = json['elapsed_time'];
    movingTime = json['moving_time'];
    startDate = json['start_date'];
    startDateLocal = json['start_date_local'];
    distance = json['distance'];
    startIndex = json['start_index'];
    endIndex = json['end_index'];
    totalElevationGain = (json['total_elevation_gain']).toDouble();
    averageSpeed = json['average_speed'];
    maxSpeed = json['max_speed'];
    averageCadence = json['average_cadence'];
    deviceWatts = json['device_watts'];
    averageWatts = json['average_watts'];
    lapIndex = json['lap_index'];
    split = json['split'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['resource_state'] = resourceState;
    data['name'] = name;
    if (activity != null) {
      data['activity'] = activity?.toJson();
    }
    if (athlete != null) {
      data['athlete'] = athlete?.toJson();
    }
    data['elapsed_time'] = elapsedTime;
    data['moving_time'] = movingTime;
    data['start_date'] = startDate;
    data['start_date_local'] = startDateLocal;
    data['distance'] = distance;
    data['start_index'] = startIndex;
    data['end_index'] = endIndex;
    data['total_elevation_gain'] = totalElevationGain;
    data['average_speed'] = averageSpeed;
    data['max_speed'] = maxSpeed;
    data['average_cadence'] = averageCadence;
    data['device_watts'] = deviceWatts;
    data['average_watts'] = averageWatts;
    data['lap_index'] = lapIndex;
    data['split'] = split;
    return data;
  }
}

class Photos {
  Primary? primary;
  bool? usePrimaryPhoto;
  int? count;

  Photos({this.primary, this.usePrimaryPhoto, this.count});

  Photos.fromJson(Map<String, dynamic> json) {
    primary =
        json['primary'] != null ? Primary.fromJson(json['primary']) : null;
    usePrimaryPhoto = json['use_primary_photo'];
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (primary != null) {
      data['primary'] = primary?.toJson();
    }
    data['use_primary_photo'] = usePrimaryPhoto;
    data['count'] = count;
    return data;
  }
}

class Primary {
  Null? id;
  String? uniqueId;
  Urls? urls;
  int? source;

  Primary({this.id, this.uniqueId, this.urls, this.source});

  Primary.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uniqueId = json['unique_id'];
    urls = json['urls'] != null ? Urls.fromJson(json['urls']) : null;
    source = json['source'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['unique_id'] = uniqueId;
    if (urls != null) {
      data['urls'] = urls?.toJson();
    }
    data['source'] = source;
    return data;
  }
}

class Urls {
  String? s100;
  String? s600;

  Urls({this.s100, this.s600});

  Urls.fromJson(Map<String, dynamic> json) {
    s100 = json['100'];
    s600 = json['600'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['100'] = s100;
    data['600'] = s600;
    return data;
  }
}

class HighlightedKudosers {
  String? destinationUrl;
  String? displayName;
  String? avatarUrl;
  bool? showName;

  HighlightedKudosers(
      {this.destinationUrl, this.displayName, this.avatarUrl, this.showName});

  HighlightedKudosers.fromJson(Map<String, dynamic> json) {
    destinationUrl = json['destination_url'];
    displayName = json['display_name'];
    avatarUrl = json['avatar_url'];
    showName = json['show_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['destination_url'] = destinationUrl;
    data['display_name'] = displayName;
    data['avatar_url'] = avatarUrl;
    data['show_name'] = showName;
    return data;
  }
}

class SummaryActivity {
  Fault? fault;
  int? id;
  int? resourceState;
  AthleteEffort? athlete;
  String? name;
  double? distance;
  int? movingTime;
  int? elapsedTime;
  double? totalElevationGain;
  String? type;
  int? workoutType;
  DateTime? startDate;
  DateTime? startDateLocal;

  SummaryActivity({
    this.id,
    this.resourceState,
    this.athlete,
    this.name,
    this.distance,
    this.movingTime,
    this.elapsedTime,
    this.totalElevationGain,
    this.type,
    this.workoutType,
    // this.startDate,
    // this.startDateLocal
  });

  SummaryActivity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    resourceState = json['resource_state'];
    athlete = json['athlete'] != null
        ? AthleteEffort.fromJson(json['athlete'])
        : null;
    name = json['name'];
    distance = json['distance'];
    movingTime = json['moving_time'];
    elapsedTime = json['elapsed_time'];
    var _elevationGain = json['total_elevation_gain'];
    // To convert the dynamic var in double when it is an int
    if ((_elevationGain % 1) == 0) {
      _elevationGain = _elevationGain + 0.0;
    }
    // if (_elevationGain == 0) _elevationGain = 0.0;
    totalElevationGain = _elevationGain;
    type = json['type'];
    workoutType = json['workout_type'];
    startDate =
        json['start_date'] != null ? _parseDate(json['start_date']) : null;
    startDateLocal = json['start_date_local'] != null
        ? _parseDate(json['start_date_local'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['resource_state'] = resourceState;
    if (athlete != null) {
      data['athlete'] = athlete!.toJson();
    }
    data['name'] = name;
    data['distance'] = distance;
    data['moving_time'] = movingTime;
    data['elapsed_time'] = elapsedTime;
    data['total_elevation_gain'] = totalElevationGain;
    data['type'] = type;
    data['workout_type'] = workoutType;
    data['start_date'] = toJsonDate(startDate!);
    data['start_date_local'] = toJsonDate(startDateLocal!);
    return data;
  }
}

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

String toJsonDate(DateTime date) {
//2020-07-19T15:44:53Z
  final DateFormat yearFormat = DateFormat('yyyy-MM-dd');
  final DateFormat timeFormat = DateFormat('Hms');
  return '${yearFormat.format(date)}T${timeFormat.format(date)}Z';
}

class ActivityType {
  static const String AlpineSki = "AlpineSki";
  static const String BackcountrySki = "BackcountrySki";
  static const String Canoeing = "Canoeing";
  static const String Crossfit = "Crossfit";
  static const String EBikeRide = "EBikeRide";
  static const String Elliptical = "Elliptical";
  static const String Golf = "Golf";
  static const String Handcycle = "Handcycle";
  static const String Hike = "Hike";
  static const String IceSkate = "IceSkate";
  static const String InlineSkate = "InlineSkate";
  static const String Kayaking = "Kayaking";
  static const String Kitesurf = "Kitesurf";
  static const String NordicSki = "NordicSki";
  static const String Ride = "Ride";
  static const String RockClimbing = "RockClimbing";
  static const String RollerSki = "RollerSki";
  static const String Rowing = "Rowing";
  static const String Run = "Run";
  static const String Sail = "Sail";
  static const String Skateboard = "Skateboard";
  static const String Snowboard = "Snowboard";
  static const String Snowshoe = "Snowshoe";
  static const String Soccer = "Soccer";
  static const String StairStepper = "StairStepper";
  static const String StandUpPaddling = "StandUpPaddling";
  static const String Surfing = "Surfing";
  static const String Swim = "Swim";
  static const String Velomobile = "Velomobile";
  static const String VirtualRide = "VirtualRide";
  static const String VirtualRun = "VirtualRun";
  static const String Walk = "Walk";
  static const String WeightTraining = "WeightTraining";
  static const String Wheelchair = "Wheelchair";
  static const String Windsurf = "Windsurf";
  static const String Workout = "Workout";
  static const String Yoga = "Yoga";
}

class PhotoActivity {
  Fault? fault;
  int? id;
  String? uniqueId;
  Map? urls;
  String? source;
  String? athleteId;
  String? activityId;
  String? activityName;
  String? resourceState;
  String? caption;
  String? createdAt;
  String? createdAtLocal;
  String? uploadedAt;
  Map? sizes;
  bool? defaultPhoto;

  PhotoActivity({
    this.id,
    this.uniqueId,
    this.urls,
    this.source,
    this.athleteId,
    this.activityId,
    this.activityName,
    this.resourceState,
    this.caption,
    this.createdAt,
    this.createdAtLocal,
    this.uploadedAt,
    this.sizes,
    this.defaultPhoto,
  });

  PhotoActivity.fromJson(Map<dynamic, dynamic> json) {
    id = json['id'];
    uniqueId = json['unique_id'];
    urls = json['urls'];
    source = json['source'].toString();
    athleteId = json['athlete_id'].toString();
    activityId = json['activity_id'].toString();
    activityName = json['activity_name'];
    resourceState = json['resource_state'].toString();
    caption = json['caption'];
    createdAt = json['created_at'];
    createdAtLocal = json['created_at_local'];
    uploadedAt = json['uploaded_at'];
    sizes = json['sizes'];
    defaultPhoto = json['default_photo'];
  }
}
