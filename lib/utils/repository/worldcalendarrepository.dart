import '../../providers/world_select_provider.dart';

abstract class WorldCalendarRepository {
  Future<Map<DateTime, List<WorldData>>> loadWorldCalendarData();

  Future saveWorldCalendarData(Map<DateTime, List<WorldData>> worldCalendar);

  Future<Map<DateTime, List<WorldData>>> scrapeWorldCalendarData();
}
