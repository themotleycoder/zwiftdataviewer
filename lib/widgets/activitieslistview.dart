import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/models/summary_activity.dart';
import 'package:intl/intl.dart';
import 'package:zwiftdataviewer/screens/ridedetailscreen.dart';
import 'package:zwiftdataviewer/utils/constants.dart' as constants;
import 'package:zwiftdataviewer/utils/strava_api_helper.dart';
import 'package:zwiftdataviewer/utils/theme.dart';

import '../providers/activities_provider.dart';
import '../providers/activity_select_provider.dart';
import '../providers/tabs_provider.dart';
import '../utils/conversions.dart';
import '../utils/database/database_init.dart';

// Fetches activities from Strava API since a specific date
Future<List<SummaryActivity>> fetchStravaActivitiesSinceDate(DateTime sinceDate) async {
  try {
    // Save the provided date as the last activity date
    // This will be used by fetchStravaActivities to determine the 'after' timestamp
    await saveLastActivityDate(sinceDate);
    
    // Now call fetchStravaActivities which will use the saved date
    return await fetchStravaActivities();
  } catch (e) {
    debugPrint('Error fetching Strava activities since date: $e');
    return [];
  }
}

// Combined provider that merges Strava API and database activities
final combinedActivitiesProvider = FutureProvider<List<SummaryActivity>>((ref) async {
  // First try to get activities from the database
  final dbActivities = await ref.watch(
    databaseActivitiesProvider(DateRange.allTime()).future,
  );
  
  // If we have database activities
  if (dbActivities.isNotEmpty) {
    try {
      // Find the most recent activity date
      final mostRecentActivity = dbActivities.first; // Activities are already sorted newest first
      final mostRecentDate = mostRecentActivity.startDate;
      
      debugPrint('Most recent activity date: $mostRecentDate');
      
      // Fetch any new activities from Strava API since that date
      final newActivities = await fetchStravaActivitiesSinceDate(mostRecentDate);
      
      if (newActivities.isNotEmpty) {
        debugPrint('Fetched ${newActivities.length} new activities from Strava API');
        
        // Save new activities to the database
        // Note: fetchStravaActivities already saves activities to the database,
        // but we'll make sure they're saved here as well
        try {
          final activityService = DatabaseInit.activityService;
          await activityService.saveActivities(newActivities);
          debugPrint('Saved ${newActivities.length} new activities to database');
        } catch (e) {
          debugPrint('Error saving new activities to database: $e');
          // Continue even if saving to database fails
        }
        
        // Combine both sets of activities
        final allActivities = [...newActivities, ...dbActivities];
        
        // Remove duplicates (in case we're re-fetching some activities)
        final Map<String, SummaryActivity> uniqueActivities = {};
        for (var activity in allActivities) {
          uniqueActivities[activity.id.toString()] = activity;
        }
        
        // Convert back to list and sort by date (newest first)
        final result = uniqueActivities.values.toList();
        result.sort((a, b) => b.startDate.compareTo(a.startDate));
        
        return result;
      }
      
      // If no new activities, return database activities
      return dbActivities;
    } catch (e) {
      debugPrint('Error fetching new activities: $e');
      // If there's an error fetching new activities, return database activities
      return dbActivities;
    }
  }
  
  // If no database activities, try to fetch from Strava API
  try {
    return await ref.watch(stravaActivitiesProvider.future);
  } catch (e) {
    // If both fail, return an empty list
    return [];
  }
});

class ActivitiesListView extends ConsumerWidget {
  const ActivitiesListView({super.key});
  
  // Returns an appropriate error title based on the error message
  String _getErrorTitle(String errorMessage) {
    if (errorMessage.contains('No access token available')) {
      return 'Authentication Required';
    } else if (errorMessage.contains('403')) {
      return 'Strava API Access Denied';
    } else if (errorMessage.contains('Request blocked')) {
      return 'Strava API Request Blocked';
    } else if (errorMessage.contains('ClientException')) {
      return 'Network Connection Issue';
    } else {
      return 'Error Loading Activities';
    }
  }
  
