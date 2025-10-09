import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/models/summary_activity.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/delegates/activitysearchdelegate.dart';
import 'package:zwiftdataviewer/models/routedata.dart';
import 'package:zwiftdataviewer/providers/routedataprovider.dart';
import 'package:zwiftdataviewer/providers/route_recommendations_provider.dart';
import 'package:zwiftdataviewer/providers/segment_count_provider.dart';
import 'package:zwiftdataviewer/providers/tabs_provider.dart';
import 'package:zwiftdataviewer/screens/layouts/mainlayout.dart';
import 'package:zwiftdataviewer/screens/route_recommendations_screen.dart';
import 'package:zwiftdataviewer/utils/constants.dart';
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/utils/ui_helpers.dart';
import 'package:zwiftdataviewer/widgets/activitieslistview.dart';
import 'package:zwiftdataviewer/widgets/filterdatebutton.dart';

// A class representing the home screen of the application.
//
// This screen serves as the main entry point of the application and provides
// navigation to different sections through a bottom navigation bar.

class HomeScreen extends MainLayout {
  // Creates a HomeScreen instance.
  //
  // @param key An optional key for this widget
  const HomeScreen({super.key});

  // Gets the title for the app bar based on the current tab.
  //
  // @param ref The WidgetRef
  // @return The title string for the current tab
  String getTitle(WidgetRef ref) {
    final tabIndex = ref.watch(homeTabsNotifier);
    switch (tabIndex) {
      case 0: // HomeScreenTab.activities
        return 'Activities';
      case 1: // HomeScreenTab.stats
        return 'Statistics';
      case 2: // HomeScreenTab.routes
        return 'Routes';
      case 3: // HomeScreenTab.recommendations
        return 'AI Routes';
      case 4: // HomeScreenTab.calendar
        return 'Calendars';
      case 5: // HomeScreenTab.segments
        return 'Segments';
      case 6: // HomeScreenTab.settings
        return 'Settings';
      default:
        return 'Zwift Data Viewer';
    }
  }

  // Gets the action buttons for the app bar based on the current tab.
  //
  // @param context The BuildContext
  // @param ref The WidgetRef
  // @param activityData The list of summary activities
  // @return A list of action widgets for the app bar
  List<Widget> getActions(
      BuildContext context, WidgetRef ref, List<SummaryActivity> activityData) {
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
    if (tabIndex == HomeScreenTab.recommendations.index) {
      actions.add(
        IconButton(
          onPressed: () => _showFilterMenu(context, ref),
          icon: const Icon(Icons.filter_list, color: Colors.black),
          tooltip: 'Filter recommendations',
        ),
      );
      actions.add(
        IconButton(
          onPressed: () => _showRegenerateDialog(context, ref),
          icon: const Icon(Icons.refresh, color: Colors.black),
          tooltip: 'Regenerate recommendations',
        ),
      );
    }
    return actions;
  }

  @override
  buildAppBar(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<SummaryActivity>> activityList =
        ref.watch(combinedActivitiesProvider);

    return activityList.when(
      data: (activityData) => UIHelpers.buildAppBar(
        getTitle(ref),
        actions: getActions(context, ref, activityData),
      ),
      error: (Object error, StackTrace stackTrace) {
        return UIHelpers.buildAppBar(getTitle(ref));
      },
      loading: () {
        return UIHelpers.buildAppBar(getTitle(ref));
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
        ref.watch(combinedActivitiesProvider);

    final AsyncValue<Map<int, List<RouteData>>> routeDataState =
        ref.watch(routeDataProvider);
        
    final AsyncValue<int> segmentCountState =
        ref.watch(segmentCountProvider);
        
    final int unviewedRecommendationsCount = 
        ref.watch(unviewedRecommendationsCountProvider);

    return BottomNavigationBar(
      elevation: cardElevation,
      key: AppKeys.tabs,
      currentIndex: getTabIndex(ref),
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
                backgroundColor: Colors.red[100],
                label: const Icon(Icons.error_outline, size: 10, color: Colors.red),
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
                                sum + (list.length)) // Use null-aware operators
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
        BottomNavigationBarItem(
          icon: Badge(
            backgroundColor: zdvOrange,
            isLabelVisible: unviewedRecommendationsCount > 0,
            label: Text(
              unviewedRecommendationsCount.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            child: const Icon(Icons.auto_awesome),
          ),
          label: 'AI Routes',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today, key: AppKeys.calendarTab),
          label: 'Calendars',
        ),
        segmentCountState.when(
          data: (count) => BottomNavigationBarItem(
            icon: Badge(
              backgroundColor: zdvmYellow[100],
              label: Text(count.toString()),
              child: const Icon(Icons.landscape, key: AppKeys.segmentsTab),
            ),
            label: 'Segments',
          ),
          loading: () => const BottomNavigationBarItem(
            icon: Icon(Icons.landscape, key: AppKeys.segmentsTab),
            label: 'Segments',
          ),
          error: (Object error, StackTrace stackTrace) {
            // Log error for debugging
            debugPrint('Error loading segment count: $error');
            return const BottomNavigationBarItem(
              icon: Icon(Icons.landscape, key: AppKeys.segmentsTab),
              label: 'Segments',
            );
          },
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

  void _showFilterMenu(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.read(recommendationFilterProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Recommendations'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: RecommendationFilter.values.map((filter) {
            return RadioListTile<RecommendationFilter>(
              title: Text(filter.label),
              value: filter,
              groupValue: currentFilter,
              onChanged: (RecommendationFilter? value) {
                if (value != null) {
                  ref.read(recommendationFilterProvider.notifier).state = value;
                  Navigator.pop(context);
                }
              },
              activeColor: zdvOrange,
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showRegenerateDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Regenerate Recommendations'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose how to generate new recommendations:'),
            SizedBox(height: 16.0),
            Text(
              '• AI Recommendations: Uses Google Gemini AI to analyze your performance',
              style: TextStyle(fontSize: 13),
            ),
            SizedBox(height: 8.0),
            Text(
              '• From Route Data: Uses algorithmic analysis without AI',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _generateFromExistingRoutes(context, ref);
            },
            child: const Text('From Route Data'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _generateNewRecommendations(context, ref);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: zdvOrange,
              foregroundColor: Colors.white,
            ),
            child: const Text('AI Recommendations'),
          ),
        ],
      ),
    );
  }

  void _generateNewRecommendations(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(routeRecommendationsProvider.notifier).generateNewRecommendations();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AI recommendations generated!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate AI recommendations: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _generateFromExistingRoutes(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(routeRecommendationsProvider.notifier).generateRecommendationsFromAvailableRoutes();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Route recommendations generated from your data!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate recommendations: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
