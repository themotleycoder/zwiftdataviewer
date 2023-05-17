import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zwiftdataviewer/utils/conversions.dart';
import 'package:zwiftdataviewer/widgets/listitemviews.dart' as list_item_views;

import '../providers/filters_provider.dart';
import '../utils/charts.dart';
import '../utils/stats.dart' as stats;

class AllStatsScreenDistElev extends ConsumerWidget {
  const AllStatsScreenDistElev({super.key});

  static const secondaryMeasureAxisId = 'secondaryMeasureAxisId';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredActivities = ref.read(dateActivityFiltersProvider);
    final Map<String, double> summaryData =
        stats.SummaryData.createSummaryData(filteredActivities);
    final Map<String, String> units = Conversions.units(context);
    return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
              child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
            child: _buildMultipleAxisLineChart(
                context, ref), //charts.BarChart(seriesList),
          )),
          Container(
            // padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
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
                      Conversions.metersToDistance(context,
                              summaryData[stats.StatsType.LongestDistance]!)
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
                    Conversions.metersToHeight(
                            context, summaryData[stats.StatsType.AvgElevation]!)
                        .toStringAsFixed(1),
                    Conversions.metersToHeight(context,
                            summaryData[stats.StatsType.HighestElevation]!)
                        .toStringAsFixed(1)
                  ],
                  units['height']!,
                )
              ],
            ),
          )
        ]);
    // });
  }

  /// Returns the chart with multiple axes.
  SfCartesianChart _buildMultipleAxisLineChart(BuildContext context, ref) {
    final Map<String, String> units = Conversions.units(context);
    late bool isCardView = true;
    return SfCartesianChart(
      legend: Legend(isVisible: !isCardView),

      /// API for multiple axis. It can returns the various axis to the chart.
      axes: <ChartAxis>[
        NumericAxis(
          opposedPosition: true,
          name: 'yAxis1',
          majorGridLines: const MajorGridLines(width: 0.5),
          labelFormat: '{value}',
          minimum: 0,
          title: AxisTitle(text: 'Elevation (${units['height']!})'),
        )
      ],
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0.5),
      ),
      primaryYAxis: NumericAxis(
        majorGridLines: const MajorGridLines(width: 0),
        opposedPosition: false,
        labelFormat: '{value}',
        minimum: 0,
        title: AxisTitle(text: 'Distance (${units['distance']!})'),
      ),
      series: ChartsData.getMultipleAxisLineSeries(context, units, ref.watch(dateActivityFiltersProvider)),
      tooltipBehavior: TooltipBehavior(enable: true),
    );
  }
}

class YearlyTotals {
  final String? year;
  final double? distance;
  final double? elevation;

  YearlyTotals({this.year, this.distance, this.elevation});
}