  // Returns a detailed error message based on the error type
  String _getErrorMessage(String errorMessage) {
    if (errorMessage.contains('No access token available')) {
      return 'Please authenticate with Strava to view your activities.';
    } else if (errorMessage.contains('403')) {
      return 'Your Strava API access may have been revoked or expired. Please check your API credentials in Settings > Strava API Status.';
    } else if (errorMessage.contains('Request blocked')) {
      return 'Strava is blocking API requests. This may be due to rate limiting or changes in Strava\'s API policies. Try again later or check Settings > Strava API Status.';
    } else if (errorMessage.contains('ClientException')) {
      return 'Network connection issue. Please check your internet connection.';
    } else if (errorMessage.contains('token expired')) {
      return 'Your Strava authentication has expired. Please reconnect to Strava.';
    } else {
      return 'An error occurred while loading activities. Check Settings > Strava API Status for troubleshooting.';
    }
  }

  // Attempts to re-authenticate with Strava using the email code method
  Future<void> _reAuthenticate(BuildContext context) async {
    try {
      // Use the new email authentication method
      final bool isAuthOk = await StravaApiHelper.authenticateWithEmailCode(context);

      if (!context.mounted) return;

      if (isAuthOk) {
        // Authentication successful
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully connected to Strava'),
            backgroundColor: zdvMidBlue,
          ),
        );
      } else {
        // Authentication failed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to connect to Strava. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      // Handle any exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error connecting to Strava: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Map<String, String> units = Conversions.units(ref);

    // Use the combined provider that merges Strava API and database activities
    final AsyncValue<List<SummaryActivity>> activitiesList =
        ref.watch(combinedActivitiesProvider);

    return Container(
      child: activitiesList.when(data: (activities) {
        // Use activities directly (already sorted newest first)
        return RefreshIndicator(
          onRefresh: () async {
            // Invalidate all activity providers to force a reload
            ref.invalidate(databaseActivitiesProvider);
            ref.invalidate(stravaActivitiesProvider);
            ref.invalidate(combinedActivitiesProvider);

            // Wait for the provider to reload
            await ref.read(combinedActivitiesProvider.future);
          },
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: constants.tileBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.separated(
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: zdvMidBlue,
                    child: Text(
                      activity.name.substring(0, 2).toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    activity.name,
                    style: const TextStyle(
                      color: zdvDrkBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        '${Conversions.metersToDistance(ref, activity.distance).toStringAsFixed(1)} ${units['distance']}',
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('MMM d').format(activity.startDateLocal),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, color: zdvMidBlue, size: 16),
                  onTap: () {
                    ref.read(detailTabsNotifier.notifier).setIndex(0);
                    ref.read(selectedActivityProvider.notifier).selectActivity(activity);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DetailScreen(),
                      ),
                    );
                  },
                );
              },
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Colors.grey[300],
              ),
            ),
          ),
        );
      }, loading: () {
        return const Center(child: CircularProgressIndicator());
      }, error: (error, stack) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: zdvOrange,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                _getErrorTitle(error.toString()),
                style: constants.headerFontStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _getErrorMessage(error.toString()),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (error.toString().contains('No access token available') ||
                          error.toString().contains('token expired')) {
                        // Attempt to re-authenticate with Strava
                        await _reAuthenticate(context);
                      }
                      // Refresh both providers
                      // ignore: unused_result
                      ref.refresh(stravaActivitiesProvider);
                      // ignore: unused_result
                      ref.refresh(databaseActivitiesProvider(DateRange.allTime()));
                      // ignore: unused_result
                      ref.refresh(combinedActivitiesProvider);
                    },
                    icon: Icon(
                      error.toString().contains('No access token available') ||
                              error.toString().contains('token expired')
                          ? Icons.login
                          : Icons.refresh,
                    ),
                    label: Text(
                      error.toString().contains('No access token available') ||
                              error.toString().contains('token expired')
                          ? 'Connect to Strava'
                          : 'Retry',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: zdvMidBlue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  
                  // Show troubleshooting button for API-related errors
                  if (error.toString().contains('403') ||
                      error.toString().contains('Request blocked') ||
                      error.toString().contains('API access denied'))
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to settings screen and select the Strava API tab
                          ref.read(homeTabsNotifier.notifier).setIndex(5); // Settings tab
                        },
                        icon: const Icon(Icons.build),
                        label: const Text('Troubleshoot'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: zdvOrange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
