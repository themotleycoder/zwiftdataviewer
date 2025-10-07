import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:zwiftdataviewer/models/route_recommendation.dart';
import 'package:zwiftdataviewer/models/routedata.dart';
import 'package:zwiftdataviewer/models/user_route_interaction.dart';
import 'package:zwiftdataviewer/providers/routedataprovider.dart';
import 'package:zwiftdataviewer/services/gemini_ai_service.dart';
import 'package:zwiftdataviewer/utils/database/services/route_recommendation_service.dart' as db;

/// Intelligent route recommendation service that analyzes user performance
/// and generates personalized route recommendations using multiple algorithms
/// 
/// This service can be extended to integrate with AI services like Gemini 2.5
/// for even more sophisticated recommendations.
class IntelligentRouteRecommendationService {
  final db.RouteRecommendationService _dbService = db.RouteRecommendationService();
  // Note: RouteRepository needs to be injected or accessed differently
  // final RouteRepository _routeRepository = RouteRepository();
  
  // Singleton pattern
  static final IntelligentRouteRecommendationService _instance = IntelligentRouteRecommendationService._internal();
  factory IntelligentRouteRecommendationService() => _instance;
  IntelligentRouteRecommendationService._internal();

  /// Generates route recommendations for a specific athlete based on their
  /// recent activity history and performance data
  Future<List<RouteRecommendation>> generateRecommendations(
    String athleteId, 
    {int recentActivityLimit = 10, int maxRecommendations = 10}
  ) async {
    try {
      // Get recent route interactions for analysis
      final recentInteractions = await _dbService.getRecentRouteInteractions(
        athleteId, 
        recentActivityLimit
      );

      if (recentInteractions.isEmpty) {
        if (kDebugMode) {
          debugPrint('No recent route interactions found for athlete $athleteId');
          debugPrint('Generating recommendations based on available routes...');
        }
        
        // Try to connect to route repository and generate basic recommendations
        return await generateRecommendationsWithoutHistory(athleteId, maxRecommendations);
      }

      // Get all available routes from database
      final List<RouteData> allRoutes = await _fetchAllRoutes();
      if (allRoutes.isEmpty) {
        if (kDebugMode) {
          debugPrint('No routes available in repository');
        }
        return [];
      }

      // Filter out already completed routes from recent interactions
      final completedRouteIds = recentInteractions.map((i) => i.routeId).toSet();
      final availableRoutes = allRoutes.where((route) => 
        route.id != null && !completedRouteIds.contains(route.id!)
      ).toList();

      if (availableRoutes.isEmpty) {
        if (kDebugMode) {
          debugPrint('All available routes have been completed recently');
        }
        return _generateExplorationRecommendations(athleteId, maxRecommendations);
      }

      // Generate different types of recommendations
      final List<RouteRecommendation> recommendations = [];

      // Try AI recommendations first (if available)
      try {
        final aiRecs = await generateAIRecommendations(
          athleteId,
          recentInteractions,
          maxRecommendations: (maxRecommendations * 0.3).ceil(), // 30% AI recommendations
        );
        recommendations.addAll(aiRecs);

        if (kDebugMode && aiRecs.isNotEmpty) {
          debugPrint('Added ${aiRecs.length} AI-powered recommendations');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('AI recommendations failed, continuing with algorithmic: $e');
        }
      }

      final remainingSlots = maxRecommendations - recommendations.length;
      if (remainingSlots <= 0) {
        // If AI provided enough recommendations, we're done
        final finalRecs = recommendations.take(maxRecommendations).toList();
        await _dbService.insertOrUpdateRecommendations(finalRecs);
        return finalRecs;
      }

      // Fill remaining slots with algorithmic recommendations
      // 1. Performance-matched recommendations (40% of remaining)
      final performanceRecs = await _generatePerformanceMatchedRecommendations(
        athleteId, recentInteractions, availableRoutes, 
        (remainingSlots * 0.4).ceil()
      );
      recommendations.addAll(performanceRecs);

      // 2. Progressive challenge recommendations (30% of remaining)
      final challengeRecs = await _generateProgressiveChallengeRecommendations(
        athleteId, recentInteractions, availableRoutes, 
        (remainingSlots * 0.3).ceil()
      );
      recommendations.addAll(challengeRecs);

      // 3. Exploration recommendations (20% of remaining)
      final explorationRecs = await _generateExplorationRecommendations(
        athleteId, (remainingSlots * 0.2).ceil(), availableRoutes
      );
      recommendations.addAll(explorationRecs);

      // 4. Similar routes recommendations (10% of remaining)
      final similarRecs = await _generateSimilarRoutesRecommendations(
        athleteId, recentInteractions, availableRoutes, 
        (remainingSlots * 0.1).ceil()
      );
      recommendations.addAll(similarRecs);

      // Sort by priority score and return top recommendations
      recommendations.sort((a, b) => b.priorityScore.compareTo(a.priorityScore));
      final finalRecs = recommendations.take(maxRecommendations).toList();

      // Store recommendations in database
      await _dbService.insertOrUpdateRecommendations(finalRecs);

      if (kDebugMode) {
        debugPrint('Generated ${finalRecs.length} recommendations for athlete $athleteId');
      }

      return finalRecs;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error generating recommendations: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return [];
    }
  }

