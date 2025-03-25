import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/providers/activity_detail_provider.dart';

/// Notifier for the selected lap summary object.
///
/// This notifier keeps track of which lap summary is currently selected,
/// and provides methods to update the selection.
class LapSummaryObjectNotifier extends StateNotifier<LapSummaryObject> {
  /// Creates a LapSummaryObjectNotifier with default values.
  LapSummaryObjectNotifier()
      : super(LapSummaryObject(0, 0, 0, 0, 0, 0, 0, 0, Colors.grey));

  /// Selects a new lap summary.
  ///
  /// @param summary The lap summary to select
  void selectSummary(LapSummaryObject summary) {
    state = summary;
  }

  /// Gets the currently selected lap summary.
  LapSummaryObject get summaryObject => state;
}

/// Provider for the selected lap summary object.
///
/// This provider gives access to the currently selected lap summary,
/// which is used to display lap details and related information.
final lapSummaryObjectProvider =
    StateNotifierProvider<LapSummaryObjectNotifier, LapSummaryObject>(
        (ref) => LapSummaryObjectNotifier());

/// Notifier for the selected lap summary object for pie charts.
///
/// This notifier keeps track of which lap summary is currently selected
/// for pie chart visualization, and provides methods to update the selection.
class LapSummaryObjectPieNotifier extends StateNotifier<LapSummaryObject> {
  /// Creates a LapSummaryObjectPieNotifier with default values.
  LapSummaryObjectPieNotifier()
      : super(LapSummaryObject(0, 0, 0, 0, 0, 0, 0, 0, Colors.grey));

  /// Selects a new lap summary for pie charts.
  ///
  /// @param summary The lap summary to select
  void selectSummary(LapSummaryObject summary) {
    state = summary;
  }

  /// Gets the currently selected lap summary for pie charts.
  LapSummaryObject get summaryObject => state;
}

/// Provider for the selected lap summary object for pie charts.
///
/// This provider gives access to the currently selected lap summary for pie charts,
/// which is used to display lap details in pie chart visualizations.
final lapSummaryObjectPieProvider =
    StateNotifierProvider<LapSummaryObjectPieNotifier, LapSummaryObject>(
        (ref) => LapSummaryObjectPieNotifier());
