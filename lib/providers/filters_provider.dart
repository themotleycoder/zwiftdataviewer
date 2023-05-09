import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/providers/activities_provider.dart';

enum DateFilter { all, month, week, year }

class DateFiltersNotifier extends StateNotifier<DateFilter> {
  DateFiltersNotifier() : super(DateFilter.all);

  void setFilter(DateFilter dateFilter) {
    state = dateFilter;
  }

  DateFilter get filter => state;
}

final dateFiltersProvider =
    StateNotifierProvider<DateFiltersNotifier, DateFilter>(
        (ref) => DateFiltersNotifier());

final dateActivityFiltersProvider = Provider((ref) {
  DateTime startDate;
  var activities = ref.watch(activitiesProvider);
  var dateFilters = ref.watch(dateFiltersProvider);
  return activities.where((activity) {
    switch (dateFilters) {
      case DateFilter.year:
        startDate = DateTime.now().subtract(const Duration(days: 365));
        return activity.startDate!.isAfter(startDate);
      case DateFilter.month:
        startDate = DateTime.now().subtract(const Duration(days: 30));
        return activity.startDate!.isAfter(startDate);
      case DateFilter.week:
        startDate = DateTime.now().subtract(const Duration(days: 7));
        return activity.startDate!.isAfter(startDate);
      default:
        return true;
    }
  }).toList();
});
