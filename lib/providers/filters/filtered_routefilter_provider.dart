import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/models/routedata.dart';
import 'package:zwiftdataviewer/providers/filters/filtered_routes_provider.dart';
import 'package:zwiftdataviewer/providers/world_select_provider.dart';

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
  final AsyncValue<List<RouteData>> routeDataModel =
      ref.watch(allRoutesProvider);

  var routes = [];
  routeDataModel.when(
    data: (data) {
      routes = data;
    },
    loading: () {
      routes = [];
    },
    error: (error, stackTrace) {
      routes = [];
    },
  );

  var routeFilters = ref.watch(distanceFiltersNotifier);

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
      .toList()
      .cast<RouteData>();
});

class RouteFilterObject {
  final RangeValues distance;
  final RangeValues elevation;
  final List<WorldData> worlds;

  RouteFilterObject(this.distance, this.elevation, this.worlds);
}
