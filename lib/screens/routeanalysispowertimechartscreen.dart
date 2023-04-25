import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../models/ActivityDetailDataModel.dart';
import '../models/ConfigDataModel.dart';
import '../stravalib/API/streams.dart';
import '../stravalib/Models/activity.dart';
import '../utils/conversions.dart';
import '../utils/theme.dart';
import '../widgets/shortdataanalysis.dart';

class TimeDataView extends StatefulWidget {
  const TimeDataView({super.key});

  @override
  _TimeDataView createState() => _TimeDataView();
}

class _TimeDataView extends State<TimeDataView> {
  List<Laps>? _laps;
  late Laps selectedLap;
  int _ftp = 0;
  List<LapSummaryObject> data = [];

  void onSelectionChanged(SelectionArgs args) {
    // You can access the selected segment index, selected series index, and selected data point.
    final int selectedIndex = args.pointIndex;
    final int selectedSeriesIndex = args.pointIndex;
    // if (data.length>0){
    //   final LapSummaryObject selectedData = data[selectedIndex];
    //   Provider.of<LapSummaryDataModel>(context, listen: false)
    //       .setSummaryModel(selectedData);
    // }
    // final TimeTotals selectedData = args.series.dataSource[selectedIndex];

    // Call your function and pass the required data.
    // myFunction(selectedData);
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> units = Conversions.units(context);
    _ftp =
        Provider.of<ConfigDataModel>(context, listen: false).configData?.ftp ??
            0;

    return Consumer<ActivityDetailDataModel>(
        builder: (context, myModel, child) {
          _laps = myModel.activityDetail?.laps;
          // selectedLap = _laps![0];
          //final List<charts.Series<dynamic, int>> seriesList2 =
          //_createSampleData(context, units, _laps!);
          return
            Column(children: [
            Expanded(
                  child: _buildDefaultPieChart(context, units, _laps!)
                  // charts.PieChart(
                  //   seriesList2,
                  //   animate: true,
                  //   // behaviors: [
                  //   //   // charts.InitialSelection(selectedDataConfig: [
                  //   //   //   charts.SeriesDatumConfig<String>('power', '1')
                  //   //   // ])
                  //   // ],
                  // )
            ),
              PowerTimeProfileDataView()
            ]);
        });
  }


  SfCircularChart _buildDefaultPieChart(BuildContext? context, Map<String, String> units, List<Laps> laps) {
    return SfCircularChart(
      // title: ChartTitle(text: 'test'),
      //legend: Legend(isVisible: true),
      // onSelectionChanged: (SelectionArgs args) =>
      //     onSelectionChanged(args),
      series: _createSampleData(context, units, _laps!),
    );
  }

  // List<PieSeries<ChartSampleData, String>> _getDefaultPieSeries() {
  //   return <PieSeries<ChartSampleData, String>>[
  //     PieSeries<ChartSampleData, String>(
  //         explode: true,
  //         explodeIndex: 0,
  //         explodeOffset: '10%',
  //         dataSource: <ChartSampleData>[
  //           ChartSampleData(x: 'David', y: 13, text: 'David \n 13%'),
  //           ChartSampleData(x: 'Steve', y: 24, text: 'Steve \n 24%'),
  //           ChartSampleData(x: 'Jack', y: 25, text: 'Jack \n 25%'),
  //           ChartSampleData(x: 'Others', y: 38, text: 'Others \n 38%'),
  //         ],
  //         xValueMapper: (ChartSampleData data, _) => data.x as String,
  //         yValueMapper: (ChartSampleData data, _) => data.y,
  //         dataLabelMapper: (ChartSampleData data, _) => data.text,
  //         startAngle: 90,
  //         endAngle: 90,
  //         dataLabelSettings: const DataLabelSettings(isVisible: true)),
  //   ];
  // }

