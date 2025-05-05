import 'dart:convert';

import 'package:zwiftdataviewer/models/worlddata.dart';
import 'package:zwiftdataviewer/utils/worldsconfig.dart';

/// Model class for the zw_worlds table in Supabase
class WorldModel {
  final int id;
  final String? name;
  final String? url;
  final String? jsonData;
  final int? athleteId;

  WorldModel({
    required this.id,
    this.name,
    this.url,
    this.jsonData,
    this.athleteId,
  });

  /// Creates a WorldModel from a WorldData object
  factory WorldModel.fromWorldData(WorldData world) {
    return WorldModel(
      id: world.id ?? 0,
      name: world.name,
      url: world.url,
      jsonData: jsonEncode(world.toJson())
    );
  }

  /// Creates a WorldModel from a map (database row)
  factory WorldModel.fromMap(Map<String, dynamic> map) {
    return WorldModel(
      id: _toInt(map['id']) ?? 0,
      name: map['name'] as String?,
      url: map['url'] as String?,
      jsonData: map['json_data'] as String?,
      athleteId: _toInt(map['athlete_id']),
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

  /// Converts this WorldModel to a WorldData object
  WorldData toWorldData() {
    if (jsonData != null) {
      try {
        return WorldData.fromJson(jsonDecode(jsonData!));
      } catch (e) {
        // Fallback to manual conversion if JSON parsing fails
      }
    }

    // Manual conversion
    GuestWorldId? guestWorldId;
    try {
      // Find the GuestWorldId enum value that corresponds to the numeric id
      for (var entry in allWorldsConfig.entries) {
        if (entry.key == id) {
          guestWorldId = entry.value.guestWorldId;
          break;
        }
      }
    } catch (e) {
      // If we can't find a matching enum, default to others
      guestWorldId = GuestWorldId.others;
    }

    return WorldData(id, guestWorldId, name, url);
  }

  /// Converts this WorldModel to a map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'json_data': jsonData,
      'athlete_id': athleteId,
    };
  }
}
