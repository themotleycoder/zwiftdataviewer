import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/models/ActivityDetailDataModel.dart';
import 'package:zwiftdataviewer/secrets.dart';
import 'package:zwiftdataviewer/stravalib/globals.dart' as Globals;
import 'package:zwiftdataviewer/stravalib/strava.dart';

import '../screens/routeanalysispowerchartscreen.dart';
import '../utils/conversions.dart';
import 'iconitemwidgets.dart';

class ShortDataAnalysis extends ConsumerWidget {
  const ShortDataAnalysis({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final lapSummaryObject = ref.watch(selectedLapSummaryProvider.notifier).selectedLapSummaryObject;

    final Strava strava = Strava(Globals.isInDebug, secret);
    Map<String, String> units = Conversions.units(context);
    final time = lapSummaryObject?.time ?? 0;
    final double watts = (lapSummaryObject?.watts ?? 0);
    final double cadence = (lapSummaryObject?.cadence ?? 0);
    final double speed = (lapSummaryObject?.speed ?? 0);
    final double distance = (lapSummaryObject?.distance ?? 0);
    final double elevation = (lapSummaryObject?.altitude ?? 0);
    return Expanded(
        flex: 1,
        child: ListView(
            // padding: const EdgeInsets.all(8.0),
            children: <Widget>[
              IconHeaderDataRow([
                IconDataObject(
                    'Time', Conversions.secondsToTime(time), Icons.timer),
                IconDataObject(
                    'Avg', watts.toStringAsFixed(1), Icons.electric_bolt,
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
                    Icons.filter_hdr,
                    units: units['height'])
              ]),
            ]));
  }
}

class ShortDataAnalysisForLapSummary extends ConsumerWidget {
  const ShortDataAnalysisForLapSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final lapSummaryObject = ref.watch(selectedLapSummaryProvider.notifier).selectedLapSummaryObject;
    final Strava strava = Strava(Globals.isInDebug, secret);
    final Map<String, String> units = Conversions.units(context);
    final time = lapSummaryObject?.time ?? 0;
    final double watts =
        (lapSummaryObject?.watts ?? 0) / (lapSummaryObject?.count ?? 0);
    final double cadence =
        (lapSummaryObject?.cadence ?? 0) / (lapSummaryObject?.count ?? 0);
    final double speed =
        (lapSummaryObject?.speed ?? 0);// / (lapSummaryObject?.count ?? 0);
    final double distance =
        (lapSummaryObject?.distance ?? 0);
    final double elevation =
        (lapSummaryObject?.altitude ?? 0);
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
