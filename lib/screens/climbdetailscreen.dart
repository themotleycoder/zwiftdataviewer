import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/models/climbdata.dart';
import 'package:zwiftdataviewer/models/routedata.dart';
import 'package:zwiftdataviewer/providers/climb_select_provider.dart';
import 'package:zwiftdataviewer/providers/filters/filtered_routes_provider.dart';
import 'package:zwiftdataviewer/screens/layouts/detailscreenlayout.dart';
import 'package:zwiftdataviewer/utils/ui_helpers.dart';
import 'package:zwiftdataviewer/widgets/routedetailtilewidget.dart';

/// A screen that displays details about a Zwift climb.
///
/// This screen shows information about a selected Zwift climb,
/// including a list of routes that include this climb.
class ClimbDetailScreen extends DetailScreenLayout {
  /// Creates a ClimbDetailScreen instance.
  ///
  /// @param key An optional key for this widget
  const ClimbDetailScreen() : super(key: AppKeys.worldDetailsScreen);

  @override
  getChildView(WidgetRef ref) {
    final AsyncValue<List<RouteData>> routeDataModel = ref.watch(routesProvider);
    
    return routeDataModel.when(
      data: (routes) {
        if (routes.isEmpty) {
          return UIHelpers.buildEmptyStateWidget(
            'No routes found for this climb',
            icon: Icons.terrain,
          );
        }
        
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: routes.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return RouteDetailTile(routes[index]);
          },
        );
      }, 
      error: (Object error, StackTrace stackTrace) {
        // Log error for debugging
        debugPrint('Error loading routes for climb: $error');
        return UIHelpers.buildErrorWidget(
          'Failed to load routes for this climb',
          () => ref.refresh(routesProvider),
        );
      }, 
      loading: () {
        return UIHelpers.buildLoadingIndicator();
      },
    );
  }

  @override
  String getTitle(WidgetRef ref) {
    final ClimbData climbData = ref.read(selectedClimbProvider);
    return climbData.name ?? 'Climb Details';
  }
}
