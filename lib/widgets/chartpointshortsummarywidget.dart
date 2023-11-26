import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/Models/summary_activity.dart';
import 'package:zwiftdataviewer/providers/activity_select_provider.dart';
import 'package:zwiftdataviewer/screens/ridedetailscreen.dart';
import 'package:zwiftdataviewer/utils/constants.dart' as constants;
import 'package:zwiftdataviewer/utils/conversions.dart';
import 'package:zwiftdataviewer/widgets/iconitemwidgets.dart';
import 'package:zwiftdataviewer/widgets/tilewidget.dart';

import '../utils/theme.dart';

Container getChartPointShortSummaryWidget(
    BuildContext context, WidgetRef ref, Map<String, String> units) {

  final SummaryActivity selectedActivity = ref.watch(selectedActivityProvider);

  return Container(
    padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            layoutTile(Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                      child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
                          child: Text(
                              selectedActivity.name == ""
                                  ? "No ride selected"
                                  : selectedActivity.name,
                              style: constants.bodyTextStyle,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              textAlign: TextAlign.left))),
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: selectedActivity.name != ""
                        ? IconButton(
                            color: zdvMidBlue,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) {
                                    return DetailScreen();
                                  },
                                ),
                              );
                            },
                            icon: const Icon(Icons.arrow_forward_ios),
                          )
                        : null,
                  ),
                ])),
          ],
        ),
        IconHeaderDataRow([
          IconDataObject(
              'Distance',
              Conversions.metersToDistance(ref, selectedActivity.distance)
                  .toStringAsFixed(1),
              Icons.route,
              units: units['distance']),
          IconDataObject(
              'Elevation',
              Conversions.metersToHeight(
                      ref, selectedActivity.totalElevationGain)
                  .toStringAsFixed(1),
              Icons.filter_hdr,
              units: units['height']),
        ]),
        IconHeaderDataRow([
          IconDataObject(
              'Time',
              Conversions.secondsToTime(selectedActivity.elapsedTime),
              Icons.schedule,
              units: units['height']),
          IconDataObject('Power', (selectedActivity.averageWatts).toString(),
              Icons.electric_bolt,
              units: 'w')
        ]),
      ],
    ),
  );
}
// }
