import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/models/routedata.dart';
import 'package:zwiftdataviewer/providers/routedataprovider.dart';
import 'package:zwiftdataviewer/providers/world_select_provider.dart';

import '../../utils/worlddata.dart';

Future<List<RouteData>> filterByWorldRoutesProvider(FutureProviderRef<List<RouteData>> ref) async {
// final filteredRoutesProvider = Provider<List<RouteData>>((ref) {
  final routeDataModel = ref.watch(routeDataProvider);
  final selectedWorld = ref.watch(selectedWorldProvider);
  final routeFilter = ref.watch(routeFilterProvider.notifier);

  List<RouteData> routeData = [];

  routeDataModel.when(
      data: (Map<int, List<RouteData>> data) {
        routeData = data[selectedWorld.id] ?? [];
      },
      error: (Object error, StackTrace stackTrace) {
        routeData = [];
      },
      loading: () {
        routeData = [];
      }
  );

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

final routesProvider =
FutureProvider<List<RouteData>>((ref) async {
  return await filterByWorldRoutesProvider(ref);
});

Future<List<RouteData>> filterByUserRoutesProvider(FutureProviderRef<List<RouteData>> ref) async {
// final filteredRoutesProvider = Provider<List<RouteData>>((ref) {
//   final routeDataModel = ref.watch(routeProvider);
  //final selectedWorld = ref.watch(selectedWorldProvider);
  // final routeFilter = ref.watch(routeFilterProvider.notifier);


  final AsyncValue<Map<int, List<RouteData>>> routeDataModel = ref.watch(routeDataProvider);

  List<RouteData> routeData = [];

  routeDataModel.when(
      data: (Map<int, List<RouteData>> data) {
        routeData = data.values.expand((list) => list).toList();
      },
      error: (Object error, StackTrace stackTrace) {

      },
      loading: () {

      }
  );

  return routeData;
  // final List<RouteData> data = routeDataModel.values.expand((list) => list).toList();
  //
  // return data;

  // return data.where((route) {
  //   switch (routeFilter) {
  //   // case routeType.eventonly:
  //   //   return route.eventOnly?.toLowerCase() == "event only";
  //   // case routeType.basiconly:
  //   //   return route.eventOnly?.toLowerCase() != "event only";
  //     default:
  //       return true;
  //   }
  // }).toList();
}

final allRoutesProvider =
FutureProvider<List<RouteData>>((ref) async {
  return await filterByUserRoutesProvider(ref);
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
