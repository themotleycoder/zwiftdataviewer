import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zwiftdataviewer/stravalib/Models/summary_activity.dart';
import 'package:zwiftdataviewer/utils/conversions.dart';
import 'package:zwiftdataviewer/widgets/listitemviews.dart';

import '../providers/filters_provider.dart';
import '../providers/summary_activity_provider.dart';
import '../utils/charts.dart';

class AllStatsScreenScatter extends ConsumerWidget {
  const AllStatsScreenScatter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<SummaryActivity> filteredActivities = ref.read(
        dateActivityFiltersProvider
            as ProviderListenable<List<SummaryActivity>>);
    final SummaryActivity summaryActivity = ref.watch(summaryActivityProvider);

    Map<String, String> units = Conversions.units(ref);
    return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
              child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
            child: buildScatterChart(ref, units, filteredActivities),
          )),
          Container(
            padding: const EdgeInsets.all(0),
            child: Column(
              children: <Widget>[
                singleDataHeaderLineItem(
                    summaryActivity.name ?? "No ride selected"),
                tripleDataSingleHeaderLineItem(
                  [
                    'Distance (${units['distance']!})',
                    'Elevation (${units['height']!})',
                    'Time'
                  ],
                  [
                    Conversions.metersToDistance(
                            ref, summaryActivity.distance ?? 0)
                        .toStringAsFixed(1),
                    Conversions.metersToHeight(
                            ref, summaryActivity.totalElevationGain ?? 0)
                        .toStringAsFixed(1),
                    Conversions.secondsToTime(summaryActivity.elapsedTime ?? 0),
                  ],
                ),
              ],
            ),
          )
        ]);
  }

  SfCartesianChart buildScatterChart(
      WidgetRef ref, units, List<SummaryActivity> activities) {
    final Map<int, List<SummaryActivity>> result =
        groupActivitiesByYear(activities);

    final chartSeries = ChartsData.getScatterSeries(ref, units, result);

    return SfCartesianChart(
      primaryXAxis: NumericAxis(
        labelFormat: '{value}',
        title: AxisTitle(text: 'Distance (${units['distance']!})'),
      ),
      primaryYAxis: NumericAxis(
        majorGridLines: const MajorGridLines(width: 0),
        opposedPosition: false,
        labelFormat: '{value}',
        minimum: 0,
        title: AxisTitle(text: 'Elevation (${units['height']!})'),
      ),
      series: chartSeries,
      legend: Legend(
        isVisible: true,
        position: LegendPosition.top,
        borderWidth: 1,
      ),
    );
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
