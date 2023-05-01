import 'package:flutter/material.dart';
import 'package:zwiftdataviewer/models/ActivityDetailDataModel.dart';
import 'package:zwiftdataviewer/secrets.dart';
import 'package:zwiftdataviewer/stravalib/globals.dart' as Globals;
import 'package:zwiftdataviewer/stravalib/strava.dart';

import '../utils/conversions.dart';
import 'iconitemwidgets.dart';

class ShortDataAnalysis extends StatelessWidget {
  final LapSummaryObject? _lapSummaryObject;

  const ShortDataAnalysis(this._lapSummaryObject, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Strava strava = Strava(Globals.isInDebug, secret);
    Map<String, String> units = Conversions.units(context);
    final time = _lapSummaryObject?.time ?? 0;
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
        child: ListView(
            // padding: const EdgeInsets.all(8.0),
            children: <Widget>[
              IconHeaderDataRow([
                IconDataObject(
                    'Time', Conversions.secondsToTime(time), Icons.timer),
                IconDataObject(
                    'Avg', watts.toStringAsFixed(1), Icons.filter_hdr,
                    units: 'w')
              ]),
              IconHeaderDataRow([
                IconDataObject(
                    'Avg', cadence.toStringAsFixed(0), Icons.autorenew,
                    units: 'rpm'),
                IconDataObject('Avg', speed.toStringAsFixed(1), Icons.speed,
                    units: units['speed'])
              ]),
              IconHeaderDataRow([
                IconDataObject(
                    'Distance',
                    Conversions.metersToDistance(context, distance)
                        .toStringAsFixed(1),
                    Icons.route,
                    units: units['distance']),
                IconDataObject(
                    'Gain',
                    Conversions.metersToHeight(context, elevation)
                        .toStringAsFixed(0),
                    Icons.autorenew,
                    units: units['height'])
              ]),
            ]));
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
    final time = _lapSummaryObject?.time ?? 0;
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
        child: ListView(
            // padding: const EdgeInsets.all(8.0),
            children: <Widget>[
              IconHeaderDataRow([
                IconDataObject(
                    'Time', Conversions.secondsToTime(time), Icons.timer),
                IconDataObject(
                    'Avg', watts.toStringAsFixed(1), Icons.filter_hdr,
                    units: 'w')
              ]),
              IconHeaderDataRow([
                IconDataObject(
                    'Avg', cadence.toStringAsFixed(0), Icons.autorenew,
                    units: 'rpm'),
                IconDataObject('Avg', speed.toStringAsFixed(1), Icons.speed,
                    units: units['speed'])
              ]),
              IconHeaderDataRow([
                IconDataObject(
                    'Distance',
                    Conversions.metersToDistance(context, distance)
                        .toStringAsFixed(1),
                    Icons.route,
                    units: units['distance']),
                IconDataObject(
                    'Gain',
                    Conversions.metersToHeight(context, elevation)
                        .toStringAsFixed(0),
                    Icons.autorenew,
                    units: units['height'])
              ]),
            ]));
  }
}
