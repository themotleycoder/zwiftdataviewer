import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:zwiftdataviewer/models/worlddata.dart';
import 'package:zwiftdataviewer/screens/worlddetailscreen.dart';
import 'package:zwiftdataviewer/utils/constants.dart' as constants;
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/utils/worlddata.dart';

import '../appkeys.dart';
import '../providers/world_calendar_provider.dart';
import '../providers/world_select_provider.dart';
import '../utils/constants.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    AsyncValue<Map<DateTime, List<WorldData>>> asyncWorldCalender =
        ref.watch(loadWorldCalendarProvider);

    return Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
      asyncWorldCalender.when(data: (Map<DateTime, List<WorldData>> worldData) {
        return TableCalendar(
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarStyle: const CalendarStyle(
            outsideDaysVisible: false,
            isTodayHighlighted: true,
            todayDecoration:
                BoxDecoration(shape: BoxShape.circle, color: zdvLgtBlue),
            selectedDecoration:
                BoxDecoration(shape: BoxShape.circle, color: zdvOrange),
            markerDecoration:
                BoxDecoration(shape: BoxShape.circle, color: zdvMidBlue),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekendStyle:
                const TextStyle().copyWith(color: constants.calenderColor),
          ),
          headerStyle: HeaderStyle(
            formatButtonTextStyle:
                const TextStyle().copyWith(color: Colors.white, fontSize: 16.0),
            formatButtonDecoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          firstDay: DateTime.utc(2010, 10, 16),
          focusedDay: DateTime.now(),
          lastDay: DateTime.utc(2030, 3, 14),
          onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
            var day = ref.read(selectedDayProvider);
            if (!isSameDay(day, selectedDay)) {
              ref.read(selectedDayProvider.notifier).selectDay(selectedDay);
            }
            _getEventsForSelectedDay(ref, worldData);
          },
          eventLoader: (DateTime dateTime) {
            final formattedDateTime =
                DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
            return _getEventsForDay(ref, worldData,
                DateTime.parse(formattedDateTime.replaceAll('Z', '')));
          },
          selectedDayPredicate: (day) {
            return isSameDay(ref.read(selectedDayProvider), day);
          },
        );
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

_getEventsForSelectedDay(
    WidgetRef ref, Map<DateTime, List<WorldData>> worldData) {
  var data = _getEventsForDay(ref, worldData);
  ref.read(eventsForDayProvider.notifier).setEventsForDay(data ?? []);
}

_getEventsForDay(WidgetRef ref, Map<DateTime, List<WorldData>> worldData,
    [DateTime? date]) {
  final DateTime selectedDay = ref.read(selectedDayProvider);
  DateTime? d = date;

  if (d == null) {
    d = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
  } else {
    d = DateTime(d.year, d.month, d.day);
  }

  return worldData[d];
}

Widget _buildEventList(WidgetRef ref, BuildContext context) {
  final List<WorldData> selectedEvents = ref.watch(eventsForDayProvider);
  // ref.read(routeProvider.notifier).load();
  final List<Widget> list = selectedEvents
      .map((world) => Card(
          color: Colors.white,
          elevation: defaultCardElevation,
          margin: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
          child: InkWell(
            child: ListTile(
                leading: const Icon(Icons.map, size: 32.0, color: zdvOrange),
                title: Text(worldsData[world.id]!.name ?? "NA"),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: zdvmMidBlue[100],
                ),
                onTap: () {
                  ref.read(selectedWorldProvider.notifier).state =
                      worldsData[world.id] as WorldData;
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
            title: Text(worldsData[1]?.name ?? ""),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: zdvmMidBlue[100],
            ),
            onTap: () {
              ref.read(selectedWorldProvider.notifier).worldSelect =
                  worldsData[1] as WorldData;
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

// Future<Map<int, List<RouteData>>> loadRoutes() async {
//   final FileRepository fileRepo = FileRepository();
//   return await fileRepo.loadRouteData();
// }
