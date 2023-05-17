import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/allstatsrootscreen.dart';
import '../screens/calendarscreen.dart';
import '../screens/routeanalysisscreen.dart';
import '../screens/routedetailscreen.dart';
import '../screens/routesectiondetailscreen.dart';
import '../screens/settingscreen.dart';
import '../widgets/activitieslistview.dart';

enum HomeScreenTab { activities, stats, calendar, settings }

class HomeTabsNotifier extends StateNotifier<int> {
  HomeTabsNotifier() : super(0);

  int values(int index) {
    return HomeScreenTab.values[index].index;
  }

  void setIndex(int tabIndex) {
    state = tabIndex;
  }

  get index => state;

  Widget getView(int index) {
    switch (index) {
      case 1:
        return const AllStatsRootScreen();
      case 2:
        return const CalendarScreen();
      case 3:
        return const SettingsScreen();
      case 0:
      default:
        return const ActivitiesListView();
    }
  }
}

final homeTabsNotifier =
    StateNotifierProvider<HomeTabsNotifier, int>((ref) => HomeTabsNotifier());

enum ActivityDetailScreenTab { details, analysis, sections }

class DetailTabsNotifier extends StateNotifier<int> {
  DetailTabsNotifier() : super(0);

  int values(int index) {
    return ActivityDetailScreenTab.values[index].index;
  }

  void setIndex(int tabIndex) {
    state = tabIndex;
  }

  get index => state;

  Widget getView(int index) {
    switch (index) {
      case 1:
        return const RouteAnalysisScreen();
      case 2:
        return const RouteSectionDetailScreen();
      case 0:
      default:
        return const RouteDetailScreen();
    }
  }
}

final detailTabsNotifier = StateNotifierProvider<DetailTabsNotifier, int>(
    (ref) => DetailTabsNotifier());
