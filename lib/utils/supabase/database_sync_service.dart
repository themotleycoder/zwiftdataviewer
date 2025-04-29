import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_strava_api/models/activity.dart';
import 'package:flutter_strava_api/models/segmentEffort.dart';
import 'package:flutter_strava_api/models/summary_activity.dart';
import 'package:zwiftdataviewer/models/extended_segment_effort.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zwiftdataviewer/utils/database/database_helper.dart';
import 'package:zwiftdataviewer/utils/database/database_init.dart';
import 'package:zwiftdataviewer/utils/database/services/activity_service.dart';
import 'package:zwiftdataviewer/utils/database/services/segment_effort_service.dart';
import 'package:zwiftdataviewer/utils/supabase/supabase_auth_service.dart';
import 'package:zwiftdataviewer/utils/supabase/supabase_database_service.dart';

/// Service for synchronizing data between SQLite and Supabase
///
/// This service provides methods for migrating data from SQLite to Supabase,
/// syncing data between SQLite and Supabase, and handling offline/online transitions.
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

  /// Performs the initial migration from SQLite to Supabase
  ///
  /// This method migrates all data from SQLite to Supabase.
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
        print('Starting initial migration from SQLite to Supabase');
      }

      // Get all activities from SQLite
      final activities = await _sqliteActivityService.loadActivities(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        DateTime(2015, 1, 1).millisecondsSinceEpoch ~/ 1000,
      );

      if (activities == null || activities.isEmpty) {
        if (kDebugMode) {
          print('No activities to migrate');
        }
        _setSyncState(SyncState.completed);
        _isSyncing = false;
        return;
      }

      final validActivities = activities.whereType<SummaryActivity>().toList();
      if (kDebugMode) {
        print('Migrating ${validActivities.length} activities');
      }

      // Migrate activities in chunks to avoid memory issues
      const chunkSize = 50;
      for (var i = 0; i < validActivities.length; i += chunkSize) {
        final end = (i + chunkSize < validActivities.length) ? i + chunkSize : validActivities.length;
        final chunk = validActivities.sublist(i, end);

        // Update progress
        _setSyncState(SyncState.migrating);
        if (kDebugMode) {
          print('Migrating activities ${i + 1}-$end of ${validActivities.length}');
        }

        // Save activities to Supabase
        await _supabaseService.saveActivities(chunk);

        // Migrate activity details, photos, streams, and segment efforts for each activity
        for (var activity in chunk) {
          await _migrateActivityDetails(activity.id);
        }
      }

      // Update last sync time
      await _updateLastSyncTime();

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

  /// Migrates activity details from SQLite to Supabase
  ///
  /// This method migrates activity details, photos, streams, and segment efforts
  /// for the specified activity from SQLite to Supabase.
  Future<void> _migrateActivityDetails(int activityId) async {
    try {
      // Migrate activity details
      final activityDetail = await _sqliteActivityService.loadActivityDetail(activityId);
      if (activityDetail != null) {
        await _supabaseService.saveActivityDetail(activityDetail);
      }

      // Migrate activity photos
      final photos = await _sqliteActivityService.loadActivityPhotos(activityId);
      if (photos.isNotEmpty) {
        await _supabaseService.saveActivityPhotos(activityId, photos);
      }

      // Migrate activity streams
      final streams = await _sqliteActivityService.loadStreams(activityId);
      if (streams.streams?.isNotEmpty == true) {
        await _supabaseService.saveStreams(activityId, streams);
      }

      // Migrate segment efforts
      final segmentEfforts = await _sqliteSegmentEffortService.getSegmentEffortsForActivity(activityId);
      if (segmentEfforts.isNotEmpty) {
        final efforts = segmentEfforts.map((e) => e.effort).toList();
        await _supabaseService.saveSegmentEfforts(activityId, efforts);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error migrating details for activity $activityId: $e');
      }
      // Continue with other activities even if one fails
    }
  }

  /// Syncs data from SQLite to Supabase
  ///
  /// This method syncs data from SQLite to Supabase.
  /// It should be called when the device comes online or when new data is added to SQLite.
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
        _setSyncState(SyncState.completed);
        _isSyncing = false;
        return;
      }

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
          await _migrateActivityDetails(activity.id);
        }
      }

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
  /// This method syncs data from Supabase to SQLite.
  /// It should be called when the app starts or when new data is added to Supabase.
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
        _setSyncState(SyncState.completed);
        _isSyncing = false;
        return;
      }

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

  /// Initial migration from SQLite to Supabase is in progress
  migrating,

  /// Synchronizing data from SQLite to Supabase
  syncingToSupabase,

  /// Synchronizing data from Supabase to SQLite
  syncingFromSupabase,

  /// Synchronization completed successfully
  completed,

  /// An error occurred during synchronization
  error,
}
