import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/models/routedata.dart';
import 'package:zwiftdataviewer/models/worlddata.dart';
import 'package:zwiftdataviewer/utils/constants.dart' as constants;
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/widgets/routedetailtilewidget.dart';

import '../providers/filters/filtered_routes_provider.dart';
import '../providers/world_select_provider.dart';

class WorldDetailScreen extends ConsumerWidget {
  const WorldDetailScreen() : super(key: AppKeys.worldDetailsScreen);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final WorldData worldData = ref.watch(selectedWorldProvider);
    final AsyncValue<List<RouteData>> routeDataModel =
        ref.watch(routesProvider);

    return Scaffold(
        appBar: AppBar(
            title: Text(worldData.name ?? "", style: constants.appBarTextStyle),
            backgroundColor: white,
            elevation: 0.0,
            leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                })),
        body: ExpandableTheme(
          data: const ExpandableThemeData(
            iconColor: zdvMidBlue,
            useInkWell: true,
          ),
          child: routeDataModel.when(
              data: (routes) {
                return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: routes.length,
                    itemBuilder: (BuildContext ctxt, int index) {
                      return RouteDetailTile(routes[index]);
                    });
              },
              error: (Object error, StackTrace stackTrace) {
                return Text(error.toString());
              },
              loading: () {
                return const Center(child: CircularProgressIndicator());
              }),
        ));
  } //);
}
