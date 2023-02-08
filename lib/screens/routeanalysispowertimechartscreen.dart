import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../models/ActivityDetailDataModel.dart';
import '../models/ConfigDataModel.dart';
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
          final List<charts.Series<dynamic, int>> seriesList2 =
          _createSampleData(context, units, _laps!);
          return
            Column(children: [
            Expanded(
                  child: charts.PieChart(
                    seriesList2,
                    animate: true,
                    // behaviors: [
                    //   // charts.InitialSelection(selectedDataConfig: [
                    //   //   charts.SeriesDatumConfig<String>('power', '1')
                    //   // ])
                    // ],
                  )),
              PowerTimeProfileDataView()
            ]);
        });
  }


  List<charts.Series<TimeTotals, int>> _createSampleData(
      BuildContext? context, Map<String, String> units, List<Laps> laps) {
    final double ftp = _ftp.toDouble();

    List<TimeTotals> data = [
      TimeTotals(1, 0.0),
      TimeTotals(2, 0.0),
      TimeTotals(3, 0.0),
      TimeTotals(4, 0.0),
      TimeTotals(5, 0.0),
      TimeTotals(6, 0.0),
    ];

    for (var lap in laps) {
      double watts = lap.averageWatts ?? 0;
      if (watts < ftp * .60) {
        data[0].time += lap.elapsedTime ?? 0;
      } else if (watts >= ftp * .60 && watts <= ftp * .75) {
        data[1].time += lap.elapsedTime ?? 0;
      } else if (watts > ftp * .75 && watts <= ftp * .89) {
        data[2].time += lap.elapsedTime ?? 0;
      } else if (watts > ftp * .89 && watts <= ftp * 1.04) {
        data[3].time += lap.elapsedTime ?? 0;
      } else if (watts > ftp * 1.04 && watts <= ftp * 1.18) {
        data[4].time += lap.elapsedTime ?? 0;
      } else if (watts > ftp * 1.18) {
        data[5].time += lap.elapsedTime ?? 0;
      } else {}
    }

    return [
      charts.Series<TimeTotals, int>(
          id: 'Sales',
          domainFn: (TimeTotals sales, _) => sales.lap,
          measureFn: (TimeTotals sales, _) => sales.time,
          data: data,
          colorFn: ((TimeTotals totals, _) {
            if (totals.lap == 1) {
              return charts.MaterialPalette.gray.shadeDefault;
            } else if (totals.lap == 2) {
              return charts.ColorUtil.fromDartColor(zdvMidBlue);
            } else if (totals.lap == 3) {
              return charts.ColorUtil.fromDartColor(zdvMidGreen);
            } else if (totals.lap == 4) {
              return charts.ColorUtil.fromDartColor(zdvYellow);
            } else if (totals.lap == 5) {
              return charts.ColorUtil.fromDartColor(zdvOrange);
            } else if (totals.lap == 6) {
              return charts.ColorUtil.fromDartColor(zdvRed);
            } else {
              return charts.MaterialPalette.gray.shadeDefault;
            }
          }))
    ];
  }

  _onSelectionChanged(charts.SelectionModel model) {
    // int? selection = model.selectedDatum[0].index ?? 0;
    // selectedLap = model.selectedSeries[0] as Laps;
    // selectedLap = _laps![selection];
    // Provider.of<LapSelectDataModel>(context, listen: false)
    //     .setSelectedLap(selectedLap);
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
    return Consumer<LapSelectDataModel>(builder: (context, myModel, child) {
      Laps? selectedSeries = myModel.selectedLap;
      Map<String, String> units = Conversions.units(context);
      return ShortDataAnalysis(selectedSeries);
    });
  }
}

class TimeTotals {
  final int lap;
  double time;

  TimeTotals(this.lap, this.time);
}