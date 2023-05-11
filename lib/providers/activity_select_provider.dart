import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/stravalib/Models/activity.dart';

class ActivitySelectNotifier extends StateNotifier<SummaryActivity> {
  ActivitySelectNotifier()
      : super(SummaryActivity());

  void selectActivity(SummaryActivity activitySelect) {
    state = activitySelect;
  }

  SummaryActivity get activitySelect => state;
}

final selectedActivityProvider = StateNotifierProvider<ActivitySelectNotifier, SummaryActivity>((ref) => ActivitySelectNotifier());