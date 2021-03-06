import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/models/ActivitiesDataModel.dart';
import 'package:zwiftdataviewer/models/ConfigDataModel.dart';
// import 'package:zwiftdataviewer/models/RouteDataModel.dart';
import 'package:zwiftdataviewer/screens/allstatsscreen.dart';
import 'package:zwiftdataviewer/screens/calendarscreen.dart';
import 'package:zwiftdataviewer/screens/settingscreen.dart';
import 'package:zwiftdataviewer/secrets.dart';
import 'package:zwiftdataviewer/stravalib/strava.dart';
import 'package:zwiftdataviewer/utils/constants.dart';
import 'package:zwiftdataviewer/utils/repository/filerepository.dart';
import 'package:zwiftdataviewer/utils/repository/webrepository.dart';
import 'package:zwiftdataviewer/widgets/activitieslistview.dart';
import 'package:zwiftdataviewer/widgets/filterdatebutton.dart';
import 'package:zwiftdataviewer/stravalib/globals.dart' as Globals;
import 'package:zwiftdataviewer/utils/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen();

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Because the state of the tabs is only a concern to the HomeScreen Widget,
  // it is stored as local state rather than in the TodoListModel.
  final _tab = ValueNotifier(HomeScreenTab.activities);
  final List<String> list = List.generate(10, (index) => "Text $index");

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Strava strava = Strava(Globals.isInDebug, secret);
    final ConfigDataModel configDataModel =
        Provider.of<ConfigDataModel>(context, listen: false);
    // final RouteDataModel routeDataModel =
    //     Provider.of<RouteDataModel>(context, listen: false);

    return ChangeNotifierProvider<ActivitiesDataModel>(
        create: (context) => ActivitiesDataModel(
            fileRepository: FileRepository(),
            webRepository: WebRepository(strava: strava))
          ..loadActivities(context),
        child: Scaffold(
          // extendBodyBehindAppBar: true,
          appBar: AppBar(
              title: Text("Zwift Data Viewer"),
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              actions: getActions()),
          body: new Stack(children: [
            Container(
                decoration: BoxDecoration(
                    // image: DecorationImage(
                    //   image: AssetImage("assets/background.png"),
                    //   fit: BoxFit.cover,
                    // ),
                    )),
            Selector<ActivitiesDataModel, bool>(
              selector: (context, model) => model.isLoading,
              builder: (context, isLoading, _) {
                if (isLoading || configDataModel.isLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      key: AppKeys.activitiesLoading,
                    ),
                  );
                }

                return ValueListenableBuilder<HomeScreenTab>(
                  valueListenable: _tab,
                  builder: (context, tab, _) {
                    switch (tab) {
                      case HomeScreenTab.stats:
                        return AllStatsScreen();
                      case HomeScreenTab.calendar:
                        return CalendarScreen();
                      case HomeScreenTab.settings:
                        return const SettingsScreen();
                      case HomeScreenTab.activities:
                      default:
                        return Consumer<ActivitiesDataModel>(
                            builder: (context, myModel, child) {
                          return ActivitiesListView(myModel.activities
                              // onRemove: (context, todo) {
                              //   Provider.of<ActivitiesDataModel>(context, listen: false)
                              //       .removeTodo(todo);
                              //   _showUndoSnackbar(context, todo);
                              // },
                              );
                        });
                    }
                  },
                );
              },
            )
          ]),
          bottomNavigationBar: ValueListenableBuilder<HomeScreenTab>(
            valueListenable: _tab,
            builder: (context, tab, _) {
              return BottomNavigationBar(
                key: AppKeys.tabs,
                currentIndex: HomeScreenTab.values.indexOf(tab),
                onTap:
                    onTabTapped, //(int index) => _tab.value = HomeScreenTab.values[index],
                type: BottomNavigationBarType.fixed,
                unselectedItemColor: zdvmMidBlue[100],
                fixedColor: zdvmOrange[100],
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.list, key: AppKeys.activitiesTab),
                    label: "Activities",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.show_chart, key: AppKeys.statsTab),
                    label: "Statistics",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_today, key: AppKeys.calendarTab),
                    label: "Calendar",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings, key: AppKeys.settingsTab),
                    label: "Settings",
                  ),
                ],
              );
            },
          ),
        ));
  }

  void refreshList() {}

  void onTabTapped(int index) {
    // setState(() {
    //   _bottomNavIndex = index;
    // });
    _tab.value = HomeScreenTab.values[index];
    setState(() {});
  }

  List<Widget> getActions() {
    List<Widget> actions = [];
    // return [
    if (_tab != null && _tab.value == HomeScreenTab.activities) {
      actions.add(
          Consumer<ActivitiesDataModel>(builder: (context, myModel, child) {
        return IconButton(
          onPressed: () {
            showSearch(
                context: context, delegate: ActivitySearch(myModel.activities));
          },
          icon: Icon(Icons.search),
        );
      }));
    }
    if (_tab != null && _tab.value == HomeScreenTab.stats) {
      actions.add(ValueListenableBuilder<HomeScreenTab>(
        valueListenable: _tab,
        builder: (_, tab, __) => FilterDateButton(
          isActive: tab == HomeScreenTab.stats,
        ),
      ));
    }
    // ];
    return actions;
  }
}
