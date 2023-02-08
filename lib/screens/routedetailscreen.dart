import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/models/ActivityDetailDataModel.dart';
import 'package:zwiftdataviewer/models/ActivityPhotosDataModel.dart';
import 'package:zwiftdataviewer/stravalib/Models/activity.dart';
import 'package:zwiftdataviewer/utils/conversions.dart';
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/widgets/ListItemViews.dart';

class RouteDetailScreen extends StatelessWidget {
  const RouteDetailScreen({required Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final Map<String, String> units = Conversions.units(context);
    return Consumer<ActivityDetailDataModel>(
        builder: (context, myModel, child) {
      final DetailedActivity? activity = myModel.activityDetail;

      if (myModel.isLoading) {
        return const Center(
          child: CircularProgressIndicator(
            key: AppKeys.activitiesLoading,
          ),
        );
      }
      return OrientationBuilder(builder: (context, orientation) {
        if (orientation == Orientation.portrait) {
          return Column(children: <Widget>[
            PrefetchImageDemo(detailedActivity: activity!, key: key!),
            RenderDetails(detailedActivity: activity!)
          ]);
        } else {
          return Row(children: <Widget>[
            PrefetchImageDemo(detailedActivity: activity!, key: key!),
            RenderDetails(detailedActivity: activity!)
          ]);
        }
        // });
      });
    });
  }
}

class PrefetchImageDemo extends StatefulWidget {
  final DetailedActivity detailedActivity;

  const PrefetchImageDemo({required Key key, required this.detailedActivity})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PrefetchImageDemoState(detailedActivity);
  }
}

class _PrefetchImageDemoState extends State<PrefetchImageDemo> {
  final DetailedActivity detailedActivity;

  _PrefetchImageDemoState(this.detailedActivity);

  int _current = 0;

  @override
  Widget build(BuildContext context) {
    final List<String> imagesUrls = createUrls(
        Provider.of<ActivityPhotosDataModel>(context, listen: true)
            .activityPhotos);
    return Container(
      color: zdvMidBlue,
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 5.0),
      child: CarouselSlider.builder(
        itemCount: imagesUrls.length,
        options: CarouselOptions(
            autoPlay: imagesUrls.length > 1 ? true : false,
            aspectRatio: 1.8,
            padEnds: false,
            viewportFraction: 1.0,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              if (!mounted) {
                setState(() {
                  _current = index;
                });
              }
            }),
        itemBuilder: (context, index, index2) {
          return Center(
            child: FadeInImage.assetNetwork(
                placeholder: 'assets/zwiftdatalogo.png',
                image: imagesUrls[index]),
          );
        },
      )
    );
  }

  List<String> createUrls(List<PhotoActivity>? activityPhotos) {
    List<String> imagesUrls = [
      detailedActivity.photos!.primary!.urls!.s600.toString()
    ];

    if (activityPhotos != null && activityPhotos.length > 1) {
      imagesUrls = [];
      for (PhotoActivity image in activityPhotos) {
        String str = image.urls!["1000"];
        imagesUrls
            .add(str); //.substring(0, str.lastIndexOf('-')) + "-768x419.jpg");
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var imageUrl in imagesUrls) {
        precacheImage(NetworkImage(imageUrl), context);
      }
    });

    if (mounted) {
      setState(() {});
    }
    return imagesUrls;
  }
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

  int _current = 0;

  @override
  Widget build(BuildContext context) {
    final Map<String, String> units = Conversions.units(context);

    return Expanded(
        // child: Container(
// top: 100,
//             margin: const EdgeInsets.fromLTRB(0, 230, 0, 0),
            child: ListView(
// padding: const EdgeInsets.all(8.0),
              children: <Widget>[
                doubleDataHeaderLineItem(
                  [
                    'Distance (${units['distance']!})',
                    'Elevation (${units['height']!})'
                  ],
                  [
                    Conversions.metersToDistance(
                            context, activity.distance ?? 0)
                        .toStringAsFixed(1),
                    Conversions.metersToHeight(
                            context, activity.totalElevationGain ?? 0)
                        .toStringAsFixed(0)
                  ],
                ),
                doubleDataHeaderLineItem(
                  ['Time', 'Calories'],
                  [
                    Conversions.secondsToTime(activity.elapsedTime!),
                    activity.calories!.toStringAsFixed(0)
                  ],
                ),
                doubleDataSingleHeaderLineItem(
                    'HeartRate',
                    null,
                    ['Avg', 'Max'],
                    [
                      activity.averageHeartrate.toString(),
                      activity.maxHeartrate.toString()
                    ],
                    'bpm'),
                doubleDataSingleHeaderLineItem(
                    'Watts',
                    null,
                    ['Avg', 'Max'],
                    [
                      activity.averageWatts!.toStringAsFixed(0),
                      activity.maxWatts!.toStringAsFixed(0),
                    ],
                    'w'),
                doubleDataSingleHeaderLineItem(
                    'Speed',
                    null,
                    ['Avg', 'Max'],
                    [
                      Conversions.mpsToMph(activity.averageSpeed!)
                          .toStringAsFixed(1),
                      Conversions.mpsToMph(activity.maxSpeed!)
                          .toStringAsFixed(1),
                    ],
                    'mph'),
              ],
            ));//);
  }
}
