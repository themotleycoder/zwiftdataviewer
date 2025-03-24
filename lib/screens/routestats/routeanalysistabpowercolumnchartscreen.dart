import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/models/activity.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/providers/activity_detail_provider.dart';
import 'package:zwiftdataviewer/providers/lap_select_provider.dart';
import 'package:zwiftdataviewer/providers/lap_summary_provider.dart';
import 'package:zwiftdataviewer/screens/layouts/routeanalysistablayout.dart';
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/utils/ui_helpers.dart';
import 'package:zwiftdataviewer/widgets/shortdataanalysis.dart';

/// A screen that displays power data analysis for a route.
///
/// This screen shows a column chart with power data for each lap,
/// along with a summary of the selected lap.
class RouteAnalysisWattsDataView extends RouteAnalysisTabLayout {
  /// Creates a RouteAnalysisWattsDataView instance.
  ///
  /// @param key An optional key for this widget
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

/// A widget that displays a column chart with power data for each lap.
///
/// This widget fetches lap data for the selected activity and displays
/// it in a column chart, with a line indicating the FTP threshold.
class DisplayChart extends ConsumerWidget {
  /// Creates a DisplayChart instance.
  ///
  /// @param key An optional key for this widget
  const DisplayChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double ftp = 229;
    final activityDetails = ref.watch(stravaActivityDetailsProvider);

    // Trigger loading of lap data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(lapsProvider(activityDetails));
        });

    final AsyncValue<List<LapSummaryObject>> lapsData =
        ref.watch(lapsProvider(activityDetails));

    return Expanded(
      child: SizedBox(
        height: 300, // Ensure the chart has a fixed height
        child: lapsData.when(
          data: (laps) {
            if (laps.isEmpty) {
              return UIHelpers.buildEmptyStateWidget(
                'No lap data available for this activity',
                icon: Icons.electric_bolt,
              );
            }
            
            return SfCartesianChart(
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
                if (args.pointIndex >= 0 && args.pointIndex < laps.length) {
                  var lapSummaryObject = laps[args.pointIndex];
                  ref
                      .read(lapSummaryObjectProvider.notifier)
                      .selectSummary(lapSummaryObject);
                }
              },
            );
          }, 
          error: (Object error, StackTrace stackTrace) {
            debugPrint('Error loading lap data: $error');
            return UIHelpers.buildErrorWidget(
              'Failed to load lap data',
              () => ref.refresh(lapsProvider(activityDetails)),
            );
          }, 
          loading: () {
            return UIHelpers.buildLoadingIndicator(
              key: AppKeys.lapsLoading,
            );
          },
        ),
      ),
    );
  }

  List<ChartSeries<LapSummaryObject, int>> _createDataSet(
      BuildContext context, List<LapSummaryObject> lapSummaryObjData) {

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
