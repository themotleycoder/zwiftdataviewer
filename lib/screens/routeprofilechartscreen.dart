import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zwiftdataviewer/models/ActivityDetailDataModel.dart';
import 'package:zwiftdataviewer/utils/conversions.dart';
import 'package:zwiftdataviewer/models/StreamsDataModel.dart';
import 'package:zwiftdataviewer/screens/ridedetailscreen.dart';
import 'package:zwiftdataviewer/stravalib/API/streams.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:zwiftdataviewer/widgets/ListItemViews.dart';
import 'package:fl_chart/fl_chart.dart';
import '../appkeys.dart';

class RouteProfileChartScreen extends StatefulWidget {
  RouteProfileChartScreen();

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
      _streamsDetail = myModel.combinedStreams == null
          ? StreamsDetailCollection()
          : myModel.combinedStreams;
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
                  ],
                  defaultRenderer:
                      charts.LineRendererConfig(includeArea: false),
                  animate: true,
                  primaryMeasureAxis: const charts.NumericAxisSpec(
                      tickProviderSpec:
                          charts.StaticNumericTickProviderSpec(
                    // Create the ticks to be used the domain axis.
                    <charts.TickSpec<num>>[
                      charts.TickSpec(0, label: ''),
                      charts.TickSpec(1, label: ''),
                      charts.TickSpec(2, label: ''),
                      charts.TickSpec(3, label: ''),
                      charts.TickSpec(4, label: ''),
                    ],
                  )),
                  disjointMeasureAxes:
                      LinkedHashMap<String, charts.NumericAxisSpec>.from({
                    'axis 1': const charts.NumericAxisSpec(),
                    'axis 2': const charts.NumericAxisSpec(),
                    'axis 3': const charts.NumericAxisSpec(),
                    'axis 4': const charts.NumericAxisSpec(),
                  }),
                  selectionModels: [
                    charts.SelectionModelConfig(
                      type: charts.SelectionModelType.info,
                      changedListener: _onSelectionChanged,
                    )
                  ],
                  behaviors: [
                    // new charts.InitialSelection(selectedDataConfig: [
                    // new charts.SeriesDatumConfig<String>('Elevation', '0')
                    // ])
                    charts.LinePointHighlighter(
                        showHorizontalFollowLine:
                            charts.LinePointHighlighterFollowLineType.none,
                        showVerticalFollowLine:
                            charts.LinePointHighlighterFollowLineType.nearest),
                    charts.SelectNearest(
                        eventTrigger: charts.SelectionTrigger.tapAndDrag)
                  ],
                )),
                // LineChartSample1(createNewDataSet(myModel)),
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
      distance = col.distance;
      elevationData.add(DistanceValue(distance, col.altitude));
      heartrateData.add(DistanceValue(distance, col.heartrate.toDouble()));
      wattsData.add(DistanceValue(distance, col.watts.toDouble()));
      cadenceData.add(DistanceValue(distance, col.cadence.toDouble()));
      gradeData.add(DistanceValue(distance, col.gradeSmooth.toDouble()));
    }

    return [
      charts.Series<DistanceValue, double>(
        id: 'Elevation',
        // colorFn specifies that the line will be blue.
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,//gray.shade300,.gray.shade300,
        // areaColorFn specifies that the area skirt will be light blue.
        areaColorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,//gray.shade300,
        domainFn: (DistanceValue elevation, _) => elevation.distance,
        measureFn: (DistanceValue elevation, _) => elevation.value,
        data: elevationData,
      )..setAttribute(charts.rendererIdKey, 'customArea'),
      charts.Series<DistanceValue, double>(
        id: 'Heartrate',
        // colorFn specifies that the line will be blue.
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        // areaColorFn specifies that the area skirt will be light blue.
        domainFn: (DistanceValue heartrate, _) => heartrate.distance,
        measureFn: (DistanceValue heartrate, _) => heartrate.value,
        data: heartrateData,
      )..setAttribute(charts.rendererIdKey, 'customArea2'),
      // new charts.Series<DistanceValue, double>(
      //   id: 'Watts',
      //   // colorFn specifies that the line will be blue.
      //   colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
      //   // areaColorFn specifies that the area skirt will be light blue.
      //   domainFn: (DistanceValue watts, _) => watts.distance,
      //   measureFn: (DistanceValue watts, _) => watts.value,
      //   data: wattsData,
      // )..setAttribute(charts.rendererIdKey, 'customArea2'),
      charts.Series<DistanceValue, double>(
        id: 'Cadence',
        // colorFn specifies that the line will be blue.
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        // areaColorFn specifies that the area skirt will be light blue.
        domainFn: (DistanceValue cadence, _) => cadence.distance,
        measureFn: (DistanceValue cadence, _) => cadence.value,
        data: cadenceData,
      )..setAttribute(charts.rendererIdKey, 'customArea2'),
    ];
  }

  Map<String, List<FlSpot>> createNewDataSet(StreamsDataModel streamsDetail) {
    final List<DistanceValue> elevationData = [];
    final List<DistanceValue> heartrateData = [];
    final List<DistanceValue> wattsData = [];
    final List<DistanceValue> cadenceData = [];
    final List<DistanceValue> gradeData = [];
    // SegmentEffort segment;
    double distance = 0.0;
    CombinedStreams col;
    final int length = _streamsDetail?.stream?.length ?? 0;

    Map<String, List<FlSpot>> retVal = {};
    List<FlSpot> flElevationData = [];
    List<FlSpot> flHeartRateData = [];
    List<FlSpot> flWattsData = [];
    List<FlSpot> flCadenceData = [];
    List<FlSpot> flGradeData = [];

    for (int x = 0; x < length; x++) {
      col = _streamsDetail!.stream![x];
      distance = col.distance;
      elevationData.add(DistanceValue(distance, col.altitude));
      heartrateData.add(DistanceValue(distance, col.heartrate.toDouble()));
      wattsData.add(DistanceValue(distance, col.watts.toDouble()));
      cadenceData.add(DistanceValue(distance, col.cadence.toDouble()));
      gradeData.add(DistanceValue(distance, col.gradeSmooth.toDouble()));

      flElevationData.add(FlSpot(distance, col.altitude));
      flHeartRateData.add(FlSpot(distance, col.heartrate.toDouble()));
      flWattsData.add(FlSpot(distance, col.watts.toDouble()));
      flCadenceData.add(FlSpot(distance, col.cadence.toDouble()));
      flGradeData.add(FlSpot(distance, col.gradeSmooth.toDouble()));
    }

    //distance, alt
    // for (int x = 0; x < elevationData.length; x++) {
    //   flElevationData
    //       .add(new FlSpot(elevationData[x].distance, elevationData[x].value));
    //   flHeartRateData
    //       .add(new FlSpot(heartrateData[x].distance, heartrateData[x].value));
    //   flWattsData.add(new FlSpot(wattsData[x].distance, wattsData[x].value));
    // }

    retVal['alt'] = flElevationData;
    retVal['heart'] = flHeartRateData;
    retVal['watts'] = flWattsData;
    retVal['cadence'] = flCadenceData;
    retVal['grade'] = flGradeData;

    return retVal;
  }
}

