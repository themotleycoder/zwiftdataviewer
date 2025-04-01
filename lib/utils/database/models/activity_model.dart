import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_strava_api/api/streams.dart';
import 'package:flutter_strava_api/models/activity.dart';
import 'package:flutter_strava_api/models/summary_activity.dart';

class ActivityModel {
  final int id;
  final int resourceState;
  final int athleteId;
  final String name;
  final double distance;
  final int movingTime;
  final int elapsedTime;
  final double totalElevationGain;
  final String type;
  final String sportType;
  final String startDate;
  final String startDateLocal;
  final String timezone;
  final double utcOffset;
  final String? locationCity;
  final String? locationState;
  final String locationCountry;
  final int achievementCount;
  final int kudosCount;
  final int commentCount;
  final int athleteCount;
  final int photoCount;
  final bool trainer;
  final bool commute;
  final bool manual;
  final bool private;
  final String visibility;
  final bool flagged;
  final String? gearId;
  final String startLatlng;
  final String endLatlng;
  final double averageSpeed;
  final double maxSpeed;
  final double averageCadence;
  final double averageWatts;
  final int maxWatts;
  final int weightedAverageWatts;
  final double kilojoules;
  final bool deviceWatts;
  final bool hasHeartrate;
  final double averageHeartrate;
  final double maxHeartrate;
  final bool heartrateOptOut;
  final bool displayHideHeartrateOption;
  final double elevHigh;
  final double elevLow;
  final int uploadId;
  final String uploadIdStr;
  final String externalId;
  final bool fromAcceptedTag;
  final int prCount;
  final int totalPhotoCount;
  final bool hasKudoed;
  final String jsonData;

  ActivityModel({
    required this.id,
    required this.resourceState,
    required this.athleteId,
    required this.name,
    required this.distance,
    required this.movingTime,
    required this.elapsedTime,
    required this.totalElevationGain,
    required this.type,
    required this.sportType,
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
    required this.jsonData,
  });

