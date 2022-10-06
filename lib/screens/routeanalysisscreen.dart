import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zwiftdataviewer/models/ActivityDetailDataModel.dart';
import 'package:zwiftdataviewer/stravalib/Models/activity.dart';
import 'package:zwiftdataviewer/utils/conversions.dart';
import '../appkeys.dart';
import '../models/ConfigDataModel.dart';
import '../widgets/listitemviews.dart';

class RouteAnalysisScreen extends StatefulWidget {
  const RouteAnalysisScreen({super.key});

  @override
  _RouteAnalysisScreenState createState() => _RouteAnalysisScreenState();
}

class _RouteAnalysisScreenState extends State<RouteAnalysisScreen> {
  List<Laps>? _laps;
  late Laps selectedLap;
  int _ftp = 0;

  @override
  Widget build(BuildContext context) {
    Map<String, String> units = Conversions.units(context);
    _ftp = Provider.of<ConfigDataModel>(context, listen: false)
        .configData
        ?.ftp??0;
    return Consumer<ActivityDetailDataModel>(
        builder: (context, myModel, child) {
      _laps = myModel.activityDetail?.laps;
      selectedLap = _laps![0];
      final List<charts.Series<dynamic, String>> seriesList =
          generateChartData(context, units, _laps!);
      return Selector<ActivityDetailDataModel, bool>(
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
                  child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                    Expanded(
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: charts.BarChart(
                              seriesList,
                              animate: true,
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
                            ))),
                    const ProfileDataView(),
                  ]))
            ]);
          });
    });
    // });
  }

  _onSelectionChanged(charts.SelectionModel model) {
    int? selection = model.selectedDatum[0].index;
    // selectedLap = model.selectedSeries[0] as Laps;
    selectedLap = _laps![selection!];
    Provider.of<LapSelectDataModel>(context, listen: false)
        .setSelectedLap(selectedLap);
  }

  List<charts.Series<LapTotals, String>> generateChartData(
      BuildContext? context, Map<String, String> units, List<Laps> laps) {
    final List<LapTotals> wattsData = [];
    var count = 0;
    for (var lap in laps) {
      count += 1;
      wattsData.add(LapTotals(count.toString(), lap.averageWatts ?? 0));
    }

    return [
      charts.Series<LapTotals, String>(
          id: 'Watts',
          domainFn: (LapTotals totals, _) => totals.lap,
          measureFn: (LapTotals totals, _) => totals.watts,
          data: wattsData,
          colorFn: ((LapTotals totals, _) {
            final double ftp = _ftp.toDouble();
            if (totals.watts < ftp * .60) {
              return charts.MaterialPalette.gray.shadeDefault;
            } else if (totals.watts >= ftp * .60 &&
                totals.watts <= ftp * .75) {
              return charts.MaterialPalette.blue.shadeDefault;
            } else if (totals.watts > ftp * .75 &&
                totals.watts <= ftp * .89) {
              return charts.MaterialPalette.green.shadeDefault;
            } else if (totals.watts > ftp * .89 &&
                totals.watts <= ftp * 1.04) {
              return charts.MaterialPalette.yellow.shadeDefault;
            } else if (totals.watts > ftp * 1.04 &&
                totals.watts <= ftp * 1.18) {
              return charts.MaterialPalette.deepOrange.shadeDefault;
            } else if (totals.watts > ftp * 1.18) {
              return charts.MaterialPalette.red.shadeDefault;
            } else {
              return charts.MaterialPalette.gray.shadeDefault;
            }
          }))
    ];
  }
}

class LapTotals {
  final String lap;
  final double watts;

  LapTotals(this.lap, this.watts);
}

class ProfileDataView extends StatefulWidget {
  const ProfileDataView({super.key});

  @override
  _ProfileDataViewState createState() => _ProfileDataViewState();
}

class _ProfileDataViewState extends State<ProfileDataView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<LapSelectDataModel>(
        builder: (context, myModel, child) {
      Laps? selectedSeries = myModel.selectedLap;
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
                        'Time',
                        'Avg Power (w)'
                      ],
                      [
                        Conversions.secondsToTime(selectedSeries?.elapsedTime ?? 0),
                        (selectedSeries?.averageWatts ?? 0)
                            .toStringAsFixed(1),
                      ],
                    ),
                    doubleDataHeaderLineItem(
                      [
                        'Avg Cadence (rpm)',
                        'Avg Speed (${units['speed']!})',
                      ],
                      [

                        (selectedSeries?.averageCadence ?? 0)
                            .toStringAsFixed(0),
                        Conversions.mpsToMph(selectedSeries?.maxSpeed ?? 0)
                            .toStringAsFixed(1),
                      ],
                    ),
                    doubleDataHeaderLineItem(
                      [
                        'Distance (${units['distance']!})',
                        'Elevation Gain (${units['height']!})'
                      ],
                      [
                        Conversions.metersToDistance(
                                context, selectedSeries?.distance ?? 0)
                            .toStringAsFixed(1),
                        Conversions.metersToHeight(
                                context, selectedSeries?.totalElevationGain ?? 0)
                            .toStringAsFixed(0)
                      ],
                    ),

                  ])));
    });
  }
}
