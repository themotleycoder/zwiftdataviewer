import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// import 'package:zwiftdataviewer/models/ActivityDetailDataModel.dart';
import 'package:zwiftdataviewer/widgets/shortdataanalysis.dart';

import '../appkeys.dart';
import '../providers/activity_detail_provider.dart';
import '../providers/activity_select_provider.dart';
import '../providers/lap_summary_provider.dart';
import '../stravalib/Models/activity.dart';
import '../utils/theme.dart';

class WattsDataView extends ConsumerWidget {
  const WattsDataView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //     (Provider.of<ConfigDataModel>(context, listen: false).configData?.ftp ??
    //             0)
    //         .toDouble();
    // return Consumer<ActivityDetailDataModel>(
    //     builder: (context, myModel, child) {
    //   return ChangeNotifierProxyProvider<ActivityDetailDataModel,
    //           LapSummaryDataModel>(
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
        WattsProfileDataView(),
      ],
    );
    //       ));
    // });
  }
}

class DisplayChart extends ConsumerWidget {
  const DisplayChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final double ftp = 229;

    AsyncValue<List<LapSummaryObject>> lapsData =
        ref.watch(lapsProvider(ref.watch(activityDetailProvider)!));

    return lapsData.when(data: (laps) {
      return SfCartesianChart(
        primaryXAxis: NumericAxis(),
        primaryYAxis: NumericAxis(
          minimum: 0,
          //maximum: lapSummaryData.maxWatts.toDouble(),
          // interval: 50,
          // numberFormat: NumberFormat.compact()
        ),
        series: _createDataSet(context, laps),
        onSelectionChanged: (SelectionArgs args) =>
            onSelectionChanged(context, args),
      );
    }, error: (Object error, StackTrace stackTrace) {
      return const Text("error");
    }, loading: () {
      return const Center(
        child: CircularProgressIndicator(
          key: AppKeys.lapsLoading,
        ),
      );
    });
  }

  List<ChartSeries<LapSummaryObject, int>> _createDataSet(
      BuildContext context, List<LapSummaryObject> lapSummaryObjData) {
    final double ftp = 229;
    //     (Provider.of<ConfigDataModel>(context, listen: false).configData?.ftp ??
    //             0)
    //         .toDouble();

    return [
      LineSeries<LapSummaryObject, int>(
          dataSource: lapSummaryObjData,
          xValueMapper: (LapSummaryObject totals, _) => totals.count,
          yValueMapper: (LapSummaryObject totals, _) => ftp,
          selectionBehavior: SelectionBehavior(
            enable: false,
          ),
          enableTooltip: false,
          name: 'FTP'),
      ColumnSeries<LapSummaryObject, int>(
        dataSource: lapSummaryObjData,
        // yAxisName: 'yAxis1',
        xValueMapper: (LapSummaryObject totals, _) => totals.count,
        yValueMapper: (LapSummaryObject totals, _) =>
            (totals.watts).roundToDouble(),
        pointColorMapper: (LapSummaryObject totals, _) => totals.color,
        name: 'Elevation',
        selectionBehavior: SelectionBehavior(
          enable: true,
          unselectedOpacity: 0.5,
        ),
      ),
    ];
  }

  onSelectionChanged(BuildContext context, SelectionArgs args) {
    var dataPointIndex = args.pointIndex;
    // final lapSummaryModel =
    //     Provider.of<LapSummaryDataModel>(context, listen: false);
    // var lapSummaryObject = lapSummaryModel.model[dataPointIndex];
    // Provider.of<SelectedLapSummaryObjectModel>(context, listen: false)
    //     .setSelectedLapSummaryObject(lapSummaryObject);
  }
}

class WattsProfileDataView extends ConsumerWidget {
  const WattsProfileDataView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final lapSummaryObject = ref.watch(selectedLapSummaryProvider.notifier).selectedLapSummaryObject;
    // return Consumer<SelectedLapSummaryProvider>(
    //     builder: (context, selectedLapSummaryObjectModel, child) {
    //   final lapSummaryObject =
    //       selectedLapSummaryObjectModel.selectedLapSummaryObject;
    return const ShortDataAnalysis();
  }
}

class LapTotals {
  final String lap;
  final double watts;
  final Color colorForWatts;

  LapTotals(this.lap, this.watts, this.colorForWatts);
}

class LapSummaryProvider extends StateNotifier<List<LapSummaryObject>> {
  LapSummaryProvider() : super([]);

  // List<LapSummaryObject> model = [];
  // bool _isLoading = false;
  //
  // bool get isLoading => _isLoading;

  // List<LapSummaryObject> get lapSummaryObjects => model;

  // void setLapSummaryModel(List<LapSummaryObject> model) {
  //   this.model = model;
  // }

  get summaryData => state;

  setLapSummaryObjects(List<LapSummaryObject> model) {
    state = model;
  }

  void add(LapSummaryObject lapSummaryObject) {
    state = [...state, lapSummaryObject];
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

  void loadData(DetailedActivity detailedActivity, double currentFtp) {
    for (var lap in detailedActivity.laps ?? []) {
      add(LapSummaryObject(
        0,
        lap.lapIndex,
        lap.distance,
        lap.movingTime,
        lap.totalElevationGain,
        lap.averageCadence,
        lap.averageWatts,
        lap.averageSpeed,
        getColorForWatts(lap.averageWatts, currentFtp),
      ));
    }
    // notifyListeners();
  }
}

final lapSummaryDataProvider =
    StateNotifierProvider<LapSummaryProvider, List<LapSummaryObject>>((ref) {
  return LapSummaryProvider();
});

class SelectedLapSummaryProvider extends StateNotifier<LapSummaryObject> {
  SelectedLapSummaryProvider()
      : super(LapSummaryObject(0, 0, 0, 0, 0, 0, 0, 0, Colors.grey));

  LapSummaryObject? get selectedLapSummaryObject => state;

  void setSelectedLapSummaryObject(LapSummaryObject lapSummaryObject) {
    state = lapSummaryObject;
  }
}

final selectedLapSummaryProvider =
    StateNotifierProvider<SelectedLapSummaryProvider, LapSummaryObject>((ref) {
  return SelectedLapSummaryProvider();
});
