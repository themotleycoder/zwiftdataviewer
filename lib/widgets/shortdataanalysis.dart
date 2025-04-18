import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/providers/lap_select_provider.dart';

import '../providers/activity_detail_provider.dart';
import '../utils/conversions.dart';
import 'iconitemwidgets.dart';

class ShortDataAnalysis extends ConsumerWidget {
  const ShortDataAnalysis({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LapSummaryObject lapSummaryObject =
        ref.watch(lapSummaryObjectProvider);

    Map<String, String> units = Conversions.units(ref);
    final time = lapSummaryObject.time;
    final double watts = (lapSummaryObject.watts);
    final double cadence = (lapSummaryObject.cadence);
    final double speed = (lapSummaryObject.speed);
    final double distance = (lapSummaryObject.distance);
    final double elevation = (lapSummaryObject.altitude);
    return Expanded(
        flex: 1,
        child: ListView(
            // padding: const EdgeInsets.all(8.0),
            children: <Widget>[
              iconHeaderDataRow([
                IconDataObject(
                    'Time', Conversions.secondsToTime(time), Icons.timer),
                IconDataObject(
                    'Avg', watts.toStringAsFixed(1), Icons.electric_bolt,
                    units: 'w')
              ]),
              iconHeaderDataRow([
                IconDataObject(
                    'Avg', cadence.toStringAsFixed(0), Icons.autorenew,
                    units: 'rpm'),
                IconDataObject('Avg',
                    Conversions.mpsToMph(speed).toStringAsFixed(1), Icons.speed,
                    units: units['speed'])
              ]),
              iconHeaderDataRow([
                IconDataObject(
                    'Distance',
                    Conversions.metersToDistance(ref, distance)
                        .toStringAsFixed(1),
                    Icons.route,
                    units: units['distance']),
                IconDataObject(
                    'Gain',
                    Conversions.metersToHeight(ref, elevation)
                        .toStringAsFixed(0),
                    Icons.filter_hdr,
                    units: units['height'])
              ]),
            ]));
  }
}

class ShortDataAnalysisForPieLapSummary extends ConsumerWidget {
  const ShortDataAnalysisForPieLapSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LapSummaryObject lapSummaryObject = ref.watch(lapSummaryObjectPieProvider);

    final Map<String, String> units = Conversions.units(ref);
    final time = lapSummaryObject.time;
    final double watts = (lapSummaryObject.watts) / (lapSummaryObject.count);
    final double cadence =
        (lapSummaryObject.cadence) / (lapSummaryObject.count);
    final double speed = (lapSummaryObject.speed) / (lapSummaryObject.count);
    final double distance = lapSummaryObject.distance;
    final double elevation = lapSummaryObject.altitude;
    return Expanded(
        flex: 1,
        child: ListView(children: <Widget>[
          iconHeaderDataRow([
            IconDataObject(
                'Time', Conversions.secondsToTime(time), Icons.timer),
            IconDataObject('Avg', watts.toStringAsFixed(1), Icons.filter_hdr,
                units: 'w')
          ]),
          iconHeaderDataRow([
            IconDataObject('Avg', cadence.toStringAsFixed(0), Icons.autorenew,
                units: 'rpm'),
            IconDataObject('Avg',
                Conversions.mpsToMph(speed).toStringAsFixed(1), Icons.speed,
                units: units['speed'])
          ]),
          iconHeaderDataRow([
            IconDataObject(
                'Distance',
                Conversions.metersToDistance(ref, distance).toStringAsFixed(1),
                Icons.route,
                units: units['distance']),
            IconDataObject(
                'Gain',
                Conversions.metersToHeight(ref, elevation).toStringAsFixed(0),
                Icons.autorenew,
                units: units['height'])
          ]),
        ]));
  }
}
