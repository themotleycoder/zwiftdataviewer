import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../stravalib/Models/activity.dart';

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
