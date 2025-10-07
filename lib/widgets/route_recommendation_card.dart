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
    
    return Card(
      elevation: recommendation.isViewed ? 1 : 3,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12.0),
              _buildRouteInfo(),
              const SizedBox(height: 12.0),
              _buildReasoningSection(),
              const SizedBox(height: 12.0),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Recommendation type icon
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: _getTypeColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            recommendation.recommendationIcon,
            style: const TextStyle(fontSize: 20),
          ),
        ),
        const SizedBox(width: 12.0),
        
        // Route name and type
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recommendation.routeData?.routeName ?? 'Route ${recommendation.routeId}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      recommendation.recommendationTypeDisplayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getTypeColor(),
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Flexible(
                    child: Text(
                      '• ${recommendation.routeData?.world ?? 'Unknown World'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Confidence score and status indicators
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildConfidenceScore(),
            const SizedBox(height: 4.0),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!recommendation.isViewed)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: zdvOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
                if (recommendation.isCompleted)
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.green,
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRouteInfo() {
    final route = recommendation.routeData;
    if (route == null) return const SizedBox.shrink();

    final distance = (route.distanceMeters ?? 0) / 1000;
    final elevation = route.altitudeMeters ?? 0;

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Wrap(
        spacing: 16.0,
        runSpacing: 8.0,
        children: [
          _buildRouteMetric(
            icon: Icons.straighten,
            label: 'Distance',
            value: '${distance.toStringAsFixed(1)} km',
          ),
          _buildRouteMetric(
            icon: Icons.terrain,
            label: 'Elevation',
            value: '${elevation.toInt()} m',
          ),
          if (route.eventOnly == 'true')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                'EVENT',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[800],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRouteMetric({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReasoningSection() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.psychology,
                size: 16,
                color: Colors.blue,
              ),
              const SizedBox(width: 6.0),
              Text(
                'AI Insight',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6.0),
          Text(
            recommendation.reasoning,
            style: const TextStyle(
              fontSize: 13,
              height: 1.3,
            ),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.stars,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4.0),
          Text(
            '${(score * 100).toInt()}%',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Freshness indicator row
        if (recommendation.isFresh)
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                'NEW',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ),
          ),
        
        if (recommendation.isFresh) const SizedBox(height: 8.0),
        
        // Action buttons - more compact layout
        Row(
          children: [
            // Compact action icons
            if (!recommendation.isViewed && onMarkAsViewed != null)
              IconButton(
                onPressed: onMarkAsViewed,
                icon: const Icon(Icons.visibility, size: 18),
                tooltip: 'Mark as viewed',
                iconSize: 18,
                padding: const EdgeInsets.all(4.0),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            
            if (!recommendation.isCompleted && onMarkAsCompleted != null)
              IconButton(
                onPressed: onMarkAsCompleted,
                icon: const Icon(Icons.check, size: 18),
                tooltip: 'Mark as done',
                iconSize: 18,
                padding: const EdgeInsets.all(4.0),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                color: Colors.green[600],
              ),
            
            const Spacer(),
            
            // Main action button - more compact
            ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.route, size: 16),
              label: const Text('View'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getTypeColor(),
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                minimumSize: const Size(80, 32),
              ),
            ),
          ],
        ),
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