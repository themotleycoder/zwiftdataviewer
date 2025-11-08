import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

/// Geographic bounds for a region
class GeoBounds {
  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;

  GeoBounds({
    required this.minLat,
    required this.maxLat,
    required this.minLng,
    required this.maxLng,
  });

  /// Creates bounds from a list of lat/lng points
  factory GeoBounds.fromPoints(List<gmaps.LatLng> points) {
    if (points.isEmpty) {
      throw ArgumentError('Points list cannot be empty');
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return GeoBounds(
      minLat: minLat,
      maxLat: maxLat,
      minLng: minLng,
      maxLng: maxLng,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'min_lat': minLat,
      'max_lat': maxLat,
      'min_lng': minLng,
      'max_lng': maxLng,
    };
  }

  factory GeoBounds.fromJson(Map<String, dynamic> json) {
    return GeoBounds(
      minLat: json['min_lat']?.toDouble() ?? 0.0,
      maxLat: json['max_lat']?.toDouble() ?? 0.0,
      minLng: json['min_lng']?.toDouble() ?? 0.0,
      maxLng: json['max_lng']?.toDouble() ?? 0.0,
    );
  }
}

/// A climb detected from elevation data
class DetectedClimb {
  /// Index in the streams data where climb starts
  final int startIndex;

  /// Index in the streams data where climb ends
  final int endIndex;

  /// Distance of the climb in meters
  final double distance;

  /// Total elevation gained in meters
  final double elevationGain;

  /// Average gradient as percentage
  final double avgGradient;

  /// Maximum gradient encountered as percentage
  final double maxGradient;

  /// GPS points along the climb
  final List<gmaps.LatLng> points;

  /// Geographic bounds of the climb
  final GeoBounds bounds;

  DetectedClimb({
    required this.startIndex,
    required this.endIndex,
    required this.distance,
    required this.elevationGain,
    required this.avgGradient,
    required this.maxGradient,
    required this.points,
    required this.bounds,
  });

  Map<String, dynamic> toJson() {
    return {
      'start_index': startIndex,
      'end_index': endIndex,
      'distance': distance,
      'elevation_gain': elevationGain,
      'avg_gradient': avgGradient,
      'max_gradient': maxGradient,
      'points': points.map((p) => [p.latitude, p.longitude]).toList(),
      'bounds': bounds.toJson(),
    };
  }

  factory DetectedClimb.fromJson(Map<String, dynamic> json) {
    final pointsList = json['points'] as List<dynamic>;
    final points = pointsList
        .map((p) => gmaps.LatLng(
              (p[0] as num).toDouble(),
              (p[1] as num).toDouble(),
            ))
        .toList();

    return DetectedClimb(
      startIndex: json['start_index'] as int,
      endIndex: json['end_index'] as int,
      distance: (json['distance'] as num).toDouble(),
      elevationGain: (json['elevation_gain'] as num).toDouble(),
      avgGradient: (json['avg_gradient'] as num).toDouble(),
      maxGradient: (json['max_gradient'] as num).toDouble(),
      points: points,
      bounds: GeoBounds.fromJson(json['bounds'] as Map<String, dynamic>),
    );
  }
}

/// A Strava segment matched to a detected climb
class MatchedSegment {
  /// Strava segment ID
  final int segmentId;

  /// Segment name
  final String name;

  /// Percentage of overlap between segment and detected climb (0-100)
  final double overlapPercentage;

  /// Climb category (0=HC, 1=Cat1, 2=Cat2, 3=Cat3, 4=Cat4, null=uncategorized)
  final int? climbCategory;

  /// Segment distance in meters
  final double distance;

  /// Average grade as percentage
  final double avgGrade;

  /// Total elevation gain in meters
  final double elevationGain;

  /// Maximum grade as percentage
  final double? maxGrade;

  /// Number of times athlete has completed this segment
  final int? athleteEffortCount;

  /// Athlete's PR time on this segment (seconds)
  final int? athletePrTime;

  /// Segment polyline (encoded)
  final String? polyline;

  MatchedSegment({
    required this.segmentId,
    required this.name,
    required this.overlapPercentage,
    this.climbCategory,
    required this.distance,
    required this.avgGrade,
    required this.elevationGain,
    this.maxGrade,
    this.athleteEffortCount,
    this.athletePrTime,
    this.polyline,
  });

