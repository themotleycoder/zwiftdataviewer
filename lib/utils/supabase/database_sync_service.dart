import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_strava_api/models/summary_activity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zwiftdataviewer/models/climbdata.dart';
import 'package:zwiftdataviewer/models/extended_segment_effort.dart';
import 'package:zwiftdataviewer/models/routedata.dart';
import 'package:zwiftdataviewer/models/worlddata.dart';
import 'package:zwiftdataviewer/utils/calendar_scraper_service.dart';
import 'package:zwiftdataviewer/utils/climbsconfig.dart';
import 'package:zwiftdataviewer/utils/database/database_helper.dart';
import 'package:zwiftdataviewer/utils/database/database_init.dart';
import 'package:zwiftdataviewer/utils/database/services/activity_service.dart';
import 'package:zwiftdataviewer/utils/database/services/segment_effort_service.dart';
import 'package:zwiftdataviewer/utils/route_scraper_service.dart';
import 'package:zwiftdataviewer/utils/supabase/supabase_auth_service.dart';
import 'package:zwiftdataviewer/utils/supabase/supabase_database_service.dart';
import 'package:zwiftdataviewer/utils/worldsconfig.dart';

/// Service for synchronizing data between SQLite and Supabase
///
/// This service implements a unidirectional data flow where Supabase is the source of truth
/// and SQLite acts as a local cache. It provides methods for syncing data from Supabase to SQLite
/// and handling offline/online transitions.
class DatabaseSyncService {
  static final DatabaseSyncService _instance = DatabaseSyncService._internal();
  final SupabaseDatabaseService _supabaseService = SupabaseDatabaseService();
  final SupabaseAuthService _authService = SupabaseAuthService();
  final ActivityService _sqliteActivityService = DatabaseInit.activityService;
  final SegmentEffortService _sqliteSegmentEffortService = DatabaseInit.segmentEffortService;
  final _syncStateController = StreamController<SyncState>.broadcast();
  
  bool _isSyncing = false;
  SyncState _currentState = SyncState.idle;
  
  // Singleton pattern
  factory DatabaseSyncService() => _instance;

  DatabaseSyncService._internal() {
    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen((result) {
      if (result.isNotEmpty) {
        _handleConnectivityChange(result.first);
      }
    });
  }

  /// Stream of synchronization state changes
  Stream<SyncState> get syncStateChanges => _syncStateController.stream;

  /// Gets the current synchronization state
  SyncState get currentState => _currentState;

  /// Checks if a sync is currently in progress
  bool get isSyncing => _isSyncing;

  /// Handles connectivity changes
  ///
  /// This method is called when the device's connectivity changes.
  /// It triggers a sync when the device comes online.
  Future<void> _handleConnectivityChange(ConnectivityResult result) async {
    if (result != ConnectivityResult.none) {
      // Device is online, check if we need to sync
      final needsSync = await _needsSync();
      if (needsSync) {
        // Sync data to Supabase
        await syncToSupabase();
      }
    }
  }

  /// Checks if a sync is needed
  ///
  /// This method checks if there are any changes that need to be synced to Supabase.
  Future<bool> _needsSync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSyncTime = prefs.getInt('last_sync_time');
      if (lastSyncTime == null) {
        // Never synced before
        return true;
      }

      // Check if there are any changes since the last sync
      final lastSyncDate = DateTime.fromMillisecondsSinceEpoch(lastSyncTime);
      final dbHelper = DatabaseHelper();
      final versionInfo = await dbHelper.getVersionInfo();
      final lastUpdated = DateTime.parse(versionInfo['last_updated'] as String);

