import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:zwiftdataviewer/screens/ridedetailscreen.dart';
import 'package:zwiftdataviewer/secrets.dart';
import 'package:zwiftdataviewer/stravalib/Models/activity.dart';
import 'package:zwiftdataviewer/stravalib/globals.dart' as globals;
import 'package:zwiftdataviewer/stravalib/strava.dart';
import 'package:zwiftdataviewer/utils/constants.dart' as constants;
import 'package:zwiftdataviewer/utils/theme.dart';

import '../providers/activities_provider.dart';
import '../providers/activity_select_provider.dart';
import '../utils/constants.dart';

class ActivitiesListView extends ConsumerWidget {
  const ActivitiesListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Strava strava = Strava(globals.isInDebug, secret);
    List<SummaryActivity> activities = [];

    activities = ref.watch(activitiesProvider);

    return Container(
        margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
        child: ListView.builder(
          itemCount: activities.length,
          itemBuilder: (context, index) {
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
                      title: Text(activities[index].name ?? "",
                          style: constants.headerFontStyle),
                      subtitle: Text(DateFormat.yMd()
                          .add_jm()
                          .format(activities[index].startDateLocal!)),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: zdvMidBlue,
                      ),
                      onTap: () {
                        ref.read(activitySelectProvider.notifier).setActivitySelect(activities[index].id!);
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
// }));
}
