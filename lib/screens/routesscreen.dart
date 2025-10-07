import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/providers/filters/filtered_routefilter_provider.dart';
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/utils/ui_helpers.dart';
import 'package:zwiftdataviewer/widgets/improved_route_filter_widget.dart';
import 'package:zwiftdataviewer/widgets/routedetailtilewidget.dart';

// A screen that displays a list of Zwift routes.
//
// This screen shows a filterable list of Zwift routes, with each route
// displayed as an expandable tile with details.
class RoutesScreen extends ConsumerWidget {
  // Creates a RoutesScreen instance.
  //
  // @param key An optional key for this widget
  const RoutesScreen() : super(key: AppKeys.worldDetailsScreen);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routeDataModel = ref.watch(distanceRouteFiltersProvider);

    return Scaffold(
      body: ExpandableTheme(
        data: const ExpandableThemeData(
          iconColor: zdvMidBlue,
          useInkWell: true,
        ),
        child: Column(
          children: [
            const Flexible(
              flex: 0,
              child: ImprovedRouteFilterWidget(),
            ),
            Expanded(
              child: routeDataModel.when(
                data: (routes) {
                  if (routes.isEmpty) {
                    return UIHelpers.buildEmptyStateWidget(
                      'No routes found matching the current filters',
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
                    'Failed to load routes',
                    () => ref.refresh(distanceRouteFiltersProvider),
                  );
                },
                loading: () {
                  return UIHelpers.buildLoadingIndicator();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
