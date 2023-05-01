import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/models/ActivityDetailDataModel.dart';
import 'package:zwiftdataviewer/models/ActivityPhotosDataModel.dart';
import 'package:zwiftdataviewer/models/StreamsDataModel.dart';
import 'package:zwiftdataviewer/screens/routeanalysisscreen.dart';
import 'package:zwiftdataviewer/screens/routedetailscreen.dart';
import 'package:zwiftdataviewer/screens/routesectiondetailscreen.dart';
import 'package:zwiftdataviewer/stravalib/API/streams.dart';
import 'package:zwiftdataviewer/stravalib/strava.dart';
import 'package:zwiftdataviewer/utils/constants.dart';
import 'package:zwiftdataviewer/utils/constants.dart' as constants;
import 'package:zwiftdataviewer/utils/repository/filerepository.dart';
import 'package:zwiftdataviewer/utils/repository/webrepository.dart';
import 'package:zwiftdataviewer/utils/theme.dart';

import '../models/ActivitiesDataModel.dart';

class DetailScreen extends StatefulWidget {
  final int id;
  final Strava strava;

  const DetailScreen({required this.id, required this.strava})
      : super(key: AppKeys.todoDetailsScreen);

  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  StreamsDetailCollection? streamsDetail;
  final _tab = ValueNotifier(ActivityDetailScreenTab.details);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (context) => ActivityDetailDataModel(
                  webRepository: WebRepository(strava: widget.strava),
                  fileRepository: FileRepository())
                ..loadActivityDetail(widget.id)),
          ChangeNotifierProvider(
              create: (context) => StreamsDataModel(
                  webRepository: WebRepository(strava: widget.strava),
                  fileRepository: FileRepository())
                ..loadStreams(widget.id)),
          ChangeNotifierProvider(
              create: (context) => ActivityPhotosDataModel(
                  webRepository: WebRepository(strava: widget.strava),
                  fileRepository: FileRepository())
                ..loadActivityPhotos(widget.id)),
          ChangeNotifierProvider(
              create: (context) => ActivitySelectDataModel()),
          ChangeNotifierProvider(create: (context) => LapSelectDataModel()),
          ChangeNotifierProvider(
              create: (context) => SummaryActivitySelectDataModel())
        ],
        child: Consumer<ActivityDetailDataModel>(
            builder: (context, myModel, child) {
          return Scaffold(
            appBar: AppBar(
                title: myModel.activityDetail == null
                    ? Text("Zwift Data Viewer",
                        style: constants.appBarTextStyle)
                    : Text(
                        "${myModel.activityDetail!.name!} (${DateFormat.yMd().format(DateTime.parse(myModel.activityDetail!.startDate!))})",
                        style: constants.appBarTextStyle),
                backgroundColor: zdvMidBlue,
                elevation: 0.0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
                // actions: getActions()
                ),
            body: Selector<ActivityDetailDataModel, ActivityDetailDataModel>(
                selector: (context, activityDetailDataModel) =>
                    activityDetailDataModel,
                builder: (context, activityDetailDataModel, _) {
                  if (activityDetailDataModel.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        key: AppKeys.activitiesLoading,
                      ),
                    );
                  }

                  return ValueListenableBuilder<ActivityDetailScreenTab>(
                    valueListenable: _tab,
                    builder: (context, tab, _) {
                      switch (tab) {
                        case ActivityDetailScreenTab.analysis:
                          return const RouteAnalysisScreen();
                        case ActivityDetailScreenTab.sections:
                          return RouteSectionDetailScreen();
                        default:
                          return const RouteDetailScreen(
                              key: AppKeys.todoDetailsScreen);
                      }
                    },
                  );
                }),
            bottomNavigationBar:
                ValueListenableBuilder<ActivityDetailScreenTab>(
                    valueListenable: _tab,
                    builder: (context, tab, _) {
                      return BottomNavigationBar(
                        key: AppKeys.tabs,
                        currentIndex:
                            ActivityDetailScreenTab.values.indexOf(tab),
                        onTap: onTabTapped,
                        type: BottomNavigationBarType.fixed,
                        unselectedItemColor: zdvmMidBlue[100],
                        fixedColor: zdvmOrange[100],
                        items: const [
                          BottomNavigationBarItem(
                            icon: Icon(Icons.list, key: AppKeys.activitiesTab),
                            label: "Details",
                          ),
                          BottomNavigationBarItem(
                            icon:
                                Icon(Icons.insights, key: AppKeys.analysisTab),
                            label: "Analysis",
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.calendar_today,
                                key: AppKeys.sectionsTab),
                            label: "Sections",
                          ),
                        ],
                      );
                    }),
          );
        }));
  }

  void onTabTapped(int index) {
    // setState(() {
    //   _bottomNavIndex = index;
    // });
    _tab.value = ActivityDetailScreenTab.values[index];
    setState(() {});
  }
}
