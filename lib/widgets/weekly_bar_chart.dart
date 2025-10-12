import 'package:flutter/material.dart';
import 'package:zwiftdataviewer/providers/weekly_dashboard_provider.dart';
import 'package:zwiftdataviewer/utils/theme.dart';

class WeeklyBarChart extends StatelessWidget {
  final List<DailyActivityData> dailyData;
  final double maxHeight;

  const WeeklyBarChart({
    super.key,
    required this.dailyData,
    this.maxHeight = 200,
  });

  @override
  Widget build(BuildContext context) {
    // Find the maximum total minutes across all days for scaling
    double maxMinutes = 0;
    for (var day in dailyData) {
      if (day.totalMinutes > maxMinutes) {
        maxMinutes = day.totalMinutes;
      }
    }

    // Ensure we have at least some height for the chart
    if (maxMinutes == 0) {
      maxMinutes = 60; // Default to 60 minutes
    }

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
                  _buildDayBar(dayData, maxMinutes),
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

  Widget _buildDayBar(DailyActivityData dayData, double maxMinutes) {
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

    // Calculate the height for each zone segment
    final segments = <Widget>[];
    // Reserve space for the label below (increase to prevent overflow)
    final availableHeight = maxHeight - 26;

    // Build from bottom up (Zone 1 to Zone 6)
    for (int zone = 1; zone <= 6; zone++) {
      final zoneMinutes = dayData.powerZoneMinutes[zone] ?? 0;
      if (zoneMinutes > 0) {
        final segmentHeight = (zoneMinutes / maxMinutes) * availableHeight;
        segments.add(
          Container(
            height: segmentHeight,
            decoration: BoxDecoration(
              color: dayData.getZoneColor(zone),
              border: zone < 6 ? Border(
                top: BorderSide(color: Colors.black.withOpacity(0.2), width: 0.5),
              ) : null,
            ),
          ),
        );
      }
    }

    return SizedBox(
      height: maxHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: zdvMidBlue.withOpacity(0.3), width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: segments.reversed.toList(), // Reverse to show Zone 6 on top
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Show total minutes as label
          Text(
            '${dayData.totalMinutes.round()}',
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
