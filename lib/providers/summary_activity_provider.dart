import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/models/summary_activity.dart';

// Notifier for the summary activity.
//
// This notifier keeps track of the current summary activity,
// and provides methods to update it.
class SummaryActivityNotifier extends StateNotifier<SummaryActivity> {
  // Creates a SummaryActivityNotifier with an empty activity as the initial state.
  SummaryActivityNotifier() : super(emptyActivity);

  // Gets the current summary activity.
  SummaryActivity activity() {
    return state;
  }

  // Sets the current summary activity.
  //
  // @param activity The summary activity to set
  set summaryActivity(SummaryActivity activity) {
    state = activity;
  }
}

// Provider for the summary activity.
//
// This provider gives access to the current summary activity,
// which is used throughout the app to display activity information.
final summaryActivityProvider =
    StateNotifierProvider<SummaryActivityNotifier, SummaryActivity>((ref) {
  return SummaryActivityNotifier();
});
