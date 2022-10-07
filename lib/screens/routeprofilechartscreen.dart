import 'dart:collection';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zwiftdataviewer/models/ActivityDetailDataModel.dart';
import 'package:zwiftdataviewer/models/StreamsDataModel.dart';
import 'package:zwiftdataviewer/screens/ridedetailscreen.dart';
import 'package:zwiftdataviewer/stravalib/API/streams.dart';
import 'package:zwiftdataviewer/utils/conversions.dart';
import 'package:zwiftdataviewer/widgets/ListItemViews.dart';
import 'package:zwiftdataviewer/utils/theme.dart';
import '../appkeys.dart';

class RouteProfileChartScreen extends StatefulWidget {
  const RouteProfileChartScreen({super.key});

  @override
  _RouteProfileChartScreenState createState() =>
      _RouteProfileChartScreenState();
}

class _RouteProfileChartScreenState extends State<RouteProfileChartScreen> {
  List<charts.Series<DistanceValue, double>> _chartData = [];
  StreamsDetailCollection? _streamsDetail;
  CombinedStreams? selectionModel;

  @override
  Widget build(BuildContext context) {
    return Consumer<StreamsDataModel>(builder: (context, myModel, child) {
      _streamsDetail = myModel.combinedStreams ?? StreamsDetailCollection();
      _chartData = createDataSet(myModel);
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
            return Container(
              // height: 200.0,
              // child: Card(
              //     elevation: 0,
              //     margin: EdgeInsets.all(8.0),
              child: Column(children: [
                Expanded(
                    child: charts.LineChart(
                  _chartData,
                  customSeriesRenderers: [
                    charts.LineRendererConfig(
                        // ID used to link series to this renderer.
                        customRendererId: 'customArea',
                        includeArea: true,
                        stacked: true),
                    charts.LineRendererConfig(
                        // ID used to link series to this renderer.
                        customRendererId: 'customArea2',
                        includeArea: false,
                        stacked: true),
                    charts.LineRendererConfig(
                        // ID used to link series to this renderer.
                        customRendererId: 'customArea3',
                        includeArea: false,
                        stacked: true),
                  ],
                  defaultRenderer:
                      charts.LineRendererConfig(includeArea: false),
                  animate: true,
                  // primaryMeasureAxis: const charts.NumericAxisSpec(
                  //   tickProviderSpec: charts.BasicNumericTickProviderSpec(
                  //       desiredTickCount: 5),
                  // ),
                  // secondaryMeasureAxis: const charts.NumericAxisSpec(
                  //   tickProviderSpec: charts.BasicNumericTickProviderSpec(
                  //       desiredTickCount: 5),
                  // ),
                  // disjointMeasureAxes:
                  //     LinkedHashMap<String, charts.NumericAxisSpec>.from({
                  //   'axis 1': const charts.NumericAxisSpec(),
                  //   'axis 2': const charts.NumericAxisSpec(),
                  //   'axis 3': const charts.NumericAxisSpec(),
                  //   // 'axis 4': const charts.NumericAxisSpec(),
                  // }),
                  selectionModels: [
                    charts.SelectionModelConfig(
                      type: charts.SelectionModelType.info,
                      changedListener: _onSelectionChanged,
                    )
                  ],
                  behaviors: [
                    charts.LinePointHighlighter(
                        showHorizontalFollowLine:
                            charts.LinePointHighlighterFollowLineType.none,
                        showVerticalFollowLine:
                            charts.LinePointHighlighterFollowLineType.nearest),
                    charts.SelectNearest(
                        eventTrigger: charts.SelectionTrigger.tapAndDrag)
                  ],
                )),
                ProfileDataView(),
              ]),
            );
          });
    });
  }

  _onSelectionChanged(charts.SelectionModel model) {
    int? selection = model.selectedDatum[0].index;
    CombinedStreams stream = _streamsDetail!.stream![selection!];
    // Provider.of<StreamsDataModel>(context, listen: false)
    //     .setSelectedSeries(stream);
    Provider.of<ActivitySelectDataModel>(context, listen: false)
        .setSelectedSeries(stream);
  }

  List<charts.Series<DistanceValue, double>> createDataSet(
      StreamsDataModel streamsDetail) {
    final List<DistanceValue> elevationData = [];
    final List<DistanceValue> heartrateData = [];
    final List<DistanceValue> wattsData = [];
    final List<DistanceValue> cadenceData = [];
    final List<DistanceValue> gradeData = [];
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
      cadenceData.add(DistanceValue(distance, col.cadence.toDouble()));
      gradeData.add(DistanceValue(distance, col.gradeSmooth.toDouble()));
    }

    return [
      charts.Series<DistanceValue, double>(
        id: 'Watts',
        seriesColor: charts.ColorUtil.fromDartColor(zdvMidBlue),
        domainFn: (DistanceValue watts, _) => watts.distance,
        measureFn: (DistanceValue watts, _) => watts.value,
        data: wattsData,
      ),
      // ..setAttribute(charts.rendererIdKey, 'customArea'),
      charts.Series<DistanceValue, double>(
        id: 'Elevation',
        seriesColor: charts.ColorUtil.fromDartColor(zdvMidGreen),
        areaColorFn: (_, __) => charts.ColorUtil.fromDartColor(zdvMidGreen),
        domainFn: (DistanceValue elevation, _) => elevation.distance,
        measureFn: (DistanceValue elevation, _) => elevation.value,
        data: elevationData,
      )..setAttribute(charts.rendererIdKey, 'customArea'),
      charts.Series<DistanceValue, double>(
        id: 'Heartrate',
        //colorFn: (_, __) => charts.ColorUtil.fromDartColor(zdvmOrange),//,
        seriesColor: charts.ColorUtil.fromDartColor(zdvOrange),//
        domainFn: (DistanceValue heartrate, _) => heartrate.distance,
        measureFn: (DistanceValue heartrate, _) => heartrate.value,
        data: heartrateData,
      ),
      // ..setAttribute(charts.rendererIdKey, 'customArea2'),
      // charts.Series<DistanceValue, double>(
      //   id: 'Cadence',
      //   // colorFn specifies that the line will be blue.
      //   colorFn: (_, __) => charts.MaterialPalette.deepOrange.shadeDefault,
      //   // areaColorFn specifies that the area skirt will be light blue.
      //   domainFn: (DistanceValue cadence, _) => cadence.distance,
      //   measureFn: (DistanceValue cadence, _) => cadence.value,
      //   data: cadenceData,
      // )
      // )..setAttribute(charts.rendererIdKey, 'customArea3'),
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
                        'Elevation (' + units['height']! + ')'
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
      //   Expanded(
      //   flex: 1,
      //   child: GridView.count(
      //     primary: false,
      //     padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      //     crossAxisSpacing: 8,
      //     mainAxisSpacing: 8,
      //     childAspectRatio: MediaQuery.of(context).size.height / 300,
      //     crossAxisCount: 2,
      //     children: <Widget>[
      //       gridViewItem(
      //           '',
      //           'Distance',
      //           Conversions.metersToDistance(
      //                   context, selectedSeries?.distance ?? 0)
      //               .toStringAsFixed(2),
      //           units['distance']!),
      //       gridViewItem(
      //           '',
      //           'Elevation',
      //           Conversions.metersToHeight(
      //                   context, selectedSeries?.altitude ?? 0)
      //               .toStringAsFixed(0),
      //           units['height']!),
      //       gridViewItem('', 'Heartrate',
      //           (selectedSeries?.heartrate ?? 0).toString(), 'bpm'),
      //       gridViewItem(
      //           '', 'Power', (selectedSeries?.watts ?? 0).toString(), 'w'),
      //       gridViewItem('', 'Cadence',
      //           (selectedSeries?.cadence ?? 0).toString(), 'rpm'),
      //       gridViewItem('', 'Grade',
      //           (selectedSeries?.gradeSmooth ?? 0).toString(), '%'),
      //     ],
      //   ),
      // );
    });
  }
}
