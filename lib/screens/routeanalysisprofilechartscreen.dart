import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zwiftdataviewer/stravalib/API/streams.dart';
import 'package:zwiftdataviewer/utils/conversions.dart';
import 'package:zwiftdataviewer/utils/theme.dart';

import '../appkeys.dart';
import '../providers/activity_select_provider.dart';
import '../providers/combinedstream_select_provider.dart';
import '../providers/streams_provider.dart';
import '../widgets/iconitemwidgets.dart';

class RouteAnalysisProfileChartScreen extends ConsumerWidget {
  const RouteAnalysisProfileChartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Column(children: [
      Expanded(
        child: DisplayChart(),
      ),
      ProfileDataView(),
    ]);
  }
}

class DisplayChart extends ConsumerWidget {
  const DisplayChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Map<String, String> units = Conversions.units(ref);

    AsyncValue<StreamsDetailCollection> streamsData =
        ref.watch(streamsProvider(ref.watch(selectedActivityProvider).id!));

    return streamsData.when(data: (streams) {
      return SfCartesianChart(
          tooltipBehavior: null,
          plotAreaBorderWidth: 0,
          legend: Legend(
              isVisible: true,
              overflowMode: LegendItemOverflowMode.wrap,
              position: LegendPosition.top),
          primaryXAxis: NumericAxis(
              title: AxisTitle(text: 'Distance (${units['distance']!})'),
              majorGridLines: const MajorGridLines(width: 0),
              minimum: 0),
          primaryYAxis: NumericAxis(
              labelFormat: ' ',
              axisLine: const AxisLine(width: 0),
              majorTickLines: const MajorTickLines(color: Colors.transparent)),
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
          series: _createDataSet(ref, streams.streams ?? []),
          onTrackballPositionChanging: (TrackballArgs args) {
            final dataPointIndex = args.chartPointInfo.dataPointIndex ?? 0;
            var combinedStreams = streams.streams![dataPointIndex];
            ref
                .read(combinedStreamSelectNotifier.notifier)
                .selectStream(combinedStreams);
          });
    }, error: (Object error, StackTrace stackTrace) {
      return const Text("error");
    }, loading: () {
      return const Center(
        child: CircularProgressIndicator(
          key: AppKeys.activitiesLoading,
        ),
      );
    });
  }

  List<XyDataSeries<DistanceValue, num>> _createDataSet(
      WidgetRef ref, List<CombinedStreams> streams) {
    final List<DistanceValue> elevationData = [];
    final List<DistanceValue> heartrateData = [];
    final List<DistanceValue> wattsData = [];
    // final List<DistanceValue> cadenceData = [];
    // final List<DistanceValue> gradeData = [];
    // SegmentEffort segment;
    double distance = 0.0;
    CombinedStreams? col;
    final int length = streams.length;
    for (int x = 0; x < length; x++) {
      col = streams[x];
      distance = Conversions.metersToDistance(ref, col.distance);
      var h = Conversions.metersToHeight(ref, col.altitude);
      elevationData.add(DistanceValue(distance, h.toDouble()));
      heartrateData.add(DistanceValue(distance, col.heartrate.toDouble()));
      wattsData.add(DistanceValue(distance, col.watts.toDouble()));

      // cadenceData.add(DistanceValue(distance, col.cadence.toDouble()));
      // gradeData.add(DistanceValue(distance, col.gradeSmooth.toDouble()));
    }

    return <XyDataSeries<DistanceValue, num>>[
      SplineAreaSeries<DistanceValue, num>(
          animationDuration: 1500,
          dataSource: elevationData,
          color: zdvMidGreen,
          opacity: 1,
          name: 'Elevation',
          xValueMapper: (DistanceValue elevation, _) => elevation.distance,
          yValueMapper: (DistanceValue elevation, _) => elevation.value,
          dataLabelSettings: const DataLabelSettings(isVisible: false),
          enableTooltip: false,
          markerSettings: const MarkerSettings(isVisible: false)),
      SplineSeries<DistanceValue, num>(
          animationDuration: 1500,
          dataSource: wattsData,
          xValueMapper: (DistanceValue watts, _) => watts.distance,
          yValueMapper: (DistanceValue watts, _) => watts.value / 10,
          width: 1,
          opacity: 0.8,
          color: zdvMidBlue,
          name: 'Watts',
          dataLabelSettings: const DataLabelSettings(isVisible: false),
          enableTooltip: false,
          markerSettings: const MarkerSettings(isVisible: false)),
      SplineSeries<DistanceValue, num>(
          animationDuration: 1500,
          dataSource: heartrateData,
          width: 1,
          opacity: 0.8,
          color: zdvRed,
          name: 'Heart Rate',
          xValueMapper: (DistanceValue heartrate, _) => heartrate.distance,
          yValueMapper: (DistanceValue heartrate, _) => heartrate.value,
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

class DistanceValue {
  final double distance;
  final double value;

  DistanceValue(this.distance, this.value);
}
