import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/providers/route_provider.dart';
import 'package:zwiftdataviewer/providers/world_select_provider.dart';

import '../utils/worlddata.dart';

final filteredRoutesProvider = Provider<List<RouteData>>((ref) {
  final routeDataModel = ref.watch(routeProvider);
  final selectedWorld = ref.watch(selectedWorldProvider);
  final routeFilter = ref.watch(routeFilterProvider.notifier);

  final List<RouteData> data = routeDataModel[selectedWorld.id] ?? [];

  return data.where((route) {
    switch (routeFilter) {
      // case routeType.eventonly:
      //   return route.eventOnly?.toLowerCase() == "event only";
      // case routeType.basiconly:
      //   return route.eventOnly?.toLowerCase() != "event only";
      default:
        return true;
    }
  }).toList();
});

class RouteFilterNotifier extends StateNotifier<routeType> {
  RouteFilterNotifier() : super(routeType.basiconly);

  set filter(routeType filter) {
    state = filter;
  }

  routeType get filter => state;
}

final routeFilterProvider =
    StateNotifierProvider<RouteFilterNotifier, routeType>(
        (ref) => RouteFilterNotifier());
