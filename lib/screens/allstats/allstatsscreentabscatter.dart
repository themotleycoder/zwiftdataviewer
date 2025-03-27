import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/models/summary_activity.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zwiftdataviewer/screens/layouts/allstatstablayout.dart';
import 'package:zwiftdataviewer/widgets/chartpointshortsummarywidget.dart';

import '../../providers/activity_select_provider.dart';
import '../../utils/charts.dart';

class AllStatsScreenTabScatter extends AllStatsTabLayout {
  const AllStatsScreenTabScatter({super.key});

  @override
  void didChangeDependencies(BuildContext context, WidgetRef ref, List<SummaryActivity> filteredActivities) {
    // Select the most recent activity by default, but only if no activity is currently selected
    if (filteredActivities.isNotEmpty) {
      // Use Future.microtask to schedule the update after the current build is complete
      Future.microtask(() {
        // Get the current selected activity
        final currentActivity = ref.read(selectedActivityProvider);
        
        // Only select a new activity if no activity is currently selected (id == 0)
        if (currentActivity.id == 0) {
          if (kDebugMode) {
            print('No activity selected, selecting the most recent one');
          }
          // Sort activities by date (most recent first)
          final sortedActivities = List<SummaryActivity>.from(filteredActivities)
            ..sort((a, b) => b.startDateLocal.compareTo(a.startDateLocal));
          
          // Select the most recent activity
          ref.read(selectedActivityProvider.notifier).selectActivity(sortedActivities.first);
        }
      });
    }
  }

  @override
  SfCartesianChart buildChart(
      WidgetRef ref, units, List<SummaryActivity> filteredActivities) {
    // Limit the number of activities to improve performance
    const maxActivitiesToShow = 500;
    List<SummaryActivity> limitedActivities = filteredActivities;
    
    if (filteredActivities.length > maxActivitiesToShow) {
      // Sort by date (most recent first) and take the most recent activities
      limitedActivities = List<SummaryActivity>.from(filteredActivities)
        ..sort((a, b) => b.startDateLocal.compareTo(a.startDateLocal))
        ..take(maxActivitiesToShow).toList();
    }
    
    final Map<int, List<SummaryActivity>> result =
        groupActivitiesByYear(limitedActivities);

    final chartSeries = ChartsData.getScatterSeries(ref, units, result);

    return SfCartesianChart(
      primaryXAxis: NumericAxis(
        labelFormat: '{value}',
        title: AxisTitle(text: 'Distance (${units['distance']!})'),
        // Reduce the number of labels to improve performance
        interval: 20, // Increased from 10 to further reduce X-axis ticks
        // Remove X-axis gridlines
        majorGridLines: const MajorGridLines(width: 0),
      ),
      primaryYAxis: NumericAxis(
        // Remove Y-axis gridlines
        majorGridLines: const MajorGridLines(width: 0),
        opposedPosition: false,
        labelFormat: '{value}',
        minimum: 0,
        title: AxisTitle(text: 'Elevation (${units['height']!})'),
        // Increase interval to reduce the number of Y-axis ticks
        interval: 250, // Increased from 100 to show fewer tick labels
        // Customize tick lines to be less prominent
        majorTickLines: const MajorTickLines(size: 4, width: 1),
        // Limit the maximum number of labels
        maximumLabels: 5, // This helps ensure we don't get too many labels
      ),
      series: chartSeries,
      // The onSelectionChanged callback is now handled in the ScatterSeries.onPointTap
      // in the ChartsData.getScatterSeries method
      legend: const Legend(
        isVisible: true,
        position: LegendPosition.top,
        borderWidth: 1,
      ),
      // Optimize zooming and panning
      zoomPanBehavior: ZoomPanBehavior(
        // Enable only essential zoom features
        enablePinching: true,
        enablePanning: true,
        // Disable more resource-intensive zoom features
        enableDoubleTapZooming: false,
        enableSelectionZooming: false,
        enableMouseWheelZooming: false,
        zoomMode: ZoomMode.xy, // Zoom in both directions
      ),
      // Optimize tooltip behavior
      tooltipBehavior: TooltipBehavior(
        enable: true,
        // Disable animation for better performance
        animationDuration: 0,
        duration: 1500,
        format: 'Distance: point.x ${units['distance']!}\nElevation: point.y ${units['height']!}',
      ),
    );
  }

  @override
  Container buildChartSummaryWidget(
      BuildContext context, WidgetRef ref, Map<String, String> units) {
    return getChartPointShortSummaryWidget(context, ref, units);
  }

  Map<int, List<SummaryActivity>> groupActivitiesByYear(
      List<SummaryActivity> activities) {
    Map<int, List<SummaryActivity>> groupedActivities = {};

    for (SummaryActivity activity in activities) {
      int year = activity.startDateLocal.year;
      if (!groupedActivities.containsKey(year)) {
        groupedActivities[year] = [];
      }
      groupedActivities[year]?.add(activity);
    }

    return groupedActivities;
  }
}
