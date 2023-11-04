import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_strava_api/Models/summary_activity.dart';
import 'package:zwiftdataviewer/utils/conversions.dart';
import 'package:zwiftdataviewer/widgets/iconitemwidgets.dart';

import '../providers/filters/filters_provider.dart';
import '../utils/charts.dart';
import '../utils/stats.dart' as stats;

class AllStatsScreenDistElev extends ConsumerWidget {
  const AllStatsScreenDistElev({super.key});

  static const secondaryMeasureAxisId = 'secondaryMeasureAxisId';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<SummaryActivity> filteredActivities =
        ref.read(dateActivityFiltersProvider);
    final Map<String, double> summaryData =
        stats.SummaryData.createSummaryData(filteredActivities);

    return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
              child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
            child: _buildMultipleAxisColumnChart(context, ref),
          )),
          buildSummaryView(ref, summaryData),
        ]);
  }

  /// Returns the chart with multiple axes.
  SfCartesianChart _buildMultipleAxisColumnChart(BuildContext context, ref) {
    final Map<String, String> units = Conversions.units(ref);
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
      series: ChartsData.getMultipleAxisColumnSeries(
          ref, units, ref.watch(dateActivityFiltersProvider)),
      onSelectionChanged: (SelectionArgs args) {
        args;
        // var lapSummaryObject = laps[args.pointIndex];
        // ref
        //     .read(lapSummaryObjectProvider.notifier)
        //     .selectSummary(lapSummaryObject);
      },
      tooltipBehavior: TooltipBehavior(enable: true), //_tooltipBehavior,//
    );
  }

  buildSummaryView(ref, Map<String, double> summaryData) {
    final Map<String, String> units = Conversions.units(ref);
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          IconHeaderDataRow([
            IconDataObject(
                'Total',
                Conversions.metersToDistance(
                        ref, summaryData[stats.StatsType.TotalDistance]!)
                    .toStringAsFixed(1),
                Icons.route,
                units: units['distance']),
            IconDataObject(
                'Total',
                Conversions.metersToHeight(
                        ref, summaryData[stats.StatsType.TotalElevation]!)
                    .toStringAsFixed(1),
                Icons.filter_hdr,
                units: units['height']),
          ]),
          IconHeaderDataRow([
            IconDataObject(
                'Average',
                Conversions.metersToDistance(
                        ref, summaryData[stats.StatsType.AvgDistance]!)
                    .toStringAsFixed(1),
                Icons.route,
                units: units['height']),
            IconDataObject(
                'Average',
                Conversions.metersToHeight(
                        ref, summaryData[stats.StatsType.AvgElevation]!)
                    .toStringAsFixed(1),
                Icons.filter_hdr,
                units: units['height']),
          ]),
          IconHeaderDataRow([
            IconDataObject(
                'Longest',
                Conversions.metersToDistance(
                        ref, summaryData[stats.StatsType.LongestDistance]!)
                    .toStringAsFixed(1),
                Icons.route,
                units: units['height']),
            IconDataObject(
                'Highest',
                Conversions.metersToHeight(
                        ref, summaryData[stats.StatsType.HighestElevation]!)
                    .toStringAsFixed(1),
                Icons.filter_hdr,
                units: units['height'])
          ]),
        ],
      ),
    );
  }
}

class YearlyTotals {
  final String? year;
  final double? distance;
  final double? elevation;

  YearlyTotals({this.year, this.distance, this.elevation});
}
