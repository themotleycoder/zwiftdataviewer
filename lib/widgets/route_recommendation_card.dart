import 'package:flutter/material.dart';
import 'package:zwiftdataviewer/models/route_recommendation.dart';
import 'package:zwiftdataviewer/utils/theme.dart';

/// Card widget displaying a single route recommendation with AI insights
/// 
/// Shows route details, confidence score, reasoning, and action buttons
class RouteRecommendationCard extends StatelessWidget {
  final RouteRecommendation recommendation;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsViewed;
  final VoidCallback? onMarkAsCompleted;

  const RouteRecommendationCard({
    super.key,
    required this.recommendation,
    this.onTap,
    this.onMarkAsViewed,
    this.onMarkAsCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final route = recommendation.routeData;
    final distance = route != null ? (route.distanceMeters ?? 0) / 1000 : 0;
    final elevation = route?.altitudeMeters ?? 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(4.0, 0, 4.0, 0),
      child: InkWell(
        onTap: onTap,
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          tileColor: recommendation.isViewed
              ? Colors.grey[100]
              : const Color(0xFFF5F5F5),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),

          // Title: Route name
          title: Row(
            children: [
              Expanded(
                child: Text(
                  route?.routeName ?? 'Route ${recommendation.routeId}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Confidence badge
              _buildConfidenceScore(),
            ],
          ),

          // Subtitle: Distance, elevation, world, and AI insight
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4.0),
              // Distance, elevation, world
              Text(
                '${distance.toStringAsFixed(1)} km • ${elevation.toInt()}m • ${route?.world ?? 'Unknown'}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4.0),
              // Recommendation type
              Text(
                recommendation.recommendationTypeDisplayName,
                style: TextStyle(
                  fontSize: 12,
                  color: _getTypeColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6.0),
              // AI reasoning (truncated)
              Text(
                recommendation.reasoning,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8.0),
              // Action buttons row
              _buildCompactActionButtons(context),
            ],
          ),

          // Trailing: Status indicators
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // if (!recommendation.isViewed)
              //   Container(
              //     width: 8,
              //     height: 8,
              //     decoration: const BoxDecoration(
              //       color: zdvOrange,
              //       shape: BoxShape.circle,
              //     ),
              //   ),
              // const SizedBox(height: 4.0),
              if (recommendation.isCompleted)
                const Icon(
                  Icons.check_circle,
                  size: 20,
                  color: Colors.green,
                ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_ios,
                color: zdvMidBlue,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfidenceScore() {
    final score = recommendation.confidenceScore;

    Color color;
    if (score >= 0.8) {
      color = Colors.green;
    } else if (score >= 0.6) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.stars,
            size: 10,
            color: color,
          ),
          const SizedBox(width: 2.0),
          Text(
            '${(score * 100).toInt()}%',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // // Mark as viewed button
        // if (!recommendation.isViewed && onMarkAsViewed != null)
        //   TextButton.icon(
        //     onPressed: onMarkAsViewed,
        //     icon: const Icon(Icons.visibility, size: 14),
        //     label: const Text('Viewed', style: TextStyle(fontSize: 11)),
        //     style: TextButton.styleFrom(
        //       padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        //       minimumSize: Size.zero,
        //       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        //     ),
        //   ),
        //
        // // Mark as completed button
        // if (!recommendation.isCompleted && onMarkAsCompleted != null) ...[
        //   if (!recommendation.isViewed && onMarkAsViewed != null)
        //     const SizedBox(width: 4.0),
        //   TextButton.icon(
        //     onPressed: onMarkAsCompleted,
        //     icon: const Icon(Icons.check, size: 14),
        //     label: const Text('Done', style: TextStyle(fontSize: 11)),
        //     style: TextButton.styleFrom(
        //       foregroundColor: Colors.green[700],
        //       padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        //       minimumSize: Size.zero,
        //       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        //     ),
        //   ),
        // ],
      ],
    );
  }

  Color _getTypeColor() {
    switch (recommendation.recommendationType) {
      case 'performance_match':
        return zdvMidBlue;
      case 'progressive_challenge':
        return Colors.orange;
      case 'exploration':
        return Colors.purple;
      case 'similar_routes':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}