
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../stravalib/Models/activity.dart';
import '../utils/theme.dart';
import 'activity_detail_provider.dart';
import 'config_provider.dart';


//final activityPhotoUrlsProvider = FutureProvider.autoDispose.family<List<String>, List<PhotoActivity>>((ref, photos) async {

final lapsProvider = FutureProvider.autoDispose.family<List<LapSummaryObject>, DetailedActivity>((ref, activity) async {
  final ftp = ref.watch(configProvider).ftp??0.0;
  List<LapSummaryObject> retValue = [];
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