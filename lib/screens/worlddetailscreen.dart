import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/models/routedata.dart';
import 'package:zwiftdataviewer/models/worlddata.dart';
import 'package:zwiftdataviewer/providers/filters/filtered_routes_provider.dart';
import 'package:zwiftdataviewer/providers/world_select_provider.dart';
import 'package:zwiftdataviewer/screens/layouts/detailscreenlayout.dart';
import 'package:zwiftdataviewer/utils/ui_helpers.dart';
import 'package:zwiftdataviewer/widgets/routedetailtilewidget.dart';

/// A screen that displays details about a Zwift world.
///
/// This screen shows information about a selected Zwift world,
/// including a list of routes available in that world.
class WorldDetailScreen extends DetailScreenLayout {
  /// Creates a WorldDetailScreen instance.
  ///
  /// @param key An optional key for this widget
  const WorldDetailScreen() : super(key: AppKeys.worldDetailsScreen);

  @override
  getChildView(WidgetRef ref) {
    final AsyncValue<List<RouteData>> routeDataModel = ref.watch(routesProvider);

    return routeDataModel.when(
      data: (routes) {
        if (routes.isEmpty) {
          return UIHelpers.buildEmptyStateWidget(
            'No routes found for this world',
            icon: Icons.route,
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
        debugPrint('Error loading routes: $error');
        return UIHelpers.buildErrorWidget(
          'Failed to load routes for this world',
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
    final WorldData worldData = ref.read(selectedWorldProvider);
    return worldData.name ?? 'World Details';
  }
}
