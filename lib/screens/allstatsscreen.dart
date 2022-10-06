import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zwiftdataviewer/models/ActivitiesDataModel.dart';
import 'package:zwiftdataviewer/stravalib/Models/activity.dart';
import 'package:zwiftdataviewer/utils/conversions.dart';
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/widgets/listitemviews.dart' as list_item_views;

class AllStatsScreen extends StatelessWidget {
  static const secondaryMeasureAxisId = 'secondaryMeasureAxisId';

  const AllStatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, double> summaryData;
    return Selector<ActivitiesDataModel, List<SummaryActivity>>(
        selector: (_, model) => model.dateFilteredActivities,
        builder: (context, activities, _) {
          summaryData = SummaryData.createSummaryData(activities);
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
                  child: charts.BarChart(seriesList),
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
                                    summaryData[StatsType.TotalDistance]!)
                                .toStringAsFixed(2),
                            Conversions.metersToDistance(context,
                                    summaryData[StatsType.AvgDistance]!)
                                .toStringAsFixed(2),
                            Conversions.metersToDistance(context,
                                    summaryData[StatsType.LongestDistance]!)
                                .toStringAsFixed(2)
                          ],
                          units["distance"]!),
                      list_item_views.tripleDataLineItem(
                        "Elevation",
                        Icons.explore,
                        ["Total", "Avg", "Highest"],
                        [
                          Conversions.metersToHeight(context,
                                  summaryData[StatsType.TotalElevation]!)
                              .toStringAsFixed(2),
                          Conversions.metersToHeight(
                                  context, summaryData[StatsType.AvgElevation]!)
                              .toStringAsFixed(2),
                          Conversions.metersToHeight(context,
                                  summaryData[StatsType.HighestElevation]!)
                              .toStringAsFixed(2)
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
}

class YearlyTotals {
  final String year;
  final double value;

  YearlyTotals(this.year, this.value);
}

class StatsType {
  static const String TotalDistance = "TotalDistance";
  static const String AvgDistance = "AvgDistance";
  static const String TotalElevation = "TotalElevation";
  static const String AvgElevation = "AvgElevation";
  static const String LongestDistance = "LongestDistance";
  static const String HighestElevation = "HighestElevation";
}

class SummaryData {
  static Map<String, double> createSummaryData(
      List<SummaryActivity> activities) {
    Map<String, double> data = <String, double>{};
    double distance = 0.0;
    double elevation = 0.0;
    double longestDistance = 0.0;
    double highestElevation = 0.0;
    for (var activity in activities) {
      distance += activity.distance!;
      elevation += activity.totalElevationGain!;
      if (activity.distance! > longestDistance) {
        longestDistance = activity.distance!;
      }
      if (activity.totalElevationGain! > highestElevation) {
        highestElevation = activity.totalElevationGain!;
      }
    }
    data[StatsType.TotalDistance] = distance;
    data[StatsType.AvgDistance] = distance / activities.length;
    data[StatsType.TotalElevation] = elevation;
    data[StatsType.AvgElevation] = elevation / activities.length;
    data[StatsType.LongestDistance] = longestDistance;
    data[StatsType.HighestElevation] = highestElevation;

    return data;
  }
}
