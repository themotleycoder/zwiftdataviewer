import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zwiftdataviewer/models/ActivityDetailDataModel.dart';
import 'package:zwiftdataviewer/models/StreamsDataModel.dart';
import 'package:zwiftdataviewer/stravalib/API/streams.dart';
import 'package:zwiftdataviewer/stravalib/Models/activity.dart';
import 'package:zwiftdataviewer/utils/conversions.dart';
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/widgets/ListItemViews.dart';

import '../appkeys.dart';

class RouteAnalysisProfileChartScreen extends StatefulWidget {
  const RouteAnalysisProfileChartScreen({super.key});

  @override
  _RouteAnalysisProfileChartScreenState createState() =>
      _RouteAnalysisProfileChartScreenState();
}

class _RouteAnalysisProfileChartScreenState
    extends State<RouteAnalysisProfileChartScreen> {
  List<charts.Series<DistanceValue, double>> _chartData = [];
  StreamsDetailCollection? _streamsDetail;
  CombinedStreams? selectionModel;

  @override
  Widget build(BuildContext context) {
    return Consumer<StreamsDataModel>(builder: (context, myModel, child) {
      _streamsDetail = myModel.combinedStreams ?? StreamsDetailCollection();
      // _chartData = createDataSet(myModel);
      return Selector<StreamsDataModel, bool>(
          selector: (context, model) => model.isLoading,
          builder: (context, isLoading, _) {
            if (isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  key: AppKeys.activitiesLoading,
                ),
              );
            }
            return Column(children: [
              Expanded(
                child: _buildLineChart(myModel),
              ),
              const ProfileDataView(),
            ]);
            // ]);
          });
    });
  }

  _buildLineChart(StreamsDataModel streamsDataModel) {
    final List<XyDataSeries<DistanceValue, num>> dataSet =
        createDataSet(streamsDataModel);
    return SfCartesianChart(
        onTrackballPositionChanging: (TrackballArgs args) {
          CombinedStreams streamObj = _streamsDetail!.stream![args.chartPointInfo.seriesIndex!];
          Provider.of<ActivitySelectDataModel>(context, listen: false)
              .setSelectedSeries(streamObj);
        },
      plotAreaBorderWidth: 0,
      // title: ChartTitle(text: isCardView ? '' : 'Inflation - Consumer price'),
      legend: Legend(
          isVisible: true,
          overflowMode: LegendItemOverflowMode.wrap,
          position: LegendPosition.top),
      primaryXAxis: NumericAxis(
          // intervalType: DateTimeIntervalType.minutes,
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          interval: 2,
          majorGridLines: const MajorGridLines(width: 0)),
      primaryYAxis: NumericAxis(
          labelFormat: ' ',
          axisLine: const AxisLine(width: 0),
          majorTickLines: const MajorTickLines(color: Colors.transparent)),
      series: dataSet,
      tooltipBehavior: TooltipBehavior(enable: true),
      trackballBehavior: TrackballBehavior(
        enable: true,
        markerSettings: TrackballMarkerSettings(
          markerVisibility: true
              ? TrackballVisibilityMode.visible
              : TrackballVisibilityMode.hidden,
          height: 10,
          width: 10,
          borderWidth: 1,
        ),
        hideDelay: 3 * 1000,
        activationMode: ActivationMode.singleTap,
        shouldAlwaysShow: true,
      ),
    );
  }

  _onSelectionChanged(SelectionArgs model) {

  }

  List<XyDataSeries<DistanceValue, num>> createDataSet(
      StreamsDataModel streamsDetail) {
    final List<DistanceValue> elevationData = [];
    final List<DistanceValue> heartrateData = [];
    final List<DistanceValue> wattsData = [];
    // final List<DistanceValue> cadenceData = [];
    // final List<DistanceValue> gradeData = [];
    // SegmentEffort segment;
    double distance = 0.0;
    CombinedStreams col;
    final int length = _streamsDetail?.stream?.length ?? 0;
    for (int x = 0; x < length; x++) {
      col = _streamsDetail!.stream![x];
      distance = Conversions.metersToDistance(context, col.distance);
      elevationData.add(DistanceValue(distance, col.altitude));
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
          markerSettings: const MarkerSettings(isVisible: false)),
    ];
  }
}

class ProfileDataView extends StatefulWidget {
  const ProfileDataView({super.key});

  @override
  _ProfileDataViewState createState() => _ProfileDataViewState();
}

class _ProfileDataViewState extends State<ProfileDataView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ActivitySelectDataModel>(
        builder: (context, myModel, child) {
      CombinedStreams? selectedSeries = myModel.selectedStream;
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

class DistanceValue {
  final double distance;
  final double value;

  DistanceValue(this.distance, this.value);
}
