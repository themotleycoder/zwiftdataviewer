import 'package:flutter/material.dart';
import 'package:zwiftdataviewer/models/ActivityDetailDataModel.dart';
import 'package:zwiftdataviewer/secrets.dart';
import 'package:zwiftdataviewer/stravalib/globals.dart' as Globals;
import 'package:zwiftdataviewer/stravalib/strava.dart';

import '../utils/conversions.dart';
import '../widgets/listitemviews.dart';

class ShortDataAnalysis extends StatelessWidget {
  final LapSummaryObject? lapSummaryObject;

  const ShortDataAnalysis(this.lapSummaryObject, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Strava strava = Strava(Globals.isInDebug, secret);
    Map<String, String> units = Conversions.units(context);
    return Expanded(
        flex: 1,
        // child: Container(
        //         // top: 100,
        //         margin: const EdgeInsets.fromLTRB(0, 16, 0, 0),
        child: ListView(
            // padding: const EdgeInsets.all(8.0),
            children: <Widget>[
              doubleDataHeaderLineItem(
                ['Time', 'Avg Power (w)'],
                [
                  Conversions.secondsToTime(lapSummaryObject?.time ?? 0),
                  (lapSummaryObject?.watts ?? 0).toStringAsFixed(1),
                ],
              ),
              doubleDataHeaderLineItem(
                [
                  'Avg Cadence (rpm)',
                  'Avg Speed (${units['speed']!})',
                ],
                [
                  (lapSummaryObject?.cadence ?? 0).toStringAsFixed(0),
                  Conversions.mpsToMph(lapSummaryObject?.speed ?? 0)
                      .toStringAsFixed(1),
                ],
              ),
              doubleDataHeaderLineItem(
                [
                  'Distance (${units['distance']!})',
                  'Elevation Gain (${units['height']!})'
                ],
                [
                  Conversions.metersToDistance(
                          context, lapSummaryObject?.distance ?? 0)
                      .toStringAsFixed(1),
                  Conversions.metersToHeight(
                          context, lapSummaryObject?.altitude ?? 0)
                      .toStringAsFixed(0)
                ],
              ),
            ]));
    // });
    // });
  }
}

class ShortDataAnalysisForLapSummary extends StatelessWidget {
  final LapSummaryObject? _lapSummaryObject;

  const ShortDataAnalysisForLapSummary(this._lapSummaryObject, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Strava strava = Strava(Globals.isInDebug, secret);
    final Map<String, String> units = Conversions.units(context);
    final double watts =
        (_lapSummaryObject?.watts ?? 0) / (_lapSummaryObject?.count ?? 0);
    final double cadence =
        (_lapSummaryObject?.cadence ?? 0) / (_lapSummaryObject?.count ?? 0);
    final double speed =
        (_lapSummaryObject?.speed ?? 0) / (_lapSummaryObject?.count ?? 0);
    final double distance =
        (_lapSummaryObject?.distance ?? 0) / (_lapSummaryObject?.count ?? 0);
    final double elevation =
        (_lapSummaryObject?.altitude ?? 0) / (_lapSummaryObject?.count ?? 0);
    return Expanded(
        flex: 1,
        // child: Container(
        //         // top: 100,
        //         margin: const EdgeInsets.fromLTRB(0, 16, 0, 0),
        child: ListView(
            // padding: const EdgeInsets.all(8.0),
            children: <Widget>[
              doubleDataHeaderLineItem(
                ['Time', 'Avg Power (w)'],
                [
                  Conversions.secondsToTime(_lapSummaryObject?.time ?? 0),
                  watts.toStringAsFixed(1),
                ],
              ),
              doubleDataHeaderLineItem(
                [
                  'Avg Cadence (rpm)',
                  'Avg Speed (${units['speed']!})',
                ],
                [
                  cadence.toStringAsFixed(0),
                  Conversions.mpsToMph(speed).toStringAsFixed(1),
                ],
              ),
              doubleDataHeaderLineItem(
                [
                  'Distance (${units['distance']!})',
                  'Elevation Gain (${units['height']!})'
                ],
                [
                  Conversions.metersToDistance(context, distance)
                      .toStringAsFixed(1),
                  Conversions.metersToHeight(context, elevation)
                      .toStringAsFixed(0)
                ],
              ),
            ]));
    // });
    // });
  }
}
