import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class RouteAnalysisTabLayout extends ConsumerWidget {
  const RouteAnalysisTabLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(children: [
      buildChart(),
      buildChartDataView(),
    ]);
  }

  Widget buildChart();

  Widget buildChartDataView();
}
