import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zwiftdataviewer/models/ConfigDataModel.dart';
import 'package:zwiftdataviewer/models/RouteDataModel.dart';
import 'package:zwiftdataviewer/routes.dart';
import 'package:zwiftdataviewer/screens/allstatsrootscreen.dart';
import 'package:zwiftdataviewer/screens/calendarscreen.dart';
import 'package:zwiftdataviewer/screens/homescreen.dart';
import 'package:zwiftdataviewer/screens/settingscreen.dart';
import 'package:zwiftdataviewer/utils/repository/filerepository.dart';
import 'package:zwiftdataviewer/utils/theme.dart';

class ZwiftViewerApp extends StatelessWidget {
  final FileRepository configRepository;

  ZwiftViewerApp({
    required this.configRepository,
  });


  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (context) =>
                  ConfigDataModel(repository: configRepository)..loadConfig()),
          ChangeNotifierProvider(
              create: (context) => RouteDataModel(repository: FileRepository())
                ..loadRouteData()),
        ],
        child: MaterialApp(
          title: 'Zwift Data Viewer',
          theme: myTheme,
          // localizationsDelegates: [
          //   ArchSampleLocalizationsDelegate(),
          //   ProviderLocalizationsDelegate(),
          // ],
          // onGenerateTitle: (context) =>
          //     ProviderLocalizations.of(context).appTitle,
          routes: {
            AppRoutes.home: (context) => HomeScreen(),
            AppRoutes.allStats: (context) => AllStatsRootScreen(),
            AppRoutes.allStats: (context) => CalendarScreen(),
            AppRoutes.settings: (context) => SettingsScreen(),
          },
        ));
  }
}


  // @override
  // Widget build(BuildContext context) {
  //   return ListenableProvider<ConfigDataModel>(
  //       create: (context) =>
  //           ConfigDataModel(repository: FileRepository())..loadConfig(),
  //       child: ListenableProvider<RouteDataModel>(
  //           create: (context) =>
  //               RouteDataModel(repository: FileRepository())..loadRouteData(),
  //           child: MaterialApp(
  //             title: 'Zwift Data Viewer',
  //             theme: myTheme,
  //             // localizationsDelegates: [
  //             //   ArchSampleLocalizationsDelegate(),
  //             //   ProviderLocalizationsDelegate(),
  //             // ],
  //             // onGenerateTitle: (context) =>
  //             //     ProviderLocalizations.of(context).appTitle,
  //             routes: {
  //               AppRoutes.home: (context) => HomeScreen(),
  //               AppRoutes.allStats: (context) => AllStatsRootScreen(),
  //               AppRoutes.allStats: (context) => CalendarScreen(),
  //               AppRoutes.settings: (context) => SettingsScreen(),
  //             },
  //           )));
  // }
// }
