import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_palette/flutter_palette.dart';
import 'package:provider/provider.dart';
import 'package:zwiftdataviewer/models/ActivitiesDataModel.dart';
import 'package:zwiftdataviewer/stravalib/Models/activity.dart';
import 'package:zwiftdataviewer/utils/conversions.dart';
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/widgets/ListItemViews.dart';

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

    return buildChartSeriesList(context!, result, colors);
  }

  _onSelectionChanged(charts.SelectionModel model) {
    int? selection = model.selectedDatum[0].index ?? 0;
    final SummaryActivity selectedRide =
        model.selectedSeries[0].data[selection];
    Provider.of<SummaryActivitySelectDataModel>(context, listen: false)
        .setSelectedActivity(selectedRide);
  }
}

List<charts.Series<SummaryActivity, double>> buildChartSeriesList(
    BuildContext context,
    Map<int, List<SummaryActivity>> activities,
    Map<int, Color> colors) {
  final List<charts.Series<SummaryActivity, double>> chartSeries = [];

  for (int key in activities.keys) {
    final List<SummaryActivity> distance = activities[key]!;
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
