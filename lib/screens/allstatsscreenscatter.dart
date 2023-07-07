import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zwiftdataviewer/screens/ridedetailscreen.dart';
import 'package:zwiftdataviewer/strava_lib/Models/summary_activity.dart';
import 'package:zwiftdataviewer/utils/conversions.dart';
import 'package:zwiftdataviewer/widgets/listitemviews.dart';

import '../providers/activity_select_provider.dart';
import '../providers/filters_provider.dart';
import '../utils/charts.dart';
import '../utils/theme.dart';

class AllStatsScreenScatter extends ConsumerWidget {
  const AllStatsScreenScatter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<SummaryActivity> filteredActivities =
        ref.read(dateActivityFiltersProvider);

    final SummaryActivity selectedActivity =
        ref.watch(selectedActivityProvider);

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
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                InkWell(
                    onTap: () {
                      selectedActivity.name!=""?
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) {
                            return const DetailScreen();
                          },
                        ),
                      ):null;
                    },
                    child: //Row(children: [
                        ListTile(
                            title:
                                singleDataHeaderLineItem(selectedActivity.name),
                            trailing: selectedActivity.name!=""?const Icon(
                              Icons.arrow_forward_ios,
                              color: zdvMidBlue,
                            ):null)),
                tripleDataSingleHeaderLineItem(
                  [
                    'Distance (${units['distance']!})',
                    'Elevation (${units['height']!})',
                    'Time'
                  ],
                  [
                    Conversions.metersToDistance(
                            ref, selectedActivity.distance)
                        .toStringAsFixed(1),
                    Conversions.metersToHeight(
                            ref, selectedActivity.totalElevationGain)
                        .toStringAsFixed(1),
                    Conversions.secondsToTime(
                        selectedActivity.elapsedTime),
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
        if (selectedActivity != null) {
          ref
              .read(selectedActivityProvider.notifier)
              .selectActivity(selectedActivity);
        }
      },
      legend: const Legend(
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
