import 'package:flutter/material.dart';
import 'package:zwiftdataviewer/secrets.dart';
import 'package:zwiftdataviewer/stravalib/Models/activity.dart';
import 'package:zwiftdataviewer/stravalib/globals.dart' as Globals;
import 'package:zwiftdataviewer/stravalib/strava.dart';
import '../widgets/listitemviews.dart';
import '../utils/conversions.dart';

class ShortDataAnalysis extends StatelessWidget {
  final Laps? _selectedSeries;

  const ShortDataAnalysis(this._selectedSeries, {Key? key}) : super(key: key);

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
                    Conversions.secondsToTime(_selectedSeries?.elapsedTime ?? 0),
                    (_selectedSeries?.averageWatts ?? 0).toStringAsFixed(1),
                  ],
                ),
                doubleDataHeaderLineItem(
                  [
                    'Avg Cadence (rpm)',
                    'Avg Speed (${units['speed']!})',
                  ],
                  [
                    (_selectedSeries?.averageCadence ?? 0).toStringAsFixed(0),
                    Conversions.mpsToMph(_selectedSeries?.averageSpeed ?? 0)
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
                        context, _selectedSeries?.distance ?? 0)
                        .toStringAsFixed(1),
                    Conversions.metersToHeight(
                        context, _selectedSeries?.totalElevationGain ?? 0)
                        .toStringAsFixed(0)
                  ],
                ),
              ]));
    // });
    // });
  }
}
