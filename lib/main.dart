import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/globals.dart' as globals;
import 'package:flutter_strava_api/models/token.dart';
import 'package:flutter_strava_api/strava.dart';
import 'package:stack_trace/stack_trace.dart' as stack_trace;
import 'package:zwiftdataviewer/providers/connectivity_provider.dart';
import 'package:zwiftdataviewer/routes.dart';
import 'package:zwiftdataviewer/screens/allstats/allstatsrootscreen.dart';
import 'package:zwiftdataviewer/screens/calendars/allcalendarsrootscreen.dart';
import 'package:zwiftdataviewer/screens/homescreen.dart';
import 'package:zwiftdataviewer/screens/ridedetailscreen.dart';
import 'package:zwiftdataviewer/screens/routesscreen.dart';
import 'package:zwiftdataviewer/screens/segments/segments_screen.dart';
import 'package:zwiftdataviewer/screens/settingscreen.dart';
import 'package:zwiftdataviewer/utils/database/database_init.dart';
import 'package:zwiftdataviewer/utils/repository/hybrid_activities_repository.dart';
import 'package:zwiftdataviewer/utils/supabase/supabase_auth_service.dart';
import 'package:zwiftdataviewer/utils/supabase/supabase_config.dart';
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
          if (kDebugMode) {
            print('  - $table: $count rows');
          }
        });
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error initializing database: $e');
    }
    // Continue even if database initialization fails
  }
  
  // Initialize Supabase
  try {
    await SupabaseConfig.initialize();
    if (kDebugMode) {
      print('Supabase initialized successfully');
    }
    
    // Initialize hybrid repository
    final hybridRepo = HybridActivitiesRepository();
    if (kDebugMode) {
      print('Hybrid repository initialized');
      print('Supabase enabled: ${hybridRepo.isSupabaseEnabled}');
      print('Online: ${hybridRepo.isOnline}');
    }
    
    // Initialize tiered storage manager
    if (kDebugMode) {
      print('Tiered storage manager initialized');
    }
    
    // Try to restore Supabase authentication from SharedPreferences
    final authService = SupabaseAuthService();
    final authRestored = await authService.tryRestoreAuth();
    if (kDebugMode) {
      print('Supabase authentication restored: $authRestored');
    }
    
    // Check if local database is empty and trigger sync if needed
    if (authRestored) {
      final status = await DatabaseInit.checkDatabaseStatus();
      if (status['file_exists'] == true) {
        final rowCounts = status['row_counts'] as Map<String, int>?;
        if (rowCounts != null) {
          final activitiesCount = rowCounts['activities'] ?? 0;
          if (activitiesCount == 0 && hybridRepo.isOnline) {
            if (kDebugMode) {
              print('Local database is empty, triggering sync from Supabase');
            }
            // Trigger sync from Supabase in the background
            hybridRepo.syncService.syncFromSupabase().then((_) {
              if (kDebugMode) {
                print('Initial sync from Supabase completed');
              }
            }).catchError((e) {
              if (kDebugMode) {
                print('Error during initial sync from Supabase: $e');
              }
            });
          }
        }
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error initializing Supabase: $e');
    }
    // Continue even if Supabase initialization fails
  }

  Future<Token?> getClient() async {
    bool isAuthOk = false;

    final Strava strava = Strava(globals.isInDebug, clientSecret);
    const prompt = 'auto';

    try {
      // Check if we have a stored token first
      Token storedToken = await strava.getStoredToken();
      
      // If token exists but is expired, try to refresh it
      if (storedToken.refreshToken != null) {
        if (kDebugMode) {
          print('Attempting to use stored token or refresh if needed');
        }
        
        // The oauth method will automatically refresh if needed
        isAuthOk = await strava.oauth(
            clientId,
            'activity:write,activity:read_all,profile:read_all',
            clientSecret,
            prompt);
            
        if (isAuthOk) {
          storedToken = await strava.getStoredToken();
          if (kDebugMode) {
            print('Successfully authenticated with Strava');
          }
          return storedToken;
        }
      } else {
        // No refresh token, need to do full auth
        if (kDebugMode) {
          print('No refresh token available, need full authentication');
        }
        
        isAuthOk = await strava.oauth(
            clientId,
            'activity:write,activity:read_all,profile:read_all',
            clientSecret,
            prompt);

        if (isAuthOk) {
          storedToken = await strava.getStoredToken();
          return storedToken;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('OAuth error: $e');
        print('If you\'re seeing 403 Forbidden errors, your Strava API credentials may need to be updated.');
        print('Visit https://www.strava.com/settings/api to check your API application status.');
      }
      // Continue with null token, the UI will handle this case
    }

    return null;
  }

  try {
    final token = await getClient();
    if (token == null) {
      if (kDebugMode) {
        print('No valid token obtained. Authentication will be required.');
        print('Please check your Strava API credentials in secrets.dart');
      }
    } else {
      if (kDebugMode) {
        print('Successfully authenticated with Strava');
        print('Token expires at: ${DateTime.fromMillisecondsSinceEpoch(token.expiresAt! * 1000)}');
      }
      
      // Try to authenticate with Supabase using Strava token
      try {
        final supabaseAuthService = SupabaseAuthService();
        
        // Get athlete ID from Strava API
        final strava = Strava(globals.isInDebug, clientSecret);
        final athlete = await strava.getLoggedInAthlete();
        final athleteId = athlete.id ?? 0;
        
        if (athleteId > 0) {
          await supabaseAuthService.signInWithStravaToken(token, athleteId);
          if (kDebugMode) {
            print('Successfully authenticated with Supabase using Strava token');
            print('Athlete ID: $athleteId');
          }
        } else {
          if (kDebugMode) {
            print('No athlete ID available for Supabase authentication');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error authenticating with Supabase: $e');
        }
        // Continue even if Supabase authentication fails
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Failed to authenticate with Strava: $e');
      print('Check your internet connection and Strava API credentials');
    }
    // The app will continue and handle authentication in the UI
  }

  // Initialize the app with ProviderScope
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
        AppRoutes.allRoutes: (context) => const RoutesScreen(),
        AppRoutes.calendar: (context) => const AllCalendarsRootScreen(),
        AppRoutes.settings: (context) => const SettingsScreen(),
        AppRoutes.segments: (context) => const SegmentsScreen(),
        AppRoutes.detail: (context) => const DetailScreen(),
      },
      // Add a builder to initialize providers that need to be accessed early
      builder: (context, child) {
        // Initialize the connectivity provider by watching it
        // This ensures the connectivity state is monitored from app startup
        ProviderScope.containerOf(context).read(connectivityProvider.notifier);
        
        return child!;
      },
    ),
  ));
}
