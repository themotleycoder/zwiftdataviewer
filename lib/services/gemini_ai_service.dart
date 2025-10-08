import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/routedata.dart';
import '../models/user_route_interaction.dart';
import '../secrets.dart';

/// Service for integrating with Google's Gemini 2.5 AI model
/// to generate intelligent route recommendations based on user performance data
class GeminiAIService {
  late final GenerativeModel _model;

  GeminiAIService() {
    _model = GenerativeModel(
      model: GeminiConfig.model,
      apiKey: GeminiConfig.apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 2048,
      ),
    );
  }

  /// Analyzes user route performance data and generates AI recommendations
  Future<String> analyzeRoutePerformance(
    List<UserRouteInteraction> interactions,
    List<RouteData> availableRoutes,
  ) async {
    try {
      final prompt = _buildAnalysisPrompt(interactions, availableRoutes);
      
      if (kDebugMode) {
        print('Sending prompt to Gemini AI (${prompt.length} characters)');
      }
      
      final response = await _model.generateContent([Content.text(prompt)]);
      final result = response.text ?? '';
      
      if (kDebugMode) {
        print('Received AI response (${result.length} characters)');
      }
      
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Error calling Gemini AI: $e');
      }
      rethrow;
    }
  }
  
  /// Builds the analysis prompt for the AI model
  String _buildAnalysisPrompt(
    List<UserRouteInteraction> interactions,
    List<RouteData> availableRoutes,
  ) {
    final buffer = StringBuffer();
    
    buffer.writeln('You are an expert cycling coach analyzing cycling performance data.');
    buffer.writeln('Based on the user\'s recent route completions, recommend 3 optimal routes.');
    buffer.writeln();
    
    // User performance context
    buffer.writeln('## USER PERFORMANCE DATA');
    buffer.writeln('Recent route completions (last ${interactions.length} rides):');
    buffer.writeln();
    
    for (int i = 0; i < interactions.length && i < 10; i++) {
      final interaction = interactions[i];
      buffer.writeln('Route ${interaction.routeId}:');
      buffer.writeln('  - Completed: ${interaction.completedAt.toLocal().toString().substring(0, 16)}');
      if (interaction.completionTimeSeconds != null) {
        buffer.writeln('  - Time: ${_formatDuration(interaction.completionTimeSeconds!)}');
      }
      if (interaction.averagePower != null) {
        buffer.writeln('  - Avg Power: ${interaction.averagePower!.toInt()}W');
      }
      if (interaction.averageHeartRate != null) {
        buffer.writeln('  - Avg HR: ${interaction.averageHeartRate!.toInt()} bpm');
      }
      if (interaction.intensityFactor != null) {
        buffer.writeln('  - Intensity Factor: ${interaction.intensityFactor!.toStringAsFixed(2)}');
      }
      if (interaction.enjoymentRating != null) {
        buffer.writeln('  - Enjoyment: ${interaction.enjoymentRating}/5');
      }
      if (interaction.perceivedEffort != null) {
        buffer.writeln('  - Perceived Effort: ${interaction.perceivedEffort}');
      }
      if (interaction.wasPersonalRecord) {
        buffer.writeln('  - ⭐ Personal Record!');
      }
      buffer.writeln();
    }
    
    // Performance summary
    final avgMetrics = _calculatePerformanceMetrics(interactions);
    buffer.writeln('## PERFORMANCE SUMMARY');
    buffer.writeln('Average Power: ${avgMetrics['avgPower']?.toInt() ?? 'N/A'}W');
    buffer.writeln('Average Heart Rate: ${avgMetrics['avgHeartRate']?.toInt() ?? 'N/A'} bpm');
    buffer.writeln('Average Intensity Factor: ${avgMetrics['avgIntensity']?.toStringAsFixed(2) ?? 'N/A'}');
    buffer.writeln('Personal Records: ${avgMetrics['prCount']?.toInt() ?? 0}/${interactions.length}');
    buffer.writeln('Average Enjoyment: ${avgMetrics['avgEnjoyment']?.toStringAsFixed(1) ?? 'N/A'}/5');
    buffer.writeln();
    
    // Available routes context
    buffer.writeln('## AVAILABLE ROUTES (Regular Cycling Routes Only)');
    buffer.writeln('NOTE: All routes listed are regular cycling routes. Event-only and run-only routes have been excluded.');
    buffer.writeln();
    final routeSample = availableRoutes.take(20).toList(); // Limit for token efficiency
    for (final route in routeSample) {
      buffer.writeln('Route ${route.id}: ${route.routeName}');
      buffer.writeln('  - World: ${route.world}');
      buffer.writeln('  - Distance: ${((route.distanceMeters ?? 0) / 1000).toStringAsFixed(1)}km');
      buffer.writeln('  - Elevation: ${route.altitudeMeters?.toInt() ?? 0}m');
      buffer.writeln();
    }

    if (availableRoutes.length > 20) {
      buffer.writeln('... and ${availableRoutes.length - 20} more routes available');
      buffer.writeln();
    }

    // Request format
    buffer.writeln('## RECOMMENDATION REQUEST');
    buffer.writeln('Analyze the user\'s performance patterns and recommend exactly 3 routes that would:');
    buffer.writeln('1. Match their current fitness level and preferences');
    buffer.writeln('2. Provide appropriate challenge for continued improvement');
    buffer.writeln('3. Consider their enjoyment patterns and world exploration');
    buffer.writeln('4. ONLY recommend from the available routes list above (no event-only or run-only routes)');
    buffer.writeln();
    buffer.writeln('RESPOND ONLY WITH VALID JSON in this exact format:');
    buffer.writeln('{');
    buffer.writeln('  "recommendations": [');
    buffer.writeln('    {');
    buffer.writeln('      "routeId": 123,');
    buffer.writeln('      "confidence": 0.85,');
    buffer.writeln('      "type": "performance_match",');
    buffer.writeln('      "reasoning": "Detailed explanation of why this route is recommended...",');
    buffer.writeln('      "factors": {');
    buffer.writeln('        "distance_match": 0.9,');
    buffer.writeln('        "elevation_match": 0.8,');
    buffer.writeln('        "world_variety": 0.7,');
    buffer.writeln('        "difficulty_progression": 0.6');
    buffer.writeln('      }');
    buffer.writeln('    }');
    buffer.writeln('  ]');
    buffer.writeln('}');
    buffer.writeln();
    buffer.writeln('Types: "performance_match", "progressive_challenge", "exploration", "similar_routes"');
    buffer.writeln('Confidence: 0.0 to 1.0 (higher = more confident)');
    
    return buffer.toString();
  }
  
  /// Calculates performance metrics from user interactions
  Map<String, double> _calculatePerformanceMetrics(List<UserRouteInteraction> interactions) {
    if (interactions.isEmpty) return {};
    
    double totalPower = 0;
    double totalHeartRate = 0;
    double totalIntensity = 0;
    double totalEnjoyment = 0;
    int powerCount = 0;
    int heartRateCount = 0;
    int intensityCount = 0;
    int enjoymentCount = 0;
    int prCount = 0;
    
    for (final interaction in interactions) {
      if (interaction.averagePower != null) {
        totalPower += interaction.averagePower!;
        powerCount++;
      }
      
      if (interaction.averageHeartRate != null) {
        totalHeartRate += interaction.averageHeartRate!;
        heartRateCount++;
      }
      
      if (interaction.intensityFactor != null) {
        totalIntensity += interaction.intensityFactor!;
        intensityCount++;
      }
      
      if (interaction.enjoymentRating != null) {
        totalEnjoyment += interaction.enjoymentRating!;
        enjoymentCount++;
      }
      
      if (interaction.wasPersonalRecord) {
        prCount++;
      }
    }
    
    return {
      'avgPower': powerCount > 0 ? totalPower / powerCount : 0,
      'avgHeartRate': heartRateCount > 0 ? totalHeartRate / heartRateCount : 0,
      'avgIntensity': intensityCount > 0 ? totalIntensity / intensityCount : 0,
      'avgEnjoyment': enjoymentCount > 0 ? totalEnjoyment / enjoymentCount : 0,
      'prCount': prCount.toDouble(),
    };
  }
  
  /// Formats duration in seconds to human-readable format
  String _formatDuration(double seconds) {
    final duration = Duration(seconds: seconds.toInt());
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else {
      return '${minutes}m ${secs}s';
    }
  }
}