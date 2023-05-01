import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zwiftdataviewer/models/ActivityDetailDataModel.dart';
import 'package:zwiftdataviewer/widgets/shortdataanalysis.dart';

import '../models/ConfigDataModel.dart';
import '../utils/theme.dart';

class WattsDataView extends StatelessWidget {
  const WattsDataView({super.key});

  @override
  Widget build(BuildContext context) {
    final double ftp =
        (Provider.of<ConfigDataModel>(context, listen: false).configData?.ftp ??
                0)
            .toDouble();
    return Consumer<ActivityDetailDataModel>(
        builder: (context, myModel, child) {
      return ChangeNotifierProxyProvider<ActivityDetailDataModel,
              LapSummaryDataModel>(
          create: (_) => LapSummaryDataModel(),
          lazy: false,
          update: (context, activityDetailDataModel, lapSummaryDataModel) {
            final newActivityDetailDataModel =
                Provider.of<ActivityDetailDataModel>(context, listen: false);
            lapSummaryDataModel?.updateFrom(newActivityDetailDataModel, ftp);
            return lapSummaryDataModel!;
          },
          child: ChangeNotifierProvider<SelectedLapSummaryObjectModel>(
            create: (_) => SelectedLapSummaryObjectModel(),
            child: Column(
              children: const [
                Expanded(child: DisplayChart()),
                WattsProfileDataView(),
              ],
            ),
          ));
    });
  }
}

class DisplayChart extends StatelessWidget {
  const DisplayChart({super.key});

  @override
  Widget build(BuildContext context) {
    final lapSummaryData = Provider.of<LapSummaryDataModel>(context);
    return SfCartesianChart(
      primaryXAxis: NumericAxis(),
      primaryYAxis: NumericAxis(
        minimum: 0,
        //maximum: lapSummaryData.maxWatts.toDouble(),
        // interval: 50,
        // numberFormat: NumberFormat.compact()
      ),
      series: _createDataSet(context, lapSummaryData),
      onSelectionChanged: (SelectionArgs args) =>
          onSelectionChanged(context, args),
    );
  }

  List<ChartSeries<LapSummaryObject, int>> _createDataSet(
      BuildContext context, LapSummaryDataModel lapSummaryData) {
    return [
      ColumnSeries<LapSummaryObject, int>(
        dataSource: lapSummaryData.lapSummaryObjects,
        yAxisName: 'yAxis1',
        xValueMapper: (LapSummaryObject totals, _) => totals.count,
        yValueMapper: (LapSummaryObject totals, _) =>
            (totals.watts).roundToDouble(),
        pointColorMapper: (LapSummaryObject totals, _) => totals.color,
        name: 'Elevation',
        selectionBehavior: SelectionBehavior(
          enable: true,
          unselectedOpacity: 0.5,
          // selectedColor: Colors.red,
          // selectedBorderColor: Colors.red,
          // selectedBorderWidth: 2,
        ),
      ),
    ];
  }

  onSelectionChanged(BuildContext context, SelectionArgs args) {
    var dataPointIndex = args.pointIndex;
    final lapSummaryModel =
        Provider.of<LapSummaryDataModel>(context, listen: false);
    var lapSummaryObject = lapSummaryModel.model[dataPointIndex];
    Provider.of<SelectedLapSummaryObjectModel>(context, listen: false)
        .setSelectedLapSummaryObject(lapSummaryObject);
  }
}

class WattsProfileDataView extends StatelessWidget {
  const WattsProfileDataView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SelectedLapSummaryObjectModel>(
        builder: (context, selectedLapSummaryObjectModel, child) {
      final lapSummaryObject =
          selectedLapSummaryObjectModel.selectedLapSummaryObject;
      return ShortDataAnalysis(lapSummaryObject);
    });
  }
}

class LapTotals {
  final String lap;
  final double watts;
  final Color colorForWatts;

  LapTotals(this.lap, this.watts, this.colorForWatts);
}

class LapSummaryDataModel extends ChangeNotifier {
  List<LapSummaryObject> model = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<LapSummaryObject> get lapSummaryObjects => model;

  void setLapSummaryModel(List<LapSummaryObject> model) {
    this.model = model;
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

  void updateFrom(ActivityDetailDataModel myModel, double ftp) {
    for (var lap in myModel.activityDetail?.laps ?? []) {
      model?.add(LapSummaryObject(
          0,
          lap.lapIndex,
          lap.distance,
          lap.movingTime,
          lap.totalElevationGain,
          lap.averageCadence,
          lap.averageWatts,
          lap.averageSpeed,
          getColorForWatts(lap.averageWatts, ftp)));
    }
    notifyListeners();
  }
}

class SelectedLapSummaryObjectModel extends ChangeNotifier {
  LapSummaryObject? _selectedLapSummaryObject;

  LapSummaryObject? get selectedLapSummaryObject => _selectedLapSummaryObject;

  void setSelectedLapSummaryObject(LapSummaryObject? lapSummaryObject) {
    _selectedLapSummaryObject = lapSummaryObject;
    notifyListeners();
  }
}