class ProfileDataView extends StatefulWidget {
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
        child: GridView.count(
          primary: false,
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: MediaQuery.of(context).size.height / 300,
          crossAxisCount: 2,
          children: <Widget>[
            gridViewItem(
                '',
                'Distance',
                Conversions.metersToDistance(
                        context, selectedSeries?.distance ?? 0)
                    .toStringAsFixed(2),
                units['distance']!),
            gridViewItem(
                '',
                'Elevation',
                Conversions.metersToHeight(
                        context, selectedSeries?.altitude ?? 0)
                    .toStringAsFixed(0),
                units['height']!),
            gridViewItem('', 'Heartrate',
                (selectedSeries?.heartrate ?? 0).toString(), 'bpm'),
            gridViewItem(
                '', 'Power', (selectedSeries?.watts ?? 0).toString(), 'w'),
            gridViewItem('', 'Cadence',
                (selectedSeries?.cadence ?? 0).toString(), 'rpm'),
            gridViewItem('', 'Grade',
                (selectedSeries?.gradeSmooth ?? 0).toString(), '%'),
          ],
        ),
      );
    });
  }
}

// class LineChartSample1 extends StatefulWidget {
//   final Map<String, List<FlSpot>> dataSet;

//   LineChartSample1(this.dataSet);

