import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/models/routedata.dart';
import 'package:zwiftdataviewer/providers/routedataprovider.dart';
import 'package:zwiftdataviewer/providers/world_select_provider.dart';
import 'package:zwiftdataviewer/utils/worldsconfig.dart';

Future<List<RouteData>> filterByWorldRoutesProvider(
    Ref ref) async {
  final routeDataModel = await ref.watch(routeDataProvider.future);
  final selectedWorld = ref.watch(selectedWorldProvider);
  final routeFilter = ref.watch(routeFilterProvider.notifier);

  List<RouteData> routeData = routeDataModel[selectedWorld.id] ?? [];

  return routeData.where((route) {
    switch (routeFilter) {
      // case routeType.eventonly:
      //   return route.eventOnly?.toLowerCase() == "event only";
      // case routeType.basiconly:
      //   return route.eventOnly?.toLowerCase() != "event only";
      default:
        return true;
    }
  }).toList();
}

final routesProvider = FutureProvider<List<RouteData>>((ref) async {
  return await filterByWorldRoutesProvider(ref);
});

Future<List<RouteData>> filterByUserRoutesProvider(
    Ref ref) async {
  final Map<int, List<RouteData>> routeDataModel = await ref.watch(routeDataProvider.future);
  
  List<RouteData> routeData = routeDataModel.values.expand((list) => list).toList();

  return routeData;
}

final allRoutesProvider = FutureProvider<List<RouteData>>((ref) async {
  return await filterByUserRoutesProvider(ref);
});

class RouteFilterNotifier extends StateNotifier<RouteType> {
  RouteFilterNotifier() : super(RouteType.basiconly);

  set filter(RouteType filter) {
    state = filter;
  }

  RouteType get filter => state;
}

final routeFilterProvider =
    StateNotifierProvider<RouteFilterNotifier, RouteType>(
        (ref) => RouteFilterNotifier());
