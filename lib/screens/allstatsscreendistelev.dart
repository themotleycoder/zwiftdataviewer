import 'dart:ffi';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zwiftdataviewer/models/ActivitiesDataModel.dart';
import 'package:zwiftdataviewer/stravalib/Models/activity.dart';
import 'package:zwiftdataviewer/utils/conversions.dart';
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/widgets/listitemviews.dart' as list_item_views;
import '../utils/Stats.dart' as stats;

class AllStatsScreenDistElev extends StatelessWidget {

  const AllStatsScreenDistElev({super.key});
  static const secondaryMeasureAxisId = 'secondaryMeasureAxisId';

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<ActivitiesDataModel>(context);
    return Selector<ActivitiesDataModel, List<SummaryActivity>>(
        selector: (_, model) => model.dateFilteredActivities,
        builder: (context, activities, child) {
          Map<String, double> summaryData;
          summaryData = stats.SummaryData.createSummaryData(activities);
          Map<String, String> units = Conversions.units(context);
          final List<charts.Series<dynamic, String>> seriesList =
              generateChartData(context, units, activities);

          return Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildMultipleAxisLineChart(context, units, activities),//charts.BarChart(seriesList),
                )),
                Container(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                  child: Column(
                    children: <Widget>[
                      list_item_views.tripleDataLineItem(
                          "Distance",
                          Icons.explore,
                          ["Total", "Avg", "Longest"],
                          [
                            Conversions.metersToDistance(context,
                                    summaryData[stats.StatsType.TotalDistance]!)
                                .toStringAsFixed(1),
                            Conversions.metersToDistance(context,
                                    summaryData[stats.StatsType.AvgDistance]!)
                                .toStringAsFixed(1),
                            Conversions.metersToDistance(
                                    context,
                                    summaryData[
                                        stats.StatsType.LongestDistance]!)
                                .toStringAsFixed(1)
                          ],
                          units["distance"]!),
                      list_item_views.tripleDataLineItem(
                        "Elevation",
                        Icons.explore,
                        ["Total", "Avg", "Highest"],
                        [
                          Conversions.metersToHeight(context,
                                  summaryData[stats.StatsType.TotalElevation]!)
                              .toStringAsFixed(1),
                          Conversions.metersToHeight(context,
                                  summaryData[stats.StatsType.AvgElevation]!)
                              .toStringAsFixed(1),
                          Conversions.metersToHeight(
                                  context,
                                  summaryData[
                                      stats.StatsType.HighestElevation]!)
                              .toStringAsFixed(1)
                        ],
                        units['height']!,
                      )
                    ],
                  ),
                )
              ]);
        });
  }

  List<charts.Series<YearlyTotals, String>> generateChartData(
      BuildContext? context,
      Map<String, String> units,
      List<SummaryActivity> activities) {
    /// Create series list with multiple series
    final Map<String, double> distances = {};
    final Map<String, double> elevations = {};
    const String totalName = "Total";

    for (var activity in activities) {
      double distance =
          Conversions.metersToDistance(context!, activity.distance!);
      double elevation =
          Conversions.metersToHeight(context, activity.totalElevationGain!);

      double d = distances[totalName] ?? 0;
      double e = elevations[totalName] ?? 0;

      distances[totalName] = distances[totalName] == null
          ? distance
          : distances[totalName] = d + distance;
      elevations[totalName] = elevations[totalName] == null
          ? elevation
          : elevations[totalName] = e + elevation;
      if (distances.containsKey(activity.startDateLocal?.year.toString())) {
        distance += distances[activity.startDateLocal?.year.toString()]!;
        elevation += elevations[activity.startDateLocal?.year.toString()]!;
      }

      int? year = activity.startDateLocal?.year;
      distances[year.toString()] = distance;
      elevations[year.toString()] = elevation;
    }

    List<YearlyTotals> distanceData = [];
    for (String key in distances.keys) {
      distanceData.add(YearlyTotals(key, distances[key]!));
    }
    List<YearlyTotals> elevationData = [];
    for (String key in elevations.keys) {
      elevationData.add(YearlyTotals(key, elevations[key]!));
    }

    return [
      charts.Series<YearlyTotals, String>(
        id: 'Distance (${units['distance']!})',
        domainFn: (YearlyTotals totals, _) => totals.year,
        measureFn: (YearlyTotals totals, _) => totals.value,
        data: distanceData,
        seriesColor: charts.ColorUtil.fromDartColor(zdvMidBlue),
      ),
      charts.Series<YearlyTotals, String>(
        id: 'Elevation (${units['height']!})',
        domainFn: (YearlyTotals totals, _) => totals.year,
        measureFn: (YearlyTotals totals, _) => totals.value,
        data: elevationData,
        seriesColor: charts.ColorUtil.fromDartColor(zdvMidGreen),
      )..setAttribute(charts.measureAxisIdKey, secondaryMeasureAxisId)
    ];
  }

  /// Returns the chart with multiple axes.
  SfCartesianChart _buildMultipleAxisLineChart(BuildContext? context,
      Map<String, String> units, List<SummaryActivity> chartData) {
    late bool isCardView = true;
    return SfCartesianChart(
      title: ChartTitle(
          text: 'chart test'),
      legend: Legend(isVisible: !isCardView),

      /// API for multiple axis. It can returns the various axis to the chart.
      axes: <ChartAxis>[
        NumericAxis(
            opposedPosition: true,
            name: 'yAxis1',
            majorGridLines: const MajorGridLines(width: 0),
            labelFormat: '{value}°F',
            minimum: 40,
            maximum: 100,
            interval: 10)
      ],
      primaryXAxis:
      DateTimeAxis(majorGridLines: const MajorGridLines(width: 0)),
      primaryYAxis: NumericAxis(
        majorGridLines: const MajorGridLines(width: 0),
        opposedPosition: false,
        minimum: 0,
        maximum: 50,
        interval: 10,
        labelFormat: '{value}°C',
      ),
      series: _getMultipleAxisLineSeries( context, units, chartData),
      tooltipBehavior: TooltipBehavior(enable: true),
    );
  }

  // static List<YearlyTotals2>? chartData = <YearlyTotals2>[
    // YearlyTotals2(year: DateTime.parse("2019"), distance: 13, elevation: 69.8),
    // YearlyTotals2(year: DateTime.parse("2019"), distance: 26, elevation: 87.8),
    // YearlyTotals2(year: DateTime.parse("2020"), distance: 13, elevation: 78.8),
    // YearlyTotals2(year: DateTime.parse("2020"), distance: 22, elevation: 75.2),
    // YearlyTotals2(year: DateTime.parse("2021"), distance: 14, elevation: 68),
    // YearlyTotals2(year: DateTime.parse("2021"), distance: 23, elevation: 78.8),
    // YearlyTotals2(year: DateTime.parse("2021"), distance: 21, elevation: 80.6),
    // YearlyTotals2(year: DateTime.parse("2022"), distance: 22, elevation: 73.4),
    // YearlyTotals2(year: DateTime.parse("2022"), distance: 16, elevation: 78.8),
    // ];

  /// Returns the list of chart series which need to
  /// render on the multiple axes chart.
  List<ChartSeries<YearlyTotals2, DateTime>> _getMultipleAxisLineSeries(BuildContext? context,
      Map<String, String> units,
      List<SummaryActivity> activities) {
    var chartData = generateNewChartData(context, units, activities);
    return <ChartSeries<YearlyTotals2, DateTime>>[
      ColumnSeries<YearlyTotals2, DateTime>(
          dataSource: chartData!,
          xValueMapper: (YearlyTotals2 sales, _) => sales.year as DateTime,
          yValueMapper: (YearlyTotals2 sales, _) => sales.distance,
          name: 'New York'),
      ColumnSeries<YearlyTotals2, DateTime>(
          dataSource: chartData!,
          yAxisName: 'yAxis1',
          xValueMapper: (YearlyTotals2 sales, _) => sales.year as DateTime,
          yValueMapper: (YearlyTotals2 sales, _) => sales.elevation,
          name: 'Washington')
    ];
  }

  List<YearlyTotals2> generateNewChartData(
      BuildContext? context,
      Map<String, String> units,
      List<SummaryActivity> activities) {
    /// Create series list with multiple series
    final Map<String, double> distances = {};
    final Map<String, double> elevations = {};
    const String totalName = "Total";

    for (var activity in activities) {
      double distance =
      Conversions.metersToDistance(context!, activity.distance!);
      double elevation =
      Conversions.metersToHeight(context, activity.totalElevationGain!);

      double d = distances[totalName] ?? 0;
      double e = elevations[totalName] ?? 0;

      distances[totalName] = distances[totalName] == null
          ? distance
          : distances[totalName] = d + distance;
      elevations[totalName] = elevations[totalName] == null
          ? elevation
          : elevations[totalName] = e + elevation;
      if (distances.containsKey(activity.startDateLocal?.year.toString())) {
        distance += distances[activity.startDateLocal?.year.toString()]!;
        elevation += elevations[activity.startDateLocal?.year.toString()]!;
      }

      int? year = activity.startDateLocal?.year;
      distances[year.toString()] = distance;
      elevations[year.toString()] = elevation;
    }

    List<YearlyTotals> distanceData = [];
    for (String key in distances.keys) {
      distanceData.add(YearlyTotals(key, distances[key]!));
    }
    List<YearlyTotals> elevationData = [];
    for (String key in elevations.keys) {
      elevationData.add(YearlyTotals(key, elevations[key]!));
    }
    int x = 0;
    List<YearlyTotals2> chartData = [];
    for (String key in elevations.keys) {
      chartData.add(YearlyTotals2(
          year: DateTime(int.parse(key)), distance: distanceData[x].value, elevation: elevationData[x].value));
      x+=1;
    }
    return chartData;

    // return [
    //   charts.Series<YearlyTotals, String>(
    //     id: 'Distance (${units['distance']!})',
    //     domainFn: (YearlyTotals totals, _) => totals.year,
    //     measureFn: (YearlyTotals totals, _) => totals.value,
    //     data: distanceData,
    //     seriesColor: charts.ColorUtil.fromDartColor(zdvMidBlue),
    //   ),
    //   charts.Series<YearlyTotals, String>(
    //     id: 'Elevation (${units['height']!})',
    //     domainFn: (YearlyTotals totals, _) => totals.year,
    //     measureFn: (YearlyTotals totals, _) => totals.value,
    //     data: elevationData,
    //     seriesColor: charts.ColorUtil.fromDartColor(zdvMidGreen),
    //   )..setAttribute(charts.measureAxisIdKey, secondaryMeasureAxisId)
    // ];
  }
}

class YearlyTotals {
  final String year;
  final double value;

  YearlyTotals(this.year, this.value);
}

class YearlyTotals2 {
  final DateTime? year;
  final double? distance;
  final double? elevation;

  YearlyTotals2({this.year, this.distance, this.elevation});
}

class ChartSampleData {
  ChartSampleData(
      {this.x,
      this.y,
      this.xValue,
      this.yValue,
      this.secondSeriesYValue,
      this.thirdSeriesYValue,
      this.pointColor,
      this.size,
      this.text,
      this.open,
      this.close,
      this.low,
      this.high,
      this.volume});

  final DateTime? x;
  final double? y;
  final double? xValue;
  final double? yValue;
  final double? secondSeriesYValue;
  final double? thirdSeriesYValue;
  final Color? pointColor;
  final double? size;
  final String? text;
  final double? open;
  final double? close;
  final double? low;
  final double? high;
  final double? volume;
}
