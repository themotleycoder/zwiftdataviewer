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

class AllStatsScreenHeartSummary extends ConsumerWidget {
  const AllStatsScreenHeartSummary({super.key});

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
          minimum: 30,
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
          var combinedStreams = filteredActivities[dataPointIndex];
          // ref
          //     .read(combinedStreamSelectNotifier.notifier)
          //     .selectStream(combinedStreams);
        });
    // }, error: (Object error, StackTrace stackTrace) {
    //   return const Text("error");
    // }, loading: () {
    //   return const Center(
    //     child: CircularProgressIndicator(
    //       key: AppKeys.activitiesLoading,
    //     ),
    //   );
    // });
  }

  List<ChartSeries<DateValue, DateTime>> _createDataSet(
      WidgetRef ref, List<SummaryActivity> activities) {
    //final List<DistanceValue> elevationData = [];
    final List<DateValue> heartrateData = [];
    //final List<DistanceValue> wattsData = [];
    // final List<DistanceValue> cadenceData = [];
    // final List<DistanceValue> gradeData = [];
    // SegmentEffort segment;
    // double distance = 0.0;
    SummaryActivity? activity;
    final int length = activities.length;
    for (int x = 0; x < length; x++) {
      activity = activities[x];
      if (activity.hasHeartrate) {
        heartrateData
            .add(DateValue(activity.startDate, activity.averageHeartrate));
      }
      // distance = Conversions.metersToDistance(ref, col.distance);
      // var h = Conversions.metersToHeight(ref, col.altitude);
      // elevationData.add(DistanceValue(distance, h.toDouble()));
      // heartrateData.add(DistanceValue(distance, col.heartrate.toDouble()));
      // wattsData.add(DistanceValue(distance, col.watts.toDouble()));

      // cadenceData.add(DistanceValue(distance, col.cadence.toDouble()));
      // gradeData.add(DistanceValue(distance, col.gradeSmooth.toDouble()));
    }

    return <ChartSeries<DateValue, DateTime>>[
      // SplineAreaSeries<DateValue, num>(
      //     animationDuration: 1500,
      //     dataSource: heartrateData,
      //     color: zdvMidGreen,
      //     opacity: 1,
      //     name: 'Elevation',
      //     xValueMapper: (DateValue hr, _) => hr.date.year,
      //     yValueMapper: (DateValue hr, _) => hr.value,
      //     dataLabelSettings: const DataLabelSettings(isVisible: false),
      //     enableTooltip: false,
      //     markerSettings: const MarkerSettings(isVisible: false)),
      // SplineSeries<DistanceValue, num>(
      //     animationDuration: 1500,
      //     dataSource: wattsData,
      //     xValueMapper: (DistanceValue watts, _) => watts.distance,
      //     yValueMapper: (DistanceValue watts, _) => watts.value / 10,
      //     width: 1,
      //     opacity: 0.8,
      //     color: zdvMidBlue,
      //     name: 'Watts',
      //     dataLabelSettings: const DataLabelSettings(isVisible: false),
      //     enableTooltip: false,
      //     markerSettings: const MarkerSettings(isVisible: false)),
      LineSeries<DateValue, DateTime>(
          animationDuration: 1500,
          dataSource: heartrateData,
          width: 1,
          opacity: 0.8,
          color: zdvRed,
          name: 'Avg Heart Rate',
          xValueMapper: (DateValue heartrate, _) => heartrate.date,
          yValueMapper: (DateValue heartrate, _) => heartrate.value<=20?null:heartrate.value,
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
