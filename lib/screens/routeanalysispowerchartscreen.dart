import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zwiftdataviewer/models/ActivityDetailDataModel.dart';
import 'package:zwiftdataviewer/stravalib/Models/activity.dart';
import 'package:zwiftdataviewer/utils/conversions.dart';
import 'package:zwiftdataviewer/widgets/shortdataanalysis.dart';

import '../models/ConfigDataModel.dart';
import '../utils/theme.dart';

class WattsDataView extends StatefulWidget {
  const WattsDataView({super.key});

  @override
  _WattsDataViewState createState() => _WattsDataViewState();
}

class _WattsDataViewState extends State<WattsDataView> {
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
      final List<charts.Series<dynamic, String>> seriesList =
          generateChartData(context, units, _laps!);
      return Column(children: [
        Expanded(
            // padding: const EdgeInsets.all(8.0),
            child: charts.OrdinalComboChart(
          seriesList,
          animate: true,
          defaultRenderer: charts.BarRendererConfig(
              groupingType: charts.BarGroupingType.grouped),
          customSeriesRenderers: [
            charts.LineRendererConfig(
                // ID used to link series to this renderer.
                customRendererId: 'customLine')
          ],
          domainAxis: const charts.OrdinalAxisSpec(
              // Make sure that we draw the domain axis line.
              showAxisLine: true,
              // But don't draw anything else.
              renderSpec: charts.NoneRenderSpec()),
          selectionModels: [
            charts.SelectionModelConfig(
              type: charts.SelectionModelType.info,
              changedListener: _onSelectionChanged,
            )
          ],
          behaviors: [
            // charts.InitialSelection(selectedDataConfig: [
            //   charts.SeriesDatumConfig<String>('power', '1')
            // ])
          ],
        )),
        WattsProfileDataView()
      ]);
    });
  }

  _onSelectionChanged(charts.SelectionModel model) {
    int? selection = model.selectedDatum[0].index ?? 0;
    // selectedLap = model.selectedSeries[0] as Laps;
    selectedLap = _laps![selection];
    Provider.of<LapSelectDataModel>(context, listen: false)
        .setSelectedLap(selectedLap);
  }

  List<charts.Series<LapTotals, String>> generateChartData(
      BuildContext? context, Map<String, String> units, List<Laps> laps) {
    final List<LapTotals> wattsData = [];
    final List<LapTotals> wattsLineData = [];
    var count = 0;
    for (var lap in laps) {
      count += 1;
      wattsData.add(LapTotals(count.toString(), lap.averageWatts ?? 0));
      wattsLineData.add(LapTotals(count.toString(), _ftp.toDouble()));
    }

    return [
      charts.Series<LapTotals, String>(
          id: 'ftp',
          domainFn: (LapTotals totals, _) => totals.lap,
          measureFn: (LapTotals totals, _) => totals.watts,
          data: wattsLineData,
          colorFn: (LapTotals totals, _) =>
              charts.MaterialPalette.gray.shade300)
        ..setAttribute(charts.rendererIdKey, 'customLine'),
      charts.Series<LapTotals, String>(
          id: 'power',
          domainFn: (LapTotals totals, _) => totals.lap,
          measureFn: (LapTotals totals, _) => totals.watts,
          data: wattsData,
          colorFn: ((LapTotals totals, _) {
            final double ftp = _ftp.toDouble();
            if (totals.watts < ftp * .60) {
              return charts.MaterialPalette.gray.shadeDefault;
            } else if (totals.watts >= ftp * .60 && totals.watts <= ftp * .75) {
              return charts.ColorUtil.fromDartColor(zdvMidBlue);
            } else if (totals.watts > ftp * .75 && totals.watts <= ftp * .89) {
              return charts.ColorUtil.fromDartColor(zdvMidGreen);
            } else if (totals.watts > ftp * .89 && totals.watts <= ftp * 1.04) {
              return charts.ColorUtil.fromDartColor(zdvYellow);
            } else if (totals.watts > ftp * 1.04 &&
                totals.watts <= ftp * 1.18) {
              return charts.ColorUtil.fromDartColor(zdvOrange);
            } else if (totals.watts > ftp * 1.18) {
              return charts.ColorUtil.fromDartColor(zdvRed);
            } else {
              return charts.MaterialPalette.gray.shadeDefault;
            }
          })),
    ];
  }
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
