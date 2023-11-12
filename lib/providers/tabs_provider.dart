import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/screens/allcalendarsrootscreen.dart';
import 'package:zwiftdataviewer/screens/allstatsrootscreen.dart';
import 'package:zwiftdataviewer/screens/routesscreen.dart';
import 'package:zwiftdataviewer/screens/settingscreen.dart';
import 'package:zwiftdataviewer/widgets/activitieslistview.dart';


enum HomeScreenTab { activities, stats, routes, calendar, settings }

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
        return const RoutesScreen();
      case 3:
        return const AllCalendarsRootScreen();
      case 4:
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
}

final detailTabsNotifier = StateNotifierProvider<DetailTabsNotifier, int>(
    (ref) => DetailTabsNotifier());
