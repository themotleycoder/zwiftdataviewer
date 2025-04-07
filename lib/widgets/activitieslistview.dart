import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/globals.dart' as globals;
import 'package:flutter_strava_api/models/summary_activity.dart';
import 'package:flutter_strava_api/strava.dart';
import 'package:intl/intl.dart';
import 'package:zwiftdataviewer/screens/ridedetailscreen.dart';
import 'package:zwiftdataviewer/utils/constants.dart' as constants;
import 'package:zwiftdataviewer/utils/theme.dart';

import '../providers/activities_provider.dart';
import '../providers/activity_select_provider.dart';
import '../providers/tabs_provider.dart';
import '../secrets.dart';
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

  // Attempts to re-authenticate with Strava
  Future<void> _reAuthenticate(BuildContext context) async {
    try {
      // Create a new Strava instance
      final Strava strava = Strava(globals.isInDebug, clientSecret);
      const prompt = 'force'; // Force re-authentication
      
      // Attempt to authenticate
      final bool isAuthOk = await strava.oauth(
          clientId,
          'activity:write,activity:read_all,profile:read_all,profile:write',
          clientSecret,
          prompt);
      
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
        return Container(
            margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: ListView.separated(
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                return Container(
                  padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                  child: Center(
                    child: InkWell(
                        child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(constants.roundedCornerSize),
                      ),
                      tileColor: constants.tileBackgroundColor,
                      leading: const Icon(Icons.directions_bike,
                          size: 32.0, color: zdvOrange),
                      title: Text(activity.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: constants.headerFontStyle),
                      subtitle: Text(
                          "${Conversions.metersToDistance(ref, activity.distance).toStringAsFixed(1)} ${units['distance']} ${DateFormat.yMd().format(activity.startDateLocal)}"),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: zdvMidBlue,
                      ),
                      onTap: () {
                        ref.read(detailTabsNotifier.notifier).setIndex(0);
                        ref
                            .read(selectedActivityProvider.notifier)
                            .selectActivity(activity);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) {
                              return const DetailScreen(
                                  // id: activities[index].id ?? -1,
                                  // strava: strava,
                                  // onRemove: () {
                                  //   Navigator.pop(context);
                                  //   onRemove(context, todo);
                                  // },
                                  );
                            },
                          ),
                        );
                      },
                    )),
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(
                height: 10,
              ),
            ));
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
                error.toString().contains('No access token available')
                    ? 'Authentication Required'
                    : 'Error loading activities',
                style: constants.headerFontStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString().contains('No access token available')
                    ? 'Please authenticate with Strava to view your activities.'
                    : error.toString().contains('ClientException')
                        ? 'Network connection issue. Please check your internet connection.'
                        : 'An error occurred while loading activities.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  if (error.toString().contains('No access token available')) {
                    // Attempt to re-authenticate with Strava
                    await _reAuthenticate(context);
                  }
                  // Refresh both providers
                  ref.refresh(stravaActivitiesProvider);
                  ref.refresh(databaseActivitiesProvider(DateRange.allTime()));
                  ref.refresh(combinedActivitiesProvider);
                },
                icon: Icon(
                  error.toString().contains('No access token available')
                      ? Icons.login
                      : Icons.refresh,
                ),
                label: Text(
                  error.toString().contains('No access token available')
                      ? 'Connect to Strava'
                      : 'Retry',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: zdvMidBlue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
