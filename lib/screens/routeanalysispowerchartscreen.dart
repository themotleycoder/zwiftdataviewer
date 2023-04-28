// import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zwiftdataviewer/models/ActivityDetailDataModel.dart';
import 'package:zwiftdataviewer/stravalib/Models/activity.dart';
import 'package:zwiftdataviewer/utils/conversions.dart';
import 'package:zwiftdataviewer/widgets/shortdataanalysis.dart';
import '../models/ConfigDataModel.dart';
import '../utils/theme.dart';

// class WattsDataView extends StatefulWidget {
//   const WattsDataView({super.key});
//
//   @override
//   _WattsDataViewState createState() => _WattsDataViewState();
// }

class WattsDataView extends StatelessWidget {
  // List<Laps>? _laps;
  // late Laps selectedLap;
  // int _ftp = 0;

  const WattsDataView({super.key});

  @override
  Widget build(BuildContext context) {
    final double ftp =
    (Provider.of<ConfigDataModel>(context, listen: false).configData?.ftp ??
        0)
        .toDouble();
    return Consumer<ActivityDetailDataModel>(
        builder: (context, myModel, child) {
          return ChangeNotifierProxyProvider<ActivityDetailDataModel,
              LapSummaryDataModel>(
              create: (_) => LapSummaryDataModel(),
              lazy: false,
              update: (context, activityDetailDataModel, lapSummaryDataModel) {
                final newActivityDetailDataModel =
                Provider.of<ActivityDetailDataModel>(context, listen: false);
                lapSummaryDataModel?.updateFrom(newActivityDetailDataModel, ftp);
                return lapSummaryDataModel!;
              },
      child: Column(children: const [
        Expanded(
            // padding: const EdgeInsets.all(8.0),
            child: DisplayChart()),

        WattsProfileDataView()
      ]));
    });
  }

  // _onSelectionChanged(charts.SelectionModel model) {
  //   int? selection = model.selectedDatum[0].index ?? 0;
  //   selectedLap = _laps![selection];
  //   Provider.of<LapSelectDataModel>(context, listen: false)
  //       .setSelectedLap(selectedLap);
  // }
  //
  // List<charts.Series<LapTotals, String>> generateChartData(
  //     BuildContext? context, Map<String, String> units, List<Laps> laps) {
  //   final List<LapTotals> wattsData = [];
  //   final List<LapTotals> wattsLineData = [];
  //   var count = 0;
  //   for (var lap in laps) {
  //     count += 1;
  //     wattsData.add(LapTotals(count.toString(), lap.averageWatts ?? 0));
  //     wattsLineData.add(LapTotals(count.toString(), _ftp.toDouble()));
  //   }
  //
  //   return [
  //     charts.Series<LapTotals, String>(
  //         id: 'ftp',
  //         domainFn: (LapTotals totals, _) => totals.lap,
  //         measureFn: (LapTotals totals, _) => totals.watts,
  //         data: wattsLineData,
  //         colorFn: (LapTotals totals, _) =>
  //             charts.MaterialPalette.gray.shade300)
  //       ..setAttribute(charts.rendererIdKey, 'customLine'),
  //     charts.Series<LapTotals, String>(
  //         id: 'power',
  //         domainFn: (LapTotals totals, _) => totals.lap,
  //         measureFn: (LapTotals totals, _) => totals.watts,
  //         data: wattsData,
  //         colorFn: ((LapTotals totals, _) {
  //           final double ftp = _ftp.toDouble();
  //           if (totals.watts < ftp * .60) {
  //             return charts.MaterialPalette.gray.shadeDefault;
  //           } else if (totals.watts >= ftp * .60 && totals.watts <= ftp * .75) {
  //             return charts.ColorUtil.fromDartColor(zdvMidBlue);
  //           } else if (totals.watts > ftp * .75 && totals.watts <= ftp * .89) {
  //             return charts.ColorUtil.fromDartColor(zdvMidGreen);
  //           } else if (totals.watts > ftp * .89 && totals.watts <= ftp * 1.04) {
  //             return charts.ColorUtil.fromDartColor(zdvYellow);
  //           } else if (totals.watts > ftp * 1.04 &&
  //               totals.watts <= ftp * 1.18) {
  //             return charts.ColorUtil.fromDartColor(zdvOrange);
  //           } else if (totals.watts > ftp * 1.18) {
  //             return charts.ColorUtil.fromDartColor(zdvRed);
  //           } else {
  //             return charts.MaterialPalette.gray.shadeDefault;
  //           }
  //         })),
  //   ];
  // }
}

class DisplayChart extends StatelessWidget {
  const DisplayChart({super.key});

  @override
  Widget build(BuildContext context) {
    final lapSummaryData = Provider.of<LapSummaryDataModel>(context);
    return SfCartesianChart(
      series: _createDataSet(context, lapSummaryData),
      // onSelectionChanged: (SelectionArgs args) =>
      //     onSelectionChanged(context, args),
    );
  }

