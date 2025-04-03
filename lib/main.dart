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
import 'package:zwiftdataviewer/screens/ridedetailscreen.dart';
import 'package:zwiftdataviewer/screens/routesscreen.dart';
import 'package:zwiftdataviewer/screens/segments/segments_screen.dart';
import 'package:zwiftdataviewer/screens/settingscreen.dart';
import 'package:zwiftdataviewer/utils/database/database_init.dart';
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

  // Initialize database
  try {
    await DatabaseInit.initialize();
    if (kDebugMode) {
      print('Database initialized successfully');
      
      // Check database status
      final status = await DatabaseInit.checkDatabaseStatus();
      print('Database status:');
      print('- File exists: ${status['file_exists']}');
      print('- File size: ${status['file_size']} bytes');
      
      if (status['file_exists']) {
        print('- Version: ${status['version']['version']}');
        print('- Last updated: ${status['version']['last_updated']}');
        print('- Tables: ${status['tables'].join(', ')}');
        print('- Row counts:');
        final counts = status['row_counts'] as Map<String, int>;
        counts.forEach((table, count) {
          print('  - $table: $count rows');
        });
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error initializing database: $e');
    }
    // Continue even if database initialization fails
  }

  Future<Token?> getClient() async {
    bool isAuthOk = false;

    final Strava strava = Strava(globals.isInDebug, clientSecret);
    const prompt = 'auto';

    try {
      isAuthOk = await strava.oauth(
          clientId,
          'activity:write,activity:read_all,profile:read_all',
          clientSecret,
          prompt);

      if (isAuthOk) {
        Token storedToken = await strava.getStoredToken();
        return storedToken;
      }
    } catch (e) {
      if (kDebugMode) {
        print('OAuth error: $e');
      }
      // Continue with null token, the UI will handle this case
    }

    return null;
  }

  try {
    final token = await getClient();
    if (token == null && kDebugMode) {
      print('No valid token obtained. Authentication will be required.');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Failed to authenticate with Strava: $e');
    }
    // The app will continue and handle authentication in the UI
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
      AppRoutes.segments: (context) => const SegmentsScreen(),
      AppRoutes.detail: (context) => const DetailScreen(),
    },
  )));
}
