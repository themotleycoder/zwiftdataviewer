import 'dart:convert';
import 'package:zwiftdataviewer/models/climb_analysis.dart';

/// Database model for climb analysis results
///
/// Follows the hybrid pattern used throughout the app:
/// - Individual fields for querying
/// - Full JSON backup in json_data column
class ClimbAnalysisModel {
  final int? id;
  final int activityId;
  final int totalClimbs;
  final double totalElevationGain;
  final String analyzedAt;
  final String jsonData;

  ClimbAnalysisModel({
    this.id,
    required this.activityId,
    required this.totalClimbs,
    required this.totalElevationGain,
    required this.analyzedAt,
    required this.jsonData,
  });

  /// Convert an ActivityClimbAnalysis to a ClimbAnalysisModel
  factory ClimbAnalysisModel.fromActivityClimbAnalysis(
    ActivityClimbAnalysis analysis,
  ) {
    return ClimbAnalysisModel(
      activityId: analysis.activityId,
      totalClimbs: analysis.totalClimbs,
      totalElevationGain: analysis.totalElevationGain,
      analyzedAt: analysis.analyzedAt.toIso8601String(),
      jsonData: jsonEncode(analysis.toJson()),
    );
  }

  /// Convert a ClimbAnalysisModel to an ActivityClimbAnalysis
  ActivityClimbAnalysis toActivityClimbAnalysis() {
    final Map<String, dynamic> json = jsonDecode(jsonData);
    return ActivityClimbAnalysis.fromJson(json);
  }

  /// Convert a Map from the database to a ClimbAnalysisModel
  factory ClimbAnalysisModel.fromMap(Map<String, dynamic> map) {
    return ClimbAnalysisModel(
      id: map['id'] as int?,
      activityId: map['activity_id'] as int,
      totalClimbs: map['total_climbs'] as int,
      totalElevationGain: (map['total_elevation_gain'] as num).toDouble(),
      analyzedAt: map['analyzed_at'] as String,
      jsonData: map['json_data'] as String,
    );
  }

  /// Convert a ClimbAnalysisModel to a Map for the database
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'activity_id': activityId,
      'total_climbs': totalClimbs,
      'total_elevation_gain': totalElevationGain,
      'analyzed_at': analyzedAt,
      'json_data': jsonData,
    };
  }

  /// Validate the model data
  void validate() {
    if (activityId <= 0) {
      throw ArgumentError('Invalid activity ID: $activityId');
    }

    if (totalClimbs < 0) {
      throw ArgumentError('Total climbs cannot be negative: $totalClimbs');
    }

    if (totalElevationGain < 0) {
      throw ArgumentError('Total elevation gain cannot be negative: $totalElevationGain');
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
}
