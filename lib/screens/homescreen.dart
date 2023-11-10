import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/Models/summary_activity.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/delegates/activitysearchdelegate.dart';
import 'package:zwiftdataviewer/models/routedata.dart';
import 'package:zwiftdataviewer/providers/activities_provider.dart';
import 'package:zwiftdataviewer/providers/routedataprovider.dart';
import 'package:zwiftdataviewer/providers/tabs_provider.dart';
import 'package:zwiftdataviewer/utils/constants.dart';
import 'package:zwiftdataviewer/utils/constants.dart' as constants;
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/widgets/filterdatebutton.dart';
import 'package:zwiftdataviewer/widgets/filterroutebutton.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homePageTabs = ref.watch(homeTabsNotifier.notifier);
    final tabIndex = ref.watch(homeTabsNotifier);
    int count = 0;

    final AsyncValue<List<SummaryActivity>> activitiesList =
        ref.watch(stravaActivitiesProvider);

    final AsyncValue<Map<int, List<RouteData>>> routeDataState =
        ref.watch(routeDataProvider);

    routeDataState.when(data: (Map<int, List<RouteData>> data) {
      List<RouteData> element;
      for(element in data.values) {
        count += element.length;
      }
    }, error: (Object error, StackTrace stackTrace) {
      count = 0;
    }, loading: () {
      count = 0;
    });

    return Scaffold(
        appBar: activitiesList.when(
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
            }),
        body: Stack(children: [
          Container(
            child: homePageTabs.getView(homePageTabs.index),
          ),
        ]),
        bottomNavigationBar: BottomNavigationBar(
          elevation: constants.cardElevation,
          key: AppKeys.tabs,
          currentIndex: tabIndex,
          onTap: (index) => ref.read(homeTabsNotifier.notifier).setIndex(index),
          type: BottomNavigationBarType.fixed,
          unselectedItemColor: zdvmMidBlue[100],
          fixedColor: zdvMidGreen,
          items: [
            activitiesList.when(
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
                        child:
                            const Icon(Icons.list, key: AppKeys.activitiesTab),
                      ),
                      label: "Activities"),
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.show_chart, key: AppKeys.statsTab),
              label: "Statistics",
            ),
            // routeDataModel.when(
            //     data: (routeData) =>
            BottomNavigationBarItem(
              icon: Badge(
                backgroundColor: zdvmYellow[100],
                label: Text(count.toString()),
                child: const Icon(Icons.route, key: AppKeys.routesTab),
              ),
              label: "Routes",
            ),
            // error: (Object error, StackTrace stackTrace) =>
            //     const BottomNavigationBarItem(
            //       icon: Icon(Icons.route, key: AppKeys.routesTab),
            //       label: "Routes",
            //     ),
            // loading: () => const BottomNavigationBarItem(
            //       icon: Icon(Icons.route, key: AppKeys.routesTab),
            //       label: "Routes",
            //     )),
            const BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today, key: AppKeys.calendarTab),
              label: "Calendar",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.settings, key: AppKeys.settingsTab),
              label: "Settings",
            ),
          ],
        ));
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
}