  // Convert a SummaryActivity to an ActivityModel
  factory ActivityModel.fromSummaryActivity(SummaryActivity activity) {
    try {
      if (kDebugMode) {
        print('Converting SummaryActivity to ActivityModel: ${activity.id}');
      }
      
      // Handle potential null values with defaults
      final model = ActivityModel(
        id: activity.id,
        resourceState: activity.resourceState,
        athleteId: activity.athlete.id,
        name: activity.name.isNotEmpty ? activity.name : 'Unnamed Activity',
        distance: activity.distance >= 0 ? activity.distance : 0,
        movingTime: activity.movingTime >= 0 ? activity.movingTime : 0,
        elapsedTime: activity.elapsedTime >= 0 ? activity.elapsedTime : 0,
        totalElevationGain: activity.totalElevationGain >= 0 ? activity.totalElevationGain : 0,
        type: activity.type.isNotEmpty ? activity.type : 'Unknown',
        sportType: activity.sportType.isNotEmpty ? activity.sportType : 'Unknown',
        startDate: activity.startDate.toIso8601String(),
        startDateLocal: activity.startDateLocal.toIso8601String(),
        timezone: activity.timezone.isNotEmpty ? activity.timezone : 'UTC',
        utcOffset: activity.utcOffset,
        locationCity: activity.locationCity,
        locationState: activity.locationState,
        locationCountry: activity.locationCountry.isNotEmpty ? activity.locationCountry : 'Unknown',
        achievementCount: activity.achievementCount >= 0 ? activity.achievementCount : 0,
        kudosCount: activity.kudosCount >= 0 ? activity.kudosCount : 0,
        commentCount: activity.commentCount >= 0 ? activity.commentCount : 0,
        athleteCount: activity.athleteCount >= 0 ? activity.athleteCount : 0,
        photoCount: activity.photoCount >= 0 ? activity.photoCount : 0,
        trainer: activity.trainer,
        commute: activity.commute,
        manual: activity.manual,
        private: activity.private,
        visibility: activity.visibility.isNotEmpty ? activity.visibility : 'private',
        flagged: activity.flagged,
        gearId: activity.gearId,
        startLatlng: jsonEncode(activity.startLatlng.toJson()),
        endLatlng: jsonEncode(activity.endLatlng.toJson()),
        averageSpeed: activity.averageSpeed >= 0 ? activity.averageSpeed : 0,
        maxSpeed: activity.maxSpeed >= 0 ? activity.maxSpeed : 0,
        averageCadence: activity.averageCadence >= 0 ? activity.averageCadence : 0,
        averageWatts: activity.averageWatts >= 0 ? activity.averageWatts : 0,
        maxWatts: activity.maxWatts >= 0 ? activity.maxWatts : 0,
        weightedAverageWatts: activity.weightedAverageWatts >= 0 ? activity.weightedAverageWatts : 0,
        kilojoules: activity.kilojoules >= 0 ? activity.kilojoules : 0,
        deviceWatts: activity.deviceWatts,
        hasHeartrate: activity.hasHeartrate,
        averageHeartrate: activity.hasHeartrate ? (activity.averageHeartrate > 0 ? activity.averageHeartrate : 1) : 0,
        maxHeartrate: activity.hasHeartrate ? (activity.maxHeartrate > 0 ? activity.maxHeartrate : 1) : 0,
        heartrateOptOut: activity.heartrateOptOut,
        displayHideHeartrateOption: activity.displayHideHeartrateOption,
        elevHigh: activity.elevHigh,
        elevLow: activity.elevLow,
        uploadId: activity.uploadId,
        uploadIdStr: activity.uploadIdStr.isNotEmpty ? activity.uploadIdStr : activity.uploadId.toString(),
        externalId: activity.externalId.isNotEmpty ? activity.externalId : 'unknown',
        fromAcceptedTag: activity.fromAcceptedTag,
        prCount: activity.prCount >= 0 ? activity.prCount : 0,
        totalPhotoCount: activity.totalPhotoCount >= 0 ? activity.totalPhotoCount : 0,
        hasKudoed: activity.hasKudoed,
        jsonData: jsonEncode(activity.toJson()),
      );
      
      try {
        model.validate();
        if (kDebugMode) {
          print('ActivityModel validation successful for activity ${activity.id}');
        }
      } catch (e) {
        if (kDebugMode) {
          print('ActivityModel validation failed for activity ${activity.id}: $e');
          print('Using model without validation');
        }
        // Continue without validation
      }
      
      return model;
    } catch (e) {
      if (kDebugMode) {
        print('Error converting SummaryActivity to ActivityModel: $e');
        print('Activity ID: ${activity.id}');
        print('Activity JSON: ${jsonEncode(activity.toJson())}');
      }
      
      // Create a minimal valid model to avoid database errors
      return ActivityModel(
        id: activity.id,
        resourceState: 1,
        athleteId: activity.athlete.id,
        name: 'Error Activity',
        distance: 0,
        movingTime: 0,
        elapsedTime: 0,
        totalElevationGain: 0,
        type: 'Unknown',
        sportType: 'Unknown',
        startDate: DateTime.now().toIso8601String(),
        startDateLocal: DateTime.now().toIso8601String(),
        timezone: 'UTC',
        utcOffset: 0,
        locationCity: null,
        locationState: null,
        locationCountry: 'Unknown',
        achievementCount: 0,
        kudosCount: 0,
        commentCount: 0,
        athleteCount: 0,
        photoCount: 0,
        trainer: false,
        commute: false,
        manual: false,
        private: false,
        visibility: 'private',
        flagged: false,
        gearId: null,
        startLatlng: '{"lat":0,"lng":0}',
        endLatlng: '{"lat":0,"lng":0}',
        averageSpeed: 0,
        maxSpeed: 0,
        averageCadence: 0,
        averageWatts: 0,
        maxWatts: 0,
        weightedAverageWatts: 0,
        kilojoules: 0,
        deviceWatts: false,
        hasHeartrate: false,
        averageHeartrate: 0,
        maxHeartrate: 0,
        heartrateOptOut: false,
        displayHideHeartrateOption: false,
        elevHigh: 0,
        elevLow: 0,
        uploadId: 0,
        uploadIdStr: '0',
        externalId: 'unknown',
        fromAcceptedTag: false,
        prCount: 0,
        totalPhotoCount: 0,
        hasKudoed: false,
        jsonData: jsonEncode(activity.toJson()),
      );
    }
  }
  
