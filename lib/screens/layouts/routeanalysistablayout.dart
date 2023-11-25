import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/Models/summary_activity.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zwiftdataviewer/providers/filters/filters_provider.dart';
import 'package:zwiftdataviewer/utils/conversions.dart';

abstract class RouteAnalysisTabLayout extends ConsumerWidget {
  const RouteAnalysisTabLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(children: [
      buildChart(),
      buildChartDataView(),
    ]);
  }

  buildChart();

  buildChartDataView();

}