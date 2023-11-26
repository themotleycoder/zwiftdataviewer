import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/screens/layouts/mainlayout.dart';
import 'package:zwiftdataviewer/screens/routedetailscreen.dart';
import 'package:zwiftdataviewer/screens/routesectiondetailscreen.dart';
import 'package:zwiftdataviewer/screens/routestats/routeanalysisrootscreen.dart';
import 'package:zwiftdataviewer/utils/constants.dart' as constants;
import 'package:zwiftdataviewer/utils/theme.dart';

import '../providers/activity_detail_provider.dart';
import '../providers/tabs_provider.dart';

class DetailScreen extends MainLayout {
  DetailScreen({super.key});

  @override
  buildAppBar(BuildContext context, WidgetRef ref) {
    final activityDetail = ref.watch(stravaActivityDetailsProvider);
    return AppBar(
        title: Text("${activityDetail.name} ",
            // "(${DateFormat.yMd().format(
            // DateTime.parse(activityDetail.startDate))})",
            style: constants.appBarTextStyle),
        backgroundColor: Colors.white,
        elevation: 0.0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            }));
  }

  @override
  buildBody(BuildContext context, WidgetRef ref) {
    // final tabIndex = ref.watch(detailTabsNotifier);
    switch (tabIndex) {
      case 1:
        return const RouteAnalysisScreen();
      case 2:
        return const RouteSectionDetailScreen();
      case 0:
      default:
        return const RouteDetailScreen();
    }
  }

  @override
  buildBottomNavigationBar(BuildContext context, WidgetRef ref) {
    // final tabIndex = ref.read(detailTabsNotifier);
    return BottomNavigationBar(
      elevation: constants.cardElevation,
      key: AppKeys.tabs,
      currentIndex: tabIndex,
      onTap: (index) => ref.read(detailTabsNotifier.notifier).setIndex(index),
      type: BottomNavigationBarType.fixed,
      unselectedItemColor: zdvmMidBlue[100],
      fixedColor: zdvmMidGreen[100],
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.list, key: AppKeys.activitiesTab),
          label: "Details",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.insights, key: AppKeys.analysisTab),
          label: "Analysis",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today, key: AppKeys.sectionsTab),
          label: "Sections",
        ),
      ],
    );
  }

  @override
  getTabIndex(WidgetRef ref) {
    return ref.read(detailTabsNotifier);
  }
}
