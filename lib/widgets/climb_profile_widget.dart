import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/utils/conversions.dart';

/// A widget that renders a 2D elevation profile of a climb segment
/// Similar to classic climb profile visualizations
class ClimbProfileWidget extends ConsumerWidget {
  final String segmentName;
  final double distance; // in meters
  final double elevationGain; // in meters
  final double averageGrade; // percentage
  final double? maxGrade; // percentage (optional)
  final String? timeString;
  final bool isPR;
  final List<double>? elevationData; // Elevation points throughout the climb (optional)
  final List<double>? gradientData; // Gradient points throughout the climb (optional)

  const ClimbProfileWidget({
    super.key,
    required this.segmentName,
    required this.distance,
    required this.elevationGain,
    required this.averageGrade,
    this.maxGrade,
    this.timeString,
    this.isPR = false,
    this.elevationData,
    this.gradientData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Map<String, String> units = Conversions.units(ref);
    final displayDistance = Conversions.metersToDistance(ref, distance);
    final displayElevation = Conversions.metersToHeight(ref, elevationGain);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with segment name
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getGradeColor(averageGrade),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    segmentName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isPR)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'PR',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Climb profile visualization
          SizedBox(
            height: 200,
            child: CustomPaint(
              painter: ClimbProfilePainter(
                distance: distance,
                elevationGain: elevationGain,
                averageGrade: averageGrade,
                maxGrade: maxGrade,
                elevationData: elevationData,
                gradientData: gradientData,
              ),
              child: Container(),
            ),
          ),

          // Stats row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  Icons.straighten,
                  '${displayDistance.toStringAsFixed(2)}${units['distance']!}',
                  'Distance',
                ),
                _buildStatItem(
                  context,
                  Icons.arrow_upward,
                  '${displayElevation.toStringAsFixed(0)}${units['height']}',
                  'Elevation',
                ),
                _buildStatItem(
                  context,
                  Icons.trending_up,
                  '${averageGrade.toStringAsFixed(1)}%',
                  'Avg Grade',
                ),
                if (timeString != null)
                  _buildStatItem(
                    context,
                    Icons.timer,
                    timeString!,
                    'Time',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getGradeColor(double grade) {
    // Ultra-detailed color gradations - more colors for finer gradient differences
    if (grade >= 25) return const Color(0xFF8B0000); // Darkest red - insane
    if (grade >= 20) return const Color(0xFFB71C1C); // Very dark red - extreme
    if (grade >= 18) return const Color(0xFFC62828); // Dark red+ - very extreme
    if (grade >= 15) return const Color(0xFFD32F2F); // Dark red - very steep
    if (grade >= 13) return const Color(0xFFE53935); // Red - very steep
    if (grade >= 12) return const Color(0xFFE64A19); // Red-orange - steep
    if (grade >= 11) return const Color(0xFFEF5350); // Light red - steep
    if (grade >= 10) return const Color(0xFFFF6F00); // Dark orange - steep
    if (grade >= 9) return const Color(0xFFFF7043); // Orange-red - hard
    if (grade >= 8) return const Color(0xFFFF8F00); // Orange - hard
    if (grade >= 7.5) return const Color(0xFFFF9800); // Orange - moderate-hard
    if (grade >= 7) return const Color(0xFFFFA726); // Light orange - moderate-hard
    if (grade >= 6.5) return const Color(0xFFFFB74D); // Light orange+ - moderate
    if (grade >= 6) return const Color(0xFFFFB300); // Yellow-orange - moderate
    if (grade >= 5.5) return const Color(0xFFFFCA28); // Yellow-orange - moderate
    if (grade >= 5) return const Color(0xFFFDD835); // Yellow - moderate
    if (grade >= 4.5) return const Color(0xFFFFEE58); // Light yellow - easy-moderate
    if (grade >= 4) return const Color(0xFF9CCC65); // Light green - easy-moderate
    if (grade >= 3.5) return const Color(0xFF8BC34A); // Light green+ - easy
    if (grade >= 3) return const Color(0xFF66BB6A); // Green - easy
    if (grade >= 2.5) return const Color(0xFF4CAF50); // Green+ - easy
    if (grade >= 2) return const Color(0xFF42A5F5); // Light blue - very easy
    if (grade >= 1.5) return const Color(0xFF2196F3); // Blue - very easy
    if (grade >= 1) return const Color(0xFF1E88E5); // Blue+ - flat
    return const Color(0xFF1976D2); // Dark blue - nearly flat
  }
}

/// Custom painter that draws the elevation profile
class ClimbProfilePainter extends CustomPainter {
  final double distance; // meters
  final double elevationGain; // meters
  final double averageGrade; // percentage
  final double? maxGrade;
  final List<double>? elevationData; // Actual elevation points
  final List<double>? gradientData; // Actual gradient points