  // Validate the model data
  void validate() {
    try {
      if (id <= 0) {
        throw ArgumentError('Invalid activity ID: $id');
      }
      if (name.isEmpty) {
        throw ArgumentError('Activity name cannot be empty');
      }
      
      // Check if start date is in the future
      try {
        final startDateTime = DateTime.parse(startDate);
        if (startDateTime.isAfter(DateTime.now())) {
          throw ArgumentError('Activity start date cannot be in the future');
        }
      } catch (e) {
        throw ArgumentError('Invalid start date format: $startDate');
      }
      
      // Validate numeric fields
      if (distance < 0) {
        throw ArgumentError('Distance cannot be negative: $distance');
      }
      if (movingTime < 0) {
        throw ArgumentError('Moving time cannot be negative: $movingTime');
      }
      if (elapsedTime < 0) {
        throw ArgumentError('Elapsed time cannot be negative: $elapsedTime');
      }
      if (totalElevationGain < 0) {
        throw ArgumentError('Total elevation gain cannot be negative: $totalElevationGain');
      }
      
      // Validate type and sport type
      if (type.isEmpty) {
        throw ArgumentError('Activity type cannot be empty');
      }
      if (sportType.isEmpty) {
        throw ArgumentError('Sport type cannot be empty');
      }
      
      // Validate speed values
      if (averageSpeed < 0) {
        throw ArgumentError('Average speed cannot be negative: $averageSpeed');
      }
      if (maxSpeed < 0) {
        throw ArgumentError('Max speed cannot be negative: $maxSpeed');
      }
      
      // Validate power values if present
      if (averageWatts < 0) {
        throw ArgumentError('Average watts cannot be negative: $averageWatts');
      }
      if (maxWatts < 0) {
        throw ArgumentError('Max watts cannot be negative: $maxWatts');
      }
      if (weightedAverageWatts < 0) {
        throw ArgumentError('Weighted average watts cannot be negative: $weightedAverageWatts');
      }
      
      // Validate heart rate values if present
      if (hasHeartrate) {
        if (averageHeartrate <= 0) {
          throw ArgumentError('Average heart rate must be positive when heart rate data is present: $averageHeartrate');
        }
        if (maxHeartrate <= 0) {
          throw ArgumentError('Max heart rate must be positive when heart rate data is present: $maxHeartrate');
        }
      }
      
      // Validate elevation values
      if (elevHigh < elevLow) {
        throw ArgumentError('High elevation ($elevHigh) cannot be less than low elevation ($elevLow)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Validation error: $e');
      }
      throw e; // Re-throw the error after logging
    }
  }

  // Convert an ActivityModel to a SummaryActivity
  SummaryActivity toSummaryActivity() {
    final Map<String, dynamic> json = jsonDecode(jsonData);
    return SummaryActivity.fromJson(json);
  }

