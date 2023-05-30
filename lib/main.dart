import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stack_trace/stack_trace.dart' as stack_trace;
import 'package:zwiftdataviewer/routes.dart';
import 'package:zwiftdataviewer/screens/allstatsrootscreen.dart';
import 'package:zwiftdataviewer/screens/calendarscreen.dart';
import 'package:zwiftdataviewer/screens/homescreen.dart';
import 'package:zwiftdataviewer/screens/settingscreen.dart';
import 'package:zwiftdataviewer/utils/theme.dart';

Future<void> main() async {
  FlutterError.demangleStackTrace = (StackTrace stack) {
    if (stack is stack_trace.Trace) return stack.vmTrace;
    if (stack is stack_trace.Chain) return stack.toTrace().vmTrace;
    return stack;
  };
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(
      child: MaterialApp(
    title: 'Zwift Data Viewer',
    theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
    // localizationsDelegates: [
    //   ArchSampleLocalizationsDelegate(),
    //   ProviderLocalizationsDelegate(),
    // ],
    // onGenerateTitle: (context) =>
    //     ProviderLocalizations.of(context).appTitle,
    routes: {
      AppRoutes.home: (context) => const HomeScreen(),
      AppRoutes.allStats: (context) => const AllStatsRootScreen(),
      AppRoutes.calendar: (context) => const CalendarScreen(),
      AppRoutes.settings: (context) => const SettingsScreen(),
    },
  )));
}