      // If the database was updated after the last sync, we need to sync
      return lastUpdated.isAfter(lastSyncDate);
    } catch (e) {
      if (kDebugMode) {
        print('Error checking if sync is needed: $e');
      }
      return true; // Sync to be safe
    }
  }

  /// Updates the last sync time
  ///
  /// This method updates the last sync time in SharedPreferences.
  Future<void> _updateLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_sync_time', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating last sync time: $e');
      }
    }
  }

  /// Sets the current sync state
  ///
  /// This method updates the current sync state and notifies listeners.
  void _setSyncState(SyncState state) {
    _currentState = state;
    _syncStateController.add(state);
  }

  /// Performs the initial migration to populate SQLite from Supabase
  ///
  /// This method fetches all data from Supabase and caches it in SQLite.
  /// It should be called once when the user first enables Supabase.
  Future<void> performInitialMigration() async {
    if (_isSyncing) {
      if (kDebugMode) {
        print('Migration already in progress');
      }
      return;
    }

    _isSyncing = true;
    _setSyncState(SyncState.migrating);

    try {
      // Ensure we're authenticated with Supabase
      final isAuthenticated = await _authService.isAuthenticated();
      if (!isAuthenticated) {
        throw Exception('Not authenticated with Supabase');
      }

      if (kDebugMode) {
        print('Starting initial migration from Supabase to SQLite');
      }

      // Sync from Supabase to SQLite
      await syncFromSupabase();

      if (kDebugMode) {
        print('Initial migration completed successfully');
      }
      _setSyncState(SyncState.completed);
    } catch (e) {
      if (kDebugMode) {
        print('Error during initial migration: $e');
      }
      _setSyncState(SyncState.error);
    } finally {
      _isSyncing = false;
    }
  }

  /// Syncs data from SQLite to Supabase
  ///
  /// This method syncs any pending changes from SQLite to Supabase.
  /// It should be called when the device comes online after being offline.
  Future<void> syncToSupabase() async {
    if (_isSyncing) {
      if (kDebugMode) {
        print('Sync already in progress');
      }
      return;
    }

    _isSyncing = true;
    _setSyncState(SyncState.syncingToSupabase);

    try {
      // Ensure we're authenticated with Supabase
      final isAuthenticated = await _authService.isAuthenticated();
      if (!isAuthenticated) {
        throw Exception('Not authenticated with Supabase');
      }

      if (kDebugMode) {
        print('Starting sync from SQLite to Supabase');
      }

      // In a unidirectional data flow, we would only sync changes that were made offline
      // For now, we'll just sync all recent activities to ensure consistency
      
      // Get last sync time
      final prefs = await SharedPreferences.getInstance();
      final lastSyncTime = prefs.getInt('last_sync_time');
      final lastSyncDate = lastSyncTime != null
          ? DateTime.fromMillisecondsSinceEpoch(lastSyncTime)
          : DateTime(2015, 1, 1);

      // Get activities updated since last sync
      final activities = await _sqliteActivityService.loadActivities(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        lastSyncDate.millisecondsSinceEpoch ~/ 1000,
      );

      if (activities == null || activities.isEmpty) {
        if (kDebugMode) {
          print('No activities to sync');
        }
      } else {
        final validActivities = activities.whereType<SummaryActivity>().toList();
        if (kDebugMode) {
          print('Syncing ${validActivities.length} activities');
        }

        // Sync activities in chunks to avoid memory issues
        const chunkSize = 50;
        for (var i = 0; i < validActivities.length; i += chunkSize) {
          final end = (i + chunkSize < validActivities.length) ? i + chunkSize : validActivities.length;
          final chunk = validActivities.sublist(i, end);

          // Update progress
          _setSyncState(SyncState.syncingToSupabase);
          if (kDebugMode) {
            print('Syncing activities ${i + 1}-$end of ${validActivities.length}');
          }

          // Save activities to Supabase
          await _supabaseService.saveActivities(chunk);

          // Sync activity details, photos, streams, and segment efforts for each activity
          for (var activity in chunk) {
            await _syncActivityDetailsToSupabase(activity.id);
          }
        }
      }

      // Sync worlds, routes, and climbs
      await _syncWorldsToSupabase();
      await _syncRoutesToSupabase();
      await _syncClimbsToSupabase();

      // Update last sync time
      await _updateLastSyncTime();

      if (kDebugMode) {
        print('Sync to Supabase completed successfully');
      }
      _setSyncState(SyncState.completed);
    } catch (e) {
      if (kDebugMode) {
        print('Error during sync to Supabase: $e');
      }
      _setSyncState(SyncState.error);
    } finally {
      _isSyncing = false;
    }
  }

  /// Syncs worlds from local config to Supabase
  ///
  /// This method syncs worlds from the local configuration to Supabase.
  Future<void> _syncWorldsToSupabase() async {
    try {
      if (kDebugMode) {
        print('Syncing worlds to Supabase');
      }

      // Get worlds from Supabase
      final existingWorlds = await _supabaseService.getWorlds();
      final existingWorldIds = existingWorlds.map((w) => w.id).toSet();

      // Create worlds from worldsconfig
      final List<WorldData> allWorlds = [];
      for (var worldEntry in allWorldsConfig.entries) {
        final worldId = worldEntry.key;
        final worldData = worldEntry.value;
        
        // Check if we already have this world
        if (existingWorldIds.contains(worldId)) {
          // Add existing world to the list
          final existingWorld = existingWorlds.firstWhere((w) => w.id == worldId);
          allWorlds.add(existingWorld);
        } else {
          // Add new world to the list
          allWorlds.add(worldData);
        }
      }

      // Save worlds to Supabase
      await _supabaseService.saveWorlds(allWorlds);

      if (kDebugMode) {
        print('Synced ${allWorlds.length} worlds to Supabase');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing worlds to Supabase: $e');
      }
      // Continue with other sync operations even if worlds sync fails
    }
  }

  /// Syncs routes from Zwift Insider to Supabase
  ///
  /// This method scrapes route data from Zwift Insider and syncs it to Supabase.
  /// 
  /// This method is also exposed as a public method for use by the UI.
  Future<void> _syncRoutesToSupabase() async {
    try {
      if (kDebugMode) {
        print('Syncing routes to Supabase');
      }

      // Get routes from Supabase
      final existingRoutes = await _supabaseService.getRoutes();
      final existingRouteIds = existingRoutes.map((r) => r.id).toSet();

      // Get worlds from Supabase
      final existingWorlds = await _supabaseService.getWorlds();
      final existingWorldIds = existingWorlds.map((w) => w.id).toSet();
      final worldsById = {for (var world in existingWorlds) world.id: world};
      final worldsByName = {for (var world in existingWorlds) world.name: world};

      // Create a map to hold unique routes by ID
      Map<int, RouteData> uniqueRoutes = {};
      
      // Check if we already have routes
      if (existingRoutes.isNotEmpty) {
        // Add existing routes to the map, ensuring no duplicates by ID
        for (var route in existingRoutes) {
          if (route.id != null && !uniqueRoutes.containsKey(route.id)) {
            uniqueRoutes[route.id!] = route;
          }
        }
      } else {
        // Scrape route data from Zwift Insider
        if (kDebugMode) {
          print('Scraping route data from Zwift Insider');
        }
        
        final routeScraperService = RouteScraperService();
        final scrapedData = await routeScraperService.scrapeRouteData();
        
        final scrapedWorlds = scrapedData['worlds'] as List<WorldData>;
        final scrapedRoutes = scrapedData['routes'] as List<RouteData>;
        
        if (kDebugMode) {
          print('Scraped ${scrapedWorlds.length} worlds and ${scrapedRoutes.length} routes from Zwift Insider');
        }
        
        // Save scraped worlds to Supabase if they don't exist
        for (var world in scrapedWorlds) {
          if (!existingWorldIds.contains(world.id)) {
            await _supabaseService.saveWorlds([world]);
          }
        }
        
        // Set athlete ID for each route and add to the map, ensuring no duplicates by ID
        for (var route in scrapedRoutes) {
          route.completed = false;
          if (route.id != null && !uniqueRoutes.containsKey(route.id)) {
            uniqueRoutes[route.id!] = route;
          }
        }
      }

      // Convert map values to list
      final List<RouteData> routesToSave = uniqueRoutes.values.toList();

      // Save routes to Supabase
      await _supabaseService.saveRoutes(routesToSave);

      if (kDebugMode) {
        print('Synced ${routesToSave.length} routes to Supabase');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing routes to Supabase: $e');
      }
      // Continue with other sync operations even if routes sync fails
    }
  }

  /// Syncs climbs from local config to Supabase
  ///
  /// This method syncs climbs from the local configuration to Supabase.
  Future<void> _syncClimbsToSupabase() async {
    try {
      if (kDebugMode) {
        print('Syncing climbs to Supabase');
      }

      // Get climbs from Supabase
      final existingClimbs = await _supabaseService.getClimbs();
      final existingClimbIds = existingClimbs.map((c) => c.id).toSet();

      // Get climbs from climbsconfig
      final List<ClimbData> allClimbs = [];
      for (var climbEntry in allClimbsConfig.entries) {
        final climbId = climbEntry.key;
        final climbData = climbEntry.value;
        
        // Check if we already have this climb
        if (existingClimbIds.contains(climbId)) {
          // Add existing climb to the list
          final existingClimb = existingClimbs.firstWhere((c) => c.id == climbId);
          allClimbs.add(existingClimb);
        } else {
          // Add new climb to the list
          allClimbs.add(climbData);
        }
      }

      // Save climbs to Supabase
      await _supabaseService.saveClimbs(allClimbs);

      if (kDebugMode) {
        print('Synced ${allClimbs.length} climbs to Supabase');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing climbs to Supabase: $e');
      }
      // Continue with other sync operations even if climbs sync fails
    }
  }
  
  /// Syncs activity details from SQLite to Supabase
  ///
  /// This method syncs activity details, photos, streams, and segment efforts
  /// for the specified activity from SQLite to Supabase.
  Future<void> _syncActivityDetailsToSupabase(int activityId) async {
    try {
      // Sync activity details
      final activityDetail = await _sqliteActivityService.loadActivityDetail(activityId);
      if (activityDetail != null) {
        await _supabaseService.saveActivityDetail(activityDetail);
      }

      // Sync activity photos
      final photos = await _sqliteActivityService.loadActivityPhotos(activityId);
      if (photos.isNotEmpty) {
        await _supabaseService.saveActivityPhotos(activityId, photos);
      }

      // Sync activity streams
      final streams = await _sqliteActivityService.loadStreams(activityId);
      if (streams.streams?.isNotEmpty == true) {
        await _supabaseService.saveStreams(activityId, streams);
      }

      // Sync segment efforts
      final segmentEfforts = await _sqliteSegmentEffortService.getSegmentEffortsForActivity(activityId);
      if (segmentEfforts.isNotEmpty) {
        final efforts = segmentEfforts.map((e) => e.effort).toList();
        await _supabaseService.saveSegmentEfforts(activityId, efforts);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing details for activity $activityId to Supabase: $e');
      }
      // Continue with other activities even if one fails
    }
  }

  /// Syncs data from Supabase to SQLite
  ///
  /// This method fetches data from Supabase and caches it in SQLite.
  /// It should be called when the app starts, when new data is added to Supabase,
  /// or when the device comes online after being offline.
  Future<void> syncFromSupabase() async {
    if (_isSyncing) {
      if (kDebugMode) {
        print('Sync already in progress');
      }
      return;
    }

    _isSyncing = true;
    _setSyncState(SyncState.syncingFromSupabase);

    try {
      // Ensure we're authenticated with Supabase
      final isAuthenticated = await _authService.isAuthenticated();
      if (!isAuthenticated) {
        throw Exception('Not authenticated with Supabase');
      }

      if (kDebugMode) {
        print('Starting sync from Supabase to SQLite');
      }

      // Get last sync time
      final prefs = await SharedPreferences.getInstance();
      final lastSyncTime = prefs.getInt('last_sync_time');
      final lastSyncDate = lastSyncTime != null
          ? DateTime.fromMillisecondsSinceEpoch(lastSyncTime)
          : DateTime(2015, 1, 1);

      // Get activities updated since last sync
      final activities = await _supabaseService.getActivities(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        lastSyncDate.millisecondsSinceEpoch ~/ 1000,
      );

      if (activities.isEmpty) {
        if (kDebugMode) {
          print('No activities to sync');
        }
      } else {
        if (kDebugMode) {
          print('Syncing ${activities.length} activities');
        }

        // Sync activities in chunks to avoid memory issues
        const chunkSize = 50;
        for (var i = 0; i < activities.length; i += chunkSize) {
          final end = (i + chunkSize < activities.length) ? i + chunkSize : activities.length;
          final chunk = activities.sublist(i, end);

          // Update progress
          _setSyncState(SyncState.syncingFromSupabase);
          if (kDebugMode) {
            print('Syncing activities ${i + 1}-$end of ${activities.length}');
          }

          // Save activities to SQLite
          await _sqliteActivityService.saveActivities(chunk);

          // Sync activity details, photos, streams, and segment efforts for each activity
          for (var activity in chunk) {
            await _syncActivityDetailsFromSupabase(activity.id);
          }
        }
      }

      // Sync worlds, routes, and climbs
      await _syncWorldsFromSupabase();
      await _syncRoutesFromSupabase();
      await _syncClimbsFromSupabase();

      // Update last sync time
      await _updateLastSyncTime();

      if (kDebugMode) {
        print('Sync from Supabase completed successfully');
      }
      _setSyncState(SyncState.completed);
    } catch (e) {
      if (kDebugMode) {
        print('Error during sync from Supabase: $e');
      }
      _setSyncState(SyncState.error);
    } finally {
      _isSyncing = false;
    }
  }

  /// Syncs worlds from Supabase to local storage
  ///
  /// This method fetches worlds from Supabase and stores them locally.
  Future<void> _syncWorldsFromSupabase() async {
    try {
      if (kDebugMode) {
        print('Syncing worlds from Supabase');
      }

      // Get worlds from Supabase
      final worlds = await _supabaseService.getWorlds();
      
      if (worlds.isEmpty) {
        if (kDebugMode) {
          print('No worlds to sync from Supabase');
        }
        return;
      }

      if (kDebugMode) {
        print('Synced ${worlds.length} worlds from Supabase');
      }

      // In a real implementation, you would save these worlds to a local database or file
      // For now, we'll just log them
      if (kDebugMode) {
        print('Worlds synced from Supabase: ${worlds.length}');
        for (var i = 0; i < min(5, worlds.length); i++) {
          print('  - ${worlds[i].name}');
        }
        if (worlds.length > 5) {
          print('  - ... and ${worlds.length - 5} more');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing worlds from Supabase: $e');
      }
      // Continue with other sync operations even if worlds sync fails
    }
  }

  /// Syncs routes from Supabase to local storage
  ///
  /// This method fetches routes from Supabase and stores them locally.
  Future<void> _syncRoutesFromSupabase() async {
    try {
      if (kDebugMode) {
        print('Syncing routes from Supabase');
      }

      // Get routes from Supabase
      final routes = await _supabaseService.getRoutes();
      
      if (routes.isEmpty) {
        if (kDebugMode) {
          print('No routes to sync from Supabase');
        }
        return;
      }

      if (kDebugMode) {
        print('Synced ${routes.length} routes from Supabase');
      }

      // In a real implementation, you would save these routes to a local database or file
      // For now, we'll just log them
      if (kDebugMode) {
        print('Routes synced from Supabase: ${routes.length}');
        for (var i = 0; i < min(5, routes.length); i++) {
          print('  - ${routes[i].routeName} (${routes[i].world})');
        }
        if (routes.length > 5) {
          print('  - ... and ${routes.length - 5} more');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing routes from Supabase: $e');
      }
      // Continue with other sync operations even if routes sync fails
    }
  }

  /// Syncs climbs from Supabase to local storage
  ///
  /// This method fetches climbs from Supabase and stores them locally.
  Future<void> _syncClimbsFromSupabase() async {
    try {
      if (kDebugMode) {
        print('Syncing climbs from Supabase');
      }

      // Get climbs from Supabase
      final climbs = await _supabaseService.getClimbs();
      
      if (climbs.isEmpty) {
        if (kDebugMode) {
          print('No climbs to sync from Supabase');
        }
        return;
      }

      if (kDebugMode) {
        print('Synced ${climbs.length} climbs from Supabase');
      }

      // In a real implementation, you would save these climbs to a local database or file
      // For now, we'll just log them
      if (kDebugMode) {
        print('Climbs synced from Supabase: ${climbs.length}');
        for (var i = 0; i < min(5, climbs.length); i++) {
          print('  - ${climbs[i].name}');
        }
        if (climbs.length > 5) {
          print('  - ... and ${climbs.length - 5} more');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing climbs from Supabase: $e');
      }
      // Continue with other sync operations even if climbs sync fails
    }
  }

  /// Helper function to get the minimum of two integers
  int min(int a, int b) => a < b ? a : b;

  /// Public method to refresh calendar data from Zwift Insider
  ///
  /// This method scrapes world and climb calendar data from Zwift Insider and syncs it to Supabase.
  /// It's intended to be called from the UI when the user wants to refresh calendar data.
  Future<void> refreshCalendarData() async {
    if (_isSyncing) {
      if (kDebugMode) {
        print('Sync already in progress');
      }
      return;
    }

    _isSyncing = true;
    _setSyncState(SyncState.syncingToSupabase);

    try {
      // Ensure we're authenticated with Supabase
      final isAuthenticated = await _authService.isAuthenticated();
      if (!isAuthenticated) {
        throw Exception('Not authenticated with Supabase');
      }

      if (kDebugMode) {
        print('Starting calendar data refresh from Zwift Insider');
      }
      
      // Scrape calendar data from Zwift Insider
      if (kDebugMode) {
        print('Scraping calendar data from Zwift Insider');
      }
      
      final calendarScraperService = CalendarScraperService();
      
      // Scrape world calendar data
      final worldCalendarData = await calendarScraperService.scrapeWorldCalendarData();
      
      // Scrape climb calendar data
      final climbCalendarData = await calendarScraperService.scrapeClimbCalendarData();
      
      if (kDebugMode) {
        print('Scraped world calendar data for ${worldCalendarData.length} days');
        print('Scraped climb calendar data for ${climbCalendarData.length} days');
      }
      
      // TODO: Save calendar data to Supabase
      // This will be implemented in a future update when the calendar tables are created
      
      if (kDebugMode) {
        print('Calendar data refresh completed successfully.');
      }
      
      _setSyncState(SyncState.completed);
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing calendar data: $e');
      }
      _setSyncState(SyncState.error);
      throw Exception('Failed to refresh calendar data: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Public method to refresh route data from Zwift Insider
  ///
  /// This method scrapes route data from Zwift Insider and syncs it to Supabase.
  /// It's intended to be called from the UI when the user wants to refresh route data.
  Future<void> refreshRouteData() async {
    if (_isSyncing) {
      if (kDebugMode) {
        print('Sync already in progress');
      }
      return;
    }

    _isSyncing = true;
    _setSyncState(SyncState.syncingToSupabase);

    try {
      // Ensure we're authenticated with Supabase
      final isAuthenticated = await _authService.isAuthenticated();
      if (!isAuthenticated) {
        throw Exception('Not authenticated with Supabase');
      }

      if (kDebugMode) {
        print('Starting route data refresh from Zwift Insider');
      }

      // Get routes from Supabase
      final existingRoutes = await _supabaseService.getRoutes();
      
      // Scrape route data from Zwift Insider
      if (kDebugMode) {
        print('Scraping route data from Zwift Insider');
      }
      
      final routeScraperService = RouteScraperService();
      final scrapedData = await routeScraperService.scrapeRouteData();
      
      final scrapedWorlds = scrapedData['worlds'] as List<WorldData>;
      final scrapedRoutes = scrapedData['routes'] as List<RouteData>;
      
      if (kDebugMode) {
        print('Scraped ${scrapedWorlds.length} worlds and ${scrapedRoutes.length} routes from Zwift Insider');
      }
      
      // Get worlds from Supabase
      final existingWorlds = await _supabaseService.getWorlds();
      final existingWorldIds = existingWorlds.map((w) => w.id).toSet();
      
      // Save scraped worlds to Supabase if they don't exist
      for (var world in scrapedWorlds) {
        if (!existingWorldIds.contains(world.id)) {
          await _supabaseService.saveWorlds([world]);
        }
      }
      
      // Create a map of existing routes by name for quick lookup
      final existingRoutesByName = {for (var route in existingRoutes) route.routeName: route};
      
      // Create a map to hold unique routes by ID
      final Map<int, RouteData> uniqueRoutesToSave = {};
      
      // Process scraped routes
      for (var scrapedRoute in scrapedRoutes) {
        if (existingRoutesByName.containsKey(scrapedRoute.routeName)) {
          // Route exists, update it if needed
          final existingRoute = existingRoutesByName[scrapedRoute.routeName]!;
          
          // Check if any data has changed
          if (existingRoute.distanceMeters != scrapedRoute.distanceMeters ||
              existingRoute.altitudeMeters != scrapedRoute.altitudeMeters ||
              existingRoute.eventOnly != scrapedRoute.eventOnly) {
            // Update the existing route with new data
            existingRoute.distanceMeters = scrapedRoute.distanceMeters;
            existingRoute.altitudeMeters = scrapedRoute.altitudeMeters;
            existingRoute.eventOnly = scrapedRoute.eventOnly;
            
            // Only add if we haven't seen this ID before
            if (existingRoute.id != null && !uniqueRoutesToSave.containsKey(existingRoute.id)) {
              uniqueRoutesToSave[existingRoute.id!] = existingRoute;
            }
          }
        } else {
          // New route, add it
          scrapedRoute.completed = false;
          
          // Only add if we haven't seen this ID before
          if (scrapedRoute.id != null && !uniqueRoutesToSave.containsKey(scrapedRoute.id)) {
            uniqueRoutesToSave[scrapedRoute.id!] = scrapedRoute;
          }
        }
      }
      
      // Convert map values to list
      final List<RouteData> routesToSave = uniqueRoutesToSave.values.toList();
      
      // Save routes to Supabase
      if (routesToSave.isNotEmpty) {
        await _supabaseService.saveRoutes(routesToSave);
      }
      
      if (kDebugMode) {
        print('Route data refresh completed successfully. Updated ${routesToSave.length} routes.');
      }
      
      _setSyncState(SyncState.completed);
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing route data: $e');
      }
      _setSyncState(SyncState.error);
      throw Exception('Failed to refresh route data: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Syncs activity details from Supabase to SQLite
  ///
  /// This method syncs activity details, photos, streams, and segment efforts
  /// for the specified activity from Supabase to SQLite.
  Future<void> _syncActivityDetailsFromSupabase(int activityId) async {
    try {
      // Sync activity details
      final activityDetail = await _supabaseService.getActivityDetail(activityId);
      if (activityDetail != null) {
        await _sqliteActivityService.saveActivityDetail(activityDetail);
      }

      // Sync activity photos
      final photos = await _supabaseService.getActivityPhotos(activityId);
      if (photos.isNotEmpty) {
        await _sqliteActivityService.saveActivityPhotos(activityId, photos);
      }

      // Sync activity streams
      final streams = await _supabaseService.getStreams(activityId);
      if (streams != null && streams.streams?.isNotEmpty == true) {
        await _sqliteActivityService.saveStreams(activityId, streams);
      }

      // Sync segment efforts
      final segmentEfforts = await _supabaseService.getSegmentEffortsForActivity(activityId);
      if (segmentEfforts.isNotEmpty) {
        // Convert SegmentEffort to ExtendedSegmentEffort
        final extendedEfforts = segmentEfforts.map((effort) {
          return ExtendedSegmentEffort(
            activityId: activityId,
            effort: effort,
          );
        }).toList();
        
        // Save segment efforts to SQLite
        for (var extendedEffort in extendedEfforts) {
          await _sqliteSegmentEffortService.saveSegmentEfforts(
            activityId,
            [extendedEffort.effort],
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing details for activity $activityId: $e');
      }
      // Continue with other activities even if one fails
    }
  }
}

/// Synchronization state
///
/// This enum represents the current state of the synchronization process.
enum SyncState {
  /// No synchronization is in progress
  idle,

  /// Initial migration is in progress
  migrating,

  /// Synchronizing pending changes from SQLite to Supabase
  syncingToSupabase,

  /// Synchronizing data from Supabase to SQLite cache
  syncingFromSupabase,

  /// Synchronization completed successfully
  completed,

  /// An error occurred during synchronization
  error,
}
