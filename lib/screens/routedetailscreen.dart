import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/providers/activity_detail_provider.dart';
import 'package:zwiftdataviewer/providers/activity_photos_provider.dart';
import 'package:zwiftdataviewer/providers/activity_select_provider.dart';
import 'package:zwiftdataviewer/utils/conversions.dart';
import 'package:zwiftdataviewer/utils/simple_carousel.dart';
import 'package:zwiftdataviewer/utils/ui_helpers.dart';
import 'package:zwiftdataviewer/widgets/iconitemwidgets.dart';

/// A screen that displays details about a Zwift route or activity.
///
/// This screen shows information about a selected route or activity,
/// including photos and key metrics like distance, elevation, time, etc.
class RouteDetailScreen extends ConsumerWidget {
  /// Creates a RouteDetailScreen instance.
  ///
  /// @param key An optional key for this widget
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

/// A widget that displays a carousel of activity photos.
///
/// This widget fetches and displays photos associated with the selected activity.
class PrefetchImageDemo extends ConsumerWidget {
  /// Creates a PrefetchImageDemo instance.
  ///
  /// @param key An optional key for this widget
  const PrefetchImageDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<String>> imagesUrls = ref.watch(
        activityPhotoUrlsProvider(
            ref.watch(photoActivitiesProvider).value ?? []));

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: imagesUrls.when(
        data: (data) {
          if (data.isEmpty) {
            return Center(
              child: UIHelpers.buildEmptyStateWidget(
                'No photos available for this activity',
                icon: Icons.photo_library,
              ),
            );
          }

          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SimpleCarousel(
                itemCount: data.length,
                height: constraints.maxHeight,
                autoPlay: data.length > 1,
                clipBehavior: Clip.antiAlias,
                itemBuilder: (context, index) {
                  return Center(
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/zwiftdatalogo.png',
                      image: data[index],
                      imageErrorBuilder: (context, error, stackTrace) {
                        debugPrint('Error loading image: $error');
                        return Image.asset('assets/zwiftdatalogo.png');
                      },
                      fadeInDuration: const Duration(milliseconds: 200),
                    ),
                  );
                },
              );
            },
          );
        },
        error: (Object error, StackTrace stackTrace) {
          debugPrint('Error loading photos: $error');
          return UIHelpers.buildErrorWidget(
            'Failed to load activity photos',
            () => ref.refresh(activityPhotoUrlsProvider(
                ref.watch(photoActivitiesProvider).value ?? [])),
          );
        },
        loading: () {
          return UIHelpers.buildLoadingIndicator();
        },
      ),
    );
  }
}

/// A widget that displays detailed metrics about a route or activity.
///
/// This widget shows key metrics like distance, elevation, time, heart rate,
/// power, and speed for the selected activity.
class RenderRouteDetails extends ConsumerWidget {
  /// Creates a RenderRouteDetails instance.
  ///
  /// @param key An optional key for this widget
  const RenderRouteDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Map<String, String> units = Conversions.units(ref);
    final activityId = ref.watch(selectedActivityProvider).id;
    final activityDetails = ref.watch(stravaActivityDetailsProvider);

    // Trigger loading of activity details but don't wait for it
    // This ensures the UI updates when the provider is updated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(stravaActivityDetailsProvider.notifier)
          .loadActivityDetails(activityId);
    });

    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
        child: ListView(
          children: <Widget>[
            // Distance and Elevation
            IconHeaderDataRow([
              IconDataObject(
                'Distance',
                Conversions.metersToDistance(ref, activityDetails.distance ?? 0)
                    .toStringAsFixed(1),
                Icons.route,
                units: units['distance'],
              ),
              IconDataObject(
                'Elevation',
                Conversions.metersToHeight(
                        ref, activityDetails.totalElevationGain ?? 0)
                    .toStringAsFixed(0),
                Icons.filter_hdr,
                units: units['height'],
              )
            ]),

            // Time and Calories
            IconHeaderDataRow([
              IconDataObject(
                'Time',
                Conversions.secondsToTime(activityDetails.elapsedTime ?? 0),
                Icons.schedule,
              ),
              IconDataObject(
                'Calories',
                (activityDetails.calories ?? 0).toStringAsFixed(0),
                Icons.local_pizza,
              ),
            ]),

            // Heart Rate
            IconHeaderDataRow([
              IconDataObject(
                'Avg HR',
                (activityDetails.averageHeartrate ?? 0).toString(),
                Icons.favorite_border,
                units: 'bpm',
              ),
              IconDataObject(
                'Max HR',
                (activityDetails.maxHeartrate ?? 0).toString(),
                Icons.favorite,
                units: 'bpm',
              ),
            ]),

            // Power
            IconHeaderDataRow([
              IconDataObject(
                'Avg Power',
                (activityDetails.averageWatts ?? 0).toStringAsFixed(0),
                Icons.electric_bolt_outlined,
                units: 'w',
              ),
              IconDataObject(
                'Max Power',
                (activityDetails.maxWatts ?? 0).toStringAsFixed(0),
                Icons.electric_bolt,
                units: 'w',
              ),
            ]),

            // Speed
            IconHeaderDataRow([
              IconDataObject(
                'Avg Speed',
                Conversions.mpsToMph(activityDetails.averageSpeed ?? 0.0)
                    .toStringAsFixed(1),
                Icons.speed_outlined,
                units: units['speed'],
              ),
              IconDataObject(
                'Max Speed',
                Conversions.mpsToMph(activityDetails.maxSpeed ?? 0)
                    .toStringAsFixed(1),
                Icons.speed,
                units: units['speed'],
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
