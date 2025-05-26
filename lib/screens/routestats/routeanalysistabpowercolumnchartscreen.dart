import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/providers/activity_detail_provider.dart';
import 'package:zwiftdataviewer/providers/config_provider.dart';
import 'package:zwiftdataviewer/providers/lap_select_provider.dart';
import 'package:zwiftdataviewer/providers/lap_summary_provider.dart';
import 'package:zwiftdataviewer/screens/layouts/routeanalysistablayout.dart';
import 'package:zwiftdataviewer/utils/ui_helpers.dart';
import 'package:zwiftdataviewer/widgets/shortdataanalysis.dart';

// A screen that displays power data analysis for a route.
//
// This screen shows a column chart with power data for each lap,
// along with a summary of the selected lap.
class RouteAnalysisWattsDataView extends RouteAnalysisTabLayout {
  // Creates a RouteAnalysisWattsDataView instance.
  //
  // @param key An optional key for this widget
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

// A widget that displays a column chart with power data for each lap.
//
// This widget fetches lap data for the selected activity and displays
// it in a column chart, with a line indicating the FTP threshold.
class DisplayChart extends ConsumerWidget {
  // Creates a DisplayChart instance.
  //
  // @param key An optional key for this widget
  const DisplayChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider);
    final double ftp = config.ftp ?? 229.0; // Use config FTP with fallback
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
              // Optimize rendering by disabling unnecessary features
              enableAxisAnimation: false,
              primaryXAxis: const NumericAxis(
                isVisible: false,
                // Reduce the number of labels to improve performance
                interval: 2,
              ),
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

  List<CartesianSeries<LapSummaryObject, int>> _createDataSet(
      BuildContext context, List<LapSummaryObject> lapSummaryObjData) {
    return [
      ColumnSeries<LapSummaryObject, int>(
        dataSource: lapSummaryObjData,
        xValueMapper: (LapSummaryObject totals, _) => totals.count,
        yValueMapper: (LapSummaryObject totals, _) =>
            (totals.watts).roundToDouble(),
        pointColorMapper: (LapSummaryObject totals, _) => totals.color,
        name: 'Power',
        // Reduce animation duration to improve performance
        animationDuration: 300,
        selectionBehavior: SelectionBehavior(
          enable: true,
          unselectedOpacity: 0.5,
        ),
        // Optimize rendering by using simpler border radius
        borderRadius: BorderRadius.zero,
        // Reduce spacing between columns to improve performance
        spacing: 0.1,
      ),
    ];
  }
}
