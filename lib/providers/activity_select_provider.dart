import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/models/summary_activity.dart';

class ActivitySelectNotifier extends StateNotifier<SummaryActivity> {
  ActivitySelectNotifier() : super(emptyActivity);

  void selectActivity(SummaryActivity activitySelect) {
    state = activitySelect;
  }

  SummaryActivity get activitySelect => state;
}

final selectedActivityProvider =
    StateNotifierProvider<ActivitySelectNotifier, SummaryActivity>(
        (ref) => ActivitySelectNotifier());
