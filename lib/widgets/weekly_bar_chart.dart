import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/providers/weekly_dashboard_provider.dart';
import 'package:zwiftdataviewer/utils/conversions.dart';
import 'package:zwiftdataviewer/utils/theme.dart';

class WeeklyBarChart extends ConsumerWidget {
  final List<DailyActivityData> dailyData;
  final double maxHeight;

  const WeeklyBarChart({
    super.key,
    required this.dailyData,
    this.maxHeight = 200,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Find the maximum total distance across all days for scaling
    double maxDistance = 0;
    for (var day in dailyData) {
      final distance = Conversions.metersToDistance(ref, day.totalDistanceMeters);
      if (distance > maxDistance) {
        maxDistance = distance;
      }
    }

    // Ensure we have at least some height for the chart
    if (maxDistance == 0) {
      maxDistance = 10; // Default to 10 km/mi
    }

    // Get distance unit for labels
    final units = Conversions.units(ref);

    return Container(
      height: maxHeight + 60, // Extra space for labels and moon icons
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          final dayData = dailyData[index];
          final dayLabel = _getDayLabel(index);

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Bar chart
                  _buildDayBar(dayData, maxDistance, ref),
                  const SizedBox(height: 8),
                  // Day label
                  Text(
                    dayLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: zdvDrkBlue,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDayBar(DailyActivityData dayData, double maxDistance, WidgetRef ref) {
    if (dayData.isRestDay) {
      // Show moon icon for rest days
      return SizedBox(
        height: maxHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.bedtime,
                color: Colors.grey[600],
                size: 20,
              ),
            ),
            const SizedBox(height: 4),
            // Show 0 for rest days
            Text(
              '0',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Calculate bar height based on total distance
    // Reserve space for the label below
    final availableHeight = maxHeight - 26;
    final distance = Conversions.metersToDistance(ref, dayData.totalDistanceMeters);
    final barHeight = (distance / maxDistance) * availableHeight;

    // Get the zone with the most time (predominant zone)
    int predominantZone = 1;
    double maxZoneMinutes = 0;
    for (var entry in dayData.powerZoneMinutes.entries) {
      if (entry.value > maxZoneMinutes) {
        maxZoneMinutes = entry.value;
        predominantZone = entry.key;
      }
    }

    return SizedBox(
      height: maxHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Single-color bar based on predominant zone
          Container(
            height: barHeight,
            decoration: BoxDecoration(
              color: dayData.getZoneColor(predominantZone),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.black.withOpacity(0.1), width: 1),
            ),
          ),
          const SizedBox(height: 4),
          // Show total distance as label
          Text(
            distance.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getDayLabel(int index) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return days[index];
  }
}