  ClimbProfilePainter({
    required this.distance,
    required this.elevationGain,
    required this.averageGrade,
    this.maxGrade,
    this.elevationData,
    this.gradientData,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background
    final bgPaint = Paint()..color = Colors.grey[100]!;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Determine if we have actual elevation data or need to generate synthetic data
    final bool hasRealData = elevationData != null && elevationData!.isNotEmpty;

    List<_ElevationPoint> points;

    if (hasRealData) {
      // Use real elevation and gradient data
      points = _createPointsFromData();
    } else {
      // Generate synthetic elevation profile with varying gradients
      points = _generateSyntheticProfile();
    }

    // Draw the profile with gradient-colored sections
    _drawGradientColoredProfile(canvas, size, points);

    // Draw grid lines
    _drawGridLines(canvas, size);

    // Draw start and finish markers
    //_drawMarker(canvas, size, 0, 'START', Colors.green[700]!);
    //_drawMarker(canvas, size, size.width, 'FINISH', Colors.red[700]!);
  }

  /// Creates elevation points from actual stream data
  List<_ElevationPoint> _createPointsFromData() {
    if (elevationData == null || elevationData!.isEmpty) {
      return _generateSyntheticProfile();
    }

    final points = <_ElevationPoint>[];
    final minElevation = elevationData!.reduce((a, b) => a < b ? a : b);

    for (int i = 0; i < elevationData!.length; i++) {
      final normalizedElevation = elevationData![i] - minElevation;
      final gradient = (gradientData != null && i < gradientData!.length)
          ? gradientData![i]
          : averageGrade;

      points.add(_ElevationPoint(
        elevation: normalizedElevation,
        gradient: gradient,
      ));
    }

    return points;
  }

  /// Generates synthetic elevation profile with varying gradients for visual effect
  /// Creates a realistic stepped/blocky profile like real Zwift segments
  List<_ElevationPoint> _generateSyntheticProfile() {
    // Create sections with consistent gradients (like real terrain)
    // Each section maintains the same gradient for a distance, creating the blocky look
    const numSections = 15; // Number of distinct gradient sections
    const pointsPerSection = 15; // Points within each section (for smooth rendering)

    final points = <_ElevationPoint>[];

    // Use maxGrade if available, otherwise estimate it
    final peakGrade = maxGrade ?? (averageGrade * 1.7);

    double currentElevation = 0.0;

    // Generate distinct gradient sections
    final sectionGradients = <double>[];
    for (int s = 0; s < numSections; s++) {
      final sectionProgress = s / numSections;

      // Create varying gradients across the climb
      double sectionGradient;

      // Determine gradient pattern based on position in climb
      if (sectionProgress < 0.15) {
        // Easier start
        sectionGradient = averageGrade * (0.6 + _pseudoRandom(s) * 0.3);
      } else if (sectionProgress < 0.3) {
        // Building up
        sectionGradient = averageGrade * (0.9 + _pseudoRandom(s) * 0.4);
      } else if (sectionProgress < 0.5) {
        // Approaching peak - steeper sections
        sectionGradient = averageGrade * (1.2 + _pseudoRandom(s) * 0.5);
      } else if (sectionProgress < 0.65) {
        // Peak difficulty zone
        sectionGradient = peakGrade * (0.85 + _pseudoRandom(s) * 0.25);
      } else if (sectionProgress < 0.8) {
        // Slight reprieve
        sectionGradient = averageGrade * (0.8 + _pseudoRandom(s) * 0.4);
      } else {
        // Final push - variable
        sectionGradient = averageGrade * (0.9 + _pseudoRandom(s) * 0.6);
      }

      // Round to nearest 0.5% for more realistic looking sections
      sectionGradient = (sectionGradient * 2).round() / 2.0;

      // Clamp to reasonable range
      sectionGradient = sectionGradient.clamp(1.0, peakGrade * 1.15);

      sectionGradients.add(sectionGradient);
    }

    // Now create points for each section
    for (int s = 0; s < numSections; s++) {
      final sectionGradient = sectionGradients[s];

      // Create multiple points per section with the SAME gradient
      // This creates the flat/blocky sections
      for (int p = 0; p < pointsPerSection; p++) {
        if (points.isNotEmpty) {
          final segmentDistance = distance / (numSections * pointsPerSection);
          final elevationChange = (sectionGradient / 100.0) * segmentDistance;
          currentElevation += elevationChange;
        }

        points.add(_ElevationPoint(
          elevation: currentElevation,
          gradient: sectionGradient, // Same gradient for entire section
        ));
      }
    }

    // Normalize elevations to match the target elevation gain
    final actualGain = currentElevation;
    if (actualGain > 0) {
      final scale = elevationGain / actualGain;
      for (var point in points) {
        point.elevation *= scale;
      }
    }

    return points;
  }

  /// Pseudo-random number generator for consistent variation
  double _pseudoRandom(int seed) {
    // Simple pseudo-random based on seed
    final a = (seed * 1103515245 + 12345) & 0x7fffffff;
    return (a % 1000) / 1000.0 - 0.5; // Returns -0.5 to 0.5
  }

  /// Draws the elevation profile with sections colored by gradient
  void _drawGradientColoredProfile(Canvas canvas, Size size, List<_ElevationPoint> points) {
    if (points.isEmpty) return;

    final margin = size.height * 0.1;
    final availableHeight = size.height - (margin * 2);
    final maxElevation = points.map((p) => p.elevation).reduce((a, b) => a > b ? a : b);

    // Draw filled sections with gradient-based colors
    for (int i = 0; i < points.length - 1; i++) {
      final progress1 = i / (points.length - 1);
      final progress2 = (i + 1) / (points.length - 1);

      final x1 = progress1 * size.width;
      final x2 = progress2 * size.width;

      final y1 = size.height - margin - (points[i].elevation / maxElevation) * availableHeight;
      final y2 = size.height - margin - (points[i + 1].elevation / maxElevation) * availableHeight;

      // Get color based on gradient at this section
      final sectionGradient = (points[i].gradient + points[i + 1].gradient) / 2;
      final sectionColor = _getGradeColor(sectionGradient);

      // Create path for this section
      final sectionPath = Path()
        ..moveTo(x1, y1)
        ..lineTo(x2, y2)
        ..lineTo(x2, size.height)
        ..lineTo(x1, size.height)
        ..close();

      // Fill with gradient from section color to transparent at bottom
      // Make colors more vivid and saturated for better differentiation
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            sectionColor.withValues(alpha: 0.95),
            sectionColor.withValues(alpha: 0.75),
            sectionColor.withValues(alpha: 0.45),
            sectionColor.withValues(alpha: 0.2),
            Colors.grey[200]!.withValues(alpha: 0.05),
          ],
          stops: const [0.0, 0.3, 0.6, 0.85, 1.0],
        ).createShader(Rect.fromLTRB(x1, y1, x2, size.height));

      canvas.drawPath(sectionPath, paint);
    }

