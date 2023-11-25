import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/models/climbdata.dart';
import 'package:zwiftdataviewer/utils/repository/filerepository.dart';

final loadClimbCalendarProvider =
    FutureProvider.autoDispose<Map<DateTime, List<ClimbData>>>((ref) async {
  final FileRepository repository = FileRepository();

  return await repository.loadClimbCalendarData();
});

class ClimbDaySelectNotifier extends StateNotifier<DateTime> {
  ClimbDaySelectNotifier() : super(DateTime.now());

  void selectDay(DateTime daySelect) {
    state = daySelect;
  }

  DateTime get daySelect => state;
}

final selectedClimbDayProvider =
    StateNotifierProvider<ClimbDaySelectNotifier, DateTime>(
        (ref) => ClimbDaySelectNotifier());

class ClimbEventsForDayNotifier extends StateNotifier<List<ClimbData>> {
  ClimbEventsForDayNotifier() : super([]);

  void setEventsForDay(List<ClimbData> events) {
    state = events;
  }

  List<ClimbData> get events => state;
}

final climbEventsForDayProvider =
    StateNotifierProvider<ClimbEventsForDayNotifier, List<ClimbData>>(
        (ref) => ClimbEventsForDayNotifier());