//   @override
//   State<StatefulWidget> createState() => LineChartSample1State(dataSet);
// }

// class LineChartSample1State extends State<LineChartSample1> {
//   bool isShowingMainData;
//   final Map<String, List<FlSpot>> spotDataSet;

//   LineChartSample1State(this.spotDataSet);

//   @override
//   void initState() {
//     super.initState();
//     isShowingMainData = true;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AspectRatio(
//       aspectRatio: 1.23,
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: const BorderRadius.all(Radius.circular(18)),
//           // gradient: LinearGradient(
//           //   begin: Alignment.bottomCenter,
//           //   end: Alignment.topCenter,
//           //   colors: [
//           //     const Color(0xff2c274c),
//           //     const Color(0xff46426c),
//           //   ],

//           // ),
//         ),
//         child: Stack(
//           children: <Widget>[
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: <Widget>[
//                 // const SizedBox(
//                 //   height: 37,
//                 // ),
//                 // const Text(
//                 //   'Unfold Shop 2018',
//                 //   style: TextStyle(
//                 //     color: Color(0xff827daa),
//                 //     fontSize: 16,
//                 //   ),
//                 //   textAlign: TextAlign.center,
//                 // ),
//                 // const SizedBox(
//                 //   height: 4,
//                 // ),
//                 // const Text(
//                 //   'Monthly Sales',
//                 //   style: TextStyle(
//                 //       color: Colors.white,
//                 //       fontSize: 32,
//                 //       fontWeight: FontWeight.bold,
//                 //       letterSpacing: 2),
//                 //   textAlign: TextAlign.center,
//                 // ),
//                 const SizedBox(
//                   height: 37,
//                 ),
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.only(right: 16.0, left: 6.0),
//                     child: LineChart(
//                       isShowingMainData ? sampleData2() : sampleData2(),
//                       swapAnimationDuration: const Duration(milliseconds: 250),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 10,
//                 ),
//               ],
//             ),
//             IconButton(
//               icon: Icon(
//                 Icons.refresh,
//                 color: Colors.white.withOpacity(isShowingMainData ? 1.0 : 0.5),
//               ),
//               onPressed: () {
//                 setState(() {
//                   isShowingMainData = !isShowingMainData;
//                 });
//               },
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   LineChartData sampleData2() {
//     Map<String, String> units = Conversions.units(context);
//     return LineChartData(
//       lineTouchData: LineTouchData(
//           enabled: true,
//           handleBuiltInTouches: true,
//           // touchTooltipData: LineTouchTooltipData(
//           //   tooltipBgColor: Constants.zdvMidBlueGrey.withOpacity(0.8),
//           //   getTooltipItems: (List<LineBarSpot> list) {
//           //     List<LineTooltipItem> items = [];
//           //     String alt = Conversions.metersToHeight(context, list[1]?.y ?? 0)
//           //         .toStringAsFixed(0);
//           //     items.add(new LineTooltipItem(
//           //         "Al: " + alt + units['height'], new TextStyle()));
//           //     items.add(new LineTooltipItem("HR: " + alt, new TextStyle()));
//           //     items.add(new LineTooltipItem("Wt: " + alt, new TextStyle()));
//           //     items.add(new LineTooltipItem("Cd: " + alt, new TextStyle()));
//           //     items.add(new LineTooltipItem("Sl: " + alt, new TextStyle()));
//           //     return [];
//           //   },
//           // ),
//           touchCallback: (LineTouchResponse touchResponse) {
//             selectionChanged(touchResponse);
//           }),
//       gridData: FlGridData(
//         show: false,
//       ),
//       titlesData: FlTitlesData(
//         bottomTitles: SideTitles(
//           showTitles: true,
//           reservedSize: 22,
//           textStyle: const TextStyle(
//             color: Color(0xff72719b),
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//           ),
//           margin: 10,
//           getTitles: (value) {
//             switch (value.toInt()) {
//               case 0:
//                 return "0";
//               //   case 7:
//               //     return 'OCT';
//               //   case 12:
//               //     return 'DEC';
//             }
//             return "";
//           },
//         ),
//         leftTitles: SideTitles(
//           showTitles: false,
//           textStyle: const TextStyle(
//             color: Color(0xff75729e),
//             fontWeight: FontWeight.bold,
//             fontSize: 14,
//           ),
//           getTitles: (value) {
//             // switch (value.toInt()) {
//             //   case 1:
//             //     return '1m';
//             //   case 2:
//             //     return '2m';
//             //   case 3:
//             //     return '3m';
//             //   case 4:
//             //     return '5m';
//             //   case 5:
//             //     return '6m';
//             // }
//             return '';
//           },
//           margin: 8,
//           reservedSize: 30,
//         ),
//       ),
//       borderData: FlBorderData(
//           show: true,
//           border: const Border(
//             bottom: BorderSide(
//               color: Colors.black87,
//               width: 1,
//             ),
//             left: BorderSide(
//               color: Colors.black87,
//               width: 1,
//             ),
//             right: BorderSide(
//               color: Colors.black87,
//               width: 1,
//             ),
//             top: BorderSide(
//               color: Colors.transparent,
//             ),
//           )),
//       // minX: 0,
//       // maxX: dataSet['alt'][dataSet['alt'].length - 1].x,
//       // maxY: 350,
//       // minY: 0,
//       lineBarsData: linesBarData2(),
//     );
//   }

//   List<LineChartBarData> linesBarData2() {
//     return [
//       LineChartBarData(
//         spots: spotDataSet['heart'],
//         isCurved: false,
//         curveSmoothness: 0,
//         colors: const [
//           Color(0x99ff0000),
//         ],
//         barWidth: 2,
//         isStrokeCapRound: false,
//         dotData: FlDotData(
//           show: false,
//         ),
//         belowBarData: BarAreaData(
//           show: false,
//         ),
//       ),
//       LineChartBarData(
//         spots: spotDataSet['alt'],
//         isCurved: true,
//         colors: const [
//           Color(0x33111111),
//         ],
//         barWidth: 1,
//         isStrokeCapRound: true,
//         dotData: FlDotData(
//           show: false,
//         ),
//         belowBarData: BarAreaData(show: true, colors: [
//           const Color(0x33111111),
//         ]),
//       ),
//       LineChartBarData(
//         spots: spotDataSet['watts'],
//         isCurved: false,
//         curveSmoothness: 0,
//         colors: const [
//           Color(0x4427b6fc),
//         ],
//         barWidth: 2,
//         isStrokeCapRound: false,
//         dotData: FlDotData(show: false),
//         belowBarData: BarAreaData(
//           show: false,
//         ),
//       ),
//       LineChartBarData(
//         spots: spotDataSet['grade'],
//         isCurved: false,
//         curveSmoothness: 0,
//         colors: const [
//           Color(0x9900ff00),
//         ],
//         barWidth: 2,
//         isStrokeCapRound: false,
//         dotData: FlDotData(
//           show: false,
//         ),
//         belowBarData: BarAreaData(
//           show: false,
//         ),
//       ),
//       LineChartBarData(
//         spots: spotDataSet['cadence'],
//         isCurved: false,
//         curveSmoothness: 0,
//         colors: const [
//           Color(0x990000ff),
//         ],
//         barWidth: 2,
//         isStrokeCapRound: false,
//         dotData: FlDotData(
//           show: false,
//         ),
//         belowBarData: BarAreaData(
//           show: false,
//         ),
//       ),
//     ];
//   }

//   selectionChanged(LineTouchResponse touchResponse) {
//     List lineBarSpots = touchResponse.lineBarSpots;
//     LineBarSpot heart = lineBarSpots[0];
//     int index = heart.spotIndex;

//     LineBarSpot alt = lineBarSpots[1];
//     LineBarSpot watts = lineBarSpots[2];
//     int time = 0;
//     LineBarSpot gradeSmooth = lineBarSpots[3];
//     LineBarSpot cadence = lineBarSpots[4];
//     CombinedStreams stream = new CombinedStreams(alt.x, time, alt.y,
//         heart.y.round(), cadence.y.round(), watts.y.round(), gradeSmooth.y);
//     Provider.of<ActivitySelectDataModel>(context, listen: false)
//         .setSelectedSeries(stream);
//   }
// }
