import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/models/activity.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/providers/activity_detail_provider.dart';
import 'package:zwiftdataviewer/providers/config_provider.dart';
import 'package:zwiftdataviewer/providers/lap_select_provider.dart';
import 'package:zwiftdataviewer/screens/layouts/routeanalysistablayout.dart';
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/utils/ui_helpers.dart';
import 'package:zwiftdataviewer/widgets/shortdataanalysis.dart';

/// A screen that displays time distribution data for a route.
///
/// This screen shows a pie chart with time spent in different power zones,
/// along with a summary of the selected zone.
class RouteAnalysisTimeDataView extends RouteAnalysisTabLayout {
  /// Creates a RouteAnalysisTimeDataView instance.
  ///
  /// @param key An optional key for this widget
  const RouteAnalysisTimeDataView({super.key});

  @override
  ConsumerWidget buildChart() {
    return const DisplayChart();
  }

  @override
  buildChartDataView() {
    return const ShortDataAnalysisForPieLapSummary();
  }
}

/// A widget that displays a pie chart with time spent in different power zones.
///
/// This widget fetches lap summary data for the selected activity and displays
/// it in a pie chart, with each slice representing a different power zone.
class DisplayChart extends ConsumerWidget {
  /// Creates a DisplayChart instance.
  ///
  /// @param key An optional key for this widget
  const DisplayChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityDetails = ref.watch(stravaActivityDetailsProvider);

    // Trigger loading of lap summary data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(lapSummaryDataProvider(activityDetails));
    });

    final AsyncValue<List<LapSummaryObject>> lapSummaryData =
        ref.watch(lapSummaryDataProvider(activityDetails));

    return Expanded(
      child: SizedBox(
        height: 300, // Ensure the chart has a fixed height
        child: lapSummaryData.when(
          data: (laps) {
            if (laps.isEmpty) {
              return UIHelpers.buildEmptyStateWidget(
                'No power zone data available for this activity',
                icon: Icons.pie_chart,
              );
            }

            return SfCircularChart(
              series: createDataSet(laps),
              legend: const Legend(
                isVisible: true,
                position: LegendPosition.bottom,
                overflowMode: LegendItemOverflowMode.wrap,
              ),
              tooltipBehavior: TooltipBehavior(enable: true),
              onSelectionChanged: (SelectionArgs args) {
                if (args.pointIndex >= 0 && args.pointIndex < laps.length) {
                  var lapSummaryObject = laps[args.pointIndex];
                  ref
                      .read(lapSummaryObjectPieProvider.notifier)
                      .selectSummary(lapSummaryObject);
                }
              },
            );
          },
          error: (Object error, StackTrace stackTrace) {
            debugPrint('Error loading lap summary data: $error');
            return UIHelpers.buildErrorWidget(
              'Failed to load power zone data',
              () => ref.refresh(lapSummaryDataProvider(activityDetails)),
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

  /// Creates a dataset for the pie chart.
  ///
  /// @param laps The list of lap summary objects
  /// @return A list of pie series for the chart
  List<PieSeries<LapSummaryObject, String>> createDataSet(
      List<LapSummaryObject> laps) {
    // Filter out laps with zero time to avoid empty slices
    final nonZeroLaps = laps.where((lap) => lap.time > 0).toList();

    if (nonZeroLaps.isEmpty) {
      return [];
    }

    return [
      PieSeries<LapSummaryObject, String>(
        explode: true,
        explodeIndex: 0,
        explodeOffset: '10%',
        xValueMapper: (LapSummaryObject stats, _) => stats.lap.toString(),
        yValueMapper: (LapSummaryObject stats, _) => stats.time,
        pointColorMapper: (LapSummaryObject stats, _) => stats.color,
        dataSource: nonZeroLaps,
        dataLabelSettings: const DataLabelSettings(
          isVisible: true,
          labelPosition: ChartDataLabelPosition.outside,
        ),
        dataLabelMapper: (LapSummaryObject stats, _) => _getZoneName(stats.lap),
        selectionBehavior: SelectionBehavior(
          enable: true,
        ),
        startAngle: 0,
        endAngle: 0,
      )
    ];
  }

  /// Gets the name of a power zone based on its index.
  ///
  /// @param zoneIndex The index of the power zone
  /// @return The name of the power zone
  String _getZoneName(int zoneIndex) {
    switch (zoneIndex) {
      case 1:
        return 'Z1';
      case 2:
        return 'Z2';
      case 3:
        return 'Z3';
      case 4:
        return 'Z4';
      case 5:
        return 'Z5';
      case 6:
        return 'Z6';
      default:
        return '';
    }
  }
}

final lapSummaryDataProvider = FutureProvider.autoDispose
    .family<List<LapSummaryObject>, DetailedActivity>((ref, activity) async {
  List<LapSummaryObject> model = [];

  final ftp = ref.read(configProvider).ftp ?? 100;

  for (int x = 1; x <= 6; x++) {
    model.add(LapSummaryObject(x, 0, 0.0, 0, 0.0, 0, 0, 0, _onColorSelect(x)));
  }

  for (var lap in activity.laps!) {
    int time = lap.elapsedTime ?? 0;
    double watts = lap.averageWatts ?? 0;
    double speed = lap.averageSpeed ?? 0;
    double cadence = lap.averageCadence ?? 0;
    double distance = lap.distance ?? 0;
    if (watts < ftp * .60) {
      incrementSummaryObject(model[0], time, watts, speed, cadence, distance);
    } else if (watts >= ftp * .60 && watts <= ftp * .75) {
      incrementSummaryObject(model[1], time, watts, speed, cadence, distance);
    } else if (watts > ftp * .75 && watts <= ftp * .89) {
      incrementSummaryObject(model[2], time, watts, speed, cadence, distance);
    } else if (watts > ftp * .89 && watts <= ftp * 1.04) {
      incrementSummaryObject(model[3], time, watts, speed, cadence, distance);
    } else if (watts > ftp * 1.04 && watts <= ftp * 1.18) {
      incrementSummaryObject(model[4], time, watts, speed, cadence, distance);
    } else if (watts > ftp * 1.18) {
      incrementSummaryObject(model[5], time, watts, speed, cadence, distance);
    } else {}
  }
  return model;
});

incrementSummaryObject(LapSummaryObject lapSummaryObject, int time,
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
