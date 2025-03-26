import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as sf_charts;

/// A simple wrapper around Syncfusion Flutter Charts to avoid name conflicts
/// with Flutter's own SelectionDetails class.
/// 
/// NOTE: This class is currently commented out due to compatibility issues with
/// the newer version of syncfusion_flutter_charts (v29.1.33). The class needs to be
/// updated to work with the new API if it's needed in the future.
/// 
/// The main issue is that the newer version of the library has changed from
/// ChartSeries to CartesianSeries, and has stricter null safety requirements.
/*
class ChartWrapper extends StatelessWidget {
  final List<sf_charts.CartesianSeries<dynamic, dynamic>> series;
  final String? title;
  final sf_charts.ChartAxis? primaryXAxis;
  final sf_charts.ChartAxis? primaryYAxis;
  final bool enableTooltip;
  final bool enableLegend;
  final bool enableZoom;
  final sf_charts.TooltipBehavior? tooltipBehavior;
  final sf_charts.ZoomPanBehavior? zoomPanBehavior;
  final sf_charts.Legend? legend;

  const ChartWrapper({
    Key? key,
    required this.series,
    this.title,
    this.primaryXAxis,
    this.primaryYAxis,
    this.enableTooltip = false,
    this.enableLegend = false,
    this.enableZoom = false,
    this.tooltipBehavior,
    this.zoomPanBehavior,
    this.legend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return sf_charts.SfCartesianChart(
      series: series,
      primaryXAxis: primaryXAxis ?? sf_charts.NumericAxis(),
      primaryYAxis: primaryYAxis ?? sf_charts.NumericAxis(),
      // Other properties need to be updated to work with the newer version
    );
  }
}
*/
