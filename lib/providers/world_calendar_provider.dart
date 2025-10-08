import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/models/worlddata.dart';
import 'package:zwiftdataviewer/utils/repository/filerepository.dart';

// Provider that loads the world calendar data.
//
// This provider fetches the world calendar data from the repository,
// which contains information about which worlds are scheduled for each day.
// It handles errors gracefully and provides meaningful error messages.
final loadWorldCalendarProvider =
    FutureProvider.autoDispose<Map<DateTime, List<WorldData>>>((ref) async {
  final FileRepository repository = FileRepository();
  try {
    final calendarData = await repository.loadWorldCalendarData();

    if (kDebugMode) {
      print('✓ World calendar loaded: ${calendarData.length} days with events');
      if (calendarData.isEmpty) {
        print('⚠️  WARNING: World calendar is empty - no scheduled worlds found');
      }
    }

    return calendarData;
  } catch (e, stackTrace) {
    // Log the error for debugging purposes
    if (kDebugMode) {
      print('❌ ERROR loading world calendar data: $e');
      print('Stack trace: $stackTrace');
    }

    // Rethrow the error so the UI can show an error state
    // Users should know when data fails to load
    rethrow;
  }
});

// Notifier for the selected day in the world calendar.
//
// This notifier keeps track of which day is currently selected in the calendar,
// and provides methods to update the selection.
class WorldDaySelectNotifier extends StateNotifier<DateTime> {
  // Creates a WorldDaySelectNotifier with the current date as the initial state.
  WorldDaySelectNotifier() : super(DateTime.now());

  // Selects a new day in the calendar.
  //
  // @param daySelect The day to select
  void selectDay(DateTime daySelect) {
    state = daySelect;
  }

  // Gets the currently selected day.
  DateTime get daySelect => state;
}

// Provider for the selected day in the world calendar.
final selectedWorldDayProvider =
    StateNotifierProvider<WorldDaySelectNotifier, DateTime>(
        (ref) => WorldDaySelectNotifier());

// Notifier for the world events for the selected day.
//
// This notifier keeps track of the list of world events for the currently
// selected day in the calendar.
class WorldEventsForDayNotifier extends StateNotifier<List<WorldData>> {
  // Creates a WorldEventsForDayNotifier with an empty list as the initial state.
  WorldEventsForDayNotifier() : super([]);

  // Sets the events for the selected day.
  //
  // @param events The list of world events for the selected day
  void setEventsForDay(List<WorldData> events) {
    state = events;
  }

  // Gets the events for the selected day.
  List<WorldData> get events => state;
}

// Provider for the world events for the selected day.
final worldEventsForDayProvider =
    StateNotifierProvider<WorldEventsForDayNotifier, List<WorldData>>(
        (ref) => WorldEventsForDayNotifier());
