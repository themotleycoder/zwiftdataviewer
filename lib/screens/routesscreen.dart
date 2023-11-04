import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/providers/filters/filtered_routefilter_provider.dart';
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/widgets/routedetailtilewidget.dart';

class RoutesScreen extends ConsumerWidget {
  const RoutesScreen() : super(key: AppKeys.worldDetailsScreen);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final WorldData worldData = ref.watch(selectedWorldProvider);
    // ref.read(selectedWorldProvider.notifier).worldSelect = "";
    // final AsyncValue<List<RouteData>> routeDataModel =
    // ref.watch(allRoutesProvider);

    // final AsyncValue<List<RouteData>> routeDataModel =
    var routeDataModel = ref.watch(distanceRouteFiltersProvider);

    return Scaffold(
        // appBar: AppBar(
        //     title: Text('Routes'),//worldData.name ?? "", style: constants.appBarTextStyle),
        //     backgroundColor: white,
        //     elevation: 0.0,
        //     leading: IconButton(
        //         icon: const Icon(Icons.arrow_back, color: Colors.black),
        //         onPressed: () {
        //           Navigator.pop(context);
        //         })),
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