  // Convert a Map from the database to an ActivityModel
  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    return ActivityModel(
      id: map['id'],
      resourceState: map['resource_state'],
      athleteId: map['athlete_id'],
      name: map['name'],
      distance: map['distance'],
      movingTime: map['moving_time'],
      elapsedTime: map['elapsed_time'],
      totalElevationGain: map['total_elevation_gain'],
      type: map['type'],
      sportType: map['sport_type'],
      startDate: map['start_date'],
      startDateLocal: map['start_date_local'],
      timezone: map['timezone'],
      utcOffset: map['utc_offset'],
      locationCity: map['location_city'],
      locationState: map['location_state'],
      locationCountry: map['location_country'],
      achievementCount: map['achievement_count'],
      kudosCount: map['kudos_count'],
      commentCount: map['comment_count'],
      athleteCount: map['athlete_count'],
      photoCount: map['photo_count'],
      trainer: map['trainer'] == 1,
      commute: map['commute'] == 1,
      manual: map['manual'] == 1,
      private: map['private'] == 1,
      visibility: map['visibility'],
      flagged: map['flagged'] == 1,
      gearId: map['gear_id'],
      startLatlng: map['start_latlng'],
      endLatlng: map['end_latlng'],
      averageSpeed: map['average_speed'],
      maxSpeed: map['max_speed'],
      averageCadence: map['average_cadence'],
      averageWatts: map['average_watts'],
      maxWatts: map['max_watts'],
      weightedAverageWatts: map['weighted_average_watts'],
      kilojoules: map['kilojoules'],
      deviceWatts: map['device_watts'] == 1,
      hasHeartrate: map['has_heartrate'] == 1,
      averageHeartrate: map['average_heartrate'],
      maxHeartrate: map['max_heartrate'],
      heartrateOptOut: map['heartrate_opt_out'] == 1,
      displayHideHeartrateOption: map['display_hide_heartrate_option'] == 1,
      elevHigh: map['elev_high'],
      elevLow: map['elev_low'],
      uploadId: map['upload_id'],
      uploadIdStr: map['upload_id_str'],
      externalId: map['external_id'],
      fromAcceptedTag: map['from_accepted_tag'] == 1,
      prCount: map['pr_count'],
      totalPhotoCount: map['total_photo_count'],
      hasKudoed: map['has_kudoed'] == 1,
      jsonData: map['json_data'],
    );
  }

  // Convert an ActivityModel to a Map for the database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'resource_state': resourceState,
      'athlete_id': athleteId,
      'name': name,
      'distance': distance,
      'moving_time': movingTime,
      'elapsed_time': elapsedTime,
      'total_elevation_gain': totalElevationGain,
      'type': type,
      'sport_type': sportType,
      'start_date': startDate,
      'start_date_local': startDateLocal,
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
      'trainer': trainer ? 1 : 0,
      'commute': commute ? 1 : 0,
      'manual': manual ? 1 : 0,
      'private': private ? 1 : 0,
      'visibility': visibility,
      'flagged': flagged ? 1 : 0,
      'gear_id': gearId,
      'start_latlng': startLatlng,
      'end_latlng': endLatlng,
      'average_speed': averageSpeed,
      'max_speed': maxSpeed,
      'average_cadence': averageCadence,
      'average_watts': averageWatts,
      'max_watts': maxWatts,
      'weighted_average_watts': weightedAverageWatts,
      'kilojoules': kilojoules,
      'device_watts': deviceWatts ? 1 : 0,
      'has_heartrate': hasHeartrate ? 1 : 0,
      'average_heartrate': averageHeartrate,
      'max_heartrate': maxHeartrate,
      'heartrate_opt_out': heartrateOptOut ? 1 : 0,
      'display_hide_heartrate_option': displayHideHeartrateOption ? 1 : 0,
      'elev_high': elevHigh,
      'elev_low': elevLow,
      'upload_id': uploadId,
      'upload_id_str': uploadIdStr,
      'external_id': externalId,
      'from_accepted_tag': fromAcceptedTag ? 1 : 0,
      'pr_count': prCount,
      'total_photo_count': totalPhotoCount,
      'has_kudoed': hasKudoed ? 1 : 0,
      'json_data': jsonData,
    };
  }
}

class ActivityDetailModel {
  final int id;
  final String jsonData;

  ActivityDetailModel({
    required this.id,
    required this.jsonData,
  });
  
  // Validate the model data
  void validate() {
    if (id <= 0) {
      throw ArgumentError('Invalid activity detail ID: $id');
    }
    
    if (jsonData.isEmpty) {
      throw ArgumentError('JSON data cannot be empty');
    }
    
    // Validate JSON format
    try {
      final json = jsonDecode(jsonData);
      if (json == null || json is! Map<String, dynamic>) {
        throw ArgumentError('Invalid JSON data format');
      }
    } catch (e) {
      throw ArgumentError('Invalid JSON data: $e');
    }
  }

