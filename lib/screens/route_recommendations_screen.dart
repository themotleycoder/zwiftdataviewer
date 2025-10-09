import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/models/route_recommendation.dart';
import 'package:zwiftdataviewer/providers/route_recommendations_provider.dart';
import 'package:zwiftdataviewer/screens/webviewscreen.dart';
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/utils/ui_helpers.dart';
import 'package:zwiftdataviewer/widgets/route_recommendation_card.dart';

/// Screen displaying AI-generated route recommendations based on user performance
/// 
/// This screen shows personalized route recommendations using various algorithms:
/// - Performance-matched routes for current fitness level
/// - Progressive challenges for skill development
/// - Exploration suggestions for discovering new worlds
/// - Similar routes based on previous enjoyment
class RouteRecommendationsScreen extends ConsumerStatefulWidget {
  const RouteRecommendationsScreen({super.key});

  @override
  ConsumerState<RouteRecommendationsScreen> createState() => _RouteRecommendationsScreenState();
}

enum RecommendationFilter {
  all('All', 'all'),
  performanceMatch('Perfect Match', 'performance_match'),
  progressiveChallenge('Next Challenge', 'progressive_challenge'),
  exploration('Explore', 'exploration'),
  similarRoutes('Similar', 'similar_routes');

  const RecommendationFilter(this.label, this.value);
  final String label;
  final String value;
}

// Provider for the selected filter
final recommendationFilterProvider = StateProvider<RecommendationFilter>((ref) => RecommendationFilter.all);

class _RouteRecommendationsScreenState extends ConsumerState<RouteRecommendationsScreen> {
  bool _showOnlyUnviewed = false;

  @override
  Widget build(BuildContext context) {
    final recommendationsAsync = ref.watch(routeRecommendationsProvider);

    return Column(
      children: [
        Expanded(
          child: recommendationsAsync.when(
            data: (recommendations) => _buildRecommendationsList(recommendations),
            loading: () => UIHelpers.buildLoadingIndicator(),
            error: (error, stackTrace) => _buildErrorState(error),
          ),
        ),
      ],
    );
  }

  // Public method to show regenerate dialog - can be called from parent
  void showRegenerateDialog(BuildContext context) {
    _showRegenerateDialog(context);
  }

