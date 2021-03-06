import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/models/RouteDataModel.dart';
import 'package:zwiftdataviewer/models/WorldDataModel.dart';
import 'package:zwiftdataviewer/screens/worlddetailscreen.dart';
import 'package:zwiftdataviewer/utils/repository/filerepository.dart';
import 'package:zwiftdataviewer/utils/worlddata.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:zwiftdataviewer/utils/constants.dart' as Constants;
import 'package:zwiftdataviewer/utils/theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen();

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarController _calendarController;
  List _selectedEvents = [];

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final t = new DateTime(now.year, now.month, now.day);
    return ChangeNotifierProvider(
        create: (context) => WorldDataModel(repository: FileRepository())
          ..loadWorldCalendarData(),
        child: Consumer<WorldDataModel>(builder: (context, myModel, child) {
          if (myModel.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                key: AppKeys.activitiesLoading,
              ),
            );
          } else {
            _selectedEvents = _selectedEvents.length < 2
                ? myModel.worldCalendarData[t]
                : _selectedEvents;
          }

          return Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
            TableCalendar(
              calendarController: _calendarController,
              events: myModel.worldCalendarData,
              startingDayOfWeek: StartingDayOfWeek.monday,
              onDaySelected: _onDaySelected,
              calendarStyle: CalendarStyle(
                selectedColor: zdvmOrange[100],
                todayColor: zdvmLgtBlue[100],
                markersColor: zdvmMidBlue[100],
                outsideDaysVisible: false,
                weekendStyle:
                    TextStyle().copyWith(color: Constants.calenderColor),
                holidayStyle:
                    TextStyle().copyWith(color: Constants.calenderColor),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekendStyle:
                    TextStyle().copyWith(color: Constants.calenderColor),
              ),
              headerStyle: HeaderStyle(
                formatButtonTextStyle:
                    TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
                formatButtonDecoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Expanded(child: _buildEventList()),
          ]);
        }));
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime day, List events) {
    setState(() {
      _selectedEvents = events;
    });
  }

  Widget _buildEventList() {
    List list = _selectedEvents
        .map((world) => Card(
            color: Colors.white,
            elevation: 0,
            margin: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
            child: InkWell(
              child: ListTile(
                  leading: const Icon(Icons.map, size: 32.0, color: zdvOrange),
                  title: Text(worldsData[world.id].name),
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
                            worldId: world.id,
                            worldData: worldsData[world.id],
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
        elevation: 0,
        margin: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
        child: InkWell(
          child: ListTile(
              leading: const Icon(Icons.map, size: 32.0, color: zdvYellow),
              title: Text(worldsData[1].name),
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
                        worldData: worldsData[1],
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
    final FileRepository fileRepo = new FileRepository();
    return await fileRepo.loadRouteData();
  }
}
