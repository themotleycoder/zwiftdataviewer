import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/models/summary_activity.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zwiftdataviewer/providers/activity_select_provider.dart';
import 'package:zwiftdataviewer/screens/layouts/allstatstablayout.dart';
import 'package:zwiftdataviewer/utils/conversions.dart';
import 'package:zwiftdataviewer/utils/datevalueobj.dart';
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/widgets/chartpointshortsummarywidget.dart';

class AllStatsScreenTabDistanceSummary extends AllStatsTabLayout {
  const AllStatsScreenTabDistanceSummary({super.key});

  @override
  SfCartesianChart buildChart(WidgetRef ref, Map<String, String> units,
      List<SummaryActivity> filteredActivities) {
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
          // Add interval to reduce number of labels
          interval: 10,
          // Limit maximum number of labels
          maximumLabels: 5,
        ),
        // Optimize trackball behavior
        trackballBehavior: TrackballBehavior(
          enable: true,
          // Enable tooltips for better user experience
          tooltipSettings: InteractiveTooltip(
            enable: true,
            format: 'Distance: point.y ${units['distance']!}',
            color: zdvYellow,
            textStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          markerSettings: const TrackballMarkerSettings(
            markerVisibility: TrackballVisibilityMode.visible,
            height: 10,
            width: 10,
            borderWidth: 2,
            color: zdvYellow,
            borderColor: Colors.black, // Add border color for better visibility
          ),
          // Set hide delay
          hideDelay: 3000,
          activationMode: ActivationMode.singleTap,
          // Only show trackball when a point is selected
          shouldAlwaysShow: false,
          // Add line customization
          lineType: TrackballLineType.vertical,
          lineColor: zdvYellow.withValues(alpha: 0.7),
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
    final List<DateValue> distanceData = [];
    SummaryActivity? activity;
    final int length = activities.length;
    
    // Optimize data processing by sampling data points for large datasets
    final int sampleRate = length > 500 ? 3 : (length > 200 ? 2 : 1);
    
    for (int x = 0; x < length; x += sampleRate) {
      activity = activities[x];
      distanceData.add(DateValue(activity.startDate,
          Conversions.metersToDistance(ref, activity.distance)));
    }

    final Map<String, String> units = Conversions.units(ref);
    return <CartesianSeries<DateValue, DateTime>>[
      LineSeries<DateValue, DateTime>(
          // Reduce animation duration for better performance
          animationDuration: 300,
          dataSource: distanceData,
          width: 2,
          opacity: 0.9,
          color: zdvYellow,
          name: 'Distance (${units['distance']!})',
          xValueMapper: (DateValue distance, _) => distance.date,
          yValueMapper: (DateValue distance, _) => distance.value,
          dataLabelSettings: const DataLabelSettings(isVisible: false),
          // Enable tooltips for trackball
          enableTooltip: true,
          markerSettings: const MarkerSettings(
            isVisible: false, // Only show markers when selected
            height: 6,
            width: 6,
            shape: DataMarkerType.circle,
            borderWidth: 2,
            borderColor: Colors.black,
          )),
    ];
  }
}