  List<ChartSeries<LapTotals, String>> _createDataSet(BuildContext context,
      LapSummaryDataModel lapSummaryData) {
    final double ftp =
    (Provider.of<ConfigDataModel>(context, listen: false).configData?.ftp ??
        0)
        .toDouble();
    final List<LapTotals> wattsData = [];
    final List<LapTotals> wattsLineData = [];
    var count = 0;
    for (var lap in lapSummaryData.lapSummaryObjects!) {
      count += 1;
      wattsData.add(LapTotals(count.toString(), lap.watts ?? 0));
      wattsLineData.add(LapTotals(count.toString(), ftp.toDouble()));
    }

    return [
      ColumnSeries<LapTotals, String>(
          dataSource: wattsData!,
          yAxisName: 'yAxis1',
          xValueMapper: (LapTotals stats, _) => stats.lap as String,
          yValueMapper: (LapTotals stats, _) =>
              (stats.watts ?? 0).roundToDouble(),
          name: 'Elevation',
          color: zdvMidGreen)
      // charts.Series<LapTotals, String>(
      //     id: 'ftp',
      //     domainFn: (LapTotals totals, _) => totals.lap,
      //     measureFn: (LapTotals totals, _) => totals.watts,
      //     data: wattsLineData,
      //     colorFn: (LapTotals totals, _) =>
      //     charts.MaterialPalette.gray.shade300)
      //   ..setAttribute(charts.rendererIdKey, 'customLine'),
      // charts.Series<LapTotals, String>(
      //     id: 'power',
      //     domainFn: (LapTotals totals, _) => totals.lap,
      //     measureFn: (LapTotals totals, _) => totals.watts,
      //     data: wattsData,
      //     colorFn: ((LapTotals totals, _) {
      //       final double ftp = _ftp.toDouble();
      //       if (totals.watts < ftp * .60) {
      //         return charts.MaterialPalette.gray.shadeDefault;
      //       } else if (totals.watts >= ftp * .60 && totals.watts <= ftp * .75) {
      //         return charts.ColorUtil.fromDartColor(zdvMidBlue);
      //       } else if (totals.watts > ftp * .75 && totals.watts <= ftp * .89) {
      //         return charts.ColorUtil.fromDartColor(zdvMidGreen);
      //       } else if (totals.watts > ftp * .89 && totals.watts <= ftp * 1.04) {
      //         return charts.ColorUtil.fromDartColor(zdvYellow);
      //       } else if (totals.watts > ftp * 1.04 &&
      //           totals.watts <= ftp * 1.18) {
      //         return charts.ColorUtil.fromDartColor(zdvOrange);
      //       } else if (totals.watts > ftp * 1.18) {
      //         return charts.ColorUtil.fromDartColor(zdvRed);
      //       } else {
      //         return charts.MaterialPalette.gray.shadeDefault;
      //       }
      //     })),

    ];
  }

  // onSelectionChanged(BuildContext buildContext, SelectionArgs args) {
  //   final lapSummaryData =
  //   Provider.of<LapSummaryDataModel>(buildContext, listen: false);
  //   var lapSummaryObject = lapSummaryData.lapSummaryObjects![args.pointIndex];
  //   Provider.of<SelectedLapSummaryObjectModel>(buildContext, listen: false)
  //       .setSelectedLapSummaryObject(lapSummaryObject);
  // }
}

class WattsProfileDataView extends StatefulWidget {
  const WattsProfileDataView({super.key});

  @override
  _WattsProfileDataViewState createState() => _WattsProfileDataViewState();
}

class _WattsProfileDataViewState extends State<WattsProfileDataView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<LapSelectDataModel>(builder: (context, myModel, child) {
      Laps? selectedSeries = myModel.selectedLap;
      Map<String, String> units = Conversions.units(context);
      return ShortDataAnalysis(selectedSeries);
    });
  }
}

class LapTotals {
  final String lap;
  final double watts;

  LapTotals(this.lap, this.watts);
}

class LapSummaryDataModel extends ChangeNotifier {
  List<LapSummaryObject>? model;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<LapSummaryObject>? get lapSummaryObjects => model;

  void setLapSummaryModel(List<LapSummaryObject> model) {
    this.model = model;
  }

  void addLapSummaryObject(LapSummaryObject model) {
    this.model!.add(model);
  }

  void updateFrom(ActivityDetailDataModel myModel, double ftp) {
    model = [];
    var laps = myModel.activityDetail?.laps ?? [];
    for (int x = 1; x <= 6; x++) {
      model!.add(
          LapSummaryObject(x, 0, 0.0, 0, 0.0, 0, 0, 0, 0, _onColorSelect(x)));
    }
    for (var lap in laps) {
      int time = lap.elapsedTime ?? 0;
      double watts = lap.averageWatts ?? 0;
      double speed = lap.averageSpeed ?? 0;
      double cadence = lap.averageCadence ?? 0;
      double distance = lap.distance ?? 0;
      //double heartrate = lap. ?? 0;
      if (watts < ftp * .60) {
        _incrementSummaryObject(
            lapSummaryObjects![0], time, watts, speed, cadence, distance);
      } else if (watts >= ftp * .60 && watts <= ftp * .75) {
        _incrementSummaryObject(
            lapSummaryObjects![1], time, watts, speed, cadence, distance);
      } else if (watts > ftp * .75 && watts <= ftp * .89) {
        _incrementSummaryObject(
            lapSummaryObjects![2], time, watts, speed, cadence, distance);
      } else if (watts > ftp * .89 && watts <= ftp * 1.04) {
        _incrementSummaryObject(
            lapSummaryObjects![3], time, watts, speed, cadence, distance);
      } else if (watts > ftp * 1.04 && watts <= ftp * 1.18) {
        _incrementSummaryObject(
            lapSummaryObjects![4], time, watts, speed, cadence, distance);
      } else if (watts > ftp * 1.18) {
        _incrementSummaryObject(
            lapSummaryObjects![5], time, watts, speed, cadence, distance);
      } else {}
    }
  }

  _incrementSummaryObject(LapSummaryObject lapSummaryObject, int time,
      double watts, double speed, double cadence, double distance) {
    lapSummaryObject.count += 1;
    lapSummaryObject.time += time;
    lapSummaryObject.watts += watts;
    lapSummaryObject.speed += speed;
    lapSummaryObject.cadence += cadence;
    lapSummaryObject.distance += distance;
  }

  Color _onColorSelect(idx) {
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
