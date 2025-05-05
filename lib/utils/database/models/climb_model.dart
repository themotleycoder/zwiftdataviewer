import 'dart:convert';

import 'package:zwiftdataviewer/models/climbdata.dart';
import 'package:zwiftdataviewer/utils/climbsconfig.dart';

/// Model class for the zw_climbs table in Supabase
class ClimbModel {
  final int id;
  final int? climbId;
  final String? name;
  final String? url;
  final String? jsonData;
  final int? athleteId;

  ClimbModel({
    required this.id,
    this.climbId,
    this.name,
    this.url,
    this.jsonData,
    this.athleteId,
  });

  /// Creates a ClimbModel from a ClimbData object
  factory ClimbModel.fromClimbData(ClimbData climb) {
    return ClimbModel(
      id: climb.id ?? 0,
      climbId: climbLookupByName[climb.name] ?? 0,
      name: climb.name,
      url: climb.url,
      jsonData: jsonEncode(climb.toJson())
    );
  }

  /// Creates a ClimbModel from a map (database row)
  factory ClimbModel.fromMap(Map<String, dynamic> map) {
    return ClimbModel(
      id: map['id'] as int,
      climbId: _toInt(map['climb_id']),
      name: map['name'] as String?,
      url: map['url'] as String?,
      jsonData: map['json_data'] as String?,
      athleteId: map['athlete_id'] as int?,
    );
  }
  
  /// Helper method to convert various numeric types to int
  static int? _toInt(dynamic value) {
    if (value == null) {
      return null;
    } else if (value is int) {
      return value;
    } else if (value is double) {
      return value.toInt();
    } else if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  /// Converts this ClimbModel to a ClimbData object
  ClimbData toClimbData() {
    if (jsonData != null) {
      try {
        return ClimbData.fromJson(jsonDecode(jsonData!));
      } catch (e) {
        // Fallback to manual conversion if JSON parsing fails
      }
    }

    // Manual conversion
    ClimbId? enumClimbId;
    if (climbId != null) {
      try {
        // Find the ClimbId enum value that corresponds to the numeric climbId
        for (var entry in allClimbsConfig.entries) {
          if (entry.key == climbId) {
            enumClimbId = entry.value.climbId;
            break;
          }
        }
      } catch (e) {
        // If we can't find a matching enum, default to others
        enumClimbId = ClimbId.others;
      }
    }

    return ClimbData(id, enumClimbId, name, url);
  }

  /// Converts this ClimbModel to a map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'climb_id': climbId,
      'name': name,
      'url': url,
      'json_data': jsonData,
      'athlete_id': athleteId,
    };
  }
}
