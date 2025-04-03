import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_strava_api/models/segmentEffort.dart';

class SegmentEffortModel {
  final int? id;
  final int activityId;
  final int segmentId;
  final String segmentName;
  final int elapsedTime;
  final int movingTime;
  final String startDate;
  final String startDateLocal;
  final double distance;
  final int? startIndex;
  final int? endIndex;
  final double? averageWatts;
  final double? averageCadence;
  final double? averageHeartrate;
  final double? maxHeartrate;
  final int? prRank;
  final bool? hidden;
  final double? elevationDifference;
  final double? averageGrade;
  final int? climbCategory;
  final String jsonData;

  SegmentEffortModel({
    this.id,
    required this.activityId,
    required this.segmentId,
    required this.segmentName,
    required this.elapsedTime,
    required this.movingTime,
    required this.startDate,
    required this.startDateLocal,
    required this.distance,
    this.startIndex,
    this.endIndex,
    this.averageWatts,
    this.averageCadence,
    this.averageHeartrate,
    this.maxHeartrate,
    this.prRank,
    this.hidden,
    this.elevationDifference,
    this.averageGrade,
    this.climbCategory,
    required this.jsonData,
  });

  // Validate the model data
  void validate() {
    if (activityId <= 0) {
      throw ArgumentError('Invalid activity ID: $activityId');
    }
    
    if (segmentId <= 0) {
      throw ArgumentError('Invalid segment ID: $segmentId');
    }
    
    if (segmentName.isEmpty) {
      throw ArgumentError('Segment name cannot be empty');
    }
    
    if (elapsedTime < 0) {
      throw ArgumentError('Elapsed time cannot be negative: $elapsedTime');
    }
    
    if (movingTime < 0) {
      throw ArgumentError('Moving time cannot be negative: $movingTime');
    }
    
    if (distance < 0) {
      throw ArgumentError('Distance cannot be negative: $distance');
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

  // Convert a SegmentEffort to a SegmentEffortModel
  factory SegmentEffortModel.fromSegmentEffort(int activityId, SegmentEffort effort) {
    try {
      if (effort.segment == null) {
        throw ArgumentError('Segment cannot be null');
      }
      
      if (effort.segment!.id == null) {
        throw ArgumentError('Segment ID cannot be null');
      }
      
      if (effort.segment!.name == null || effort.segment!.name!.isEmpty) {
        throw ArgumentError('Segment name cannot be empty');
      }
      
      final model = SegmentEffortModel(
        activityId: activityId,
        segmentId: effort.segment!.id!,
        segmentName: effort.segment!.name!,
        elapsedTime: effort.elapsedTime ?? 0,
        movingTime: effort.movingTime ?? 0,
        startDate: effort.startDate ?? DateTime.now().toIso8601String(),
        startDateLocal: effort.startDateLocal ?? DateTime.now().toIso8601String(),
        distance: effort.distance ?? 0,
        startIndex: effort.startIndex,
        endIndex: effort.endIndex,
        averageWatts: effort.averageWatts,
        averageCadence: effort.averageCadence,
        averageHeartrate: effort.averageHeartrate,
        maxHeartrate: effort.maxHeartrate,
        prRank: effort.prRank,
        hidden: effort.hidden,
        elevationDifference: effort.segment?.elevationHigh != null && effort.segment?.elevationLow != null 
            ? effort.segment!.elevationHigh! - effort.segment!.elevationLow!
            : null,
        averageGrade: effort.segment?.averageGrade,
        climbCategory: effort.segment?.climbCategory,
        jsonData: jsonEncode(effort.toJson()),
      );
      
      try {
        model.validate();
        if (kDebugMode) {
          print('SegmentEffortModel validation successful for segment ${effort.segment!.id}');
        }
      } catch (e) {
        if (kDebugMode) {
          print('SegmentEffortModel validation failed for segment ${effort.segment!.id}: $e');
          print('Using model without validation');
        }
        // Continue without validation
      }
      
      return model;
    } catch (e) {
      if (kDebugMode) {
        print('Error converting SegmentEffort to SegmentEffortModel: $e');
        print('Segment ID: ${effort.segment?.id}');
        print('Segment JSON: ${jsonEncode(effort.toJson())}');
      }
      
      // Create a minimal valid model to avoid database errors
      return SegmentEffortModel(
        activityId: activityId,
        segmentId: effort.segment?.id ?? 0,
        segmentName: effort.segment?.name ?? 'Unknown Segment',
        elapsedTime: effort.elapsedTime ?? 0,
        movingTime: effort.movingTime ?? 0,
        startDate: effort.startDate ?? DateTime.now().toIso8601String(),
        startDateLocal: effort.startDateLocal ?? DateTime.now().toIso8601String(),
        distance: effort.distance ?? 0,
        jsonData: jsonEncode(effort.toJson()),
      );
    }
  }

  // Convert a SegmentEffortModel to a SegmentEffort
  SegmentEffort toSegmentEffort() {
    final Map<String, dynamic> json = jsonDecode(jsonData);
    
    // Ensure segment is not null and is a Map to prevent "type 'Null' is not a subtype of type 'Map<String, dynamic>'" error
    if (json['segment'] == null) {
      // Create a minimal valid segment object
      json['segment'] = {
        'id': segmentId,
        'name': segmentName,
        'average_grade': averageGrade,
        'climb_category': climbCategory,
      };
    }
    
    return SegmentEffort.fromJson(json);
  }

  // Convert a Map from the database to a SegmentEffortModel
  factory SegmentEffortModel.fromMap(Map<String, dynamic> map) {
    return SegmentEffortModel(
      id: map['id'],
      activityId: map['activity_id'],
      segmentId: map['segment_id'],
      segmentName: map['segment_name'],
      elapsedTime: map['elapsed_time'],
      movingTime: map['moving_time'],
      startDate: map['start_date'],
      startDateLocal: map['start_date_local'],
      distance: map['distance'],
      startIndex: map['start_index'],
      endIndex: map['end_index'],
      averageWatts: map['average_watts'],
      averageCadence: map['average_cadence'],
      averageHeartrate: map['average_heartrate'],
      maxHeartrate: map['max_heartrate'],
      prRank: map['pr_rank'],
      hidden: map['hidden'] == 1,
      elevationDifference: map['elevation_difference'],
      averageGrade: map['average_grade'],
      climbCategory: map['climb_category'],
      jsonData: map['json_data'],
    );
  }

  // Convert a SegmentEffortModel to a Map for the database
  Map<String, dynamic> toMap() {
    return {
      'activity_id': activityId,
      'segment_id': segmentId,
      'segment_name': segmentName,
      'elapsed_time': elapsedTime,
      'moving_time': movingTime,
      'start_date': startDate,
      'start_date_local': startDateLocal,
      'distance': distance,
      'start_index': startIndex,
      'end_index': endIndex,
      'average_watts': averageWatts,
      'average_cadence': averageCadence,
      'average_heartrate': averageHeartrate,
      'max_heartrate': maxHeartrate,
      'climb_category': climbCategory,
      'json_data': jsonData,
    };
  }
}