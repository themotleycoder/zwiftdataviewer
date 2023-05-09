
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ConfigDataModel.dart';
import '../secrets.dart';
import '../stravalib/Models/activity.dart';
import '../stravalib/globals.dart';
import '../stravalib/strava.dart';
import '../utils/repository/filerepository.dart';
import '../utils/repository/webrepository.dart';

class SummaryActivityNotifier extends StateNotifier<SummaryActivity> {
  SummaryActivityNotifier() : super(SummaryActivity());

  SummaryActivity activity() {
    return state;
  }

  set summaryActivity(SummaryActivity activity) {
    state = activity;
  }

}

final summaryActivityProvider =
    StateNotifierProvider<SummaryActivityNotifier, SummaryActivity>((ref) {
  return SummaryActivityNotifier();
});
