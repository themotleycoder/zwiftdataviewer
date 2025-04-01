import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/providers/activity_detail_provider.dart';
import 'package:zwiftdataviewer/providers/lap_select_provider.dart';
import 'package:zwiftdataviewer/providers/lap_summary_provider.dart';
import 'package:zwiftdataviewer/screens/layouts/routeanalysistablayout.dart';
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/utils/ui_helpers.dart';
import 'package:zwiftdataviewer/widgets/shortdataanalysis.dart';

// A screen that displays power time distribution for a route.
//
// This screen shows a pie chart with power time distribution data,
// along with a summary of the selected lap.
class RouteAnalysisPowerTimePieChartScreen extends RouteAnalysisTabLayout {
  // Creates a RouteAnalysisPowerTimePieChartScreen instance.
  //
  // @param key An optional key for this widget
  const RouteAnalysisPowerTimePieChartScreen({super.key});

  @override
  ConsumerWidget buildChart() {
    return const DisplayChart();
  }

  @override
  buildChartDataView() {
    return const ShortDataAnalysis();
  }
}

// A widget that displays a pie chart with power time distribution data.
//
// This widget fetches lap data for the selected activity and displays
// it in a pie chart, showing the distribution of time spent in different
// power zones.
class DisplayChart extends ConsumerWidget {
  // Creates a DisplayChart instance.
  //
  // @param key An optional key for this widget
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

            return SfCircularChart(
              // Optimize legend rendering
              legend: const Legend(
                isVisible: true,
                position: LegendPosition.right,
                overflowMode: LegendItemOverflowMode.wrap,
              ),
              series: _createDataSet(context, laps, ftp),
              // Disable tooltips for better performance
              tooltipBehavior: TooltipBehavior(
                enable: false,
              ),
              // Optimize selection behavior
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

  List<PieSeries<PowerZoneData, String>> _createDataSet(
      BuildContext context, List<LapSummaryObject> lapSummaryObjData, double ftp) {
    // Calculate power zones based on FTP
    final List<PowerZoneData> powerZoneData = [
      PowerZoneData('Zone 1', 0, ftp * 0.60, Colors.grey),
      PowerZoneData('Zone 2', ftp * 0.60, ftp * 0.75, zdvMidBlue),
      PowerZoneData('Zone 3', ftp * 0.75, ftp * 0.89, zdvMidGreen),
      PowerZoneData('Zone 4', ftp * 0.89, ftp * 1.04, zdvYellow),
      PowerZoneData('Zone 5', ftp * 1.04, ftp * 1.18, zdvOrange),
      PowerZoneData('Zone 6', ftp * 1.18, double.infinity, zdvRed),
    ];

    // Calculate time spent in each zone
    for (var lap in lapSummaryObjData) {
      double watts = lap.watts;
      for (var zone in powerZoneData) {
        if (watts >= zone.lowerBound && watts < zone.upperBound) {
          zone.timeSpent += lap.time; // Using time instead of movingTime
          break;
        }
      }
    }

    return [
      PieSeries<PowerZoneData, String>(
        dataSource: powerZoneData,
        xValueMapper: (PowerZoneData data, _) => data.zoneName,
        yValueMapper: (PowerZoneData data, _) => data.timeSpent,
        pointColorMapper: (PowerZoneData data, _) => data.color,
        // Reduce animation duration for better performance
        animationDuration: 300,
        // Optimize rendering by using simpler explode settings
        explode: false,
        // Optimize data labels
        dataLabelSettings: const DataLabelSettings(
          isVisible: true,
          labelPosition: ChartDataLabelPosition.outside,
          // Use a simpler label format
          labelIntersectAction: LabelIntersectAction.shift,
          connectorLineSettings: ConnectorLineSettings(
            type: ConnectorType.line,
            length: '10%',
          ),
        ),
        // Enable selection for better user interaction
        selectionBehavior: SelectionBehavior(
          enable: true,
        ),
      ),
    ];
  }
}

// Data class for power zone information.
class PowerZoneData {
  final String zoneName;
  final double lowerBound;
  final double upperBound;
  final Color color;
  double timeSpent = 0;

  PowerZoneData(this.zoneName, this.lowerBound, this.upperBound, this.color);
}
