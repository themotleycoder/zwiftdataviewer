/// Model representing a user's interaction/performance on a specific route
/// 
/// This tracks user performance metrics when completing routes, enabling
/// intelligent route recommendations based on historical performance data.
class UserRouteInteraction {
  final int? id;
  final int routeId;
  final int activityId;
  final String athleteId;
  final DateTime completedAt;
  final double? completionTimeSeconds;
  final double? averagePower;
  final double? averageHeartRate;
  final double? maxPower;
  final double? maxHeartRate;
  final double? normalizedPower;
  final double? intensityFactor;
  final double? trainingStressScore;
  final double? averageSpeed;
  final double? maxSpeed;
  final double? elevationGain;
  final String? perceivedEffort; // 'easy', 'moderate', 'hard', 'very_hard'
  final double? enjoymentRating; // 1-5 scale
  final bool wasPersonalRecord;
  final Map<String, dynamic>? additionalMetrics;

  UserRouteInteraction({
    this.id,
    required this.routeId,
    required this.activityId,
    required this.athleteId,
    required this.completedAt,
    this.completionTimeSeconds,
    this.averagePower,
    this.averageHeartRate,
    this.maxPower,
    this.maxHeartRate,
    this.normalizedPower,
    this.intensityFactor,
    this.trainingStressScore,
    this.averageSpeed,
    this.maxSpeed,
    this.elevationGain,
    this.perceivedEffort,
    this.enjoymentRating,
    this.wasPersonalRecord = false,
    this.additionalMetrics,
  });

  factory UserRouteInteraction.fromJson(Map<String, dynamic> json) {
    return UserRouteInteraction(
      id: json['id'] as int?,
      routeId: json['routeId'] as int,
      activityId: json['activityId'] as int,
      athleteId: json['athleteId'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      completionTimeSeconds: json['completionTimeSeconds'] as double?,
      averagePower: json['averagePower'] as double?,
      averageHeartRate: json['averageHeartRate'] as double?,
      maxPower: json['maxPower'] as double?,
      maxHeartRate: json['maxHeartRate'] as double?,
      normalizedPower: json['normalizedPower'] as double?,
      intensityFactor: json['intensityFactor'] as double?,
      trainingStressScore: json['trainingStressScore'] as double?,
      averageSpeed: json['averageSpeed'] as double?,
      maxSpeed: json['maxSpeed'] as double?,
      elevationGain: json['elevationGain'] as double?,
      perceivedEffort: json['perceivedEffort'] as String?,
      enjoymentRating: json['enjoymentRating'] as double?,
      wasPersonalRecord: json['wasPersonalRecord'] as bool? ?? false,
      additionalMetrics: json['additionalMetrics'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routeId': routeId,
      'activityId': activityId,
      'athleteId': athleteId,
      'completedAt': completedAt.toIso8601String(),
      'completionTimeSeconds': completionTimeSeconds,
      'averagePower': averagePower,
      'averageHeartRate': averageHeartRate,
      'maxPower': maxPower,
      'maxHeartRate': maxHeartRate,
      'normalizedPower': normalizedPower,
      'intensityFactor': intensityFactor,
      'trainingStressScore': trainingStressScore,
      'averageSpeed': averageSpeed,
      'maxSpeed': maxSpeed,
      'elevationGain': elevationGain,
      'perceivedEffort': perceivedEffort,
      'enjoymentRating': enjoymentRating,
      'wasPersonalRecord': wasPersonalRecord,
      'additionalMetrics': additionalMetrics,
    };
  }

  /// Creates a copy of this interaction with updated fields
  UserRouteInteraction copyWith({
    int? id,
    int? routeId,
    int? activityId,
    String? athleteId,
    DateTime? completedAt,
    double? completionTimeSeconds,
    double? averagePower,
    double? averageHeartRate,
    double? maxPower,
    double? maxHeartRate,
    double? normalizedPower,
    double? intensityFactor,
    double? trainingStressScore,
    double? averageSpeed,
    double? maxSpeed,
    double? elevationGain,
    String? perceivedEffort,
    double? enjoymentRating,
    bool? wasPersonalRecord,
    Map<String, dynamic>? additionalMetrics,
  }) {
    return UserRouteInteraction(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      activityId: activityId ?? this.activityId,
      athleteId: athleteId ?? this.athleteId,
      completedAt: completedAt ?? this.completedAt,
      completionTimeSeconds: completionTimeSeconds ?? this.completionTimeSeconds,
      averagePower: averagePower ?? this.averagePower,
      averageHeartRate: averageHeartRate ?? this.averageHeartRate,
      maxPower: maxPower ?? this.maxPower,
      maxHeartRate: maxHeartRate ?? this.maxHeartRate,
      normalizedPower: normalizedPower ?? this.normalizedPower,
      intensityFactor: intensityFactor ?? this.intensityFactor,
      trainingStressScore: trainingStressScore ?? this.trainingStressScore,
      averageSpeed: averageSpeed ?? this.averageSpeed,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      elevationGain: elevationGain ?? this.elevationGain,
      perceivedEffort: perceivedEffort ?? this.perceivedEffort,
      enjoymentRating: enjoymentRating ?? this.enjoymentRating,
      wasPersonalRecord: wasPersonalRecord ?? this.wasPersonalRecord,
      additionalMetrics: additionalMetrics ?? this.additionalMetrics,
    );
  }

  /// Calculates a difficulty score based on performance metrics
  /// Returns a value between 0.0 (very easy) and 10.0 (extremely hard)
  double get difficultyScore {
    double score = 5.0; // Base difficulty

    // Factor in intensity factor if available
    if (intensityFactor != null) {
      if (intensityFactor! > 1.0) {
        score += 2.0;
      } else if (intensityFactor! > 0.9) {
        score += 1.0;
      } else if (intensityFactor! < 0.7) {
        score -= 1.0;
      }
    }

    // Factor in perceived effort
    if (perceivedEffort != null) {
      switch (perceivedEffort!.toLowerCase()) {
        case 'easy':
          score -= 2.0;
          break;
        case 'moderate':
          break; // No change
        case 'hard':
          score += 2.0;
          break;
        case 'very_hard':
          score += 3.0;
          break;
      }
    }

    // Clamp between 0 and 10
    return score.clamp(0.0, 10.0);
  }

  /// Calculates a performance score based on various metrics
  /// Returns a value between 0.0 (poor performance) and 10.0 (excellent performance)
  double get performanceScore {
    double score = 5.0; // Base score

    if (wasPersonalRecord) score += 2.0;
    
    if (enjoymentRating != null) {
      score += (enjoymentRating! - 3.0); // Adjust based on 1-5 scale, 3 being neutral
    }

    if (intensityFactor != null) {
      if (intensityFactor! > 1.0) score += 1.0; // High intensity suggests good performance
    }

    return score.clamp(0.0, 10.0);
  }
}