    // Draw outline on top
    final outlinePath = Path();
    for (int i = 0; i < points.length; i++) {
      final progress = i / (points.length - 1);
      final x = progress * size.width;
      final y = size.height - margin - (points[i].elevation / maxElevation) * availableHeight;

      if (i == 0) {
        outlinePath.moveTo(x, y);
      } else {
        outlinePath.lineTo(x, y);
      }
    }

    final outlinePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(outlinePath, outlinePaint);
  }

  /// Draws grid lines for reference
  void _drawGridLines(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey[400]!.withValues(alpha: 0.3)
      ..strokeWidth = 1;

    for (int i = 1; i < 4; i++) {
      final y = (i / 4) * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawMarker(Canvas canvas, Size size, double x, String label, Color color) {
    // Draw vertical line
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(x, size.height * 0.2),
      Offset(x, size.height - 20),
      linePaint,
    );

    // Draw label background
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final labelX = x == 0 ? 4.0 : x - textPainter.width - 4;
    final labelY = size.height - 30.0;

    final labelRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(labelX - 4, labelY - 2, textPainter.width + 8, textPainter.height + 4),
      const Radius.circular(4),
    );

    final labelBgPaint = Paint()..color = color;
    canvas.drawRRect(labelRect, labelBgPaint);

    textPainter.paint(canvas, Offset(labelX, labelY));
  }

