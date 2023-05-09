import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zwiftdataviewer/screens/routeanalysispowerchartscreen.dart';

// import '../models/ActivityDetailDataModel.dart';
import '../models/ConfigDataModel.dart';
import '../providers/activity_detail_provider.dart';
import '../stravalib/Models/activity.dart';
import '../utils/theme.dart';
import '../widgets/shortdataanalysis.dart';

class TimeDataView extends ConsumerWidget {
  const TimeDataView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double ftp = 229;
        // (Provider.of<ConfigDataModel>(context, listen: false).configData?.ftp ??
        //         0)
        //     .toDouble();

    final activityDetail = ref.watch(activityDetailProvider.notifier).activityDetail;
    final lapSummaryData = ref.watch(lapSummaryDataProvider.notifier);

    // return Consumer<ActivityDetailDataModel>(
    //   builder: (context, myModel, child) {
    //     return ChangeNotifierProxyProvider<ActivityDetailDataModel,
    //         LapSummaryDataModel>(
    //       create: (_) => LapSummaryDataModel(),
    //       lazy: false,
    //       update: (context, activityDetailDataModel, lapSummaryDataModel) {
    //         final newActivityDetailDataModel =
    //             Provider.of<ActivityDetailDataModel>(context, listen: false);
    //         lapSummaryDataModel?.updateFrom(newActivityDetailDataModel, ftp);
    //         return lapSummaryDataModel!;
    //       },
    //       child: ChangeNotifierProvider<SelectedLapSummaryObjectModel>(
    //         create: (_) => SelectedLapSummaryObjectModel(),
            return Column(
              children: const [
                Expanded(child: DisplayChart()),
                PowerTimeProfileDataView(),
              ],
            );
    //       ),
    //     );
    //   },
    // );
  }
}

class DisplayChart extends ConsumerWidget {
  const DisplayChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lapSummaryData = ref.watch(lapSummaryDataProvider.notifier);
    // final lapSummaryData = Provider.of<LapSummaryDataModel>(context);
    return SfCircularChart(
      series: _createDataSet(lapSummaryData),
      onSelectionChanged: (SelectionArgs args) =>
          onSelectionChanged(context, args),
    );
  }

  List<PieSeries<LapSummaryObject, int>> _createDataSet(
      LapSummaryProvider lapSummaryData) {
    return [
      PieSeries<LapSummaryObject, int>(
        explode: true,
        explodeIndex: 0,
        explodeOffset: '10%',
        xValueMapper: (LapSummaryObject stats, _) => stats.lap,
        yValueMapper: (LapSummaryObject stats, _) => stats.time,
        pointColorMapper: (LapSummaryObject stats, _) => stats.color,
        dataSource: lapSummaryData.summaryData,
        selectionBehavior: SelectionBehavior(
          enable: true,
        ),
        startAngle: 0,
        endAngle: 0,
      )
    ];
  }

  onSelectionChanged(BuildContext buildContext, SelectionArgs args) {
    // final lapSummaryData =
    //     Provider.of<LapSummaryDataModel>(buildContext, listen: false);
    var lapSummaryObject = lapSummaryData.lapSummaryObjects![args.pointIndex];
    // Provider.of<SelectedLapSummaryObjectModel>(buildContext, listen: false)
    //     .setSelectedLapSummaryObject(lapSummaryObject);
  }
}

class PowerTimeProfileDataView extends ConsumerWidget {
  const PowerTimeProfileDataView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Consumer<SelectedLapSummaryObjectModel>(
      builder: (context, selectedLapSummaryObjectModel, child) {
        final lapSummaryObject =
            selectedLapSummaryObjectModel.selectedLapSummaryObject;
        if (lapSummaryObject != null) {
          lapSummaryObject
              .watts; // Do something with the selected LapSummaryObject
        }
        return const ShortDataAnalysisForLapSummary();
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

class LapSummaryDataModel extends StateNotifier<List<LapSummaryObject>> {
  LapSummaryDataModel() : super([]);
// class LapSummaryDataModel extends ChangeNotifier {
//   List<LapSummaryObject>? model;
//
//   bool _isLoading = false;
//
//   bool get isLoading => _isLoading;
//
//   List<LapSummaryObject>? get lapSummaryObjects => model;
//
//   void setLapSummaryModel(List<LapSummaryObject> model) {
//     this.model = model;
//   }
//
//   void addLapSummaryObject(LapSummaryObject model) {
//     this.model!.add(model);
//   }

  get summaryData => state;

  setLapSummaryObjects(List<LapSummaryObject> model) {
    state = model;
  }

  void add(LapSummaryObject lapSummaryObject) {
    state = [...state, lapSummaryObject];
  }

  void loadData(DetailedActivity detailedActivity, double ftp) {
  // void updateFrom(ActivityDetailDataModel myModel, double ftp) {
  //   model = [];
    var laps = detailedActivity.laps ?? [];
    for (int x = 1; x <= 6; x++) {
      add(LapSummaryObject(x, 0, 0.0, 0, 0.0, 0, 0, 0, _onColorSelect(x)));
    }
    for (var lap in laps) {
      int time = lap.elapsedTime ?? 0;
      double watts = lap.averageWatts ?? 0;
      double speed = lap.averageSpeed ?? 0;
      double cadence = lap.averageCadence ?? 0;
      double distance = lap.distance ?? 0;
      if (watts < ftp * .60) {
        _incrementSummaryObject(
            summaryData![0], time, watts, speed, cadence, distance);
      } else if (watts >= ftp * .60 && watts <= ftp * .75) {
        _incrementSummaryObject(
            summaryData![1], time, watts, speed, cadence, distance);
      } else if (watts > ftp * .75 && watts <= ftp * .89) {
        _incrementSummaryObject(
            summaryData![2], time, watts, speed, cadence, distance);
      } else if (watts > ftp * .89 && watts <= ftp * 1.04) {
        _incrementSummaryObject(
            summaryData![3], time, watts, speed, cadence, distance);
      } else if (watts > ftp * 1.04 && watts <= ftp * 1.18) {
        _incrementSummaryObject(
            summaryData![4], time, watts, speed, cadence, distance);
      } else if (watts > ftp * 1.18) {
        _incrementSummaryObject(
            summaryData![5], time, watts, speed, cadence, distance);
      } else {}
    }
  }

  _incrementSummaryObject(LapSummaryObject lapSummaryObject, int time,
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
}
