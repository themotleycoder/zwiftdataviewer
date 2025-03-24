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
import 'package:zwiftdataviewer/utils/constants.dart';
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/utils/ui_helpers.dart';
import 'package:zwiftdataviewer/widgets/filterdatebutton.dart';
import 'package:zwiftdataviewer/widgets/filterroutebutton.dart';

/// A class representing the home screen of the application.
///
/// This screen serves as the main entry point of the application and provides
/// navigation to different sections through a bottom navigation bar.

class HomeScreen extends MainLayout {
  /// Creates a HomeScreen instance.
  ///
  /// @param key An optional key for this widget
  HomeScreen({super.key});


  /// Gets the action buttons for the app bar based on the current tab.
  ///
  /// @param context The BuildContext
  /// @param ref The WidgetRef
  /// @param activityData The list of summary activities
  /// @return A list of action widgets for the app bar
  List<Widget> getActions(BuildContext context, WidgetRef ref, List<SummaryActivity> activityData) {
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
      data: (activityData) => UIHelpers.buildAppBar(
        'Zwift Data Viewer',
        actions: getActions(context, ref, activityData),
      ),
      error: (Object error, StackTrace stackTrace) {
        return UIHelpers.buildAppBar('Zwift Data Viewer');
      },
      loading: () {
        return UIHelpers.buildAppBar('Zwift Data Viewer');
      },
    );
  }

  @override
  buildBody(BuildContext context, WidgetRef ref) {
    final homePageTabs = ref.watch(homeTabsNotifier.notifier);
    
    // Get the current tab view
    final currentView = homePageTabs.getView(homePageTabs.index);
    
    // Wrap the view with error handling for better user experience
    return currentView;
  }

  @override
  buildBottomNavigationBar(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<SummaryActivity>> activityList =
        ref.watch(stravaActivitiesProvider);

    final AsyncValue<Map<int, List<RouteData>>> routeDataState =
        ref.watch(routeDataProvider);

    return BottomNavigationBar(
      elevation: cardElevation,
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
            label: 'Activities',
          ),
          loading: () => BottomNavigationBarItem(
              icon: Badge(
                backgroundColor: zdvmYellow[100],
                label: const Text('0'),
                child: const Icon(Icons.list, key: AppKeys.activitiesTab),
              ),
              label: 'Activities'),
          error: (Object error, StackTrace stackTrace) {
            // Log error for debugging
            debugPrint('Error loading activities: $error');
            return BottomNavigationBarItem(
              icon: Badge(
                backgroundColor: zdvmYellow[100],
                label: const Text('0'),
                child: const Icon(Icons.list, key: AppKeys.activitiesTab),
              ),
              label: 'Activities',
            );
          },
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.show_chart, key: AppKeys.statsTab),
          label: 'Statistics',
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
                                (list.length)) // Use null-aware operators
                        .toString()),
                    child: const Icon(Icons.route, key: AppKeys.routesTab),
                  ),
                  label: 'Routes',
                ),
            error: (Object error, StackTrace stackTrace) {
              // Log error for debugging
              debugPrint('Error loading routes: $error');
              return const BottomNavigationBarItem(
                icon: Icon(Icons.route, key: AppKeys.routesTab),
                label: 'Routes',
              );
            },
            loading: () => const BottomNavigationBarItem(
                  icon: Icon(Icons.route, key: AppKeys.routesTab),
                  label: 'Routes',
                )),
        const BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today, key: AppKeys.calendarTab),
          label: 'Calendars',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.settings, key: AppKeys.settingsTab),
          label: 'Settings',
        ),
      ],
    );
  }

  @override
  getTabIndex(WidgetRef ref) {
    return ref.watch(homeTabsNotifier);
  }
}