  Color _getGradeColor(double grade) {
    // Ultra-detailed color gradations - more colors for finer gradient differences
    if (grade >= 25) return const Color(0xFF8B0000); // Darkest red - insane
    if (grade >= 20) return const Color(0xFFB71C1C); // Very dark red - extreme
    if (grade >= 18) return const Color(0xFFC62828); // Dark red+ - very extreme
    if (grade >= 15) return const Color(0xFFD32F2F); // Dark red - very steep
    if (grade >= 13) return const Color(0xFFE53935); // Red - very steep
    if (grade >= 12) return const Color(0xFFE64A19); // Red-orange - steep
    if (grade >= 11) return const Color(0xFFEF5350); // Light red - steep
    if (grade >= 10) return const Color(0xFFFF6F00); // Dark orange - steep
    if (grade >= 9) return const Color(0xFFFF7043); // Orange-red - hard
    if (grade >= 8) return const Color(0xFFFF8F00); // Orange - hard
    if (grade >= 7.5) return const Color(0xFFFF9800); // Orange - moderate-hard
    if (grade >= 7) return const Color(0xFFFFA726); // Light orange - moderate-hard
    if (grade >= 6.5) return const Color(0xFFFFB74D); // Light orange+ - moderate
    if (grade >= 6) return const Color(0xFFFFB300); // Yellow-orange - moderate
    if (grade >= 5.5) return const Color(0xFFFFCA28); // Yellow-orange - moderate
    if (grade >= 5) return const Color(0xFFFDD835); // Yellow - moderate
    if (grade >= 4.5) return const Color(0xFFFFEE58); // Light yellow - easy-moderate
    if (grade >= 4) return const Color(0xFF9CCC65); // Light green - easy-moderate
    if (grade >= 3.5) return const Color(0xFF8BC34A); // Light green+ - easy
    if (grade >= 3) return const Color(0xFF66BB6A); // Green - easy
    if (grade >= 2.5) return const Color(0xFF4CAF50); // Green+ - easy
    if (grade >= 2) return const Color(0xFF42A5F5); // Light blue - very easy
    if (grade >= 1.5) return const Color(0xFF2196F3); // Blue - very easy
    if (grade >= 1) return const Color(0xFF1E88E5); // Blue+ - flat
    return const Color(0xFF1976D2); // Dark blue - nearly flat
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Helper class to store elevation and gradient data points
class _ElevationPoint {
  double elevation;
  final double gradient;

  _ElevationPoint({
    required this.elevation,
    required this.gradient,
  });
}