  Widget _buildRecommendationsList(List<RouteRecommendation> allRecommendations) {
    final selectedFilter = ref.watch(recommendationFilterProvider);

    // Apply filters
    var filteredRecommendations = allRecommendations.where((rec) {
      // Filter by type
      if (selectedFilter.value != 'all' && rec.recommendationType != selectedFilter.value) {
        return false;
      }

      // Filter by viewed status
      if (_showOnlyUnviewed && rec.isViewed) {
        return false;
      }

      return true;
    }).toList();

    if (filteredRecommendations.isEmpty) {
      return _buildEmptyState();
    }

    // Group recommendations by type for better organization
    final groupedRecommendations = <String, List<RouteRecommendation>>{};
    for (final rec in filteredRecommendations) {
      groupedRecommendations.putIfAbsent(rec.recommendationType, () => []).add(rec);
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (selectedFilter == RecommendationFilter.all) ...[
          _buildStatsCard(allRecommendations),
          const SizedBox(height: 16.0),
        ],
        ...groupedRecommendations.entries.map((entry) {
          return _buildRecommendationGroup(entry.key, entry.value);
        }),
      ],
    );
  }

  Widget _buildStatsCard(List<RouteRecommendation> recommendations) {
    final highConfidenceCount = recommendations.where((r) => r.confidenceScore >= 0.8).length;
    final newCount = recommendations.where((r) => !r.isViewed).length;
    final completedCount = recommendations.where((r) => r.isCompleted).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recommendation Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                _buildStatItem('Total', recommendations.length.toString(), zdvMidBlue),
                _buildStatItem('High Confidence', highConfidenceCount.toString(), Colors.green),
                _buildStatItem('New', newCount.toString(), zdvOrange),
                _buildStatItem('Completed', completedCount.toString(), Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationGroup(String type, List<RouteRecommendation> recommendations) {
    // Sort by priority score
    recommendations.sort((a, b) => b.priorityScore.compareTo(a.priorityScore));

    final typeDisplayName = recommendations.first.recommendationTypeDisplayName;
    final typeIcon = recommendations.first.recommendationIcon;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Text(
                typeIcon,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  typeDisplayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: zdvOrange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  '${recommendations.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...recommendations.map((rec) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: RouteRecommendationCard(
            recommendation: rec,
            onTap: () => _onRecommendationTapped(rec),
            onMarkAsViewed: () => _markAsCompleted(rec),
            onMarkAsCompleted: () => _markAsCompleted(rec),
          ),
        )),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.route_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16.0),
          Text(
            _getEmptyStateMessage(),
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0),
          Column(
            children: [
              ElevatedButton.icon(
                onPressed: () => _generateNewRecommendations(),
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Generate AI Recommendations'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: zdvOrange,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 8.0),
              ElevatedButton.icon(
                onPressed: () => _generateFromExistingRoutes(),
                icon: const Icon(Icons.route),
                label: const Text('Use My Route Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: zdvMidBlue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16.0),
          const Text(
            'Failed to load recommendations',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8.0),
          Text(
            error.toString(),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0),
          ElevatedButton.icon(
            onPressed: () => ref.refresh(routeRecommendationsProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  String _getEmptyStateMessage() {
    final selectedFilter = ref.watch(recommendationFilterProvider);

    if (_showOnlyUnviewed) {
      return 'No new recommendations available.\nCheck back after completing some routes!';
    }
    if (selectedFilter != RecommendationFilter.all) {
      return 'No recommendations found for this category.\nTry adjusting your filters.';
    }
    return 'No recommendations available yet.\nComplete some routes to get personalized suggestions!';
  }

  void _onRecommendationTapped(RouteRecommendation recommendation) {
    final route = recommendation.routeData;

    // Navigate to route details in browser
    if (route != null && route.url != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WebViewScreen(
            url: route.url!,
            title: '${route.world}: ${route.routeName}',
          ),
        ),
      );

      // Mark as viewed
      if (!recommendation.isViewed) {
        _markAsViewed(recommendation);
      }
    } else {
      // Show error if route data is missing
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Route details not available'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _markAsViewed(RouteRecommendation recommendation) {
    ref.read(routeRecommendationsProvider.notifier).markAsViewed(recommendation.id!);
  }

  void _markAsCompleted(RouteRecommendation recommendation) {
    ref.read(routeRecommendationsProvider.notifier).markAsCompleted(recommendation.id!);
  }

  void _generateNewRecommendations() async {
    try {
      await ref.read(routeRecommendationsProvider.notifier).generateNewRecommendations();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AI recommendations generated!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate AI recommendations: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _generateFromExistingRoutes() async {
    try {
      await ref.read(routeRecommendationsProvider.notifier).generateRecommendationsFromAvailableRoutes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Route recommendations generated from your data!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate recommendations: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showRegenerateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Regenerate Recommendations'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose how to generate new recommendations:'),
            SizedBox(height: 16.0),
            Text(
              '• AI Recommendations: Uses Google Gemini AI to analyze your performance',
              style: TextStyle(fontSize: 13),
            ),
            SizedBox(height: 8.0),
            Text(
              '• From Route Data: Uses algorithmic analysis without AI',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _generateFromExistingRoutes();
            },
            child: const Text('From Route Data'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _generateNewRecommendations();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: zdvOrange,
              foregroundColor: Colors.white,
            ),
            child: const Text('AI Recommendations'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recommendation Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('AI-powered route recommendations analyze your:'),
            SizedBox(height: 8.0),
            Text('• Recent route completions'),
            Text('• Performance metrics'),
            Text('• Preferred difficulty levels'),
            Text('• World exploration patterns'),
            SizedBox(height: 16.0),
            Text(
              'Recommendations are updated based on your latest activities.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}