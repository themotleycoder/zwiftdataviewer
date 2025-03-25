import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/globals.dart' as globals;
import 'package:flutter_strava_api/models/token.dart';
import 'package:flutter_strava_api/strava.dart';
import 'package:stack_trace/stack_trace.dart' as stack_trace;
import 'package:zwiftdataviewer/routes.dart';
import 'package:zwiftdataviewer/screens/allstats/allstatsrootscreen.dart';
import 'package:zwiftdataviewer/screens/calendars/allcalendarsrootscreen.dart';
import 'package:zwiftdataviewer/screens/homescreen.dart';
import 'package:zwiftdataviewer/screens/routesscreen.dart';
import 'package:zwiftdataviewer/screens/settingscreen.dart';
import 'package:zwiftdataviewer/utils/theme.dart';

import 'secrets.dart';

Future<void> main() async {
  FlutterError.demangleStackTrace = (StackTrace stack) {
    if (stack is stack_trace.Trace) return stack.vmTrace;
    if (stack is stack_trace.Chain) return stack.toTrace().vmTrace;
    return stack;
  };
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize secrets
  await Secrets.initialize();

  Future<Token?> getClient() async {
    bool isAuthOk = false;

    final Strava strava = Strava(globals.isInDebug, clientSecret);
    const prompt = 'auto';

    isAuthOk = await strava.oauth(
        clientId,
        'activity:write,activity:read_all,profile:read_all,profile:write',
        clientSecret,
        prompt);

    if (isAuthOk) {
      Token storedToken = await strava.getStoredToken();
      return storedToken;
    }

    return null;
  }

  try {
    await getClient();
  } catch (e) {
    if (kDebugMode) {
      print('Failed to authenticate with Strava: $e');
    }
    // Handle authentication failure gracefully
  }

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
      AppRoutes.allroutes: (context) => const RoutesScreen(),
      AppRoutes.calendar: (context) => const AllCalendarsRootScreen(),
      AppRoutes.settings: (context) => const SettingsScreen(),
    },
  )));
}
