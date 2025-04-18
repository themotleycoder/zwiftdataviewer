import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/models/segmentEffort.dart';
import 'package:zwiftdataviewer/screens/segments/segment_detail_screen.dart';
import 'package:zwiftdataviewer/utils/constants.dart' as constants;
import 'package:zwiftdataviewer/utils/conversions.dart';
import 'package:zwiftdataviewer/utils/theme.dart';

import '../providers/activity_detail_provider.dart';
import '../utils/constants.dart';

final Map<int, String> climbingCAT = {1: '4', 2: '3', 3: '2', 4: '1', 5: 'HC'};

class RouteSectionDetailScreen extends ConsumerWidget {
  const RouteSectionDetailScreen({super.key});

  Widget createIcon(int prRank) {
    Color? col = Colors.white;
    String text = '';
    if (prRank == 1) {
      col = zdvYellow;
      text = 'PR';
    } else if (prRank == 2) {
      col = Colors.grey[400];
      text = '2';
    } else if (prRank == 3) {
      col = zdvOrange;
      text = '3';
    } else {
      text = '';
    }

    return Stack(children: <Widget>[
      Icon(Icons.bookmark, size: 48.0, color: col),
      Positioned.fill(
          child: Align(
        alignment: Alignment.center,
        child: Text(text,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 16.0,
              color: Colors.white,
            )),
      ))
    ]);
  }

  Row createSubTitle(
      WidgetRef ref, SegmentEffort segmentEffort, Map<String, String> units) {
    var distance =
        Conversions.metersToDistance(ref, segmentEffort.distance ?? 0)
            .toStringAsFixed(1);
    var elevation = Conversions.metersToHeight(
            ref, segmentEffort.segment?.elevationHigh ?? 0)
        .toStringAsFixed(0);
    var grade = (segmentEffort.segment?.averageGrade ?? 0).toStringAsFixed(0);

    String category =
        climbingCAT[(segmentEffort.segment?.climbCategory ?? 0)].toString();
    if (category != 'null') {
      category = 'cat $category';
    } else {
      category = '';
    }

    return Row(children: [
      Wrap(
        spacing: 20,
        children: [
          Text(distance + units['distance']!),
          Text(elevation + units['height']!),
          Text('$grade%'),
          Text(category,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              )),
        ],
      )
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Map<String, String> units = Conversions.units(ref);
    List<SegmentEffort>? segmentEfforts = [];

    final activityDetail = ref.watch(stravaActivityDetailsProvider);

    segmentEfforts = activityDetail.segmentEfforts ?? [];

    return ListView.separated(
      itemCount: segmentEfforts.length,
      separatorBuilder: (BuildContext context, int index) => Container(),
      itemBuilder: (BuildContext context, int index) {
        final SegmentEffort effort = segmentEfforts![index];
        return Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Center(
              child: InkWell(
            onTap: () {
              // Navigate to the segment detail screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) {
                    return SegmentDetailScreen(
                      segmentId: effort.segment?.id ?? 0,
                      segmentName: effort.segment?.name ?? '',
                    );
                  },
                ),
              );
            },
            child: Card(
                color: Colors.white,
                elevation: defaultCardElevation,
                child: ListTile(
                  leading: createIcon(effort.prRank ?? 0),
                  title: Text(segmentEfforts[index].segment!.name ?? '',
                      style: constants.headerFontStyle),
                  subtitle: createSubTitle(ref, segmentEfforts[index], units),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: zdvMidBlue,
                  ),
                )),
          )),
          // margin: EdgeInsets.all(1.0),
        );
      },
    );
    // }, error: (Object error, StackTrace stackTrace) {
    //   return const Text("error");
    // }, loading: () {
    //   return const Text("loading");
    // });
  }
}
