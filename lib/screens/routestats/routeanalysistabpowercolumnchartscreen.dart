import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/Models/activity.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/providers/activity_detail_provider.dart';
import 'package:zwiftdataviewer/providers/lap_select_provider.dart';
import 'package:zwiftdataviewer/providers/lap_summary_provider.dart';
import 'package:zwiftdataviewer/screens/layouts/routeanalysistablayout.dart';
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/widgets/shortdataanalysis.dart';

class RouteAnalysisWattsDataView extends RouteAnalysisTabLayout {
  const RouteAnalysisWattsDataView({super.key});

  @override
  ConsumerWidget buildChart() {
    return const DisplayChart();
  }

  @override
  buildChartDataView() {
    return const ShortDataAnalysis();
  }
}

class DisplayChart extends ConsumerWidget {
  const DisplayChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double ftp = 229;

    AsyncValue<List<LapSummaryObject>> lapsData =
        ref.watch(lapsProvider(ref.watch(stravaActivityDetailsProvider)!));

    return lapsData.when(data: (laps) {
      return Expanded(
          child: SfCartesianChart(
          primaryXAxis: NumericAxis(isVisible: false),
          primaryYAxis: NumericAxis(
            plotBands: <PlotBand>[
              PlotBand(
                start: ftp,
                end: ftp,
                borderColor: Colors.red,
                text: 'FTP',
                isVisible: true,
                borderWidth: 1,
              )
            ],
            minimum: 0,
            interval: 50,
          ),
          series: _createDataSet(context, laps),
          onSelectionChanged: (SelectionArgs args) {
            var lapSummaryObject = laps[args.pointIndex];
            ref
                .read(lapSummaryObjectProvider.notifier)
                .selectSummary(lapSummaryObject);
          }));
    }, error: (Object error, StackTrace stackTrace) {
      return const Text("error");
    }, loading: () {
      return const Center(
        child: CircularProgressIndicator(
          key: AppKeys.lapsLoading,
        ),
      );
    });
  }

  List<ChartSeries<LapSummaryObject, int>> _createDataSet(
      BuildContext context, List<LapSummaryObject> lapSummaryObjData) {
    const double ftp = 229;

    return [
      // LineSeries<LapSummaryObject, int>(
      //     dataSource: lapSummaryObjData,
      //     xValueMapper: (LapSummaryObject totals, _) => totals.count,
      //     yValueMapper: (LapSummaryObject totals, _) => ftp,
      //     selectionBehavior: SelectionBehavior(
      //       enable: false,
      //     ),
      //     enableTooltip: false,
      //     name: 'FTP'),
      ColumnSeries<LapSummaryObject, int>(
        dataSource: lapSummaryObjData,
        // yAxisName: 'yAxis1',
        xValueMapper: (LapSummaryObject totals, _) => totals.count,
        yValueMapper: (LapSummaryObject totals, _) =>
            (totals.watts).roundToDouble(),
        pointColorMapper: (LapSummaryObject totals, _) => totals.color,
        name: 'Power',
        selectionBehavior: SelectionBehavior(
          enable: true,
          unselectedOpacity: 0.5,
        ),
      ),
    ];
  }
}

class LapTotals {
  final String lap;
  final double watts;
  final Color colorForWatts;

  LapTotals(this.lap, this.watts, this.colorForWatts);
}

class LapSummaryProvider extends StateNotifier<List<LapSummaryObject>> {
  LapSummaryProvider() : super([]);

  get summaryData => state;

  setLapSummaryObjects(List<LapSummaryObject> model) {
    state = model;
  }

  void add(LapSummaryObject lapSummaryObject) {
    state = [...state, lapSummaryObject];
  }

  Color getColorForWatts(double watts, double ftp) {
    if (watts < ftp * .60) {
      return Colors.grey;
    } else if (watts >= ftp * .60 && watts <= ftp * .75) {
      return zdvMidBlue;
    } else if (watts > ftp * .75 && watts <= ftp * .89) {
      return zdvMidGreen;
    } else if (watts > ftp * .89 && watts <= ftp * 1.04) {
      return zdvYellow;
    } else if (watts > ftp * 1.04 && watts <= ftp * 1.18) {
      return zdvOrange;
    } else if (watts > ftp * 1.18) {
      return zdvRed;
    } else {
      return Colors.grey;
    }
  }

  void loadData(DetailedActivity detailedActivity, double currentFtp) {
    for (var lap in detailedActivity.laps ?? []) {
      add(LapSummaryObject(
        0,
        lap.lapIndex,
        lap.distance,
        lap.movingTime,
        lap.totalElevationGain,
        lap.averageCadence,
        lap.averageWatts,
        lap.averageSpeed,
        getColorForWatts(lap.averageWatts, currentFtp),
      ));
    }
    // notifyListeners();
  }
}
