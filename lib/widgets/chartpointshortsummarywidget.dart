import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/models/summary_activity.dart';
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
  
  // Debug print to verify the selected activity in the widget
  if (kDebugMode) {
    print('Widget displaying activity: ${selectedActivity.name}, ID: ${selectedActivity.id}');
  }

  return Container(
    padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
    // Add animation for smoother transitions when selection changes
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        // Add subtle highlight when an activity is selected
        color: selectedActivity.id != 0 ? Colors.blue.withOpacity(0.05) : null,
        borderRadius: BorderRadius.circular(8),
      ),
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
                                selectedActivity.name == ''
                                    ? 'No ride selected'
                                    : selectedActivity.name,
                                style: constants.bodyTextStyle,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                textAlign: TextAlign.left))),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: selectedActivity.name != ''
                          ? IconButton(
                              color: zdvMidBlue,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) {
                                      return const DetailScreen();
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
          iconHeaderDataRow([
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
          iconHeaderDataRow([
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
    ),
  );
}
