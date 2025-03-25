import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/models/summary_activity.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zwiftdataviewer/providers/activity_select_provider.dart';
import 'package:zwiftdataviewer/screens/layouts/allstatstablayout.dart';
import 'package:zwiftdataviewer/utils/datevalueobj.dart';
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/widgets/chartpointshortsummarywidget.dart';

class AllStatsScreenTabHeartSummary extends AllStatsTabLayout {
  const AllStatsScreenTabHeartSummary({super.key});

  @override
  SfCartesianChart buildChart(
      WidgetRef ref, units, List<SummaryActivity> filteredActivities) {
    return SfCartesianChart(
        tooltipBehavior: null,
        plotAreaBorderWidth: 0,
        legend: const Legend(
            isVisible: true,
            overflowMode: LegendItemOverflowMode.wrap,
            position: LegendPosition.top),
        primaryXAxis: DateTimeAxis(
            title: AxisTitle(text: 'Date'),
            dateFormat: DateFormat('MMM yy'),
            minimum: filteredActivities.last.startDateLocal,
            maximumLabels: 5),
        primaryYAxis: NumericAxis(
          axisLine: const AxisLine(width: 0),
          majorTickLines: const MajorTickLines(color: Colors.transparent),
          majorGridLines: const MajorGridLines(width: 0.5),
          opposedPosition: false,
          labelFormat: '{value}',
          minimum: 50,
          maximum: 200,
        ),
        trackballBehavior: TrackballBehavior(
          enable: true,
          tooltipSettings: const InteractiveTooltip(enable: false),
          markerSettings: const TrackballMarkerSettings(
            markerVisibility: TrackballVisibilityMode.visible,
            height: 10,
            width: 10,
            borderWidth: 1,
          ),
          hideDelay: 3000,
          activationMode: ActivationMode.singleTap,
          shouldAlwaysShow: true,
        ),
        series: _createDataSet(ref, filteredActivities),
        onTrackballPositionChanging: (TrackballArgs args) {
          final dataPointIndex = args.chartPointInfo.dataPointIndex ?? 0;
          var selectedActivity = filteredActivities[dataPointIndex];
          ref
              .read(selectedActivityProvider.notifier)
              .selectActivity(selectedActivity);
        });
  }

  @override
  Container buildChartSummaryWidget(
      BuildContext context, WidgetRef ref, Map<String, String> units) {
    return getChartPointShortSummaryWidget(context, ref, units);
  }

  List<ChartSeries<DateValue, DateTime>> _createDataSet(
      WidgetRef ref, List<SummaryActivity> activities) {
    final List<DateValue> heartrateData = [];
    SummaryActivity? activity;
    final int length = activities.length;
    for (int x = 0; x < length; x++) {
      activity = activities[x];
      if (activity.hasHeartrate &&
          activity.averageHeartrate > 50 &&
          activity.averageHeartrate < 200) {
        heartrateData
            .add(DateValue(activity.startDate, activity.averageHeartrate));
      }
    }

    return <ChartSeries<DateValue, DateTime>>[
      LineSeries<DateValue, DateTime>(
          animationDuration: 1500,
          dataSource: heartrateData,
          width: 1,
          opacity: 0.8,
          color: zdvRed,
          name: 'Avg Heart Rate',
          xValueMapper: (DateValue heartrate, _) => heartrate.date,
          yValueMapper: (DateValue heartrate, _) =>
              heartrate.value <= 20 ? null : heartrate.value,
          dataLabelSettings: const DataLabelSettings(isVisible: false),
          enableTooltip: false,
          markerSettings: const MarkerSettings(isVisible: false)),
    ];
  }
}
