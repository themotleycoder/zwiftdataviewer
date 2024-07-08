import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/models/summary_activity.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/delegates/activitysearchdelegate.dart';
import 'package:zwiftdataviewer/models/routedata.dart';
import 'package:zwiftdataviewer/providers/activities_provider.dart';
import 'package:zwiftdataviewer/providers/routedataprovider.dart';
import 'package:zwiftdataviewer/providers/tabs_provider.dart';
import 'package:zwiftdataviewer/screens/layouts/mainlayout.dart';
import 'package:zwiftdataviewer/utils/constants.dart' as constants;
import 'package:zwiftdataviewer/utils/constants.dart';
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/widgets/filterdatebutton.dart';
import 'package:zwiftdataviewer/widgets/filterroutebutton.dart';


//This is temporary until I can figure out how to use the data for an AI analysis
class ActivitySummaries {
  List<ActivitySummary> activitySummaries = [];

  ActivitySummaries(this.activitySummaries);

  add(ActivitySummary activitySummary) {
    activitySummaries.add(activitySummary);
  }

  toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["activitySummaries"] =
        activitySummaries.map((v) => v.toJson()).toList();
    return data;
  }

  fromJson(Map<String, dynamic> json) {}

  writeToTerminal() {
    //for (ActivitySummary activitySummary in activitySummaries) {
    print(jsonEncode(toJson()));
    //}
  }
}

class ActivitySummary {
  String name;
  double averageWatts;
  double averageHeartrate;
  double averageSpeed;
  double distance;
  double totalElevationGain;

  ActivitySummary(this.name, this.averageWatts, this.averageHeartrate,
      this.averageSpeed, this.distance, this.totalElevationGain);

  toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['averageWatts'] = averageWatts.toStringAsFixed(1);
    data['averageHeartrate'] = averageHeartrate.toStringAsFixed(1);
    data['averageSpeed'] = averageSpeed.toStringAsFixed(1);
    data['distance'] = distance.toStringAsFixed(1);
    data['totalElevationGain'] = totalElevationGain.toStringAsFixed(1);
    return data;
  }

  fromJson(Map<String, dynamic> json) {
    return ActivitySummary(
        json["name"],
        json["averageWatts"],
        json["averageHeartrate"],
        json["averageSpeed"],
        json["distance"],
        json["totalElevationGain"]);
  }
}
//end temporary code

class HomeScreen extends MainLayout {
  HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<SummaryActivity>> activityList =
        ref.watch(stravaActivitiesProvider);

    //This is temporary until I can figure out how to use the data for an AI analysis
    final ActivitySummaries activitySummaries = ActivitySummaries([]);
    activityList.when(
        data: (List<SummaryActivity> data) {
          List<SummaryActivity> shortList = data.sublist(0, 5);
          for (SummaryActivity activity in shortList) {
            activitySummaries.add(ActivitySummary(
                activity.name,
                activity.averageWatts,
                activity.averageHeartrate,
                activity.averageSpeed * 2.237,
                activity.distance * 0.000621,
                activity.totalElevationGain * 3.2808));
          }
          activitySummaries.writeToTerminal();
        },
        error: (Object error, StackTrace stackTrace) {},
        loading: () {});
    //end temporary code

