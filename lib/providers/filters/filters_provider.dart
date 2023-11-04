import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/providers/activities_provider.dart';
import 'package:flutter_strava_api/Models/summary_activity.dart';
import '../../utils/worlddata.dart';

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

final dateActivityFiltersProvider = Provider<List<SummaryActivity>>((ref) {
  DateTime startDate;

  final AsyncValue<List<SummaryActivity>> activitiesList =
      ref.watch(stravaActivitiesProvider);
  var activities = [];
  activitiesList.when(
    data: (a) {
      activities = a;
    },
    loading: () {},
    error: (error, stackTrace) {},
  );

  // var activities = ref.read(stravaActivitiesProvider);
  var dateFilters = ref.watch(dateFiltersProvider);
  return activities
      .where((activity) {
        switch (dateFilters) {
          case DateFilter.year:
            startDate = DateTime.now().subtract(const Duration(days: 365));
            return activity.startDate.isAfter(startDate);
          case DateFilter.month:
            startDate = DateTime.now().subtract(const Duration(days: 30));
            return activity.startDate.isAfter(startDate);
          case DateFilter.week:
            startDate = DateTime.now().subtract(const Duration(days: 7));
            return activity.startDate.isAfter(startDate);
          default:
            return true;
        }
      })
      .toList()
      .cast<SummaryActivity>();
});

class GuestWorldFiltersNotifier extends StateNotifier<GuestWorldId> {
  GuestWorldFiltersNotifier() : super(GuestWorldId.all);

  void setFilter(GuestWorldId guestWorldId) {
    state = guestWorldId;
  }

  GuestWorldId get filter => state;
}

final guestWorldFiltersNotifier =
    StateNotifierProvider<GuestWorldFiltersNotifier, GuestWorldId>(
        (ref) => GuestWorldFiltersNotifier());

final filteredRoutesProvider = Provider((ref) {
  var routes = []; //ref.watch(worldRouteProvider).entries;
  var guestWorldFilters = ref.watch(guestWorldFiltersNotifier);
  return routes.where((route) {
    switch (guestWorldFilters) {
      case GuestWorldId.all:
        return true;
      default:
        return true;
    }
  }).toList();
});


