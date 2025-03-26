import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/models/summary_activity.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zwiftdataviewer/providers/activity_select_provider.dart';
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/utils/yearlytotals.dart';

import 'conversions.dart';

class ChartsData {
  static

      /// Returns the list of chart series which need to
      /// render on the multiple axes chart.
      List<CartesianSeries<YearlyTotals, String>> getMultipleAxisColumnSeries(
          WidgetRef ref,
          Map<String, String> units,
          List<SummaryActivity> activities) {
    var chartData = generateChartData(ref, units, activities);
    return <CartesianSeries<YearlyTotals, String>>[
      ColumnSeries<YearlyTotals, String>(
          dataSource: chartData,
          xValueMapper: (YearlyTotals stats, _) => stats.year as String,
          yValueMapper: (YearlyTotals stats, _) =>
              (stats.distance ?? 0 / 1000).roundToDouble(),
          name: 'Distance',
          color: zdvMidBlue),
      ColumnSeries<YearlyTotals, String>(
          dataSource: chartData,
          yAxisName: 'yAxis1',
          xValueMapper: (YearlyTotals stats, _) => stats.year as String,
          yValueMapper: (YearlyTotals stats, _) =>
              (stats.elevation ?? 0 / 1000).roundToDouble(),
          name: 'Elevation',
          color: zdvMidGreen)
    ];
  }

  static List<YearlyTotals> generateChartData(WidgetRef ref,
      Map<String, String> units, List<SummaryActivity> activities) {
    /// Create series list with multiple series
    final Map<String, double> distances = {};
    final Map<String, double> elevations = {};
    // const String totalName = "Total";

    for (var activity in activities) {
      double distance = Conversions.metersToDistance(ref, activity.distance);
      double elevation =
          Conversions.metersToHeight(ref, activity.totalElevationGain);

      // double d = distances[totalName] ?? 0;
      // double e = elevations[totalName] ?? 0;
      //
      // distances[totalName] = distances[totalName] == null
      //     ? distance
      //     : distances[totalName] = d + distance;
      // elevations[totalName] = elevations[totalName] == null
      //     ? elevation
      //     : elevations[totalName] = e + elevation;
      if (distances.containsKey(activity.startDateLocal.year.toString())) {
        distance += distances[activity.startDateLocal.year.toString()]!;
        elevation += elevations[activity.startDateLocal.year.toString()]!;
      }

      int? year = activity.startDateLocal.year;
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

  static List<CartesianSeries<dynamic, dynamic>> getScatterSeries(
      WidgetRef ref, units, Map<int, List<SummaryActivity>> activities) {
    final List<int> years = activities.keys.toList();
    final List<CartesianSeries<dynamic, dynamic>> chartSeries = [];

    final Map<int, Color> colors = generateColor(years);

    for (int key in colors.keys) {
      chartSeries.add(ScatterSeries<SummaryActivity, double>(
        name: key.toString().substring(2),
        color: colors[key],
        // Set the color property for the series
        pointColorMapper: (SummaryActivity stats, _) {
          return colors[stats.startDateLocal.year]!;
        },
        xValueMapper: (SummaryActivity stats, _) =>
            Conversions.metersToDistance(ref, (stats.distance).roundToDouble()),
        yValueMapper: (SummaryActivity stats, _) => Conversions.metersToHeight(
            ref, (stats.totalElevationGain).roundToDouble()),
        dataSource: activities[key]!,
        selectionBehavior: SelectionBehavior(enable: true),
        // Remove initialSelectedDataIndexes to avoid unmodifiable list error
        onPointTap: (ChartPointDetails details) {
          // Get the index of the tapped data point
          final int pointIndex = details.pointIndex!;
          // Get the corresponding SummaryActivity object and update the provider
          final selectedActivity = activities[key]![pointIndex];
          ref.read(selectedActivityProvider.notifier).selectActivity(selectedActivity);
        },
      ));
    }
    return chartSeries;
  }

  // Custom color generation function to replace ColorPalette.splitComplimentary
  static Map<int, Color> generateColor(List<int> years) {
    if (years.isEmpty) {
      return {};
    }

    // Base color (zdvMidGreen)
    final HSVColor baseColor = HSVColor.fromColor(zdvMidGreen);

    // Generate a list of colors with varying hues
    final List<Color> colors = [];
    final int count = years.length;

    for (int i = 0; i < count; i++) {
      // Calculate a new hue by rotating around the color wheel
      // For split complementary effect, we'll use a 150 degree spread
      final double hueOffset = (i * 150.0 / count) % 360;
      final double newHue = (baseColor.hue + hueOffset) % 360;

      // Add some variability to saturation and value
      final double satVariability = (i % 3 - 1) * 0.1; // -0.1, 0, or 0.1
      final double valVariability = (i % 3 - 1) * 0.1; // -0.1, 0, or 0.1

      final double newSaturation =
          (baseColor.saturation + satVariability).clamp(0.3, 1.0);
      final double newValue =
          (baseColor.value + valVariability).clamp(0.7, 1.0);

      colors.add(
          HSVColor.fromAHSV(1.0, newHue, newSaturation, newValue).toColor());
    }

    // Map years to colors
    return {
      for (var entry in years.asMap().entries) entry.value: colors[entry.key]
    };
  }
}