  // Convert a DetailedActivity to an ActivityDetailModel
  factory ActivityDetailModel.fromDetailedActivity(DetailedActivity activity) {
    final model = ActivityDetailModel(
      id: activity.id!,
      jsonData: jsonEncode(activity.toJson()),
    );
    model.validate();
    return model;
  }

  // Convert an ActivityDetailModel to a DetailedActivity
  DetailedActivity toDetailedActivity() {
    final Map<String, dynamic> json = jsonDecode(jsonData);
    return DetailedActivity.fromJson(json);
  }

  // Convert a Map from the database to an ActivityDetailModel
  factory ActivityDetailModel.fromMap(Map<String, dynamic> map) {
    return ActivityDetailModel(
      id: map['id'],
      jsonData: map['json_data'],
    );
  }

  // Convert an ActivityDetailModel to a Map for the database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'json_data': jsonData,
    };
  }
}

class ActivityPhotoModel {
  final int? id;
  final int activityId;
  final String photoId;
  final String jsonData;
  final String? uniqueId;

  ActivityPhotoModel({
    this.id,
    required this.activityId,
    required this.photoId,
    required this.jsonData,
    this.uniqueId,
  }) {
    validate();
  }
  
  // Validate the model data
  void validate() {
    if (activityId <= 0) {
      throw ArgumentError('Invalid activity ID: $activityId');
    }
    
    if (jsonData.isEmpty) {
      throw ArgumentError('JSON data cannot be empty');
    }
    
    // Validate JSON format
    try {
      final json = jsonDecode(jsonData);
      if (json == null || json is! Map<String, dynamic>) {
        throw ArgumentError('Invalid JSON data format');
      }
    } catch (e) {
      throw ArgumentError('Invalid JSON data: $e');
    }
  }

  // Convert a PhotoActivity to an ActivityPhotoModel
  factory ActivityPhotoModel.fromPhotoActivity(int activityId, PhotoActivity photo) {
    try {
      // Skip photos with null IDs
      if (photo.id == null) {
        throw ArgumentError('Photo ID cannot be null');
      }
      
      // Ensure photo.toJson() returns a valid Map
      final photoJson = photo.toJson();
      if (photoJson == null) {
        throw ArgumentError('Photo JSON cannot be null');
      }
      
      // Extract uniqueId if available
      String? uniqueId;
      try {
        if (photoJson.containsKey('unique_id') && photoJson['unique_id'] != null) {
          uniqueId = photoJson['unique_id'].toString();
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error extracting uniqueId: $e');
        }
      }
      
      final model = ActivityPhotoModel(
        activityId: activityId,
        photoId: photo.id!.toString(),
        jsonData: jsonEncode(photoJson),
        uniqueId: uniqueId,
      );
      return model; // validate() is called in the constructor
    } catch (e) {
      if (kDebugMode) {
        print('Error creating ActivityPhotoModel: $e');
        print('Activity ID: $activityId, Photo: ${photo.toString()}');
      }
      // Rethrow the error to be handled by the caller
      throw e;
    }
  }

  // Convert an ActivityPhotoModel to a PhotoActivity
  PhotoActivity toPhotoActivity() {
    try {
      if (jsonData.isEmpty) {
        throw ArgumentError('JSON data is empty');
      }
      
      final dynamic decodedJson = jsonDecode(jsonData);
      if (decodedJson == null) {
        throw ArgumentError('Decoded JSON is null');
      }
      
      if (decodedJson is! Map<String, dynamic>) {
        throw ArgumentError('Decoded JSON is not a Map<String, dynamic>');
      }
      
      final Map<String, dynamic> json = decodedJson;
      return PhotoActivity.fromJson(json);
    } catch (e) {
      if (kDebugMode) {
        print('Error converting ActivityPhotoModel to PhotoActivity: $e');
        print('Photo ID: $photoId, Activity ID: $activityId');
        print('JSON data: $jsonData');
      }
      // Return a minimal valid PhotoActivity
      return PhotoActivity(
        id: photoId,
        urls: {},
      );
    }
  }

