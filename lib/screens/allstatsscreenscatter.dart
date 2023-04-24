import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zwiftdataviewer/models/ActivitiesDataModel.dart';
import 'package:zwiftdataviewer/stravalib/Models/activity.dart';
import 'package:zwiftdataviewer/utils/conversions.dart';
import 'package:zwiftdataviewer/widgets/ListItemViews.dart';
import '../utils/charts.dart';

class AllStatsScreenScatter extends StatelessWidget {
  const AllStatsScreenScatter({super.key});
  @override
  Widget build(BuildContext context) {
    return Selector<ActivitiesDataModel, List<SummaryActivity>>(
        selector: (_, model) => model.dateFilteredActivities,
        builder: (context, activities, child) {
          Map<String, String> units = Conversions.units(context);
          return Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                  child: buildScatterChart(context, units, activities),
                )),
                Consumer<SummaryActivitySelectDataModel>(
                    builder: (context, summaryActivity, child) {
                  return Container(
                    padding: const EdgeInsets.all(0),
                    child: Column(
                      children: <Widget>[
                        singleDataHeaderLineItem(
                            summaryActivity.activity?.name ??
                                "No ride selected"),
                        tripleDataSingleHeaderLineItem(
                          [
                            'Distance (${units['distance']!})',
                            'Elevation (${units['height']!})',
                            'Time'
                          ],
                          [
                            Conversions.metersToDistance(context,
                                    summaryActivity.activity?.distance ?? 0)
                                .toStringAsFixed(1),
                            Conversions.metersToHeight(
                                    context,
                                    summaryActivity
                                            .activity?.totalElevationGain ??
                                        0)
                                .toStringAsFixed(1),
                            Conversions.secondsToTime(
                                summaryActivity.activity?.elapsedTime ?? 0),
                          ],
                        ),
                      ],
                    ),
                  );
                })
              ]);
        });
  }

  SfCartesianChart buildScatterChart(
      BuildContext context, units, List<SummaryActivity> activities) {
    final Map<int, List<SummaryActivity>> result =
        groupActivitiesByYear(activities);

    final chartSeries = ChartsData.getScatterSeries(context, units, result);

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
      int year = activity.startDateLocal!.year;
      if (!groupedActivities.containsKey(year)) {
        groupedActivities[year] = [];
      }
      groupedActivities[year]?.add(activity);
    }

    return groupedActivities;
  }
}
