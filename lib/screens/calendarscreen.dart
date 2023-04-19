import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/models/RouteDataModel.dart';
import 'package:zwiftdataviewer/models/WorldDataModel.dart';
import 'package:zwiftdataviewer/screens/worlddetailscreen.dart';
import 'package:zwiftdataviewer/utils/constants.dart' as constants;
import 'package:zwiftdataviewer/utils/repository/filerepository.dart';
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/utils/worlddata.dart';

import '../utils/constants.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // CalendarController _calendarController;
  List<dynamic> _selectedEvents = [];
  DateTime _selectedDay = DateTime.now();
  WorldDataModel? _myModel;

  @override
  void initState() {
    super.initState();
    // _calendarController = CalendarController();
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final t = DateTime(now.year, now.month, now.day);
    return ChangeNotifierProvider(
        create: (context) => WorldDataModel(repository: FileRepository())
          ..loadWorldCalendarData(),
        child: Consumer<WorldDataModel>(builder: (context, myModel, child) {
          if (myModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                key: AppKeys.activitiesLoading,
              ),
            );
          } else {
            _myModel = myModel;
            _selectedEvents = (_selectedEvents.length < 2
                ? myModel.worldCalendarData![t]
                : _selectedEvents)!;
          }

          return Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
            TableCalendar(
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
                formatButtonTextStyle: const TextStyle()
                    .copyWith(color: Colors.white, fontSize: 16.0),
                formatButtonDecoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              firstDay: DateTime.utc(2010, 10, 16),
              focusedDay: DateTime.now(),
              lastDay: DateTime.utc(2030, 3, 14),
              onDaySelected: _onDaySelected,
              eventLoader: _getEventsForDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
            ),
            const SizedBox(height: 8.0),
            Expanded(child: _buildEventList()),
          ]);
        }));
  }

  @override
  void dispose() {
    // _calendarController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        // _focusedDay = focusedDay;
        // _rangeStart = null; // Important to clean those
        // _rangeEnd = null;
        // _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents = _getEventsForDay(selectedDay);
    }
  }

  List<dynamic> _getEventsForDay(DateTime selectedDay) {
    final DateTime d =
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    return _myModel?.worldCalendarData![d] ?? [];
  }

  Widget _buildEventList() {
    List<Widget> list = _selectedEvents
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) {
                          return WorldDetailScreen(
                            worldId: world.id ?? 1,
                            worldData: worldsData[world.id]!,
                          );
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) {
                      return WorldDetailScreen(
                        worldId: 1,
                        worldData: worldsData[1]!,
                      );
                    },
                  ),
                );
              }),
        )));

    return ListView(
      children: list,
    );
  }

  Future<Map<int, List<RouteData>>> loadRoutes() async {
    final FileRepository fileRepo = FileRepository();
    return await fileRepo.loadRouteData();
  }
}