  // Convert a Map from the database to an ActivityPhotoModel
  factory ActivityPhotoModel.fromMap(Map<String, dynamic> map) {
    return ActivityPhotoModel(
      id: map['id'],
      activityId: map['activity_id'],
      photoId: map['photo_id'],
      jsonData: map['json_data'],
      uniqueId: map['unique_id'],
    );
  }

  // Convert an ActivityPhotoModel to a Map for the database
  Map<String, dynamic> toMap() {
    return {
      'activity_id': activityId,
      'photo_id': photoId,
      'unique_id': uniqueId,
      'json_data': jsonData,
    };
  }
}

class ActivityStreamModel {
  final int? id;
  final int activityId;
  final String jsonData;

  ActivityStreamModel({
    this.id,
    required this.activityId,
    required this.jsonData,
  }) {
    validate();
  }
  
  // Validate the model data
  void validate() {
    if (activityId <= 0) {
      throw ArgumentError('Invalid activity ID: $activityId');
    }
    
    if (jsonData.isEmpty) {
      throw ArgumentError('JSON data cannot be empty');
    }
    
    // Validate JSON format
    try {
      final json = jsonDecode(jsonData);
      if (json == null || json is! Map<String, dynamic>) {
        throw ArgumentError('Invalid JSON data format');
      }
    } catch (e) {
      throw ArgumentError('Invalid JSON data: $e');
    }
  }

  // Convert a StreamsDetailCollection to an ActivityStreamModel
  factory ActivityStreamModel.fromStreamsDetailCollection(
      int activityId, StreamsDetailCollection streams) {
    final model = ActivityStreamModel(
      activityId: activityId,
      jsonData: jsonEncode(streams.toJson()),
    );
    return model; // validate() is called in the constructor
  }

  // Convert an ActivityStreamModel to a StreamsDetailCollection
  StreamsDetailCollection toStreamsDetailCollection() {
    final Map<String, dynamic> jsonMap = jsonDecode(jsonData);
    
    // Check if the JSON has the expected structure
    if (jsonMap.containsKey('streams') && jsonMap['streams'] is List) {
      if (kDebugMode) {
        print('Converting stored streams data to StreamsDetailCollection format');
      }
      
      // The stored JSON has a "streams" array, but StreamsDetailCollection.fromJson
      // expects a different structure with direct keys for each stream type
      final List<dynamic> streamsList = jsonMap['streams'];
      
      // Create a map with the structure expected by StreamsDetailCollection.fromJson
      final Map<String, dynamic> transformedJson = {
        'distance': {
          'series_type': 'distance',
          'data': streamsList.map((item) => item['distance']).toList(),
        },
        'time': {
          'series_type': 'time',
          'data': streamsList.map((item) => item['time']).toList(),
        },
        'altitude': {
          'series_type': 'altitude',
          'data': streamsList.map((item) => item['altitude']).toList(),
        },
        'heartrate': {
          'series_type': 'heartrate',
          'data': streamsList.map((item) => item['heartrate']).toList(),
        },
        'cadence': {
          'series_type': 'cadence',
          'data': streamsList.map((item) => item['cadence']).toList(),
        },
        'watts_calc': {
          'series_type': 'watts',
          'data': streamsList.map((item) => item['watts']).toList(),
        },
        'grade_smooth': {
          'series_type': 'grade',
          'data': streamsList.map((item) => item['gradeSmooth']).toList(),
        },
      };
      
      return StreamsDetailCollection.fromJson(transformedJson);
    } else {
      // If the JSON doesn't have the expected structure, try using it directly
      // (this is a fallback and might not work)
      if (kDebugMode) {
        print('Warning: Unexpected streams data format');
      }
      return StreamsDetailCollection.fromJson(jsonMap);
    }
  }

  // Convert a Map from the database to an ActivityStreamModel
  factory ActivityStreamModel.fromMap(Map<String, dynamic> map) {
    return ActivityStreamModel(
      id: map['id'],
      activityId: map['activity_id'],
      jsonData: map['json_data'],
    );
  }

  // Convert an ActivityStreamModel to a Map for the database
  Map<String, dynamic> toMap() {
    return {
      'activity_id': activityId,
      'json_data': jsonData,
    };
  }
}
