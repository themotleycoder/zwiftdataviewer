import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/screens/allstats/allstatsrootscreen.dart';
import 'package:zwiftdataviewer/screens/calendars/allcalendarsrootscreen.dart';
import 'package:zwiftdataviewer/screens/dashboard_home_screen.dart';
import 'package:zwiftdataviewer/screens/route_recommendations_screen.dart';
import 'package:zwiftdataviewer/screens/routesscreen.dart';
import 'package:zwiftdataviewer/screens/segments/segments_screen.dart';
import 'package:zwiftdataviewer/screens/settingscreen.dart';
import 'package:zwiftdataviewer/widgets/activitieslistview.dart';

enum HomeScreenTab { dashboard, activities, stats, routes, recommendations, calendar, segments, settings }

class HomeTabsNotifier extends StateNotifier<int> {
  HomeTabsNotifier() : super(0);

  int values(int index) {
    return HomeScreenTab.values[index].index;
  }

  void setIndex(int tabIndex) {
    state = tabIndex;
  }

  int get index => state;

  Widget getView(int index) {
    switch (index) {
      case 1:
        return const ActivitiesListView();
      case 2:
        return const AllStatsRootScreen();
      case 3:
        return const RoutesScreen();
      case 4:
        return const RouteRecommendationsScreen();
      case 5:
        return const AllCalendarsRootScreen();
      case 6:
        return const SegmentsScreen();
      case 7:
        return const SettingsScreen();
      case 0:
      default:
        return const DashboardHomeScreen();
    }
  }
}

final homeTabsNotifier =
    StateNotifierProvider<HomeTabsNotifier, int>((ref) => HomeTabsNotifier());

enum ActivityDetailScreenTab { details, map, analysis, sections }

class DetailTabsNotifier extends StateNotifier<int> {
  DetailTabsNotifier() : super(0);

  int values(int index) {
    return ActivityDetailScreenTab.values[index].index;
  }

  void setIndex(int tabIndex) {
    state = tabIndex;
  }

  int get index => state;
}

final detailTabsNotifier = StateNotifierProvider<DetailTabsNotifier, int>(
    (ref) => DetailTabsNotifier());
