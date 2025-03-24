import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/api/streams.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/providers/activity_select_provider.dart';
import 'package:zwiftdataviewer/providers/combinedstream_select_provider.dart';
import 'package:zwiftdataviewer/providers/streams_provider.dart';
import 'package:zwiftdataviewer/screens/layouts/routeanalysistablayout.dart';
import 'package:zwiftdataviewer/utils/conversions.dart';
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/utils/ui_helpers.dart';
import 'package:zwiftdataviewer/widgets/iconitemwidgets.dart';

/// A screen that displays the elevation profile chart for a route.
///
/// This screen shows a chart with elevation, heart rate, and power data
/// plotted against distance.
class RouteAnalysisProfileChartScreen extends RouteAnalysisTabLayout {
  /// Creates a RouteAnalysisProfileChartScreen instance.
  ///
  /// @param key An optional key for this widget
  const RouteAnalysisProfileChartScreen({super.key});

  @override
  ConsumerWidget buildChart() {
    return const DisplayChart();
  }

  @override
  buildChartDataView() {
    return const ProfileDataView();
  }
}

/// A widget that displays a chart with elevation, heart rate, and power data.
///
/// This widget fetches stream data for the selected activity and displays
/// it in a chart with multiple series.
class DisplayChart extends ConsumerWidget {
  /// Creates a DisplayChart instance.
  ///
  /// @param key An optional key for this widget
  const DisplayChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Map<String, String> units = Conversions.units(ref);
    final activityId = ref.watch(selectedActivityProvider).id;
    
    // Trigger loading of streams data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(streamsProvider(activityId));
    });

    final AsyncValue<StreamsDetailCollection> streamsData =
        ref.watch(streamsProvider(activityId));

    return Expanded(
      child: SizedBox(
        height: 300, // Ensure the chart has a fixed height
        child: streamsData.when(
          data: (streams) {
            if (streams.streams == null || streams.streams!.isEmpty) {
              return Center(
                child: UIHelpers.buildEmptyStateWidget(
                  'No stream data available for this activity',
                  icon: Icons.show_chart,
                ),
              );
            }
            
            return SfCartesianChart(
              tooltipBehavior: null,
              plotAreaBorderWidth: 0,
              legend: const Legend(
                isVisible: true,
                overflowMode: LegendItemOverflowMode.wrap,
                position: LegendPosition.top,
              ),
              primaryXAxis: NumericAxis(
                title: AxisTitle(text: 'Distance (${units['distance']!})'),
                majorGridLines: const MajorGridLines(width: 0),
                minimum: 0,
              ),
              primaryYAxis: NumericAxis(
                labelFormat: ' ',
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(color: Colors.transparent),
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
              series: _createDataSet(ref, streams.streams ?? []),
              onTrackballPositionChanging: (TrackballArgs args) {
                final dataPointIndex = args.chartPointInfo.dataPointIndex ?? 0;
                if (streams.streams != null && 
                    dataPointIndex >= 0 && 
                    dataPointIndex < streams.streams!.length) {
                  var combinedStreams = streams.streams![dataPointIndex];
                  ref
                      .read(combinedStreamSelectNotifier.notifier)
                      .selectStream(combinedStreams);
                }
              },
            );
          }, 
          error: (Object error, StackTrace stackTrace) {
            debugPrint('Error loading streams data: $error');
            return UIHelpers.buildErrorWidget(
              'Failed to load activity stream data',
              () => ref.refresh(streamsProvider(activityId)),
            );
          }, 
          loading: () {
            return UIHelpers.buildLoadingIndicator(
              key: AppKeys.activitiesLoading,
            );
          },
        ),
      ),
    );
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
          yValueMapper: (DistanceValue heartrate, _) => heartrate.value * 5,
          dataLabelSettings: const DataLabelSettings(isVisible: false),
          enableTooltip: false,
          markerSettings: const MarkerSettings(isVisible: false)),
    ];
  }
}

/// A widget that displays detailed metrics for the selected point on the chart.
///
/// This widget shows distance, elevation, heart rate, power, cadence, and grade
/// data for the point selected on the chart.
class ProfileDataView extends ConsumerWidget {
  /// Creates a ProfileDataView instance.
  ///
  /// @param key An optional key for this widget
  const ProfileDataView({super.key});

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
