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
    return Selector<ActivitiesDataModel, List<SummaryActivity>>(
        selector: (_, model) => model.dateFilteredActivities,
        builder: (context, activities, child) {
          Map<String, double> summaryData;
          summaryData = stats.SummaryData.createSummaryData(activities);
          Map<String, String> units = Conversions.units(context);

          return Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: buildChart(context, units, activities),//charts.BarChart(seriesList),
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

  /// Returns the chart with multiple axes.
  SfCartesianChart buildChart(BuildContext? context,
      Map<String, String> units, List<SummaryActivity> chartData) {
    late bool isCardView = true;
    return SfCartesianChart(
      // plotAreaBorderWidth: 0,
      // title: ChartTitle(
      //     text: 'chart test'),
      legend: Legend(isVisible: !isCardView),

      /// API for multiple axis. It can returns the various axis to the chart.
      axes: <ChartAxis>[
        NumericAxis(
          opposedPosition: true,
          name: 'yAxis1',
          axisLine: const AxisLine(width: 0),
          majorGridLines: const MajorGridLines(width: 0),
          // minorGridLines: const MinorGridLines(width: 0),
          majorTickLines: const MajorTickLines(width: 0),
          labelFormat: '{value}',
          minimum: 0,
        )
      ],
      primaryXAxis: CategoryAxis(majorGridLines: const MajorGridLines(width: 0),),
      primaryYAxis: NumericAxis(
        axisLine: const AxisLine(width: 0),
        //majorGridLines: const MajorGridLines(width: 0),
        // minorGridLines: const MinorGridLines(width: 0),
        majorTickLines: const MajorTickLines(width: 0),
        opposedPosition: false,
        labelFormat: '{value}',
        minimum: 0,
      ),
      series: buildDataSeries( context, units, chartData),
      tooltipBehavior: TooltipBehavior(enable: true),
    );
  }

  /// Returns the list of chart series which need to
  /// render on the multiple axes chart.
  List<ChartSeries<YearlyTotals, String>> buildDataSeries(BuildContext? context,
      Map<String, String> units,
      List<SummaryActivity> activities) {
    var chartData = generateChartData(context, units, activities);
    return <ChartSeries<YearlyTotals, String>>[
      ColumnSeries<YearlyTotals, String>(
          dataSource: chartData,
          xValueMapper: (YearlyTotals sales, _) => sales.year as String,
          yValueMapper: (YearlyTotals sales, _) => sales.distance,
          name: 'Distance',
          borderRadius: BorderRadius.circular(2),
          color: zdvMidBlue),
      ColumnSeries<YearlyTotals, String>(
          dataSource: chartData,
          yAxisName: 'yAxis1',
          xValueMapper: (YearlyTotals sales, _) => sales.year as String,
          yValueMapper: (YearlyTotals sales, _) => sales.elevation,
          name: 'Elevation',
          borderRadius: BorderRadius.circular(2),
      color: zdvMidGreen)
    ];
  }

  List<YearlyTotals> generateChartData(
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

    List<YearlyTotals> chartData = [];
    for (String key in distances.keys) {
      chartData.add(YearlyTotals(
          year: key, distance: distances[key], elevation: elevations[key]));
    }
    return chartData;
  }
}

class YearlyTotals {
  final String? year;
  final double? distance;
  final double? elevation;

  YearlyTotals({this.year, this.distance, this.elevation});
}

