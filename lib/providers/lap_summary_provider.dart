import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/Models/activity.dart';

import '../utils/theme.dart';
import 'activity_detail_provider.dart';
import 'config_provider.dart';

final lapsProvider = FutureProvider.autoDispose
    .family<List<LapSummaryObject>, DetailedActivity>((ref, activity) async {
  final ftp = ref.watch(configProvider).ftp ?? 0.0;
  List<LapSummaryObject> retValue = [];
  // if (activity.laps!.length > 1) {
    for (var lap in activity.laps ?? []) {
      retValue.add(LapSummaryObject(
        0,
        lap.lapIndex,
        lap.distance,
        lap.movingTime,
        lap.totalElevationGain,
        lap.averageCadence,
        lap.averageWatts,
        lap.averageSpeed,
        getColorForWatts(lap.averageWatts, ftp),
      ));
    }
  // } else {
  //   AsyncValue<StreamsDetailCollection> streamsData =
  //     ref.read(streamsProvider(ref.watch(selectedActivityProvider).id));
  //
  //     streamsData.when(data: (streams) {
  //       for (var stream in streams.streams ?? []){
  //         retValue.add(LapSummaryObject(
  //           0,
  //           0,
  //           stream.distance ?? 0,
  //           stream.time ?? 0,
  //           stream.altitude ?? 0,
  //           0,
  //           stream.watts as double ?? 0,
  //           0,
  //           getColorForWatts(stream.watts as double, ftp),
  //         ));
  //         stream.watts;
  //       }
  //     }, error: (Object error, StackTrace stackTrace) {
  //       stackTrace.toString();
  //     }, loading: () {
  //
  //     });
  // }
  return retValue;
});

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
