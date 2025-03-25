import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/models/climbdata.dart';
import 'package:zwiftdataviewer/utils/repository/filerepository.dart';

/// Provider that loads the climb calendar data.
///
/// This provider fetches the climb calendar data by scraping it directly,
/// which contains information about which climbs are scheduled for each day.
/// It handles errors gracefully and provides meaningful error messages.
final loadClimbCalendarProvider =
    FutureProvider.autoDispose<Map<DateTime, List<ClimbData>>>((ref) async {
  final FileRepository repository = FileRepository();

  try {
    // Force a refresh by scraping the data directly
    return await repository.scrapeClimbCalendarData();
  } catch (e) {
    // Log the error for debugging purposes
    if (kDebugMode) {
      print('Error loading climb calendar data: $e');
    }
    
    // Return empty data instead of rethrowing
    // This allows the UI to show an empty state rather than an error
    return {};
  }
});

/// Notifier for the selected day in the climb calendar.
///
/// This notifier keeps track of which day is currently selected in the calendar,
/// and provides methods to update the selection.
class ClimbDaySelectNotifier extends StateNotifier<DateTime> {
  /// Creates a ClimbDaySelectNotifier with the current date as the initial state.
  ClimbDaySelectNotifier() : super(DateTime.now());

  /// Selects a new day in the calendar.
  ///
  /// @param daySelect The day to select
  void selectDay(DateTime daySelect) {
    state = daySelect;
  }

  /// Gets the currently selected day.
  DateTime get daySelect => state;
}

/// Provider for the selected day in the climb calendar.
final selectedClimbDayProvider =
    StateNotifierProvider<ClimbDaySelectNotifier, DateTime>(
        (ref) => ClimbDaySelectNotifier());

/// Notifier for the climb events for the selected day.
///
/// This notifier keeps track of the list of climb events for the currently
/// selected day in the calendar.
class ClimbEventsForDayNotifier extends StateNotifier<List<ClimbData>> {
  /// Creates a ClimbEventsForDayNotifier with an empty list as the initial state.
  ClimbEventsForDayNotifier() : super([]);

  /// Sets the events for the selected day.
  ///
  /// @param events The list of climb events for the selected day
  void setEventsForDay(List<ClimbData> events) {
    state = events;
  }

  /// Gets the events for the selected day.
  List<ClimbData> get events => state;
}

/// Provider for the climb events for the selected day.
final climbEventsForDayProvider =
    StateNotifierProvider<ClimbEventsForDayNotifier, List<ClimbData>>(
        (ref) => ClimbEventsForDayNotifier());
