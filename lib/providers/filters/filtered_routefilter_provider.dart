import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/models/routedata.dart';
import 'package:zwiftdataviewer/models/worlddata.dart';
import 'package:zwiftdataviewer/providers/filters/filtered_routes_provider.dart';

class DistanceFiltersNotifier extends StateNotifier<RouteFilterObject> {
  DistanceFiltersNotifier()
      : super(RouteFilterObject(
            const RangeValues(0, 1000000), const RangeValues(0, 1000000), []));

  void setFilter(RouteFilterObject routeFilters) {
    state = routeFilters;
  }

  RouteFilterObject get filter => state;
}

final distanceFiltersNotifier =
    StateNotifierProvider<DistanceFiltersNotifier, RouteFilterObject>(
        (ref) => DistanceFiltersNotifier());

final distanceRouteFiltersProvider =
    FutureProvider<List<RouteData>>((ref) async {
  final List<RouteData> routes = await ref.watch(allRoutesProvider.future);
  final RouteFilterObject routeFilters = ref.watch(distanceFiltersNotifier);

  return routes
      .where((route) {
        return route.distanceMeters! >= routeFilters.distance.start &&
            route.distanceMeters! <= routeFilters.distance.end &&
            route.altitudeMeters! >= routeFilters.elevation.start &&
            route.altitudeMeters! <= routeFilters.elevation.end &&
            (routeFilters.worlds.isEmpty
                ? true
                : routeFilters.worlds.any((world) =>
                    world.name ==
                    route.world)); // Updated location-based filter
      })
      .toList();
});

class RouteFilterObject {
  final RangeValues distance;
  final RangeValues elevation;
  final List<WorldData> worlds;

  RouteFilterObject(this.distance, this.elevation, this.worlds);
}
