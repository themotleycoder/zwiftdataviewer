import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/ActivityDetailDataModel.dart';
import '../models/ConfigDataModel.dart';
import '../utils/theme.dart';
import '../widgets/shortdataanalysis.dart';

class TimeDataView extends StatelessWidget {
  const TimeDataView({super.key});

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
              children: [
                Expanded(child: DisplayChart()),
                PowerTimeProfileDataView(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DisplayChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final lapSummaryData = Provider.of<LapSummaryDataModel>(context);
    return SfCircularChart(
      series: _createSampleData(lapSummaryData),
      onSelectionChanged: (SelectionArgs args) =>
          onSelectionChanged(context!, args),
    );
  }

  List<PieSeries<LapSummaryObject, int>> _createSampleData(
      LapSummaryDataModel lapSummaryData) {
    return [
      PieSeries<LapSummaryObject, int>(
        explode: true,
        explodeIndex: 0,
        explodeOffset: '10%',
        xValueMapper: (LapSummaryObject stats, _) => stats.lap,
        yValueMapper: (LapSummaryObject stats, _) => stats.time,
        pointColorMapper: (LapSummaryObject stats, _) => stats.color,
        dataSource: lapSummaryData.lapSummaryObjects,
        selectionBehavior: SelectionBehavior(
          enable: true,
        ),
        startAngle: 0,
        endAngle: 0,
      )
    ];
  }

  onSelectionChanged(BuildContext buildContext, SelectionArgs args) {
    final lapSummaryData =
        Provider.of<LapSummaryDataModel>(buildContext, listen: false);
    var lapSummaryObject = lapSummaryData.lapSummaryObjects![args.pointIndex];
    Provider.of<SelectedLapSummaryObjectModel>(buildContext, listen: false)
        .setSelectedLapSummaryObject(lapSummaryObject);
  }
}

class PowerTimeProfileDataView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SelectedLapSummaryObjectModel>(
      builder: (context, selectedLapSummaryObjectModel, child) {
        final lapSummaryObject =
            selectedLapSummaryObjectModel.selectedLapSummaryObject;
        if (lapSummaryObject != null) {
          lapSummaryObject
              .watts; // Do something with the selected LapSummaryObject
        }
        return ShortDataAnalysisForLapSummary(lapSummaryObject);
      },
    );
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

class LapSummaryDataModel extends ChangeNotifier {
  List<LapSummaryObject>? model;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<LapSummaryObject>? get lapSummaryObjects => model;

  void setLapSummaryModel(List<LapSummaryObject> model) {
    this.model = model;
  }

  void addLapSummaryObject(LapSummaryObject model) {
    this.model!.add(model);
  }

  void updateFrom(ActivityDetailDataModel myModel, double ftp) {
    model = [];
    var laps = myModel.activityDetail?.laps ?? [];
    for (int x = 1; x <= 6; x++) {
      model!.add(
          LapSummaryObject(x, 0, 0.0, 0, 0.0, 0, 0, 0, 0, _onColorSelect(x)));
    }
    for (var lap in laps) {
      double watts = lap.averageWatts ?? 0;
      double speed = lap.averageSpeed ?? 0;
      double cadence = lap.averageCadence ?? 0;
      if (watts < ftp * .60) {
        lapSummaryObjects![0].count += 1;
        lapSummaryObjects![0].time += lap.elapsedTime ?? 0;
        lapSummaryObjects![0].watts += watts;
        lapSummaryObjects![0].speed += speed;
        lapSummaryObjects![0].cadence += cadence;
      } else if (watts >= ftp * .60 && watts <= ftp * .75) {
        lapSummaryObjects![1].count += 1;
        lapSummaryObjects![1].time += lap.elapsedTime ?? 0;
        lapSummaryObjects![1].watts += watts;
      } else if (watts > ftp * .75 && watts <= ftp * .89) {
        lapSummaryObjects![2].count += 1;
        lapSummaryObjects![2].time += lap.elapsedTime ?? 0;
        lapSummaryObjects![2].watts += watts;
      } else if (watts > ftp * .89 && watts <= ftp * 1.04) {
        lapSummaryObjects![3].count += 1;
        lapSummaryObjects![3].time += lap.elapsedTime ?? 0;
        lapSummaryObjects![3].watts += watts;
      } else if (watts > ftp * 1.04 && watts <= ftp * 1.18) {
        lapSummaryObjects![4].count += 1;
        lapSummaryObjects![4].time += lap.elapsedTime ?? 0;
        lapSummaryObjects![4].watts += watts;
      } else if (watts > ftp * 1.18) {
        lapSummaryObjects![5].count += 1;
        lapSummaryObjects![5].time += lap.elapsedTime ?? 0;
        lapSummaryObjects![5].watts += watts;
      } else {}
    }
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
}
