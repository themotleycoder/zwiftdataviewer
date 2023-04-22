import 'package:flutter/material.dart';
import 'package:flutter_palette/flutter_palette.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zwiftdataviewer/models/ActivitiesDataModel.dart';
import 'package:zwiftdataviewer/stravalib/Models/activity.dart';
import 'package:zwiftdataviewer/utils/conversions.dart';
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/widgets/ListItemViews.dart';
import '../utils/charts.dart';

class AllStatsScreenScatter extends StatefulWidget {
  const AllStatsScreenScatter({super.key});

  @override
  _AllStatsScreenScatterState createState() => _AllStatsScreenScatterState();
}

class _AllStatsScreenScatterState extends State<AllStatsScreenScatter> {
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
                  padding: const EdgeInsets.all(8.0),
                  child: buildScatterChart(context, units, activities),
                )),
                Consumer<SummaryActivitySelectDataModel>(
                    builder: (context, summaryActivity, child) {
                  return Container(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
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

    final chartSeries = getScatterSeries(context, units, result);

    return SfCartesianChart(
      primaryXAxis: NumericAxis(),
      primaryYAxis: NumericAxis(
        majorGridLines: const MajorGridLines(width: 0),
        opposedPosition: false,
        labelFormat: '{value}',
        minimum: 0,
      ),
      series: chartSeries,
      legend: Legend(
        isVisible: true,
        position: LegendPosition.top,
        borderWidth: 1,
      ),
    );
  }

  List<ChartSeries<dynamic, dynamic>> getScatterSeries(
      BuildContext context, units, Map<int, List<SummaryActivity>> activities) {
    final List<int> years = activities.keys.toList();
    final List<ChartSeries<dynamic, dynamic>> chartSeries = [];

    final Map<int, Color> colors = generateColor(years);

    for (int key in colors.keys) {
      chartSeries.add(ScatterSeries<SummaryActivity, double>(
        name: key.toString().substring(2),
        color: colors[key], // Set the color property for the series
        pointColorMapper: (SummaryActivity stats, _) {
          return colors[stats.startDateLocal!.year]!;
        },
        xValueMapper: (SummaryActivity stats, _) =>
            Conversions.metersToDistance(context, stats.distance ?? 0),
        yValueMapper: (SummaryActivity stats, _) =>
            Conversions.metersToHeight(context, stats.totalElevationGain ?? 0),
        dataSource: activities[key]!,
      ));
    }
    return chartSeries;
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

Map<int, Color> generateColor(List<int> years) {
  if (years == null || years.isEmpty) {
    return {};
  }

  final ColorPalette palette = ColorPalette.splitComplimentary(
    zdvMidGreen,
    numberOfColors: years.length,
    hueVariability: 30,
    saturationVariability: 30,
    brightnessVariability: 30,
  );

  return { for (var entry in years.asMap().entries) entry.value : palette[entry.key] };
}
