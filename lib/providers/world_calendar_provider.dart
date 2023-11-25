import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/models/worlddata.dart';
import 'package:zwiftdataviewer/utils/repository/filerepository.dart';

final loadWorldCalendarProvider =
    FutureProvider.autoDispose<Map<DateTime, List<WorldData>>>((ref) async {
  final FileRepository repository = FileRepository();

  return await repository.loadWorldCalendarData();
});

class WorldDaySelectNotifier extends StateNotifier<DateTime> {
  WorldDaySelectNotifier() : super(DateTime.now());

  void selectDay(DateTime daySelect) {
    state = daySelect;
  }

  DateTime get daySelect => state;
}

final selectedWorldDayProvider =
    StateNotifierProvider<WorldDaySelectNotifier, DateTime>(
        (ref) => WorldDaySelectNotifier());

class WorldEventsForDayNotifier extends StateNotifier<List<WorldData>> {
  WorldEventsForDayNotifier() : super([]);

  void setEventsForDay(List<WorldData> events) {
    state = events;
  }

  List<WorldData> get events => state;
}

final worldEventsForDayProvider =
    StateNotifierProvider<WorldEventsForDayNotifier, List<WorldData>>(
        (ref) => WorldEventsForDayNotifier());
