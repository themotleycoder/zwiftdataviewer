import 'package:flutter/widgets.dart';
import 'package:zwiftdataviewer/utils/yearlytotals.dart';
import '../stravalib/Models/activity.dart';
import 'conversions.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class ChartsData {
  static List<YearlyTotals> generateColumnChartData(BuildContext? context,
      Map<String, String> units, List<SummaryActivity> activities) {
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

  static List<charts.Series<SummaryActivity, double>> buildChartSeriesList(
      BuildContext context,
      Map<int, List<SummaryActivity>> activities,
      Map<int, Color> colors) {
    final List<charts.Series<SummaryActivity, double>> chartSeries = [];

    for (int key in activities.keys) {
      final List<SummaryActivity>distance = activities[key]!;
      chartSeries.add(charts.Series<SummaryActivity, double>(
        id: key.toString().substring(2),
        // Providing a color function is optional.
        colorFn: (SummaryActivity stats, _) {
          // Bucket the measure column value into 3 distinct colors.
          return charts.ColorUtil.fromDartColor(
              colors[stats.startDateLocal!.year]!);
        },
        domainFn: (SummaryActivity stats, _) =>
            Conversions.metersToDistance(context, stats.distance ?? 0),
        measureFn: (SummaryActivity stats, _) =>
            Conversions.metersToHeight(context, stats.totalElevationGain ?? 0),
        // Providing a radius function is optional.
        // radiusPxFn: (SummaryActivity stats, _) => sales.radius,
        data: distance,
      ));
    }

    return chartSeries;
  }
}