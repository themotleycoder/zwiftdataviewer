import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/utils/constants.dart';
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/widgets/filterdatebutton.dart';

import '../delegates/activitysearchdelegate.dart';
import '../providers/activities_provider.dart';
import '../providers/tabs_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final activities = ref.watch(activitiesProvider.notifier);
    final homePageTabs = ref.watch(homeTabsNotifier.notifier);
    final tabIndex = ref.watch(homeTabsNotifier);

    // activities.loadActivities(ref);

    return Scaffold(
        appBar: AppBar(
            title: Text(
              "Zwift Data Viewer",
              style: appBarTextStyle,
            ),
            backgroundColor: zdvMidBlue,
            elevation: 0.0,
            actions: getActions(context, ref)),
        body: Stack(children: [
          Container(
            child: homePageTabs.getView(homePageTabs.index),
          )
        ]),
        bottomNavigationBar: BottomNavigationBar(
          key: AppKeys.tabs,
          currentIndex: tabIndex,
          onTap: (index) => ref.read(homeTabsNotifier.notifier).setIndex(index),
          type: BottomNavigationBarType.fixed,
          unselectedItemColor: zdvmMidBlue[100],
          fixedColor: zdvmOrange[100],
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.list, key: AppKeys.activitiesTab),
              label: "Activities",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart, key: AppKeys.statsTab),
              label: "Statistics",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today, key: AppKeys.calendarTab),
              label: "Calendar",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings, key: AppKeys.settingsTab),
              label: "Settings",
            ),
          ],
        ));
  }

  void refreshList() {}

  List<Widget> getActions(context, ref) {
    List<Widget> actions = [];
    final activities = ref.read(stravaActivitiesProvider.notifier);
    final tabIndex = ref.watch(homeTabsNotifier);
    if (tabIndex == HomeScreenTab.activities.index) {
      actions.add(
        IconButton(
          onPressed: () {
            showSearch(
                context: context,
                delegate: ActivitySearch(activities.activities));
          },
          icon: const Icon(Icons.search, color: Colors.white),
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
