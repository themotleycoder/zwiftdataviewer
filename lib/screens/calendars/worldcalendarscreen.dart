import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/models/worlddata.dart';
import 'package:zwiftdataviewer/providers/world_calendar_provider.dart';
import 'package:zwiftdataviewer/providers/world_select_provider.dart';
import 'package:zwiftdataviewer/screens/worlddetailscreen.dart';
import 'package:zwiftdataviewer/utils/constants.dart';
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/utils/worldsconfig.dart';
import 'package:zwiftdataviewer/widgets/worldeventscalendarwidget.dart';

class WorldCalendarScreen extends ConsumerWidget {
  const WorldCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Map<DateTime, List<WorldData>>> asyncWorldCalender =
        ref.watch(loadWorldCalendarProvider);

    return Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
      asyncWorldCalender.when(data: (Map<DateTime, List<WorldData>> worldData) {
        return WorldEventsCalendarWidget(ref, worldData);
      }, error: (Object error, StackTrace stackTrace) {
        print(error);
        return const Text('Error loading data');
      }, loading: () {
        return const Center(
          child: CircularProgressIndicator(
            key: AppKeys.activitiesLoading,
          ),
        );
      }),
      const SizedBox(height: 8.0),
      Expanded(child: _buildEventList(ref, context)),
    ]);
  }
}

Widget _buildEventList(WidgetRef ref, BuildContext context) {
  final List<WorldData> selectedEvents = ref.watch(worldEventsForDayProvider);
  // ref.read(routeProvider.notifier).load();
  final List<Widget> list = selectedEvents
      .map((world) => Card(
          color: Colors.white,
          elevation: defaultCardElevation,
          margin: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
          child: InkWell(
            child: ListTile(
                leading: const Icon(Icons.map, size: 32.0, color: zdvOrange),
                title: Text(allWorldsConfig[world.id]!.name ?? "NA"),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: zdvmMidBlue[100],
                ),
                onTap: () {
                  ref.read(selectedWorldProvider.notifier).state =
                      allWorldsConfig[world.id] as WorldData;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) {
                        return const WorldDetailScreen();
                      },
                    ),
                  );
                }),
          )))
      .toList();
  //add watopia
  list.add(Card(
      color: Colors.white,
      elevation: defaultCardElevation,
      margin: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
      child: InkWell(
        child: ListTile(
            leading: const Icon(Icons.map, size: 32.0, color: zdvYellow),
            title: Text(allWorldsConfig[1]?.name ?? ""),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: zdvmMidBlue[100],
            ),
            onTap: () {
              ref.read(selectedWorldProvider.notifier).worldSelect =
                  allWorldsConfig[1] as WorldData;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) {
                    return const WorldDetailScreen();
                  },
                ),
              );
            }),
      )));

  return ListView(
    children: list,
  );
}
