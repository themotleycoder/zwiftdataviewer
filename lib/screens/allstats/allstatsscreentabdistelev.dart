import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/models/summary_activity.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zwiftdataviewer/screens/layouts/allstatstablayout.dart';
import 'package:zwiftdataviewer/utils/conversions.dart';
import 'package:zwiftdataviewer/widgets/iconitemwidgets.dart';

import '../../providers/filters/filters_provider.dart';
import '../../utils/charts.dart';
import '../../utils/stats.dart' as stats;

class AllStatsScreenTabDistElev extends AllStatsTabLayout {
  const AllStatsScreenTabDistElev({super.key});

  static const secondaryMeasureAxisId = 'secondaryMeasureAxisId';

  @override
  SfCartesianChart buildChart(
      WidgetRef ref, units, List<SummaryActivity> filteredActivities) {
    final Map<String, String> units = Conversions.units(ref);
    late bool isCardView = true;

    return SfCartesianChart(
      legend: Legend(isVisible: !isCardView),

      // API for multiple axis. It can returns the various axis to the chart.
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
      primaryXAxis: const CategoryAxis(
        majorGridLines: MajorGridLines(width: 0.5),
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

  @override
  Container buildChartSummaryWidget(
      BuildContext context, WidgetRef ref, Map<String, String> units) {
    final List<SummaryActivity> filteredActivities =
        ref.read(dateActivityFiltersProvider);
    final Map<String, double> summaryData =
        stats.SummaryData.createSummaryData(filteredActivities);
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          iconHeaderDataRow([
            IconDataObject(
                'Total',
                Conversions.metersToDistance(
                        ref, summaryData[stats.StatsType.totalDistance]!)
                    .toStringAsFixed(1),
                Icons.route,
                units: units['distance']),
            IconDataObject(
                'Total',
                Conversions.metersToHeight(
                        ref, summaryData[stats.StatsType.totalElevation]!)
                    .toStringAsFixed(1),
                Icons.filter_hdr,
                units: units['height']),
          ]),
          iconHeaderDataRow([
            IconDataObject(
                'Average',
                Conversions.metersToDistance(
                        ref, summaryData[stats.StatsType.avgDistance]!)
                    .toStringAsFixed(1),
                Icons.route,
                units: units['distance']),
            IconDataObject(
                'Average',
                Conversions.metersToHeight(
                        ref, summaryData[stats.StatsType.avgElevation]!)
                    .toStringAsFixed(1),
                Icons.filter_hdr,
                units: units['height']),
          ]),
          iconHeaderDataRow([
            IconDataObject(
                'Longest',
                Conversions.metersToDistance(
                        ref, summaryData[stats.StatsType.longestDistance]!)
                    .toStringAsFixed(1),
                Icons.route,
                units: units['distance']),
            IconDataObject(
                'Highest',
                Conversions.metersToHeight(
                        ref, summaryData[stats.StatsType.highestElevation]!)
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
