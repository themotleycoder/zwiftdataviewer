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
        // Remove null tooltipBehavior to avoid conflicts with trackball
        plotAreaBorderWidth: 0,
        legend: const Legend(
            isVisible: true,
            overflowMode: LegendItemOverflowMode.wrap,
            position: LegendPosition.top),
        primaryXAxis: DateTimeAxis(
            title: const AxisTitle(text: 'Date'),
            // Change date format to mm/yy
            dateFormat: DateFormat('MM/yy'),
            minimum: filteredActivities.last.startDateLocal,
            maximumLabels: 5,
            // Remove gridlines for better performance and cleaner look
            majorGridLines: const MajorGridLines(width: 0)),
        primaryYAxis: const NumericAxis(
          axisLine: AxisLine(width: 0),
          majorTickLines: MajorTickLines(color: Colors.transparent),
          // Remove gridlines for better performance and cleaner look
          majorGridLines: MajorGridLines(width: 0),
          opposedPosition: false,
          labelFormat: '{value}',
          minimum: 50,
          maximum: 200,
          // Reduce number of labels
          interval: 25,
        ),
        // Optimize trackball behavior
        trackballBehavior: TrackballBehavior(
          enable: true,
          // Enable tooltips for better user experience
          tooltipSettings: const InteractiveTooltip(
            enable: true,
            format: 'Heart Rate: point.y bpm',
            color: zdvRed,
            textStyle: TextStyle(color: Colors.white),
          ),
          markerSettings: const TrackballMarkerSettings(
            markerVisibility: TrackballVisibilityMode.visible,
            height: 10,
            width: 10,
            borderWidth: 2,
            color: zdvRed,
            borderColor: Colors.white, // Add border color for better visibility
          ),
          // Set hide delay
          hideDelay: 3000,
          activationMode: ActivationMode.singleTap,
          // Only show trackball when a point is selected
          shouldAlwaysShow: false,
          // Add line customization
          lineType: TrackballLineType.vertical,
          lineColor: zdvRed.withOpacity(0.7),
          lineWidth: 2,
        ),
        series: _createDataSet(ref, filteredActivities),
        onTrackballPositionChanging: (TrackballArgs args) {
          final dataPointIndex = args.chartPointInfo.dataPointIndex ?? 0;
          if (dataPointIndex >= 0 && dataPointIndex < filteredActivities.length) {
            var selectedActivity = filteredActivities[dataPointIndex];
            ref
                .read(selectedActivityProvider.notifier)
                .selectActivity(selectedActivity);
          }
        });
  }

  @override
  Container buildChartSummaryWidget(
      BuildContext context, WidgetRef ref, Map<String, String> units) {
    return getChartPointShortSummaryWidget(context, ref, units);
  }

  List<CartesianSeries<DateValue, DateTime>> _createDataSet(
      WidgetRef ref, List<SummaryActivity> activities) {
    final List<DateValue> heartrateData = [];
    SummaryActivity? activity;
    final int length = activities.length;
    
    // Optimize data processing by sampling data points for large datasets
    final int sampleRate = length > 500 ? 3 : (length > 200 ? 2 : 1);
    
    for (int x = 0; x < length; x += sampleRate) {
      activity = activities[x];
      if (activity.hasHeartrate &&
          activity.averageHeartrate > 50 &&
          activity.averageHeartrate < 200) {
        heartrateData
            .add(DateValue(activity.startDate, activity.averageHeartrate));
      }
    }

    return <CartesianSeries<DateValue, DateTime>>[
      LineSeries<DateValue, DateTime>(
          // Reduce animation duration for better performance
          animationDuration: 300,
          dataSource: heartrateData,
          width: 2,
          opacity: 0.9,
          color: zdvRed,
          name: 'Avg Heart Rate',
          xValueMapper: (DateValue heartrate, _) => heartrate.date,
          yValueMapper: (DateValue heartrate, _) =>
              heartrate.value <= 20 ? null : heartrate.value,
          dataLabelSettings: const DataLabelSettings(isVisible: false),
          // Enable tooltips for trackball
          enableTooltip: true,
          markerSettings: const MarkerSettings(
            isVisible: false, // Only show markers when selected
            height: 6,
            width: 6,
            shape: DataMarkerType.circle,
            borderWidth: 2,
            borderColor: Colors.white,
          )),
    ];
  }
}
