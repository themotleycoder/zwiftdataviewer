import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/Models/summary_activity.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zwiftdataviewer/screens/layouts/allstatstablayout.dart';
import 'package:zwiftdataviewer/widgets/chartpointshortsummarywidget.dart';

import '../../providers/activity_select_provider.dart';
import '../../utils/charts.dart';

class AllStatsScreenTabScatter extends AllStatsTabLayout {
  const AllStatsScreenTabScatter({super.key});

  @override
  SfCartesianChart buildChart(
      WidgetRef ref, units, List<SummaryActivity> filteredActivities) {
    final Map<int, List<SummaryActivity>> result =
        groupActivitiesByYear(filteredActivities);

    final chartSeries = ChartsData.getScatterSeries(ref, units, result);

    return SfCartesianChart(
      primaryXAxis: NumericAxis(
        labelFormat: '{value}',
        title: AxisTitle(text: 'Distance (${units['distance']!})'),
      ),
      primaryYAxis: NumericAxis(
        majorGridLines: const MajorGridLines(width: 0.5),
        opposedPosition: false,
        labelFormat: '{value}',
        minimum: 0,
        title: AxisTitle(text: 'Elevation (${units['height']!})'),
      ),
      series: chartSeries,
      onSelectionChanged: (SelectionArgs args) {
        var selectedActivity =
            result.values.toList()[args.seriesIndex][args.pointIndex];
        ref
            .read(selectedActivityProvider.notifier)
            .selectActivity(selectedActivity);
      },
      legend: const Legend(
        isVisible: true,
        position: LegendPosition.top,
        borderWidth: 1,
      ),
    );
  }

  @override
  Container buildChartSummaryWidget(BuildContext context, WidgetRef ref, Map<String, String> units) {
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
