import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/providers/activities_provider.dart';
import 'package:zwiftdataviewer/providers/tabs_provider.dart';
import 'package:zwiftdataviewer/strava_lib/Models/summary_activity.dart';
import 'package:zwiftdataviewer/utils/constants.dart';
import 'package:zwiftdataviewer/utils/constants.dart' as constants;
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/widgets/filterdatebutton.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homePageTabs = ref.watch(homeTabsNotifier.notifier);
    final tabIndex = ref.watch(homeTabsNotifier);
    List<SummaryActivity> activities = [];

    // final List<SummaryActivity> activities =
    //     ref.watch(stravaActivitiesProvider);

    final AsyncValue<List<SummaryActivity>> activitiesList = ref.watch(stravaActivitiesProvider);

    activitiesList.when(
      data: (a) {
        activities = a;
      },
      loading: () {},
      error: (error, stackTrace) {
        print(error);
      },
    );

    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Zwift Data Viewer",
            style: appBarTextStyle,
          ),
          backgroundColor: Colors.white,
          elevation: 0.0,
          actions: getActions(context, ref),
        ),
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
          fixedColor: zdvmOrange[400],
          items: [
            BottomNavigationBarItem(
              icon: Badge(
                backgroundColor: zdvmYellow[100],
                label: Text(activities.length.toString()),
                child: const Icon(Icons.list, key: AppKeys.activitiesTab),
              ),
              label: "Activities",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.show_chart, key: AppKeys.statsTab),
              label: "Statistics",
            ),
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

  List<Widget> getActions(context, ref) {
    List<Widget> actions = [];
    final AsyncValue<List<SummaryActivity>> activitiesList =
        ref.read(stravaActivitiesProvider);
    final tabIndex = ref.watch(homeTabsNotifier);
    if (tabIndex == HomeScreenTab.activities.index) {
      actions.add(
        IconButton(
          onPressed: () {
            // showSearch(
            //     context: context,
            //     delegate: ActivitySearch(activities.state.reversed.toList()));
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
    return actions;
  }
}
