import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/strava_lib/Models/summary_activity.dart';

class SummaryActivityNotifier extends StateNotifier<SummaryActivity> {
  SummaryActivityNotifier() : super(emptyActivity);

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