  List<PieSeries<LapSummaryObject, int>> _createSampleData(
      BuildContext? context, Map<String, String> units, List<Laps> laps) {
    final double ftp = _ftp.toDouble();

    data = [
      LapSummaryObject(1, 0.0, 0, 0.0, 0, 0, 0, _onColorSelect(1)),
      LapSummaryObject(2, 0.0, 0, 0.0, 0, 0, 0, _onColorSelect(2)),
      LapSummaryObject(3, 0.0, 0, 0.0, 0, 0, 0, _onColorSelect(3)),
      LapSummaryObject(4, 0.0, 0, 0.0, 0, 0, 0, _onColorSelect(4)),
      LapSummaryObject(5, 0.0, 0, 0.0, 0, 0, 0, _onColorSelect(5)),
      LapSummaryObject(6, 0.0, 0, 0.0, 0, 0, 0, _onColorSelect(6)),
    ];

    for (var lap in laps) {
      double watts = lap.averageWatts ?? 0;
      if (watts < ftp * .60) {
        data[0].time += lap.elapsedTime ?? 0;
        data[0].watts += watts;
      } else if (watts >= ftp * .60 && watts <= ftp * .75) {
        data[1].time += lap.elapsedTime ?? 0;
        data[1].watts += watts;
      } else if (watts > ftp * .75 && watts <= ftp * .89) {
        data[2].time += lap.elapsedTime ?? 0;
        data[2].watts += watts;
      } else if (watts > ftp * .89 && watts <= ftp * 1.04) {
        data[3].time += lap.elapsedTime ?? 0;
        data[3].watts += watts;
      } else if (watts > ftp * 1.04 && watts <= ftp * 1.18) {
        data[4].time += lap.elapsedTime ?? 0;
        data[4].watts += watts;
      } else if (watts > ftp * 1.18) {
        data[5].time += lap.elapsedTime ?? 0;
        data[5].watts += watts;
      } else {}
    }

    return [
      PieSeries<LapSummaryObject, int>(

          explode: true,
          explodeIndex: 0,
          explodeOffset: '10%',
          xValueMapper: (LapSummaryObject stats, _) => stats.lap,
          yValueMapper: (LapSummaryObject stats, _) => stats.time,
          pointColorMapper: (LapSummaryObject stats, _) => stats.color,
          dataSource: data,
          selectionBehavior: SelectionBehavior(
            enable: true,

          ),
        //_onColorSelect(TimeTotals totals),
        // onPointTap: (PointTapArgs args) {
        //   print(args.pointIndex);
        // },
        startAngle: 0,
        endAngle: 0,
    )
    ];
  }

  _onSelectionChanged(LapSummaryObject model) {
    // int? selection = model.selectedDatum[0].index ?? 0;
    // selectedLap = model.selectedSeries[0] as Laps;
    // selectedLap = _laps![selection];
    Provider.of<LapSummaryDataModel>(context, listen: false)
        .setSummaryModel(model);
  }

  Color _onColorSelect(idx){
    if (idx == 1) {
      return Colors.grey;
    } else if (idx == 2) {
      return zdvMidBlue;
    } else if (idx == 3) {
      return zdvMidGreen;
    } else if (idx == 4) {
      return zdvYellow;
    } else if (idx == 5) {
      return zdvOrange;
    } else if (idx == 6) {
      return zdvRed;
    } else {
      return Colors.grey;
    }
  }

}

class PowerTimeProfileDataView extends StatefulWidget {
  const PowerTimeProfileDataView({super.key});

  @override
  _PowerTimeProfileDataViewState createState() => _PowerTimeProfileDataViewState();
}

class _PowerTimeProfileDataViewState extends State<PowerTimeProfileDataView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<LapSummaryDataModel>(builder: (context, myModel, child) {
      LapSummaryObject? selectedSeries = myModel.model;
      Map<String, String> units = Conversions.units(context);
      return Container();//ShortDataAnalysis(selectedSeries);
    });
  }
}

// class LapSummaryObject {
//   final int lap;
//   double time;
//   double watts;
//   final Color color;
//
//   LapSummaryObject(this.lap, this.time, this.watts, this.color);
// }