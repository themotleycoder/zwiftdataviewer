import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/providers/activity_select_provider.dart';
import 'package:zwiftdataviewer/screens/ridedetailscreen.dart';
import 'package:zwiftdataviewer/strava_lib/Models/summary_activity.dart';
import 'package:zwiftdataviewer/utils/constants.dart' as constants;
import 'package:zwiftdataviewer/utils/conversions.dart';
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/widgets/iconitemwidgets.dart';

class ChartPointShortSummaryWidget extends ConsumerWidget {
  const ChartPointShortSummaryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SummaryActivity selectedActivity =
        ref.watch(selectedActivityProvider);
    final Map<String, String> units = Conversions.units(ref);

    return Container(
      padding: const EdgeInsets.fromLTRB(0,0,0,16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          InkWell(
              onTap: () {
                selectedActivity.name != ""
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) {
                            return const DetailScreen();
                          },
                        ),
                      )
                    : null;
              },
              child: Row(children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                    child: Text(selectedActivity.name,
                        style: constants.bodyTextStyle,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.left),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                  child: selectedActivity.name != ""
                      ? const Icon(
                          Icons.arrow_forward_ios,
                          color: zdvMidBlue,
                        )
                      : null,
                ),
              ])),
          IconHeaderDataRow([
            IconDataObject(
                'Distance',
                Conversions.metersToDistance(
                    ref, selectedActivity.distance)
                    .toStringAsFixed(1),
                Icons.route,
                units: units['distance']),
            IconDataObject(
                'Elevation',
                Conversions.metersToHeight(ref, selectedActivity.totalElevationGain)
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
}
