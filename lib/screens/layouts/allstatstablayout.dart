import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/models/summary_activity.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zwiftdataviewer/providers/filters/filters_provider.dart';
import 'package:zwiftdataviewer/utils/conversions.dart';

abstract class AllStatsTabLayout extends ConsumerWidget {
  const AllStatsTabLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<SummaryActivity> filteredActivities =
        ref.read(dateActivityFiltersProvider);
    final Map<String, String> units = Conversions.units(ref);

    // Call didChangeDependencies to allow subclasses to perform initialization
    didChangeDependencies(context, ref, filteredActivities);

    return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
              child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
            child: buildChart(ref, units, filteredActivities),
          )),
          buildChartSummaryWidget(context, ref, units),
        ]);
  }

  // This method can be overridden by subclasses to perform initialization
  // when the widget's dependencies change
  void didChangeDependencies(BuildContext context, WidgetRef ref, List<SummaryActivity> filteredActivities) {
    // Default implementation does nothing
  }

  SfCartesianChart buildChart(WidgetRef ref, Map<String, String> units,
      List<SummaryActivity> filteredActivities);

  Container buildChartSummaryWidget(
      BuildContext context, WidgetRef ref, Map<String, String> units);
}
