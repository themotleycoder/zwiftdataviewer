import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/models/route_recommendation.dart';
import 'package:zwiftdataviewer/services/route_recommendation_service.dart';
import 'package:zwiftdataviewer/utils/database/services/route_recommendation_service.dart' as db;
import 'package:zwiftdataviewer/utils/supabase/supabase_auth_service.dart';

/// Provider for managing route recommendations state
/// 
/// Handles loading, generating, and updating route recommendations
/// using the intelligent recommendation service and local database cache.
class RouteRecommendationsNotifier extends StateNotifier<AsyncValue<List<RouteRecommendation>>> {
  final IntelligentRouteRecommendationService _intelligentService;
  final db.RouteRecommendationService _dbService;
  final SupabaseAuthService _authService;

  RouteRecommendationsNotifier(
    this._intelligentService,
    this._dbService,
    this._authService,
  ) : super(const AsyncValue.loading()) {
    _loadRecommendations();
  }

  /// Loads recommendations from local cache
  Future<void> _loadRecommendations() async {
    try {
      final athleteId = await _getAthleteId();
      if (athleteId == null) {
        state = const AsyncValue.data([]);
        return;
      }

      // Load from local database first (cache-aside pattern)
      final recommendations = await _dbService.getActiveRecommendations(athleteId);
      state = AsyncValue.data(recommendations);

      // If we have no recommendations, try to generate some
      if (recommendations.isEmpty) {
        await generateNewRecommendations(silent: true);
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print('Error loading recommendations: $error');
      }
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Generates new recommendations using the intelligent service
  Future<void> generateNewRecommendations({bool silent = false}) async {
    if (!silent) {
      state = const AsyncValue.loading();
    }

    try {
      final athleteId = await _getAthleteId();
      if (athleteId == null) {
        throw Exception('User not authenticated');
      }

      // Generate new recommendations
      final newRecommendations = await _intelligentService.generateRecommendations(
        athleteId,
        recentActivityLimit: 10,
        maxRecommendations: 15,
      );

      // Update state
      state = AsyncValue.data(newRecommendations);

      if (kDebugMode) {
        print('Generated ${newRecommendations.length} new recommendations');
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print('Error generating recommendations: $error');
      }
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Marks a recommendation as viewed
  Future<void> markAsViewed(int recommendationId) async {
    try {
      await _dbService.markRecommendationAsViewed(recommendationId);
      
      // Update local state
      state.whenData((recommendations) {
        final updatedRecommendations = recommendations.map((rec) {
          if (rec.id == recommendationId) {
            return rec.copyWith(isViewed: true);
          }
          return rec;
        }).toList();
        
        state = AsyncValue.data(updatedRecommendations);
      });

      if (kDebugMode) {
        print('Marked recommendation $recommendationId as viewed');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error marking recommendation as viewed: $error');
      }
      // Don't update state on error to prevent inconsistency
    }
  }

  /// Marks a recommendation as completed
  Future<void> markAsCompleted(int recommendationId) async {
    try {
      await _dbService.markRecommendationAsCompleted(recommendationId);
      
      // Update local state
      state.whenData((recommendations) {
        final updatedRecommendations = recommendations.map((rec) {
          if (rec.id == recommendationId) {
            return rec.copyWith(isCompleted: true, isViewed: true);
          }
          return rec;
        }).toList();
        
        state = AsyncValue.data(updatedRecommendations);
      });

      if (kDebugMode) {
        print('Marked recommendation $recommendationId as completed');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error marking recommendation as completed: $error');
      }
    }
  }

  /// Refreshes recommendations from the server/database
  Future<void> refresh() async {
    await _loadRecommendations();
  }

  /// Cleans up expired recommendations
  Future<void> cleanupExpired() async {
    try {
      final deletedCount = await _dbService.cleanupExpiredRecommendations();
      
      if (deletedCount > 0) {
        if (kDebugMode) {
          print('Cleaned up $deletedCount expired recommendations');
        }
        // Refresh the list after cleanup
        await _loadRecommendations();
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error cleaning up expired recommendations: $error');
      }
    }
  }

  /// Force generation of recommendations without checking for existing route interactions
  /// This is useful when you have route data but no activity history linked yet
  Future<void> generateRecommendationsFromAvailableRoutes() async {
    state = const AsyncValue.loading();

    try {
      final athleteId = await _getAthleteId();
      if (athleteId == null) {
        throw Exception('User not authenticated');
      }

      if (kDebugMode) {
        print('Generating recommendations from available routes for athlete $athleteId');
      }

      // Create the intelligent service and call the fallback method directly
      final intelligentService = IntelligentRouteRecommendationService();
      final newRecommendations = await intelligentService.generateRecommendationsWithoutHistory(
        athleteId,
        15,
      );

      // Update state
      state = AsyncValue.data(newRecommendations);

      if (kDebugMode) {
        print('Generated ${newRecommendations.length} recommendations from available routes');
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print('Error generating recommendations from available routes: $error');
      }
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Gets the current athlete ID from auth service
  Future<String?> _getAthleteId() async {
    try {
      final athleteId = _authService.currentAthleteId;
      
      if (athleteId != null) {
        return athleteId.toString();
      }
      
      if (kDebugMode) {
        print('No athlete ID found in user metadata');
      }
      return null;
    } catch (error) {
      if (kDebugMode) {
        print('Error getting athlete ID: $error');
      }
      return null;
    }
  }
}

/// Provider for the route recommendations service dependencies
final _intelligentRouteRecommendationServiceProvider = Provider<IntelligentRouteRecommendationService>((ref) {
  return IntelligentRouteRecommendationService();
});

final _dbRouteRecommendationServiceProvider = Provider<db.RouteRecommendationService>((ref) {
  return db.RouteRecommendationService();
});

final _supabaseAuthServiceProvider = Provider<SupabaseAuthService>((ref) {
  return SupabaseAuthService();
});

/// Main provider for route recommendations
final routeRecommendationsProvider = StateNotifierProvider<RouteRecommendationsNotifier, AsyncValue<List<RouteRecommendation>>>((ref) {
  final intelligentService = ref.watch(_intelligentRouteRecommendationServiceProvider);
  final dbService = ref.watch(_dbRouteRecommendationServiceProvider);
  final authService = ref.watch(_supabaseAuthServiceProvider);
  
  return RouteRecommendationsNotifier(intelligentService, dbService, authService);
});

/// Provider for recommendations filtered by type
final recommendationsByTypeProvider = Provider.family<AsyncValue<List<RouteRecommendation>>, String>((ref, type) {
  final recommendationsAsync = ref.watch(routeRecommendationsProvider);
  
  return recommendationsAsync.when(
    data: (recommendations) {
      if (type == 'all') {
        return AsyncValue.data(recommendations);
      }
      
      final filtered = recommendations.where((rec) => rec.recommendationType == type).toList();
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

/// Provider for unviewed recommendations count
final unviewedRecommendationsCountProvider = Provider<int>((ref) {
  final recommendationsAsync = ref.watch(routeRecommendationsProvider);
  
  return recommendationsAsync.when(
    data: (recommendations) => recommendations.where((rec) => !rec.isViewed).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Provider for high confidence recommendations
final highConfidenceRecommendationsProvider = Provider<AsyncValue<List<RouteRecommendation>>>((ref) {
  final recommendationsAsync = ref.watch(routeRecommendationsProvider);
  
  return recommendationsAsync.when(
    data: (recommendations) {
      final highConfidence = recommendations.where((rec) => rec.confidenceScore >= 0.8).toList();
      return AsyncValue.data(highConfidence);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

/// Provider for recommendation statistics
final recommendationStatsProvider = Provider<Map<String, int>>((ref) {
  final recommendationsAsync = ref.watch(routeRecommendationsProvider);
  
  return recommendationsAsync.when(
    data: (recommendations) {
      final stats = <String, int>{
        'total': recommendations.length,
        'new': recommendations.where((rec) => !rec.isViewed).length,
        'high_confidence': recommendations.where((rec) => rec.confidenceScore >= 0.8).length,
        'completed': recommendations.where((rec) => rec.isCompleted).length,
        'performance_match': recommendations.where((rec) => rec.recommendationType == 'performance_match').length,
        'progressive_challenge': recommendations.where((rec) => rec.recommendationType == 'progressive_challenge').length,
        'exploration': recommendations.where((rec) => rec.recommendationType == 'exploration').length,
        'similar_routes': recommendations.where((rec) => rec.recommendationType == 'similar_routes').length,
      };
      
      return stats;
    },
    loading: () => <String, int>{},
    error: (_, __) => <String, int>{},
  );
});