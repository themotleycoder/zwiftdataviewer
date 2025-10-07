import 'package:zwiftdataviewer/models/routedata.dart';

/// Represents a route recommendation with scoring and reasoning
/// 
/// This model contains a recommended route along with the AI-generated
/// reasoning and confidence scores for why this route was recommended.
class RouteRecommendation {
  final int? id;
  final String athleteId;
  final int routeId;
  final double confidenceScore; // 0.0 to 1.0
  final String recommendationType; // 'performance_match', 'progressive_challenge', 'exploration', 'similar_routes'
  final String reasoning; // AI-generated explanation
  final Map<String, dynamic> scoringFactors; // Detailed scoring breakdown
  final DateTime generatedAt;
  final bool isViewed;
  final bool isCompleted;
  final RouteData? routeData; // Optional, populated when needed

  RouteRecommendation({
    this.id,
    required this.athleteId,
    required this.routeId,
    required this.confidenceScore,
    required this.recommendationType,
    required this.reasoning,
    required this.scoringFactors,
    required this.generatedAt,
    this.isViewed = false,
    this.isCompleted = false,
    this.routeData,
  });

  factory RouteRecommendation.fromJson(Map<String, dynamic> json) {
    return RouteRecommendation(
      id: json['id'] as int?,
      athleteId: json['athleteId'] as String,
      routeId: json['routeId'] as int,
      confidenceScore: json['confidenceScore'] as double,
      recommendationType: json['recommendationType'] as String,
      reasoning: json['reasoning'] as String,
      scoringFactors: json['scoringFactors'] as Map<String, dynamic>,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      isViewed: json['isViewed'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      routeData: json['routeData'] != null 
          ? RouteData.fromJson(json['routeData'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'athleteId': athleteId,
      'routeId': routeId,
      'confidenceScore': confidenceScore,
      'recommendationType': recommendationType,
      'reasoning': reasoning,
      'scoringFactors': scoringFactors,
      'generatedAt': generatedAt.toIso8601String(),
      'isViewed': isViewed,
      'isCompleted': isCompleted,
      'routeData': routeData?.toJson(),
    };
  }

  /// Creates a copy of this recommendation with updated fields
  RouteRecommendation copyWith({
    int? id,
    String? athleteId,
    int? routeId,
    double? confidenceScore,
    String? recommendationType,
    String? reasoning,
    Map<String, dynamic>? scoringFactors,
    DateTime? generatedAt,
    bool? isViewed,
    bool? isCompleted,
    RouteData? routeData,
  }) {
    return RouteRecommendation(
      id: id ?? this.id,
      athleteId: athleteId ?? this.athleteId,
      routeId: routeId ?? this.routeId,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      recommendationType: recommendationType ?? this.recommendationType,
      reasoning: reasoning ?? this.reasoning,
      scoringFactors: scoringFactors ?? this.scoringFactors,
      generatedAt: generatedAt ?? this.generatedAt,
      isViewed: isViewed ?? this.isViewed,
      isCompleted: isCompleted ?? this.isCompleted,
      routeData: routeData ?? this.routeData,
    );
  }

  /// Gets a user-friendly recommendation type name
  String get recommendationTypeDisplayName {
    switch (recommendationType) {
      case 'performance_match':
        return 'Perfect Match';
      case 'progressive_challenge':
        return 'Next Challenge';
      case 'exploration':
        return 'New Discovery';
      case 'similar_routes':
        return 'Similar Route';
      default:
        return 'Recommended';
    }
  }

  /// Gets an appropriate icon for the recommendation type
  String get recommendationIcon {
    switch (recommendationType) {
      case 'performance_match':
        return '🎯';
      case 'progressive_challenge':
        return '📈';
      case 'exploration':
        return '🗺️';
      case 'similar_routes':
        return '🔄';
      default:
        return '⭐';
    }
  }

  /// Gets the confidence level as a string
  String get confidenceLevel {
    if (confidenceScore >= 0.8) return 'High';
    if (confidenceScore >= 0.6) return 'Medium';
    return 'Low';
  }

  /// Gets a color associated with the confidence level
  String get confidenceColor {
    if (confidenceScore >= 0.8) return '#4CAF50'; // Green
    if (confidenceScore >= 0.6) return '#FF9800'; // Orange
    return '#F44336'; // Red
  }

  /// Checks if this recommendation is still fresh (generated within last 7 days)
  bool get isFresh {
    final now = DateTime.now();
    final daysDifference = now.difference(generatedAt).inDays;
    return daysDifference <= 7;
  }

  /// Gets the priority score for ordering recommendations
  /// Higher scores should be shown first
  double get priorityScore {
    double score = confidenceScore;
    
    // Boost fresh recommendations
    if (isFresh) score += 0.1;
    
    // Boost unviewed recommendations
    if (!isViewed) score += 0.05;
    
    // Boost certain types
    switch (recommendationType) {
      case 'progressive_challenge':
        score += 0.15;
        break;
      case 'performance_match':
        score += 0.1;
        break;
      case 'exploration':
        score += 0.05;
        break;
    }
    
    return score.clamp(0.0, 1.0);
  }
}

/// Enum for different types of recommendations
enum RecommendationType {
  performanceMatch('performance_match', 'Routes that match your fitness level'),
  progressiveChallenge('progressive_challenge', 'Routes that provide the next level of challenge'),
  exploration('exploration', 'New routes in worlds you haven\'t fully explored'),
  similarRoutes('similar_routes', 'Routes similar to ones you\'ve enjoyed');

  const RecommendationType(this.value, this.description);
  
  final String value;
  final String description;
}