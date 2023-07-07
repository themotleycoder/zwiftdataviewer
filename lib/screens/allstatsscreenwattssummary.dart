import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zwiftdataviewer/strava_lib/Models/summary_activity.dart';
import 'package:zwiftdataviewer/utils/conversions.dart';
import 'package:zwiftdataviewer/utils/theme.dart';

import '../providers/combinedstream_select_provider.dart';
import '../providers/filters_provider.dart';
import '../widgets/iconitemwidgets.dart';

class AllStatsScreenWattsSummary extends ConsumerWidget {
  const AllStatsScreenWattsSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<SummaryActivity> filteredActivities =
        ref.watch(dateActivityFiltersProvider);

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
            minimum: filteredActivities.first.startDateLocal,
            maximumLabels: 5),
        primaryYAxis: NumericAxis(
          axisLine: const AxisLine(width: 0),
          majorTickLines: const MajorTickLines(color: Colors.transparent),
          majorGridLines: const MajorGridLines(width: 0.5),
          opposedPosition: false,
          labelFormat: '{value}',
          minimum: 0,
          // maximum: 200,
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
          var combinedStreams = filteredActivities[dataPointIndex];
          // ref
          //     .read(combinedStreamSelectNotifier.notifier)
          //     .selectStream(combinedStreams);
        });
  }

  List<ChartSeries<DateValue, DateTime>> _createDataSet(
      WidgetRef ref, List<SummaryActivity> activities) {
    final List<DateValue> distanceData = [];
    SummaryActivity? activity;
    final int length = activities.length;
    for (int x = 0; x < length; x++) {
      activity = activities[x];
      distanceData.add(DateValue(activity.startDate, activity.averageWatts));
    }

    return <ChartSeries<DateValue, DateTime>>[
      LineSeries<DateValue, DateTime>(
          animationDuration: 1500,
          dataSource: distanceData,
          width: 1,
          opacity: 0.8,
          color: zdvmOrange.shade100,
          name: 'Avg Watts',
          xValueMapper: (DateValue distance, _) => distance.date,
          yValueMapper: (DateValue distance, _) => distance.value,
          dataLabelSettings: const DataLabelSettings(isVisible: false),
          enableTooltip: false,
          markerSettings: const MarkerSettings(isVisible: false)),
    ];
  }
}

class ProfileDataView extends ConsumerWidget {
  const ProfileDataView({super.key});

  // const ProfileDataView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var selectedSeries = ref.watch(combinedStreamSelectNotifier);

    Map<String, String> units = Conversions.units(ref);
    return Expanded(
        flex: 1,
        child: Container(
            // top: 100,
            margin: const EdgeInsets.fromLTRB(0, 16, 0, 0),
            child: ListView(
                // padding: const EdgeInsets.all(8.0),
                children: <Widget>[
                  IconHeaderDataRow([
                    IconDataObject(
                        'Distance',
                        Conversions.metersToDistance(
                                ref, selectedSeries.distance)
                            .toStringAsFixed(1),
                        Icons.route,
                        units: units['distance']),
                    IconDataObject(
                        'Elevation',
                        Conversions.metersToHeight(ref, selectedSeries.altitude)
                            .toStringAsFixed(0),
                        Icons.filter_hdr,
                        units: units['height'])
                  ]),
                  IconHeaderDataRow([
                    IconDataObject('Heartrate',
                        (selectedSeries.heartrate).toString(), Icons.favorite,
                        units: 'bpm'),
                    IconDataObject('Power', (selectedSeries.watts).toString(),
                        Icons.electric_bolt,
                        units: 'w')
                  ]),
                  IconHeaderDataRow([
                    IconDataObject('Cadence',
                        (selectedSeries.cadence).toString(), Icons.autorenew,
                        units: 'rpm'),
                    IconDataObject(
                        'Grade',
                        (selectedSeries.gradeSmooth).toString(),
                        Icons.network_cell,
                        units: '%')
                  ]),
                ])));
    // });
  }
}

class DateValue {
  final DateTime date;
  final double value;

  DateValue(this.date, this.value);
}