  /// Get climb category as a human-readable string
  String get climbCategoryLabel {
    if (climbCategory == null) return 'Uncategorized';
    switch (climbCategory) {
      case 0:
        return 'HC (Hors Catégorie)';
      case 1:
        return 'Category 1';
      case 2:
        return 'Category 2';
      case 3:
        return 'Category 3';
      case 4:
        return 'Category 4';
      default:
        return 'Category $climbCategory';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'segment_id': segmentId,
      'name': name,
      'overlap_percentage': overlapPercentage,
      'climb_category': climbCategory,
      'distance': distance,
      'avg_grade': avgGrade,
      'elevation_gain': elevationGain,
      'max_grade': maxGrade,
      'athlete_effort_count': athleteEffortCount,
      'athlete_pr_time': athletePrTime,
      'polyline': polyline,
    };
  }

  factory MatchedSegment.fromJson(Map<String, dynamic> json) {
    return MatchedSegment(
      segmentId: json['segment_id'] as int,
      name: json['name'] as String,
      overlapPercentage: (json['overlap_percentage'] as num).toDouble(),
      climbCategory: json['climb_category'] as int?,
      distance: (json['distance'] as num).toDouble(),
      avgGrade: (json['avg_grade'] as num).toDouble(),
      elevationGain: (json['elevation_gain'] as num).toDouble(),
      maxGrade: json['max_grade'] != null ? (json['max_grade'] as num).toDouble() : null,
      athleteEffortCount: json['athlete_effort_count'] as int?,
      athletePrTime: json['athlete_pr_time'] as int?,
      polyline: json['polyline'] as String?,
    );
  }
}

/// A detected climb with its matched segments
class ClimbWithSegments {
  /// The detected climb
  final DetectedClimb climb;

  /// Matched Strava segments, sorted by overlap percentage (descending)
  final List<MatchedSegment> segments;

  ClimbWithSegments({
    required this.climb,
    required this.segments,
  });

  /// Get the best matching segment (highest overlap)
  MatchedSegment? get bestMatch {
    return segments.isEmpty ? null : segments.first;
  }

  /// Get categorized segments only
  List<MatchedSegment> get categorizedSegments {
    return segments.where((s) => s.climbCategory != null).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'climb': climb.toJson(),
      'segments': segments.map((s) => s.toJson()).toList(),
    };
  }

  factory ClimbWithSegments.fromJson(Map<String, dynamic> json) {
    return ClimbWithSegments(
      climb: DetectedClimb.fromJson(json['climb'] as Map<String, dynamic>),
      segments: (json['segments'] as List<dynamic>)
          .map((s) => MatchedSegment.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Complete analysis of an activity's climbs
class ActivityClimbAnalysis {
  /// Strava activity ID
  final int activityId;

  /// Total number of climbs detected
  final int totalClimbs;

  /// Total elevation gain from all climbs (meters)
  final double totalElevationGain;

  /// All detected climbs with their matched segments
  final List<ClimbWithSegments> climbs;

  /// When the analysis was performed
  final DateTime analyzedAt;

  ActivityClimbAnalysis({
    required this.activityId,
    required this.totalClimbs,
    required this.totalElevationGain,
    required this.climbs,
    required this.analyzedAt,
  });

  /// Get all categorized climbs
  List<ClimbWithSegments> get categorizedClimbs {
    return climbs.where((c) => c.categorizedSegments.isNotEmpty).toList();
  }

  /// Get summary statistics
  Map<String, dynamic> get statistics {
    final categorizedCount = categorizedClimbs.length;
    final totalMatches = climbs.fold<int>(0, (sum, c) => sum + c.segments.length);

    return {
      'total_climbs': totalClimbs,
      'categorized_climbs': categorizedCount,
      'total_elevation_gain': totalElevationGain,
      'total_segment_matches': totalMatches,
      'avg_matches_per_climb': totalClimbs > 0 ? totalMatches / totalClimbs : 0.0,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'activity_id': activityId,
      'total_climbs': totalClimbs,
      'total_elevation_gain': totalElevationGain,
      'climbs': climbs.map((c) => c.toJson()).toList(),
      'analyzed_at': analyzedAt.toIso8601String(),
    };
  }

  factory ActivityClimbAnalysis.fromJson(Map<String, dynamic> json) {
    return ActivityClimbAnalysis(
      activityId: json['activity_id'] as int,
      totalClimbs: json['total_climbs'] as int,
      totalElevationGain: (json['total_elevation_gain'] as num).toDouble(),
      climbs: (json['climbs'] as List<dynamic>)
          .map((c) => ClimbWithSegments.fromJson(c as Map<String, dynamic>))
          .toList(),
      analyzedAt: DateTime.parse(json['analyzed_at'] as String),
    );
  }
}
