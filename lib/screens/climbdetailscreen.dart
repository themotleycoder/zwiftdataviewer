import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/models/climbdata.dart';
import 'package:zwiftdataviewer/models/routedata.dart';
import 'package:zwiftdataviewer/providers/climb_select_provider.dart';
import 'package:zwiftdataviewer/screens/layouts/detailscreenlayout.dart';
import 'package:zwiftdataviewer/widgets/routedetailtilewidget.dart';

import '../providers/filters/filtered_routes_provider.dart';

class ClimbDetailScreen extends DetailScreenLayout {
  const ClimbDetailScreen() : super(key: AppKeys.worldDetailsScreen);

  @override
  getChildView(WidgetRef ref) {
    final AsyncValue<List<RouteData>> routeDataModel = ref.watch(routesProvider);
    return routeDataModel.when(data: (routes) {
      return ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: routes.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return RouteDetailTile(routes[index]);
          });
    }, error: (Object error, StackTrace stackTrace) {
      return Text(error.toString());
    }, loading: () {
      return const Center(child: CircularProgressIndicator());
    });
  }

  @override
  String getTitle(WidgetRef ref) {
    final ClimbData climbData = ref.read(selectedClimbProvider);
    return climbData.name ?? "";
  } //);
}
