import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/providers/activity_detail_provider.dart';
import 'package:zwiftdataviewer/providers/tabs_provider.dart';
import 'package:zwiftdataviewer/screens/layouts/mainlayout.dart';
import 'package:zwiftdataviewer/screens/routedetailscreen.dart';
import 'package:zwiftdataviewer/screens/routesectiondetailscreen.dart';
import 'package:zwiftdataviewer/screens/routestats/routeanalysisrootscreen.dart';
import 'package:zwiftdataviewer/utils/constants.dart';
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/utils/ui_helpers.dart';

/// A screen that displays detailed information about a ride.
///
/// This screen shows various details about a selected ride, including
/// route information, analysis, and sections. It uses a bottom navigation
/// bar to switch between different views of the ride data.
class DetailScreen extends MainLayout {
  /// Creates a DetailScreen instance.
  ///
  /// @param key An optional key for this widget
  const DetailScreen({super.key});

  @override
  buildAppBar(BuildContext context, WidgetRef ref) {
    final activityDetail = ref.watch(stravaActivityDetailsProvider);

    return UIHelpers.buildAppBar(
      '${activityDetail.name}',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
        tooltip: 'Back',
      ),
    );
  }

  @override
  buildBody(BuildContext context, WidgetRef ref) {
    // Return the appropriate screen based on the selected tab
    final currentTabIndex = getTabIndex(ref);
    switch (currentTabIndex) {
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
    final currentIndex = ref.watch(detailTabsNotifier);
    return BottomNavigationBar(
      elevation: cardElevation,
      key: AppKeys.tabs,
      currentIndex: currentIndex,
      onTap: (index) => ref.read(detailTabsNotifier.notifier).setIndex(index),
      type: BottomNavigationBarType.fixed,
      unselectedItemColor: zdvmMidBlue[100],
      fixedColor: zdvmMidGreen[100],
      items: const [
        // Navigation items with semantic labels for accessibility
        BottomNavigationBarItem(
          icon: Icon(Icons.list, key: AppKeys.activitiesTab),
          label: 'Details',
          tooltip: 'View ride details',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.insights, key: AppKeys.analysisTab),
          label: 'Analysis',
          tooltip: 'View ride analysis',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today, key: AppKeys.sectionsTab),
          label: 'Sections',
          tooltip: 'View ride sections',
        ),
      ],
    );
  }

  @override
  getTabIndex(WidgetRef ref) {
    return ref.watch(detailTabsNotifier);
  }
}
