import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/models/ActivityDetailDataModel.dart';
import 'package:zwiftdataviewer/models/ActivityPhotosDataModel.dart';
import 'package:zwiftdataviewer/stravalib/Models/activity.dart';
import 'package:zwiftdataviewer/utils/conversions.dart';

import '../providers/activity_detail_provider.dart';
import '../providers/activity_photos_provider.dart';
import '../widgets/iconitemwidgets.dart';

class RouteDetailScreen extends ConsumerWidget {
  const RouteDetailScreen({required Key key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final Map<String, String> units = Conversions.units(context);

    final activityDetail = ref.watch(activityDetailProvider.notifier).activityDetail;

    // return Consumer<ActivityDetailDataModel>(
    //     builder: (context, myModel, child) {
    //   final DetailedActivity? activity = myModel.activityDetail;

      // if (myModel.isLoading) {
      //   return const Center(
      //     child: CircularProgressIndicator(
      //       key: AppKeys.activitiesLoading,
      //     ),
      //   );
      // }
      return OrientationBuilder(builder: (context, orientation) {
        if (orientation == Orientation.portrait) {
          return Column(children: <Widget>[
            PrefetchImageDemo(key: key!),
            RenderDetails(detailedActivity: activityDetail)
          ]);
        } else {
          return Row(children: <Widget>[
            PrefetchImageDemo(key: key!),
            RenderDetails(detailedActivity: activityDetail)
          ]);
        }
        // });
      });
    // });
  }
}

// class PrefetchImageDemo extends StatefulWidget {
//   final DetailedActivity detailedActivity;
//
//   const PrefetchImageDemo({required Key key, required this.detailedActivity})
//       : super(key: key);
//
//   @override
//   State<StatefulWidget> createState() {
//     return _PrefetchImageDemoState(detailedActivity);
//   }
// }

class PrefetchImageDemo extends ConsumerWidget {
  // final DetailedActivity detailedActivity;

  // _PrefetchImageDemoState(this.detailedActivity);

  // int _current = 0;

  const PrefetchImageDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<String> imagesUrls = [];
    final DetailedActivity detailedActivity = ref.watch(activityDetailProvider.notifier).activityDetail;
    ref.watch(activityPhotosProvider.notifier)
        .loadActivityPhotos(detailedActivity.id!);
    imagesUrls = ref.watch(activityPhotosProvider.notifier).createUrls(detailedActivity);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var imageUrl in imagesUrls) {
        precacheImage(NetworkImage(imageUrl), context);
      }
    });

    // final List<String> imagesUrls = createUrls(
    //     Provider.of<ActivityPhotosDataModel>(context, listen: true)
    //         .activityPhotos);
    return Container(
        color: Colors.white,
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 5.0),
        child: CarouselSlider.builder(
          itemCount: imagesUrls.length,
          options: CarouselOptions(
              autoPlay: imagesUrls.length > 1 ? true : false,
              // aspectRatio: 1.5,
              // enlargeFactor: 1.0,
              // viewportFraction: 1.0,
              enlargeCenterPage: false,
              onPageChanged: (index, reason) {
                // if (!mounted) {
                //   setState(() {
                //     _current = index;
                //   });
                // }
              }),
          itemBuilder: (context, index, index2) {
            return Center(
              child: FadeInImage.assetNetwork(
                  placeholder: 'assets/zwiftdatalogo.png',
                  image: imagesUrls[index]),
            );
          },
        ));
  }

  // List<String> createUrls(List<PhotoActivity>? activityPhotos) {
  //   List<String> imagesUrls = [
  //     detailedActivity.photos!.primary!.urls!.s600.toString()
  //   ];
  //
  //   if (activityPhotos != null && activityPhotos.length > 1) {
  //     imagesUrls = [];
  //     for (PhotoActivity image in activityPhotos) {
  //       String str = image.urls!["1800"] ??
  //           image.urls!["1000"] ??
  //           image.urls!["600"] ??
  //           image.urls!["200"] ??
  //           image.urls!["100"] ??
  //           image.urls!["50"] ??
  //           image.urls!["25"] ??
  //           image.urls!["10"] ??
  //           image.urls!["5"] ??
  //           image.urls!["3"] ??
  //           image.urls!["2"] ??
  //           image.urls!["1"] ??
  //           image.urls!["0"] ??
  //           "";
  //       imagesUrls
  //           .add(str); //.substring(0, str.lastIndexOf('-')) + "-768x419.jpg");
  //     }
  //   }
  //
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     for (var imageUrl in imagesUrls) {
  //       precacheImage(NetworkImage(imageUrl), context);
  //     }
  //   });
  //
  //   // if (mounted) {
  //   //   setState(() {});
  //   // }
  //   return imagesUrls;
  // }
}

class RenderDetails extends StatefulWidget {
  final DetailedActivity detailedActivity;

  const RenderDetails({required this.detailedActivity});

  // : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RenderDetailsState(detailedActivity);
  }
}

class _RenderDetailsState extends State<RenderDetails> {
  final DetailedActivity activity;

  _RenderDetailsState(this.activity);

  @override
  Widget build(BuildContext context) {
    final Map<String, String> units = Conversions.units(context);

    return Expanded(
        child: Container(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: <Widget>[
                IconHeaderDataRow([
                  IconDataObject(
                      'Distance',
                      Conversions.metersToDistance(
                              context, activity.distance ?? 0)
                          .toStringAsFixed(1),
                      Icons.route,
                      units: units['distance']),
                  IconDataObject(
                      'Elevation',
                      Conversions.metersToHeight(
                              context, activity.totalElevationGain ?? 0)
                          .toStringAsFixed(0),
                      Icons.filter_hdr,
                      units: units['height'])
                ]),
                IconHeaderDataRow([
                  IconDataObject(
                      'Time',
                      Conversions.secondsToTime(activity.elapsedTime!),
                      Icons.schedule),
                  IconDataObject('Calories',
                      activity.calories!.toStringAsFixed(0), Icons.local_pizza),
                ]),
                IconHeaderDataRow([
                  IconDataObject('Avg', activity.averageHeartrate.toString(),
                      Icons.favorite,
                      units: 'bpm'),
                  IconDataObject(
                      'Max', activity.maxHeartrate.toString(), Icons.favorite,
                      units: 'bpm'),
                ]),
                IconHeaderDataRow([
                  IconDataObject(
                      'Avg',
                      activity.averageWatts!.toStringAsFixed(0),
                      Icons.electric_bolt,
                      units: 'w'),
                  IconDataObject('Max', activity.maxWatts!.toStringAsFixed(0),
                      Icons.electric_bolt,
                      units: 'w'),
                ]),
                IconHeaderDataRow([
                  IconDataObject(
                      'Avg',
                      Conversions.mpsToMph(activity.averageSpeed!)
                          .toStringAsFixed(1),
                      Icons.speed,
                      units: units['speed']),
                  IconDataObject(
                      'Max',
                      Conversions.mpsToMph(activity.maxSpeed!)
                          .toStringAsFixed(1),
                      Icons.speed,
                      units: units['speed']),
                ]),
              ],
            ))); //);
  }
}
