import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_strava_api/models/summary_activity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zwiftdataviewer/utils/database/database_helper.dart';
import 'package:zwiftdataviewer/utils/database/database_init.dart';
import 'package:zwiftdataviewer/utils/database/services/activity_service.dart';
import 'package:zwiftdataviewer/utils/supabase/activity_sync_service.dart';
import 'package:zwiftdataviewer/utils/supabase/route_sync_service.dart';
import 'package:zwiftdataviewer/utils/supabase/supabase_auth_service.dart';
import 'package:zwiftdataviewer/utils/supabase/supabase_database_service.dart';
import 'package:zwiftdataviewer/utils/supabase/sync_state.dart';

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
  final ActivitySyncService _activitySyncService = ActivitySyncService();
  final RouteSyncService _routeSyncService = RouteSyncService();
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

        // Sync activities using the activity sync service
        await _activitySyncService.syncActivitiesToSupabase(validActivities);
      }

      // Sync worlds, routes, and climbs
      await _routeSyncService.syncWorldsToSupabase();
      await _routeSyncService.syncRoutesToSupabase();
      await _routeSyncService.syncClimbsToSupabase();

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

        // Sync activities using the activity sync service
        await _activitySyncService.syncActivitiesFromSupabase(activities);
      }

      // Sync worlds, routes, and climbs
      await _routeSyncService.syncWorldsFromSupabase();
      await _routeSyncService.syncRoutesFromSupabase();
      await _routeSyncService.syncClimbsFromSupabase();

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
      
      // Use the route sync service to refresh calendar data
      await _routeSyncService.refreshCalendarData();
      
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

      // Use the route sync service to refresh route data
      await _routeSyncService.refreshRouteData();
      
      if (kDebugMode) {
        print('Route data refresh completed successfully.');
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
}
