import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_palette/flutter_palette.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zwiftdataviewer/models/ActivitiesDataModel.dart';
import 'package:zwiftdataviewer/stravalib/Models/activity.dart';
import 'package:zwiftdataviewer/utils/conversions.dart';
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/widgets/ListItemViews.dart';
import '../utils/charts.dart';

class AllStatsScreenScatter extends StatefulWidget {
  const AllStatsScreenScatter({super.key});

  @override
  _AllStatsScreenScatterState createState() => _AllStatsScreenScatterState();
}

class _AllStatsScreenScatterState extends State<AllStatsScreenScatter> {
  @override
  Widget build(BuildContext context) {
    return Selector<ActivitiesDataModel, List<SummaryActivity>>(
        selector: (_, model) => model.dateFilteredActivities,
        builder: (context, activities, child) {
          Map<String, String> units = Conversions.units(context);
          final List<charts.Series<dynamic, double>> seriesList =
              generateChartData(context, units, activities);
          return Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: buildScatterChart(context, units, activities),
                )),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: charts.ScatterPlotChart(
                    seriesList,
                    animate: true,
                    behaviors: [charts.SeriesLegend()],
                    selectionModels: [
                      charts.SelectionModelConfig(
                        type: charts.SelectionModelType.info,
                        changedListener: _onSelectionChanged,
                      )
                    ],
                  ),
                )),
                Consumer<SummaryActivitySelectDataModel>(
                    builder: (context, summaryActivity, child) {
                  return Container(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                    child: Column(
                      children: <Widget>[
                        singleDataHeaderLineItem(
                            summaryActivity.activity?.name ??
                                "No ride selected"),
                        tripleDataSingleHeaderLineItem(
                          [
                            'Distance (${units['distance']!})',
                            'Elevation (${units['height']!})',
                            'Time'
                          ],
                          [
                            Conversions.metersToDistance(context,
                                    summaryActivity.activity?.distance ?? 0)
                                .toStringAsFixed(1),
                            Conversions.metersToHeight(
                                    context,
                                    summaryActivity
                                            .activity?.totalElevationGain ??
                                        0)
                                .toStringAsFixed(1),
                            Conversions.secondsToTime(
                                summaryActivity.activity?.elapsedTime ?? 0),
                          ],
                        ),
                      ],
                    ),
                  );
                })
              ]);
        });
  }

  List<charts.Series<SummaryActivity, double>> generateChartData(
      BuildContext? context,
      Map<String, String> units,
      List<SummaryActivity> activities) {
    /// Create series list with multiple series
    final Map<int, List<SummaryActivity>> result = {};
    final List<int> years = [];

    for (var activity in activities) {
      int year = activity.startDateLocal!.year;
      if (!result.containsKey(year)) {
        result[year] = [];
      }
      if (!years.contains(year)) {
        years.add(year);
      }

      result[year]!.add(activity);
    }

    final Map<int, Color> colors = generateColor(years);

    return ChartsData.buildChartSeriesList(context!, result, colors);
  }

  _onSelectionChanged(charts.SelectionModel model) {
    int? selection = model.selectedDatum[0].index ?? 0;
    final SummaryActivity selectedRide =
        model.selectedSeries[0].data[selection];
    Provider.of<SummaryActivitySelectDataModel>(context, listen: false)
        .setSelectedActivity(selectedRide);
  }

  SfCartesianChart buildScatterChart(
      BuildContext context, units, List<SummaryActivity> activities) {
    return SfCartesianChart(
      primaryXAxis: NumericAxis(),
      primaryYAxis: NumericAxis(
        majorGridLines: const MajorGridLines(width: 0),
        opposedPosition: false,
        labelFormat: '{value}',
        minimum: 0,
      ),
      series: getScatterSeries(context, units, activities),
      legend: Legend(
        isVisible: true,
        position: LegendPosition.top,
        // offset: enableFloatingLegend ? Offset(_xOffset, _yOffset) : null,
        // overflowMode: _overflow      Mode,
        // toggleSeriesVisibility: toggleVisibility,
        // backgroundColor: model.currentThemeData?.brightness == Brightness.light
        //     ? Colors.white.withOpacity(0.5)
        //     : const Color.fromRGBO(33, 33, 33, 0.5),
        // borderColor: model.currentThemeData?.brightness == Brightness.light
        //     ? Colors.black.withOpacity(0.5)
        //     : Colors.white.withOpacity(0.5),
        borderWidth: 1,
      ),
    );
  }

  List<charts.Series<SummaryActivity, double>> getScatterSeries(
      BuildContext context, units, List<SummaryActivity> activities) {
    // List<charts.Series<SummaryActivity, double>> series = [];
    // var chartData = generateChartData(context, units, activities);

    final Map<int, List<SummaryActivity>> result =
        groupActivitiesByYear(activities);
    final List<int> years = result.keys.toList();
    final List<charts.Series<SummaryActivity, double>> chartSeries = [];

    final Map<int, Color> colors = generateColor(years);

    for (int key in result.keys) {
      final List<SummaryActivity> distance = result[key]!;
      chartSeries.add(charts.Series<SummaryActivity, double>(
        id: key.toString().substring(2),
        // Providing a color function is optional.
        colorFn: (SummaryActivity stats, _) {
          // Bucket the measure column value into 3 distinct colors.
          return charts.ColorUtil.fromDartColor(
              colors[stats.startDateLocal!.year]!);
        },
        domainFn: (SummaryActivity stats, _) =>
            Conversions.metersToDistance(context, stats.distance ?? 0),
        measureFn: (SummaryActivity stats, _) =>
            Conversions.metersToHeight(context, stats.totalElevationGain ?? 0),
        // Providing a radius function is optional.
        // radiusPxFn: (SummaryActivity stats, _) => sales.radius,
        data: distance,
      ));
    }
    return chartSeries;
  }

  Map<int, List<SummaryActivity>> groupActivitiesByYear(
      List<SummaryActivity> activities) {
    Map<int, List<SummaryActivity>> groupedActivities = {};

    for (SummaryActivity activity in activities) {
      int year = activity.startDateLocal!.year;
      if (!groupedActivities.containsKey(year)) {
        groupedActivities[year] = [];
      }
      groupedActivities[year]?.add(activity);
    }

    return groupedActivities;
  }
}

Map<int, Color> generateColor(List<int> years) {
  ColorPalette palette = ColorPalette.splitComplimentary(
    zdvMidGreen,
    numberOfColors: years.length,
    hueVariability: 30,
    saturationVariability: 30,
    brightnessVariability: 30,
  );

  int x = 0;
  final Map<int, Color> colors = {};
  for (Color color in palette) {
    colors[years[x]] = color;
    x += 1;
  }

  return colors;
}
