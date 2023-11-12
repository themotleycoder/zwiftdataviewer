import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/models/climbdata.dart';

import '../utils/repository/filerepository.dart';

final loadClimbCalendarProvider =
    FutureProvider.autoDispose<Map<DateTime, List<ClimbData>>>((ref) async {
  final FileRepository repository = FileRepository();

  return await repository.loadClimbCalendarData();
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

class EventsForDayNotifier extends StateNotifier<List<ClimbData>> {
  EventsForDayNotifier() : super([]);

  void setEventsForDay(List<ClimbData> events) {
    state = events;
  }

  List<ClimbData> get events => state;
}

final eventsForDayProvider =
    StateNotifierProvider<EventsForDayNotifier, List<ClimbData>>(
        (ref) => EventsForDayNotifier());
