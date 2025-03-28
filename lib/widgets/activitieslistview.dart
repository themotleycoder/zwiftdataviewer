import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/models/summary_activity.dart';
import 'package:intl/intl.dart';
import 'package:zwiftdataviewer/screens/ridedetailscreen.dart';
import 'package:zwiftdataviewer/utils/constants.dart' as constants;
import 'package:zwiftdataviewer/utils/theme.dart';

import '../providers/activities_provider.dart';
import '../providers/activity_select_provider.dart';
import '../providers/tabs_provider.dart';
import '../utils/conversions.dart';

class ActivitiesListView extends ConsumerWidget {
  const ActivitiesListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Map<String, String> units = Conversions.units(ref);

    final AsyncValue<List<SummaryActivity>> activitiesList =
        ref.watch(stravaActivitiesProvider);

    return Container(
      child: activitiesList.when(data: (activities) {
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
                'Error loading activities',
                style: constants.headerFontStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString().contains('ClientException')
                    ? 'Network connection issue. Please check your internet connection.'
                    : 'An error occurred while loading activities.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // Refresh the activities provider
                  ref.refresh(stravaActivitiesProvider);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
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
