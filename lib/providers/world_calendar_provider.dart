import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/providers/world_select_provider.dart';

import '../utils/repository/filerepository.dart';

final loadWorldCalendarProvider =
    FutureProvider.autoDispose<Map<DateTime, List<WorldData>>>((ref) async {
  final FileRepository repository = FileRepository();

  return await repository.loadWorldCalendarData();
});

class DaySelectNotifier extends StateNotifier<DateTime> {
  DaySelectNotifier() : super(DateTime.now());

  void selectDay(DateTime daySelect) {
    state = daySelect;
  }

  DateTime get daySelect => state;
}

final selectedDayProvider = StateNotifierProvider<DaySelectNotifier, DateTime>(
    (ref) => DaySelectNotifier());

class EventsForDayNotifier extends StateNotifier<List<WorldData>> {
  EventsForDayNotifier() : super([]);

  void setEventsForDay(List<WorldData> events) {
    state = events;
  }

  List<WorldData> get events => state;
}

final eventsForDayProvider =
    StateNotifierProvider<EventsForDayNotifier, List<WorldData>>(
        (ref) => EventsForDayNotifier());
