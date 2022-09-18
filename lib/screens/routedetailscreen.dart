import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/models/ActivityDetailDataModel.dart';
import 'package:zwiftdataviewer/models/ActivityPhotosDataModel.dart';
import 'package:zwiftdataviewer/stravalib/Models/activity.dart';
import 'package:zwiftdataviewer/utils/conversions.dart';
import 'package:zwiftdataviewer/widgets/ListItemViews.dart';

class RouteDetailScreen extends StatelessWidget {
  const RouteDetailScreen({required Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, String> units = Conversions.units(context);
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

      return Stack(children: <Widget>[
        PrefetchImageDemo(detailedActivity: activity!, key: key!),
        Container(
            // top: 100,
            margin: const EdgeInsets.fromLTRB(0, 240, 0, 0),
            child: ListView(
              // padding: const EdgeInsets.all(8.0),
              children: <Widget>[
                doubleDataHeaderLineItem(
                  [
                    'Distance (' + units['distance']! + ')',
                    'Elevation (' + units['height']! + ')'
                  ],
                  [
                    Conversions.metersToDistance(
                            context, activity.distance ?? 0)
                        .toStringAsFixed(2),
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
                          .toStringAsFixed(2),
                      Conversions.mpsToMph(activity.maxSpeed!)
                          .toStringAsFixed(2),
                    ],
                    'mph'),
              ],
            )),
      ]);
      // });
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
        child: Stack(alignment: Alignment.bottomCenter, children: [
      CarouselSlider.builder(
        itemCount: imagesUrls.length,
        options: CarouselOptions(
            autoPlay:
                imagesUrls != null && imagesUrls.length > 1 ? true : false,
            // aspectRatio: 2.0,
            viewportFraction: 1,
            enlargeCenterPage: false,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            }),
        itemBuilder: (context, index, index2) {
          return Container(
              child: Center(
            child: FadeInImage.assetNetwork(
                placeholder: 'assets/Zwift_logo.png', image: imagesUrls[index]),
          ));
        },
      ),
      Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: imagesUrls.map((url) {
              int index = imagesUrls.indexOf(url);
              return Container(
                width: 8.0,
                height: 8.0,
                margin:
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _current == index ? Colors.white : Colors.white54,
                ),
              );
            }).toList(),
          )),
    ]));
  }

  List<String> createUrls(List<PhotoActivity>? activityPhotos) {
    List<String> imagesUrls = [
      detailedActivity.photos!.primary!.urls!.s600.toString()
    ];

    if (activityPhotos != null && activityPhotos.length > 1) {
      imagesUrls = [];
      for (PhotoActivity image in activityPhotos) {
        String str = image.urls!["0"];
        imagesUrls.add(str.substring(0, str.lastIndexOf('-')) + "-768x419.jpg");
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      imagesUrls.forEach((imageUrl) {
        precacheImage(NetworkImage(imageUrl), context);
      });
    });

    setState(() {});
    return imagesUrls;
  }
}
