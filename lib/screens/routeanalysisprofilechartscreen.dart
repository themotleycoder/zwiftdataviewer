import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zwiftdataviewer/models/ActivityDetailDataModel.dart';
import 'package:zwiftdataviewer/models/StreamsDataModel.dart';
import 'package:zwiftdataviewer/stravalib/API/streams.dart';
import 'package:zwiftdataviewer/utils/conversions.dart';
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/widgets/ListItemViews.dart';

import '../appkeys.dart';

class RouteAnalysisProfileChartScreen extends StatelessWidget {
  const RouteAnalysisProfileChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ActivityDetailDataModel>(
        builder: (context, myModel, child) {
      return Consumer<StreamsDataModel>(builder: (context, myModel, child) {
        return ChangeNotifierProvider<SelectedStreamObjectModel>(
            create: (_) => SelectedStreamObjectModel(),
            child: Selector<StreamsDataModel, bool>(
                selector: (context, model) => model.isLoading,
                builder: (context, isLoading, _) {
                  if (isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        key: AppKeys.activitiesLoading,
                      ),
                    );
                  }
                  return Column(children: const [
                    Expanded(
                      child: DisplayChart(),
                    ),
                    ProfileDataView(),
                  ]);
                  // ]);
                }));
      });
    });
  }
}

class DisplayChart extends StatelessWidget {
  const DisplayChart({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, String> units = Conversions.units(context);
    var combinedStreams =
        Provider.of<StreamsDataModel>(context).combinedStreams;
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
      series: _createDataSet(context, combinedStreams),
      onTrackballPositionChanging: (TrackballArgs args) =>
          onTBSelectionChanged(context, args),
    );
  }

  List<XyDataSeries<DistanceValue, num>> _createDataSet(
      BuildContext context, StreamsDetailCollection? combinedStreams) {
    final List<DistanceValue> elevationData = [];
    final List<DistanceValue> heartrateData = [];
    final List<DistanceValue> wattsData = [];
    // final List<DistanceValue> cadenceData = [];
    // final List<DistanceValue> gradeData = [];
    // SegmentEffort segment;
    double distance = 0.0;
    CombinedStreams? col;
    final int length = combinedStreams?.stream!.length ?? 0;
    for (int x = 0; x < length; x++) {
      col = combinedStreams?.stream![x];
      distance = Conversions.metersToDistance(context, col!.distance);
      var h = Conversions.metersToHeight(context, col.altitude);
      elevationData.add(DistanceValue(distance, h.toDouble()));
      heartrateData.add(DistanceValue(distance, col.heartrate.toDouble()));
      wattsData.add(DistanceValue(distance, col.watts.toDouble()));

      // cadenceData.add(DistanceValue(distance, col.cadence.toDouble()));
      // gradeData.add(DistanceValue(distance, col.gradeSmooth.toDouble()));
    }

    return <XyDataSeries<DistanceValue, num>>[
      SplineAreaSeries<DistanceValue, num>(
          animationDuration: 1500,
          dataSource: elevationData!,
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
          dataSource: wattsData!,
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
          dataSource: heartrateData!,
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

  onTBSelectionChanged(BuildContext context, TrackballArgs args) {
    var dataPointIndex = args.chartPointInfo.dataPointIndex;
    var combinedStreams =
        Provider.of<StreamsDataModel>(context, listen: false).combinedStreams;
    var combinedStream = combinedStreams?.stream![dataPointIndex!];
    Provider.of<SelectedStreamObjectModel>(context, listen: false)
        .setSelectedCombinedStream(combinedStream);
  }
}

class ProfileDataView extends StatelessWidget {
  const ProfileDataView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SelectedStreamObjectModel>(
        builder: (context, selectedCombinedStream, child) {
      final selectedSeries = selectedCombinedStream.selectedCombinedStreams;
      Map<String, String> units = Conversions.units(context);
      return Expanded(
          flex: 1,
          child: Container(
              // top: 100,
              margin: const EdgeInsets.fromLTRB(0, 16, 0, 0),
              child: ListView(
                  // padding: const EdgeInsets.all(8.0),
                  children: <Widget>[
                    doubleDataHeaderLineItem(
                      [
                        'Distance (${units['distance']!})',
                        'Elevation (${units['height']!})'
                      ],
                      [
                        Conversions.metersToDistance(
                                context, selectedSeries?.distance ?? 0)
                            .toStringAsFixed(1),
                        Conversions.metersToHeight(
                                context, selectedSeries?.altitude ?? 0)
                            .toStringAsFixed(0)
                      ],
                    ),
                    doubleDataHeaderLineItem(
                      ['Heartrate (bpm)', 'Power(w)'],
                      [
                        (selectedSeries?.heartrate ?? 0).toString(),
                        (selectedSeries?.watts ?? 0).toString()
                      ],
                    ),
                    doubleDataHeaderLineItem(
                      ['Cadence (rpm)', 'Grade (%)'],
                      [
                        (selectedSeries?.cadence ?? 0).toString(),
                        (selectedSeries?.gradeSmooth ?? 0).toString()
                      ],
                    )
                  ])));
    });
  }
}

class SelectedStreamObjectModel extends ChangeNotifier {
  CombinedStreams? _combinedStreamsObject;

  CombinedStreams? get selectedCombinedStreams => _combinedStreamsObject;

  void setSelectedCombinedStream(CombinedStreams? combinedStreamsObject) {
    _combinedStreamsObject = combinedStreamsObject;
    notifyListeners();
  }
}

class DistanceValue {
  final double distance;
  final double value;

  DistanceValue(this.distance, this.value);
}
