import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../appkeys.dart';
import '../providers/activity_detail_provider.dart';
import '../providers/config_provider.dart';
import '../providers/lap_select_provider.dart';
import '../strava_lib/Models/activity.dart';
import '../utils/theme.dart';
import '../widgets/shortdataanalysis.dart';

class TimeDataView extends StatelessWidget {
  const TimeDataView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Expanded(child: DisplayChart()),
        ShortDataAnalysisForPieLapSummary(),
      ],
    );
  }
}

class DisplayChart extends ConsumerWidget {
  const DisplayChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<LapSummaryObject>> lapSummaryData = ref.watch(
        lapSummaryDataProvider(ref.watch(stravaActivityDetailsProvider)));

    return lapSummaryData.when(data: (laps) {
      return SfCircularChart(
          series: createDataSet(laps),
          onSelectionChanged: (SelectionArgs args) {
            var lapSummaryObject = laps[args.pointIndex];
            ref
                .read(lapSummaryObjectPieProvider.notifier)
                .selectSummary(lapSummaryObject);
          });
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

  List<PieSeries<LapSummaryObject, int>> createDataSet(
      List<LapSummaryObject> laps) {
    return [
      PieSeries<LapSummaryObject, int>(
        explode: true,
        explodeIndex: 0,
        explodeOffset: '10%',
        xValueMapper: (LapSummaryObject stats, _) => stats.lap,
        yValueMapper: (LapSummaryObject stats, _) => stats.time,
        pointColorMapper: (LapSummaryObject stats, _) => stats.color,
        dataSource: laps,
        selectionBehavior: SelectionBehavior(
          enable: true,
        ),
        startAngle: 0,
        endAngle: 0,
      )
    ];
  }
}

final lapSummaryDataProvider = FutureProvider.autoDispose
    .family<List<LapSummaryObject>, DetailedActivity>((ref, activity) async {
  List<LapSummaryObject> model = [];

  final ftp = ref.read(configProvider).ftp ?? 100;

  for (int x = 1; x <= 6; x++) {
    model.add(LapSummaryObject(x, 0, 0.0, 0, 0.0, 0, 0, 0, _onColorSelect(x)));
  }

  for (var lap in activity.laps!) {
    int time = lap.elapsedTime ?? 0;
    double watts = lap.averageWatts ?? 0;
    double speed = lap.averageSpeed ?? 0;
    double cadence = lap.averageCadence ?? 0;
    double distance = lap.distance ?? 0;
    if (watts < ftp * .60) {
      incrementSummaryObject(model[0], time, watts, speed, cadence, distance);
    } else if (watts >= ftp * .60 && watts <= ftp * .75) {
      incrementSummaryObject(model[1], time, watts, speed, cadence, distance);
    } else if (watts > ftp * .75 && watts <= ftp * .89) {
      incrementSummaryObject(model[2], time, watts, speed, cadence, distance);
    } else if (watts > ftp * .89 && watts <= ftp * 1.04) {
      incrementSummaryObject(model[3], time, watts, speed, cadence, distance);
    } else if (watts > ftp * 1.04 && watts <= ftp * 1.18) {
      incrementSummaryObject(model[4], time, watts, speed, cadence, distance);
    } else if (watts > ftp * 1.18) {
      incrementSummaryObject(model[5], time, watts, speed, cadence, distance);
    } else {}
  }
  return model;
});

incrementSummaryObject(LapSummaryObject lapSummaryObject, int time,
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