    return super.build(context, ref);
  }

  void refreshList() {}

  List<Widget> getActions(context, ref, List<SummaryActivity> activityData) {
    List<Widget> actions = [];
    final tabIndex = ref.watch(homeTabsNotifier);
    if (tabIndex == HomeScreenTab.activities.index) {
      actions.add(
        IconButton(
          onPressed: () {
            showSearch(
                context: context,
                delegate: ActivitySearch(activityData.reversed.toList()));
          },
          icon: const Icon(Icons.search, color: Colors.black),
        ),
      );
    }
    if (tabIndex == HomeScreenTab.stats.index) {
      actions.add(
        const FilterDateButton(isActive: true //tab == HomeScreenTab.stats,
            ),
      );
    }
    if (tabIndex == HomeScreenTab.routes.index) {
      actions.add(
        const FilterRouteButton(isActive: true //tab == HomeScreenTab.stats,
            ),
      );
    }
    return actions;
  }

  @override
  buildAppBar(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<SummaryActivity>> activityList =
        ref.watch(stravaActivitiesProvider);
    return activityList.when(
        data: (activityData) => AppBar(
              title: Text(
                "Zwift Data Viewer",
                style: appBarTextStyle,
              ),
              backgroundColor: Colors.white,
              elevation: 0.0,
              actions: getActions(context, ref, activityData),
            ),
        error: (Object error, StackTrace stackTrace) {
          AppBar(
            title: Text(
              "Zwift Data Viewer",
              style: appBarTextStyle,
            ),
            backgroundColor: Colors.white,
            elevation: 0.0,
          );
          return null;
        },
        loading: () {
          AppBar(
            title: Text(
              "Zwift Data Viewer",
              style: appBarTextStyle,
            ),
            backgroundColor: Colors.white,
            elevation: 0.0,
          );
          return null;
        });
  }

  @override
  buildBody(BuildContext context, WidgetRef ref) {
    final homePageTabs = ref.watch(homeTabsNotifier.notifier);
    return homePageTabs.getView(homePageTabs.index);
  }

  @override
  buildBottomNavigationBar(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<SummaryActivity>> activityList =
        ref.watch(stravaActivitiesProvider);

    final AsyncValue<Map<int, List<RouteData>>> routeDataState =
        ref.watch(routeDataProvider);

    return BottomNavigationBar(
      elevation: constants.cardElevation,
      key: AppKeys.tabs,
      currentIndex: tabIndex,
      onTap: (index) => ref.read(homeTabsNotifier.notifier).setIndex(index),
      type: BottomNavigationBarType.fixed,
      unselectedItemColor: zdvmMidBlue[100],
      fixedColor: zdvMidGreen,
      items: [
        activityList.when(
          data: (activityData) => BottomNavigationBarItem(
            icon: Badge(
              backgroundColor: zdvmYellow[100],
              label: Text(activityData.length.toString()),
              child: const Icon(Icons.list, key: AppKeys.activitiesTab),
            ),
            label: "Activities",
          ),
          loading: () => BottomNavigationBarItem(
              icon: Badge(
                backgroundColor: zdvmYellow[100],
                label: const Text("0"),
                child: const Icon(Icons.list, key: AppKeys.activitiesTab),
              ),
              label: "Activities"),
          error: (Object error, StackTrace stackTrace) =>
              BottomNavigationBarItem(
                  icon: Badge(
                    backgroundColor: zdvmYellow[100],
                    label: const Text("0"),
                    child: const Icon(Icons.list, key: AppKeys.activitiesTab),
                  ),
                  label: "Activities"),
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.show_chart, key: AppKeys.statsTab),
          label: "Statistics",
        ),
        routeDataState.when(
            data: (routeData) => BottomNavigationBarItem(
                  icon: Badge(
                    backgroundColor: zdvmYellow[100],
                    label: Text(routeData.values
                        .fold<int>(
                            0,
                            (sum, list) =>
                                sum +
                                (list.length ?? 0)) // Use null-aware operators
                        .toString()),
                    child: const Icon(Icons.route, key: AppKeys.routesTab),
                  ),
                  label: "Routes",
                ),
            error: (Object error, StackTrace stackTrace) =>
                const BottomNavigationBarItem(
                  icon: Icon(Icons.route, key: AppKeys.routesTab),
                  label: "Routes",
                ),
            loading: () => const BottomNavigationBarItem(
                  icon: Icon(Icons.route, key: AppKeys.routesTab),
                  label: "Routes",
                )),
        const BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today, key: AppKeys.calendarTab),
          label: "Calendars",
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.settings, key: AppKeys.settingsTab),
          label: "Settings",
        ),
      ],
    );
  }

  @override
  getTabIndex(WidgetRef ref) {
    return ref.watch(homeTabsNotifier);
  }
}
