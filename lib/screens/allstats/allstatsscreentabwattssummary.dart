import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/models/summary_activity.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zwiftdataviewer/screens/layouts/allstatstablayout.dart';
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/widgets/chartpointshortsummarywidget.dart';

import '../../providers/activity_select_provider.dart';
import '../../utils/datevalueobj.dart';

class AllStatsScreenTabWattsSummary extends AllStatsTabLayout {
  const AllStatsScreenTabWattsSummary({super.key});

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
          // Add interval to reduce number of labels
          interval: 50,
          // Limit maximum number of labels
          maximumLabels: 5,
        ),
        // Optimize trackball behavior
        trackballBehavior: TrackballBehavior(
          enable: true,
          // Enable tooltips for better user experience
          tooltipSettings: const InteractiveTooltip(
            enable: true,
            format: 'Power: point.y watts',
            color: zdvMidBlue,
            textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          markerSettings: const TrackballMarkerSettings(
            markerVisibility: TrackballVisibilityMode.visible,
            height: 10,
            width: 10,
            borderWidth: 2,
            color: zdvMidBlue,
            borderColor: Colors.white, // Add border color for better visibility
          ),
          // Set hide delay
          hideDelay: 3000,
          activationMode: ActivationMode.singleTap,
          // Only show trackball when a point is selected
          shouldAlwaysShow: false,
          // Add line customization
          lineType: TrackballLineType.vertical,
          lineColor: zdvMidBlue.withOpacity(0.7),
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
    final List<DateValue> wattsData = [];
    SummaryActivity? activity;
    final int length = activities.length;
    
    // Optimize data processing by sampling data points for large datasets
    final int sampleRate = length > 500 ? 3 : (length > 200 ? 2 : 1);
    
    for (int x = 0; x < length; x += sampleRate) {
      activity = activities[x];
      // Only add activities with valid power data
      if (activity.averageWatts > 0) {
        wattsData.add(DateValue(activity.startDate, activity.averageWatts));
      }
    }

    return <CartesianSeries<DateValue, DateTime>>[
      LineSeries<DateValue, DateTime>(
          // Reduce animation duration for better performance
          animationDuration: 300,
          dataSource: wattsData,
          width: 2,
          opacity: 0.9,
          color: zdvMidBlue,
          name: 'Avg Watts',
          xValueMapper: (DateValue watts, _) => watts.date,
          yValueMapper: (DateValue watts, _) => watts.value,
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
