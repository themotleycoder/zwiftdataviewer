import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:group_button/group_button.dart';
import 'package:zwiftdataviewer/models/routedata.dart';
import 'package:zwiftdataviewer/providers/filters/filtered_routefilter_provider.dart';
import 'package:zwiftdataviewer/providers/filters/filtered_routes_provider.dart';
import 'package:zwiftdataviewer/providers/world_select_provider.dart';
import 'package:zwiftdataviewer/utils/conversions.dart';
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/utils/worlddata.dart';


class FilterRouteButton extends ConsumerWidget {
  final bool isActive;

  const FilterRouteButton({required this.isActive, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double? maxLength = 1;
    double? maxElevation = 1;

    final AsyncValue<List<RouteData>> routeDataModel =
        ref.watch(allRoutesProvider);

    routeDataModel.when(data: (routes) {
      maxLength = routes.isNotEmpty?routes[0]
          .distanceMeters!:1; //Conversions.metersToDistance(ref, routes[0].distanceMeters!);
      maxElevation = routes.isNotEmpty?routes[0]
          .altitudeMeters!:1; //Conversions.metersToHeight(ref, routes[0].altitudeMeters!);
      for (var route in routes) {
        final d = route
            .distanceMeters!; //Conversions.metersToDistance(ref, route.distanceMeters!);
        final e = route
            .altitudeMeters!; //Conversions.metersToHeight(ref, route.altitudeMeters!);

        if (d > maxLength!) {
          maxLength = d;
        }
        if (e > maxElevation!) {
          maxElevation = e;
        }
      }
    }, error: (Object error, StackTrace stackTrace) {
      return Text(error.toString());
    }, loading: () {
      return const Center(child: CircularProgressIndicator());
    });

    return IconButton(
        icon: const Icon(Icons.filter_list, color: Colors.black),
        onPressed: () {
          showBottomSheet(
              context, ref, maxLength ?? 5000000, maxElevation ?? 10000);
        });
  }

  showBottomSheet(BuildContext context, WidgetRef ref, double maxLength,
      double maxElevation) {
    final Map<String, String> units = Conversions.units(ref);
    RangeValues distanceRangeValues = RangeValues(1, maxLength);
    RangeValues elevationRangeValues = RangeValues(1, maxElevation);

    final distanceFilterProv = ref.read(distanceFiltersNotifier.notifier);

    final controller = GroupButtonController();

    final List<WorldSelectedObj> selectedWorlds = [];
    final List<WorldData> allWorlds = worldsData.values.toList(growable: false);
    int index = 0;
    for (var world in allWorlds) {
      controller.selectIndex(index);
      index++;
      selectedWorlds.add(WorldSelectedObj(world, true));
    }

    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 500,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(children: [
                  //const Icon(Icons.filter_list, color: Colors.black),
                  ElevatedButton(
                    child: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ]),
                Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: Column(children: [
                      Text("Distance(${units['distance']})"),
                      StatefulBuilder(builder: (context, state) {
                        return RangeSlider(
                          values: distanceRangeValues,
                          max: maxLength,
                          divisions: 10,
                          activeColor: zdvMidBlue,
                          labels: RangeLabels(
                            distanceRangeValues.start.round().toString(),
                            distanceRangeValues.end.round().toString(),
                          ),
                          onChanged: (RangeValues values) {
                            distanceRangeValues = values;
                            distanceFilterProv.setFilter(RouteFilterObject(
                                values, elevationRangeValues, []));
                            state(() {});
                          },
                        );
                      }),
                      Text("Elevation(${units['height']})"),
                      StatefulBuilder(builder: (context, state) {
                        return RangeSlider(
                          values: elevationRangeValues,
                          max: maxElevation,
                          divisions: 50,
                          activeColor: zdvMidBlue,
                          labels: RangeLabels(
                            elevationRangeValues.start.round().toString(),
                            elevationRangeValues.end.round().toString(),
                          ),
                          onChanged: (RangeValues values) {
                            elevationRangeValues = values;
                            distanceFilterProv.setFilter(RouteFilterObject(
                                distanceRangeValues, values, []));
                            state(() {});
                          },
                        );
                      })
                    ])),
                Column(
                  children: [
                    const Text("Worlds"),
                    GroupButton<WorldData>(
                        isRadio: false,
                        controller: controller,
                        onSelected: (val, index, isSelected) {
                          selectedWorlds[index].isSelected = isSelected;
                          final selectedWorldsList = selectedWorlds
                              .where((element) => element.isSelected)
                              .map((e) => e.world)
                              .toList(growable: false);
                          distanceFilterProv.setFilter(RouteFilterObject( distanceRangeValues, elevationRangeValues, selectedWorldsList));
                        },
                        buttons: worldsData.entries
                            .map((e) => e.value)
                            .toList(growable: false),
                        buttonTextBuilder: (selected, world, context) {
                          return world.name!;
                        },
                        options: GroupButtonOptions(
                          spacing: 8,
                          groupRunAlignment: GroupRunAlignment.center,
                          selectedColor: zdvMidBlue,
                          borderRadius: BorderRadius.circular(4.0),
                        ))
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class WorldSelectedObj {
  final WorldData world;
  bool isSelected;

  WorldSelectedObj(this.world, this.isSelected);
}
