import 'dart:convert';

import 'package:zwiftdataviewer/models/routedata.dart';

/// Model class for the zw_routes table in Supabase
class RouteModel {
  final int id;
  final String? url;
  final String? world;
  final double? distanceMeters;
  final double? altitudeMeters;
  final String? eventOnly;
  final String? routeName;
  final bool? completed;
  final int? imageId;
  final String? jsonData;
  final int? athleteId;

  RouteModel({
    required this.id,
    this.url,
    this.world,
    this.distanceMeters,
    this.altitudeMeters,
    this.eventOnly,
    this.routeName,
    this.completed,
    this.imageId,
    this.jsonData,
    this.athleteId,
  });

  /// Creates a RouteModel from a RouteData object
  factory RouteModel.fromRouteData(RouteData route) {
    return RouteModel(
      id: route.id ?? 0,
      url: route.url,
      world: route.world,
      distanceMeters: route.distanceMeters,
      altitudeMeters: route.altitudeMeters,
      eventOnly: route.eventOnly,
      routeName: route.routeName,
      completed: route.completed,
      imageId: route.imageId,
      jsonData: jsonEncode(route.toJson())
    );
  }

  /// Creates a RouteModel from a map (database row)
  factory RouteModel.fromMap(Map<String, dynamic> map) {
    return RouteModel(
      id: map['id'] as int,
      url: map['url'] as String?,
      world: map['world'] as String?,
      distanceMeters: _toDouble(map['distance_meters']),
      altitudeMeters: _toDouble(map['altitude_meters']),
      eventOnly: map['event_only'] as String?,
      routeName: map['route_name'] as String?,
      completed: map['completed'] as bool?,
      imageId: map['image_id'] as int?,
      jsonData: map['json_data'] as String?,
      athleteId: map['athlete_id'] as int?,
    );
  }
  
  /// Helper method to convert various numeric types to double
  static double? _toDouble(dynamic value) {
    if (value == null) {
      return null;
    } else if (value is double) {
      return value;
    } else if (value is int) {
      return value.toDouble();
    } else if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  /// Converts this RouteModel to a RouteData object
  RouteData toRouteData() {
    if (jsonData != null) {
      try {
        return RouteData.fromJson(jsonDecode(jsonData!));
      } catch (e) {
        // Fallback to manual conversion if JSON parsing fails
      }
    }

    // Manual conversion
    final route = RouteData(
      url,
      world,
      distanceMeters,
      altitudeMeters,
      eventOnly,
      routeName,
      id,
    );
    route.completed = completed;
    route.imageId = imageId;
    return route;
  }

  /// Converts this RouteModel to a map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'world': world,
      'distance_meters': distanceMeters,
      'altitude_meters': altitudeMeters,
      'event_only': eventOnly,
      'route_name': routeName,
      'completed': completed,
      'image_id': imageId,
      'json_data': jsonData,
      'athlete_id': athleteId,
    };
  }
}
