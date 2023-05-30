import 'package:flutter/widgets.dart';
import 'package:flutter_palette/flutter_palette.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zwiftdataviewer/stravalib/Models/summary_activity.dart';
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/utils/yearlytotals.dart';

import 'conversions.dart';

class ChartsData {
  static

      /// Returns the list of chart series which need to
      /// render on the multiple axes chart.
      List<ChartSeries<YearlyTotals, String>> getMultipleAxisLineSeries(
          WidgetRef ref,
          Map<String, String> units,
          List<SummaryActivity> activities) {
    var chartData = generateChartData(ref, units, activities);
    return <ChartSeries<YearlyTotals, String>>[
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
    const String totalName = "Total";

    for (var activity in activities) {
      double distance = Conversions.metersToDistance(ref, activity.distance!);
      double elevation =
          Conversions.metersToHeight(ref, activity.totalElevationGain!);

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

  static List<ChartSeries<dynamic, dynamic>> getScatterSeries(
      WidgetRef ref, units, Map<int, List<SummaryActivity>> activities) {
    final List<int> years = activities.keys.toList();
    final List<ChartSeries<dynamic, dynamic>> chartSeries = [];

    final Map<int, Color> colors = generateColor(years);

    for (int key in colors.keys) {
      chartSeries.add(ScatterSeries<SummaryActivity, double>(
        name: key.toString().substring(2),
        color: colors[key],
        // Set the color property for the series
        pointColorMapper: (SummaryActivity stats, _) {
          return colors[stats.startDateLocal!.year]!;
        },
        xValueMapper: (SummaryActivity stats, _) =>
            Conversions.metersToDistance(
                ref, (stats.distance ?? 0).roundToDouble()),
        yValueMapper: (SummaryActivity stats, _) => Conversions.metersToHeight(
            ref, (stats.totalElevationGain ?? 0).roundToDouble()),
        dataSource: activities[key]!,
        selectionBehavior: SelectionBehavior(enable: true),
        initialSelectedDataIndexes: const [0],
        onPointTap: (ChartPointDetails details) {
          // Get the index of the tapped data point
          final int pointIndex = details.pointIndex!;
          // Get the corresponding SummaryActivity object and do something with it
          _onSelectionChanged(activities[key]![pointIndex]);
        },
      ));
    }
    return chartSeries;
  }

  static _onSelectionChanged(SummaryActivity selectedRide) {
    // Provider.of<SummaryActivitySelectDataModel>(context, listen: false)
    //     .setSelectedActivity(selectedRide);
  }

  static Map<int, Color> generateColor(List<int> years) {
    if (years.isEmpty) {
      return {};
    }

    final ColorPalette palette = ColorPalette.splitComplimentary(
      zdvMidGreen,
      numberOfColors: years.length,
      hueVariability: 30,
      saturationVariability: 30,
      brightnessVariability: 30,
    );

    return {
      for (var entry in years.asMap().entries) entry.value: palette[entry.key]
    };
  }
}