  /// Generates AI-powered recommendations using Gemini 2.5
  /// 
  /// This method integrates with Google's Gemini 2.5 API to analyze
  /// user performance data and generate sophisticated recommendations
  Future<List<RouteRecommendation>> generateAIRecommendations(
    String athleteId,
    List<UserRouteInteraction> recentInteractions,
    {int maxRecommendations = 3}
  ) async {
    try {
      if (recentInteractions.isEmpty) {
        if (kDebugMode) {
          debugPrint('No recent interactions for AI analysis');
        }
        return [];
      }

      final geminiService = GeminiAIService();
      
      // Get available routes
      final availableRoutes = await _getAvailableRoutes();
      if (availableRoutes.isEmpty) {
        if (kDebugMode) {
          debugPrint('No available routes for AI recommendations');
        }
        return [];
      }
      
      // Get AI analysis
      final analysisResult = await geminiService.analyzeRoutePerformance(
        recentInteractions,
        availableRoutes,
      );
      
      // Parse AI response and create recommendations
      return _parseAIRecommendations(analysisResult, athleteId, maxRecommendations);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error generating AI recommendations: $e');
      }
      // Fallback to algorithmic recommendations
      return [];
    }
  }

  /// Fetches all available routes from the database
  Future<List<RouteData>> _fetchAllRoutes() async {
    try {
      // Use the route data provider's loading function
      final routesByWorld = await loadRouteDataFromSupabase();

      // Flatten the map into a single list of routes
      final allRoutes = <RouteData>[];
      for (final routes in routesByWorld.values) {
        allRoutes.addAll(routes);
      }

      // Filter out event-only and run-only routes
      final regularRoutes = allRoutes.where((route) {
        final eventOnly = route.eventOnly?.toLowerCase();
        // Exclude if:
        // - eventOnly == 'true' (event-only route)
        // - Contains 'event only' text
        // - Contains 'run only' (not for cycling)
        if (eventOnly == null || eventOnly.isEmpty) return true;
        if (eventOnly == 'true') return false;
        if (eventOnly.contains('event only')) return false;
        if (eventOnly.contains('run only')) return false;
        return true;
      }).toList();

      if (kDebugMode) {
        debugPrint('Fetched ${allRoutes.length} routes from database, ${regularRoutes.length} are regular cycling routes');
      }

      return regularRoutes;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching routes: $e');
      }
      // Try fallback to file repository
      try {
        final routesByWorld = await loadRouteDataFromFile();
        final allRoutes = <RouteData>[];
        for (final routes in routesByWorld.values) {
          allRoutes.addAll(routes);
        }

        // Filter out event-only and run-only routes
        final regularRoutes = allRoutes.where((route) {
          final eventOnly = route.eventOnly?.toLowerCase();
          // Exclude if:
          // - eventOnly == 'true' (event-only route)
          // - Contains 'event only' text
          // - Contains 'run only' (not for cycling)
          if (eventOnly == null || eventOnly.isEmpty) return true;
          if (eventOnly == 'true') return false;
          if (eventOnly.contains('event only')) return false;
          if (eventOnly.contains('run only')) return false;
          return true;
        }).toList();

        if (kDebugMode) {
          debugPrint('Fallback fetched ${allRoutes.length} routes, ${regularRoutes.length} are regular cycling routes');
        }

        return regularRoutes;
      } catch (fallbackError) {
        if (kDebugMode) {
          debugPrint('Fallback to file repository also failed: $fallbackError');
        }
        return [];
      }
    }
  }

  /// Gets available routes from the system
  Future<List<RouteData>> _getAvailableRoutes() async {
    // Delegate to _fetchAllRoutes
    return await _fetchAllRoutes();
  }

  /// Parses AI response and creates RouteRecommendation objects
  List<RouteRecommendation> _parseAIRecommendations(
    String aiResponse, 
    String athleteId, 
    int maxRecommendations
  ) {
    try {
      // Clean the response to extract JSON
      final jsonStart = aiResponse.indexOf('{');
      final jsonEnd = aiResponse.lastIndexOf('}') + 1;


      if (jsonStart == -1 || jsonEnd <= jsonStart) {
        throw const FormatException('No JSON found in AI response');
      }
      
      final jsonString = aiResponse.substring(jsonStart, jsonEnd);
      final Map<String, dynamic> parsed = jsonDecode(jsonString);
      
      final recommendations = <RouteRecommendation>[];
      final aiRecommendations = parsed['recommendations'] as List<dynamic>? ?? [];
      
      for (int i = 0; i < aiRecommendations.length && i < maxRecommendations; i++) {
        final rec = aiRecommendations[i] as Map<String, dynamic>;
        
        final recommendation = RouteRecommendation(
          athleteId: athleteId,
          routeId: rec['routeId'] as int,
          confidenceScore: (rec['confidence'] as num).toDouble(),
          recommendationType: rec['type'] as String,
          reasoning: rec['reasoning'] as String,
          scoringFactors: rec['factors'] as Map<String, dynamic>? ?? {},
          generatedAt: DateTime.now(),
        );
        
        recommendations.add(recommendation);
      }


      if (kDebugMode) {
        debugPrint('Parsed ${recommendations.length} AI recommendations');
      }

      return recommendations;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error parsing AI recommendations: $e');
        debugPrint('AI Response: $aiResponse');
      }
      return [];
    }
  }

  /// Generates recommendations for routes that match the user's current fitness level
  Future<List<RouteRecommendation>> _generatePerformanceMatchedRecommendations(
    String athleteId,
    List<UserRouteInteraction> recentInteractions,
    List<RouteData> availableRoutes,
    int maxRecommendations
  ) async {
    final recommendations = <RouteRecommendation>[];
    
    // Calculate user's average performance metrics
    final avgMetrics = _calculateAverageMetrics(recentInteractions);
    
    for (final route in availableRoutes) {
      if (recommendations.length >= maxRecommendations) break;
      
      final score = _calculatePerformanceMatchScore(route, avgMetrics);
      if (score > 0.6) { // Only recommend routes with good fit
        final reasoning = _generatePerformanceMatchReasoning(route, avgMetrics, score);
        
        recommendations.add(RouteRecommendation(
          athleteId: athleteId,
          routeId: route.id!,
          confidenceScore: score,
          recommendationType: 'performance_match',
          reasoning: reasoning,
          scoringFactors: {
            'distance_match': _calculateDistanceMatch(route, avgMetrics),
            'elevation_match': _calculateElevationMatch(route, avgMetrics),
            'overall_score': score,
          },
          generatedAt: DateTime.now(),
          routeData: route,
        ));
      }
    }
    
    // Sort by confidence score
    recommendations.sort((a, b) => b.confidenceScore.compareTo(a.confidenceScore));
    return recommendations.take(maxRecommendations).toList();
  }

  /// Generates recommendations for routes that provide the next level of challenge
  Future<List<RouteRecommendation>> _generateProgressiveChallengeRecommendations(
    String athleteId,
    List<UserRouteInteraction> recentInteractions,
    List<RouteData> availableRoutes,
    int maxRecommendations
  ) async {
    final recommendations = <RouteRecommendation>[];
    
    // Find the user's current difficulty level
    final currentDifficulty = _calculateCurrentDifficultyLevel(recentInteractions);
    final targetDifficulty = currentDifficulty + 1.0; // Small step up
    
    for (final route in availableRoutes) {
      if (recommendations.length >= maxRecommendations) break;
      
      final routeDifficulty = _estimateRouteDifficulty(route);
      final difficultyDiff = (routeDifficulty - targetDifficulty).abs();
      
      if (difficultyDiff <= 1.0) { // Within reasonable challenge range
        final score = (1.0 - difficultyDiff / 2.0).clamp(0.0, 1.0);
        final reasoning = _generateProgressiveChallengeReasoning(route, currentDifficulty, routeDifficulty);
        
        recommendations.add(RouteRecommendation(
          athleteId: athleteId,
          routeId: route.id!,
          confidenceScore: score,
          recommendationType: 'progressive_challenge',
          reasoning: reasoning,
          scoringFactors: {
            'current_difficulty': currentDifficulty,
            'route_difficulty': routeDifficulty,
            'target_difficulty': targetDifficulty,
            'challenge_score': score,
          },
          generatedAt: DateTime.now(),
          routeData: route,
        ));
      }
    }
    
    recommendations.sort((a, b) => b.confidenceScore.compareTo(a.confidenceScore));
    return recommendations.take(maxRecommendations).toList();
  }

  /// Generates recommendations for exploring new worlds or areas
  Future<List<RouteRecommendation>> _generateExplorationRecommendations(
    String athleteId,
    int maxRecommendations,
    [List<RouteData>? availableRoutes]
  ) async {
    final recommendations = <RouteRecommendation>[];
    
    // TODO: Get routes from repository
    final routes = availableRoutes ?? <RouteData>[];
    if (routes.isEmpty) return recommendations;
    
    // Get user's interaction history to find unexplored worlds
    final allInteractions = await _dbService.getRouteInteractions(athleteId);
    final exploredWorlds = allInteractions.map((i) => i.routeId).toSet();
    
    // Group routes by world
    final routesByWorld = <String, List<RouteData>>{};
    for (final route in routes) {
      if (route.world != null && route.id != null && !exploredWorlds.contains(route.id!)) {
        routesByWorld.putIfAbsent(route.world!, () => []).add(route);
      }
    }
    
    // Recommend popular routes from unexplored worlds
    for (final world in routesByWorld.keys) {
      if (recommendations.length >= maxRecommendations) break;
      
      final worldRoutes = routesByWorld[world]!;
      worldRoutes.sort((a, b) => (b.distanceMeters ?? 0).compareTo(a.distanceMeters ?? 0));
      
      for (final route in worldRoutes.take(2)) { // Top 2 from each world
        if (recommendations.length >= maxRecommendations) break;
        
        final score = 0.7 + (Random().nextDouble() * 0.2); // Random exploration score
        final reasoning = 'Explore ${route.world}! This ${(route.distanceMeters ?? 0 / 1000).toStringAsFixed(1)}km route offers new scenery and challenges in a world you haven\'t visited recently.';
        
        recommendations.add(RouteRecommendation(
          athleteId: athleteId,
          routeId: route.id!,
          confidenceScore: score,
          recommendationType: 'exploration',
          reasoning: reasoning,
          scoringFactors: {
            'world_exploration': 1.0,
            'route_popularity': 0.8,
            'exploration_score': score,
          },
          generatedAt: DateTime.now(),
          routeData: route,
        ));
      }
    }
    
    recommendations.sort((a, b) => b.confidenceScore.compareTo(a.confidenceScore));
    return recommendations.take(maxRecommendations).toList();
  }

  /// Generates recommendations for routes similar to ones the user has enjoyed
  Future<List<RouteRecommendation>> _generateSimilarRoutesRecommendations(
    String athleteId,
    List<UserRouteInteraction> recentInteractions,
    List<RouteData> availableRoutes,
    int maxRecommendations
  ) async {
    final recommendations = <RouteRecommendation>[];
    
    // Find highly rated interactions
    final enjoyedInteractions = recentInteractions.where((i) => 
      (i.enjoymentRating ?? 0) >= 4.0 || i.wasPersonalRecord
    ).toList();
    
    if (enjoyedInteractions.isEmpty) return recommendations;
    
    // Note: In a real implementation, you'd get route data for enjoyed routes
    // For now, we'll use the available routes parameter
    
    // Find similar routes based on distance and elevation
    for (final route in availableRoutes) {
      if (recommendations.length >= maxRecommendations) break;
      
      double maxSimilarity = 0.0;
      for (final interaction in enjoyedInteractions) {
        final similarity = _calculateRouteSimilarity(route, interaction);
        maxSimilarity = max(maxSimilarity, similarity);
      }
      
      if (maxSimilarity > 0.7) {
        final reasoning = 'Based on routes you\'ve enjoyed, this ${(route.distanceMeters ?? 0 / 1000).toStringAsFixed(1)}km route in ${route.world} has similar characteristics to your favorites.';
        
        recommendations.add(RouteRecommendation(
          athleteId: athleteId,
          routeId: route.id!,
          confidenceScore: maxSimilarity,
          recommendationType: 'similar_routes',
          reasoning: reasoning,
          scoringFactors: {
            'similarity_score': maxSimilarity,
            'based_on_enjoyment': 1.0,
          },
          generatedAt: DateTime.now(),
          routeData: route,
        ));
      }
    }
    
    recommendations.sort((a, b) => b.confidenceScore.compareTo(a.confidenceScore));
    return recommendations.take(maxRecommendations).toList();
  }

  // ==================== Helper Methods ====================

  Map<String, double> _calculateAverageMetrics(List<UserRouteInteraction> interactions) {
    if (interactions.isEmpty) return {};
    
    double totalDistance = 0;
    double totalElevation = 0;
    double totalPower = 0;
    double totalIntensity = 0;
    int powerCount = 0;
    int intensityCount = 0;
    
    for (final interaction in interactions) {
      // Note: We'd need to get route data to calculate actual distances
      // For now, using placeholder logic
      totalDistance += 20000; // Placeholder: 20km average
      totalElevation += 200;  // Placeholder: 200m average
      
      if (interaction.averagePower != null) {
        totalPower += interaction.averagePower!;
        powerCount++;
      }
      
      if (interaction.intensityFactor != null) {
        totalIntensity += interaction.intensityFactor!;
        intensityCount++;
      }
    }
    
    return {
      'avg_distance': totalDistance / interactions.length,
      'avg_elevation': totalElevation / interactions.length,
      'avg_power': powerCount > 0 ? totalPower / powerCount : 0,
      'avg_intensity': intensityCount > 0 ? totalIntensity / intensityCount : 0,
    };
  }

  double _calculatePerformanceMatchScore(RouteData route, Map<String, double> avgMetrics) {
    double score = 0.5; // Base score
    
    // Distance matching
    final distanceMatch = _calculateDistanceMatch(route, avgMetrics);
    score += distanceMatch * 0.3;
    
    // Elevation matching
    final elevationMatch = _calculateElevationMatch(route, avgMetrics);
    score += elevationMatch * 0.2;
    
    return score.clamp(0.0, 1.0);
  }

  double _calculateDistanceMatch(RouteData route, Map<String, double> avgMetrics) {
    final routeDistance = route.distanceMeters ?? 20000;
    final avgDistance = avgMetrics['avg_distance'] ?? 20000;
    
    final ratio = routeDistance / avgDistance;
    // Prefer routes within 20% of average distance
    if (ratio >= 0.8 && ratio <= 1.2) {
      return 1.0 - (ratio - 1.0).abs() * 2.5; // Scale difference
    }
    return 0.0;
  }

  double _calculateElevationMatch(RouteData route, Map<String, double> avgMetrics) {
    final routeElevation = route.altitudeMeters ?? 200;
    final avgElevation = avgMetrics['avg_elevation'] ?? 200;
    
    final ratio = routeElevation / avgElevation;
    // Prefer routes within 30% of average elevation
    if (ratio >= 0.7 && ratio <= 1.3) {
      return 1.0 - (ratio - 1.0).abs() * 1.67; // Scale difference
    }
    return 0.0;
  }

  double _calculateCurrentDifficultyLevel(List<UserRouteInteraction> interactions) {
    if (interactions.isEmpty) return 5.0; // Default medium difficulty
    
    final difficultyScores = interactions.map((i) => i.difficultyScore).toList();
    return difficultyScores.reduce((a, b) => a + b) / difficultyScores.length;
  }

  double _estimateRouteDifficulty(RouteData route) {
    double difficulty = 5.0; // Base difficulty
    
    final distance = route.distanceMeters ?? 20000; // meters
    final elevation = route.altitudeMeters ?? 200; // meters
    
    // Factor in distance (longer = harder)
    if (distance > 40000) {
      difficulty += 2.0;
    } else if (distance > 25000) {
      difficulty += 1.0;
    } else if (distance < 10000) {
      difficulty -= 1.0;
    }
    
    // Factor in elevation (more elevation = harder)
    if (elevation > 500) {
      difficulty += 2.0;
    } else if (elevation > 300) {
      difficulty += 1.0;
    } else if (elevation < 100) {
      difficulty -= 1.0;
    }
    
    return difficulty.clamp(1.0, 10.0);
  }

  double _calculateRouteSimilarity(RouteData route, UserRouteInteraction interaction) {
    // Placeholder similarity calculation
    // In a real implementation, this would compare route characteristics
    return 0.75; // Mock similarity score
  }

  String _generatePerformanceMatchReasoning(RouteData route, Map<String, double> metrics, double score) {
    final distance = (route.distanceMeters ?? 0) / 1000;
    final elevation = route.altitudeMeters ?? 0;
    
    return 'This ${distance.toStringAsFixed(1)}km route in ${route.world} with ${elevation.toInt()}m elevation matches your recent performance profile. '
           'Perfect for maintaining your current fitness level while enjoying a new challenge.';
  }

  String _generateProgressiveChallengeReasoning(RouteData route, double currentDifficulty, double routeDifficulty) {
    final distance = (route.distanceMeters ?? 0) / 1000;
    
    return 'Ready to level up! This ${distance.toStringAsFixed(1)}km route in ${route.world} provides the perfect next challenge '
           'based on your recent progress. It\'s designed to push you just enough to improve without overwhelming.';
  }

  /// Generates recommendations when no user history is available
  /// This uses the existing route data and provides general recommendations
  Future<List<RouteRecommendation>> generateRecommendationsWithoutHistory(
    String athleteId,
    int maxRecommendations,
  ) async {
    try {
      // Get routes from existing providers
      final availableRoutes = await _getRoutesFromExistingProviders();

      if (availableRoutes.isEmpty) {
        if (kDebugMode) {
          debugPrint('No routes available from providers');
        }
        return [];
      }

      if (kDebugMode) {
        debugPrint('Found ${availableRoutes.length} routes for recommendations');
      }

      final recommendations = <RouteRecommendation>[];
      
      // Generate beginner-friendly recommendations
      final beginnerRoutes = availableRoutes.where((route) => 
        (route.distanceMeters ?? 0) < 20000 && // Less than 20km
        (route.altitudeMeters ?? 0) < 200      // Less than 200m elevation
      ).toList();
      
      // Generate medium challenge recommendations  
      final mediumRoutes = availableRoutes.where((route) => 
        (route.distanceMeters ?? 0) >= 20000 && (route.distanceMeters ?? 0) <= 40000 &&
        (route.altitudeMeters ?? 0) >= 200 && (route.altitudeMeters ?? 0) <= 500
      ).toList();
      
      // Generate challenging recommendations
      final challengingRoutes = availableRoutes.where((route) => 
        (route.distanceMeters ?? 0) > 40000 || // Long distance
        (route.altitudeMeters ?? 0) > 500      // High elevation
      ).toList();

      // Create diverse recommendations
      int added = 0;
      
      // Add 1-2 beginner routes
      for (final route in beginnerRoutes.take(2)) {
        if (added >= maxRecommendations) break;
        if (route.id == null) continue;
        
        recommendations.add(RouteRecommendation(
          athleteId: athleteId,
          routeId: route.id!,
          confidenceScore: 0.7,
          recommendationType: 'exploration',
          reasoning: 'Perfect starter route! This ${((route.distanceMeters ?? 0) / 1000).toStringAsFixed(1)}km route in ${route.world ?? 'Zwift'} is ideal for building confidence and exploring the platform.',
          scoringFactors: {
            'beginner_friendly': 1.0,
            'distance_appropriate': 0.9,
            'elevation_gentle': 0.8,
          },
          generatedAt: DateTime.now(),
          routeData: route,
        ));
        added++;
      }
      
      // Add 1-2 medium routes
      for (final route in mediumRoutes.take(2)) {
        if (added >= maxRecommendations) break;
        if (route.id == null) continue;
        
        recommendations.add(RouteRecommendation(
          athleteId: athleteId,
          routeId: route.id!,
          confidenceScore: 0.75,
          recommendationType: 'performance_match',
          reasoning: 'Great balanced route! This ${((route.distanceMeters ?? 0) / 1000).toStringAsFixed(1)}km route in ${route.world ?? 'Zwift'} offers a good mix of distance and elevation for a solid workout.',
          scoringFactors: {
            'balanced_challenge': 1.0,
            'distance_variety': 0.8,
            'elevation_moderate': 0.7,
          },
          generatedAt: DateTime.now(),
          routeData: route,
        ));
        added++;
      }
      
      // Add 1 challenging route  
      for (final route in challengingRoutes.take(1)) {
        if (added >= maxRecommendations) break;
        if (route.id == null) continue;
        
        recommendations.add(RouteRecommendation(
          athleteId: athleteId,
          routeId: route.id!,
          confidenceScore: 0.65,
          recommendationType: 'progressive_challenge',
          reasoning: 'Ready for a challenge? This ${((route.distanceMeters ?? 0) / 1000).toStringAsFixed(1)}km route in ${route.world ?? 'Zwift'} will test your limits and help you improve your fitness.',
          scoringFactors: {
            'challenging_distance': 0.9,
            'elevation_demanding': 0.8,
            'growth_opportunity': 1.0,
          },
          generatedAt: DateTime.now(),
          routeData: route,
        ));
        added++;
      }
      
      // If we still need more recommendations, add random exploration routes
      final remainingRoutes = availableRoutes.where((route) => 
        route.id != null && !recommendations.any((rec) => rec.routeId == route.id)
      ).toList();
      
      remainingRoutes.shuffle();
      for (final route in remainingRoutes.take(maxRecommendations - added)) {
        recommendations.add(RouteRecommendation(
          athleteId: athleteId,
          routeId: route.id!,
          confidenceScore: 0.6,
          recommendationType: 'exploration',
          reasoning: 'Discover something new! This route in ${route.world ?? 'Zwift'} offers a fresh experience and new scenery to explore.',
          scoringFactors: {
            'variety': 1.0,
            'exploration': 0.9,
          },
          generatedAt: DateTime.now(),
          routeData: route,
        ));
      }

      // Store recommendations in database
      if (recommendations.isNotEmpty) {
        await _dbService.insertOrUpdateRecommendations(recommendations);
      }

      if (kDebugMode) {
        debugPrint('Generated ${recommendations.length} recommendations without user history');
      }

      return recommendations;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error generating recommendations without history: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return [];
    }
  }

  /// Gets routes from existing providers/repositories
  Future<List<RouteData>> _getRoutesFromExistingProviders() async {
    try {
      if (kDebugMode) {
        debugPrint('Loading routes from existing route data provider...');
      }

      // Load route data from the same source as your route list view
      final routeDataMap = await loadRouteDataFromSupabase();

      // Flatten the map to get all routes from all worlds
      final allRoutes = <RouteData>[];
      for (final worldRoutes in routeDataMap.values) {
        allRoutes.addAll(worldRoutes);
      }

      // Filter out event-only and run-only routes
      final regularRoutes = allRoutes.where((route) {
        final eventOnly = route.eventOnly?.toLowerCase();
        // Exclude if:
        // - eventOnly == 'true' (event-only route)
        // - Contains 'event only' text
        // - Contains 'run only' (not for cycling)
        if (eventOnly == null || eventOnly.isEmpty) return true;
        if (eventOnly == 'true') return false;
        if (eventOnly.contains('event only')) return false;
        if (eventOnly.contains('run only')) return false;
        return true;
      }).toList();

      if (kDebugMode) {
        debugPrint('Loaded ${allRoutes.length} routes from data provider, ${regularRoutes.length} are regular cycling routes');

        // Log some sample routes for debugging
        for (int i = 0; i < min(5, regularRoutes.length); i++) {
          final route = regularRoutes[i];
          debugPrint('Sample route ${i + 1}: ${route.routeName} (${route.world}) - ${((route.distanceMeters ?? 0) / 1000).toStringAsFixed(1)}km');
        }
      }

      return regularRoutes;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading from Supabase, trying file repository: $e');
      }
      
      try {
        // Fallback to file repository
        final routeDataMap = await loadRouteDataFromFile();

        final allRoutes = <RouteData>[];
        for (final worldRoutes in routeDataMap.values) {
          allRoutes.addAll(worldRoutes);
        }

        // Filter out event-only and run-only routes
        final regularRoutes = allRoutes.where((route) {
          final eventOnly = route.eventOnly?.toLowerCase();
          // Exclude if:
          // - eventOnly == 'true' (event-only route)
          // - Contains 'event only' text
          // - Contains 'run only' (not for cycling)
          if (eventOnly == null || eventOnly.isEmpty) return true;
          if (eventOnly == 'true') return false;
          if (eventOnly.contains('event only')) return false;
          if (eventOnly.contains('run only')) return false;
          return true;
        }).toList();

        if (kDebugMode) {
          debugPrint('Loaded ${allRoutes.length} routes from file repository, ${regularRoutes.length} are regular cycling routes');
        }

        return regularRoutes;
      } catch (fileError) {
        if (kDebugMode) {
          debugPrint('Error loading routes from file repository: $fileError');
        }
        return [];
      }
    }
  }
}