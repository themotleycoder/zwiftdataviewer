import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/utils/conversions.dart';

import '../providers/activity_detail_provider.dart';
import '../providers/activity_photos_provider.dart';
import '../providers/activity_select_provider.dart';
import '../widgets/iconitemwidgets.dart';

class RouteDetailScreen extends ConsumerWidget {
  const RouteDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OrientationBuilder(builder: (context, orientation) {
      if (orientation == Orientation.portrait) {
        return const Column(children: <Widget>[
          Expanded(child: PrefetchImageDemo()),
          RenderRouteDetails()
        ]);
      } else {
        return const Row(
            children: <Widget>[PrefetchImageDemo(), RenderRouteDetails()]);
      }
    });
  }
}

class PrefetchImageDemo extends ConsumerWidget {
  const PrefetchImageDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<String>> imagesUrls = ref.watch(activityPhotoUrlsProvider(
        ref.watch(photoActivitiesProvider).value ?? []));

    return Container(
        color: Colors.white,
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: imagesUrls.when(
          data: (data) {
            return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              return CarouselSlider.builder(
                itemCount: data.length,
                options: CarouselOptions(
                  height: constraints.maxHeight,
                  autoPlay: data.length > 1 ? true : false,
                  viewportFraction: 2,
                  clipBehavior: Clip.antiAlias,
                  enlargeCenterPage: false,
                  // onPageChanged: (index, reason) {
                  //   // if (!mounted) {
                  //   //   setState(() {
                  //   //     _current = index;
                  //   //   });
                  //   // }
                  // }
                ),
                itemBuilder: (context, index, index2) {
                  return Center(
                    child: FadeInImage.assetNetwork(
                        placeholder: 'assets/zwiftdatalogo.png',
                        image: data[index]),
                  );
                },
              );
            });
          },
          error: (Object error, StackTrace stackTrace) {
            return const Text("error");
          },
          loading: () {
            return const Center(
                child: FadeInImage(
              placeholder: AssetImage('assets/zwiftdatalogo.png'),
              image: AssetImage('assets/zwiftdatalogo.png'),
            ));
          },
        ));
  }
}

class RenderRouteDetails extends ConsumerWidget {
  const RenderRouteDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Map<String, String> units = Conversions.units(ref);
    // final asyncActivityDetail = ref.watch(activityDetailFromStreamProvider(
    //     ref.watch(selectedActivityProvider).id));

    var activityId = ref.watch(selectedActivityProvider).id;
    // final activityDetails = ref.watch(stravaActivityDetailsProvider(activityId));

    return Consumer(builder: (context, watch, child) {
      final activityDetails = ref.watch(stravaActivityDetailsProvider);

      return FutureBuilder(
        future: ref
            .read(stravaActivityDetailsProvider.notifier)
            .loadActivityDetails(activityId),
        builder: (context, snapshot) {
          // final activityDetail = activityDetails;
          return Expanded(
              child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(
                    children: <Widget>[
                      IconHeaderDataRow([
                        IconDataObject(
                            'Distance',
                            Conversions.metersToDistance(
                                    ref, activityDetails.distance ?? 0)
                                .toStringAsFixed(1),
                            Icons.route,
                            units: units['distance']),
                        IconDataObject(
                            'Elevation',
                            Conversions.metersToHeight(ref,
                                    activityDetails.totalElevationGain ?? 0)
                                .toStringAsFixed(0),
                            Icons.filter_hdr,
                            units: units['height'])
                      ]),
                      IconHeaderDataRow([
                        IconDataObject(
                            'Time',
                            Conversions.secondsToTime(
                                activityDetails.elapsedTime ?? 0),
                            Icons.schedule),
                        IconDataObject(
                            'Calories',
                            (activityDetails.calories ?? 0).toStringAsFixed(0),
                            Icons.local_pizza),
                      ]),
                      IconHeaderDataRow([
                        IconDataObject(
                            'Avg',
                            (activityDetails.averageHeartrate ?? 0).toString(),
                            Icons.favorite,
                            units: 'bpm'),
                        IconDataObject(
                            'Max',
                            (activityDetails.maxHeartrate ?? 0).toString(),
                            Icons.favorite,
                            units: 'bpm'),
                      ]),
                      IconHeaderDataRow([
                        IconDataObject(
                            'Avg',
                            (activityDetails.averageWatts ?? 0)
                                .toStringAsFixed(0),
                            Icons.electric_bolt,
                            units: 'w'),
                        IconDataObject(
                            'Max',
                            (activityDetails.maxWatts ?? 0).toStringAsFixed(0),
                            Icons.electric_bolt,
                            units: 'w'),
                      ]),
                      IconHeaderDataRow([
                        IconDataObject(
                            'Avg',
                            Conversions.mpsToMph(
                                    activityDetails.averageSpeed ?? 0.0)
                                .toStringAsFixed(1),
                            Icons.speed,
                            units: units['speed']),
                        IconDataObject(
                            'Max',
                            Conversions.mpsToMph(activityDetails.maxSpeed ?? 0)
                                .toStringAsFixed(1),
                            Icons.speed,
                            units: units['speed']),
                      ]),
                    ],
                  )));
        },
        // error: (Object error, StackTrace stackTrace) {
        //   return const Text("error");
        // },
        // loading: () {
        //   return const Center(child: CircularProgressIndicator());
        // },
      );
    }); //);
  }
}
