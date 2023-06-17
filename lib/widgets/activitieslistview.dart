import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:zwiftdataviewer/screens/ridedetailscreen.dart';
import 'package:zwiftdataviewer/utils/constants.dart' as constants;
import 'package:zwiftdataviewer/utils/theme.dart';

import '../providers/activities_provider.dart';
import '../providers/activity_select_provider.dart';
import '../providers/tabs_provider.dart';
import '../stravalib/Models/summary_activity.dart';
import '../utils/constants.dart';
import '../utils/conversions.dart';

class ActivitiesListView extends ConsumerWidget {
  const ActivitiesListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Map<String, String> units = Conversions.units(ref);

    final List<SummaryActivity> activities =
        ref.watch(stravaActivitiesProvider).reversed.toList();

    if (activities.isEmpty) {
      ref.read(stravaActivitiesProvider.notifier).loadActivities();
      return const Center(child: CircularProgressIndicator());
    } else {
      return Container(
          margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
          child: ListView.builder(
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              return Container(
                padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                child: Center(
                    child: InkWell(
                  child: Card(
                      color: white,
                      elevation: defaultCardElevation,
                      child: ListTile(
                        leading: const Icon(Icons.directions_bike,
                            size: 32.0, color: zdvOrange),
                        title: Text(activity.name,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: constants.headerFontStyle),
                        subtitle: Text(
                            "${Conversions.metersToDistance(ref, activity.distance).toStringAsFixed(1)} ${units['distance']} ${DateFormat.yMd()
                                .format(activity.startDateLocal)}"),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: zdvMidBlue,
                        ),
                        onTap: () {
                          ref.read(detailTabsNotifier.notifier).setIndex(0);
                          ref
                              .read(selectedActivityProvider.notifier)
                              .selectActivity(activity);
                          // ref.read(activitySelectProvider.notifier).setActivitySelect(activities[index]);
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
                        // onItemClick(_activities[index], context);
                      )),
                )),
                // margin: EdgeInsets.all(1.0),
              );
            },
          ));
    }
  }
// }));
}
