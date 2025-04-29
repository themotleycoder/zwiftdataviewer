import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_strava_api/api/streams.dart';
import 'package:flutter_strava_api/models/activity.dart';
import 'package:flutter_strava_api/models/summary_activity.dart';
import 'package:zwiftdataviewer/utils/database/database_init.dart';
import 'package:zwiftdataviewer/utils/database/services/activity_service.dart';
import 'package:zwiftdataviewer/utils/repository/activitesrepository.dart';
import 'package:zwiftdataviewer/utils/repository/streamsrepository.dart';
import 'package:zwiftdataviewer/utils/supabase/database_sync_service.dart';
import 'package:zwiftdataviewer/utils/supabase/supabase_auth_service.dart';
import 'package:zwiftdataviewer/utils/supabase/supabase_database_service.dart';

/// Hybrid repository for activities
///
/// This repository uses both SQLite and Supabase for storing and retrieving data.
/// It tries to use Supabase first when online, and falls back to SQLite when offline.
/// It also queues changes for sync when back online.
class HybridActivitiesRepository implements ActivitiesRepository, StreamsRepository {
  final ActivityService _sqliteService = DatabaseInit.activityService;
  final SupabaseDatabaseService _supabaseService = SupabaseDatabaseService();
  final SupabaseAuthService _authService = SupabaseAuthService();
  final DatabaseSyncService _syncService = DatabaseSyncService();
  
  bool _isOnline = false;
  bool _isSupabaseEnabled = true; // This could be a user preference
  
  // Singleton pattern
  static final HybridActivitiesRepository _instance = HybridActivitiesRepository._internal();
  factory HybridActivitiesRepository() => _instance;
  
  HybridActivitiesRepository._internal() {
    // Initialize connectivity status
    _checkConnectivity();
    
    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen((result) {
      if (result.isNotEmpty) {
        _handleConnectivityChange(result.first);
      }
    });
  }
  
  /// Checks the current connectivity status
  Future<void> _checkConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      _isOnline = result != ConnectivityResult.none;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking connectivity: $e');
      }
      _isOnline = false;
    }
  }
  
  /// Handles connectivity changes
  ///
  /// This method is called when the device's connectivity changes.
  /// It triggers a sync when the device comes online.
  Future<void> _handleConnectivityChange(ConnectivityResult result) async {
    final wasOffline = !_isOnline;
    _isOnline = result != ConnectivityResult.none;
    
    if (_isOnline && wasOffline && _isSupabaseEnabled) {
      // Device just came online, sync changes
      await _syncService.syncToSupabase();
    }
  }
  
  /// Checks if Supabase should be used
  ///
  /// This method checks if Supabase is enabled and if the device is online.
  Future<bool> _shouldUseSupabase() async {
    if (!_isSupabaseEnabled) return false;
    if (!_isOnline) return false;
    
    // Check if authenticated with Supabase
    try {
      return await _authService.isAuthenticated();
    } catch (e) {
      if (kDebugMode) {
        print('Error checking Supabase authentication: $e');
      }
      return false;
    }
  }
  
  /// Sets whether Supabase is enabled
  ///
  /// This method sets whether Supabase should be used for storing and retrieving data.
  /// If enabled, it will try to use Supabase first when online, and fall back to SQLite when offline.
  /// If disabled, it will always use SQLite.
  Future<void> setSupabaseEnabled(bool enabled) async {
    _isSupabaseEnabled = enabled;
    
    if (enabled && _isOnline) {
      // Supabase was just enabled and we're online, perform initial migration
      final isAuthenticated = await _authService.isAuthenticated();
      if (isAuthenticated) {
        await _syncService.performInitialMigration();
      }
    }
  }
  
  /// Gets whether Supabase is enabled
  bool get isSupabaseEnabled => _isSupabaseEnabled;
  
  /// Gets whether the device is online
  bool get isOnline => _isOnline;
  
  /// Gets the sync service
  DatabaseSyncService get syncService => _syncService;
  
  // ActivitiesRepository implementation
  
  @override
  Future<List<SummaryActivity?>?> loadActivities(int beforeDate, int afterDate) async {
    try {
      // Try to use Supabase if enabled and online
      if (await _shouldUseSupabase()) {
        try {
          final activities = await _supabaseService.getActivities(beforeDate, afterDate);
          return activities;
        } catch (e) {
          if (kDebugMode) {
            print('Error loading activities from Supabase: $e');
            print('Falling back to SQLite');
          }
          // Fall back to SQLite
        }
      }
      
      // Use SQLite
      return await _sqliteService.loadActivities(beforeDate, afterDate);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading activities: $e');
      }
      rethrow;
    }
  }
  
  @override
  Future<DetailedActivity?> loadActivityDetail(int activityId) async {
    try {
      // Try to use Supabase if enabled and online
      if (await _shouldUseSupabase()) {
        try {
          final activityDetail = await _supabaseService.getActivityDetail(activityId);
          if (activityDetail != null) {
            return activityDetail;
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error loading activity detail from Supabase: $e');
            print('Falling back to SQLite');
          }
          // Fall back to SQLite
        }
      }
      
      // Use SQLite
      return await _sqliteService.loadActivityDetail(activityId);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading activity detail: $e');
      }
      rethrow;
    }
  }
  
  @override
  Future<List<PhotoActivity>> loadActivityPhotos(int activityId) async {
    try {
      // Try to use Supabase if enabled and online
      if (await _shouldUseSupabase()) {
        try {
          final photos = await _supabaseService.getActivityPhotos(activityId);
          return photos;
        } catch (e) {
          if (kDebugMode) {
            print('Error loading activity photos from Supabase: $e');
            print('Falling back to SQLite');
          }
          // Fall back to SQLite
        }
      }
      
      // Use SQLite
      return await _sqliteService.loadActivityPhotos(activityId);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading activity photos: $e');
      }
      return []; // Return empty list on error
    }
  }
  
  @override
  Future saveActivities(List<SummaryActivity> activities) async {
    try {
      // Always save to SQLite first
      await _sqliteService.saveActivities(activities);
      
      // Try to save to Supabase if enabled and online
      if (await _shouldUseSupabase()) {
        try {
          await _supabaseService.saveActivities(activities);
        } catch (e) {
          if (kDebugMode) {
            print('Error saving activities to Supabase: $e');
            print('Changes will be synced when online');
          }
          // Queue for sync when online
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving activities: $e');
      }
      rethrow;
    }
  }
  
  // StreamsRepository implementation
  
  @override
  Future<StreamsDetailCollection> loadStreams(int activityId) async {
    try {
      // Try to use Supabase if enabled and online
      if (await _shouldUseSupabase()) {
        try {
          final streams = await _supabaseService.getStreams(activityId);
          if (streams != null) {
            return streams;
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error loading streams from Supabase: $e');
            print('Falling back to SQLite');
          }
          // Fall back to SQLite
        }
      }
      
      // Use SQLite
      return await _sqliteService.loadStreams(activityId);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading streams: $e');
      }
      return StreamsDetailCollection(); // Return empty collection on error
    }
  }
  
  // Additional methods
  
  /// Saves activity details
  ///
  /// This method saves activity details to both SQLite and Supabase.
  Future<void> saveActivityDetail(DetailedActivity activity) async {
    try {
      // Always save to SQLite first
      await _sqliteService.saveActivityDetail(activity);
      
      // Try to save to Supabase if enabled and online
      if (await _shouldUseSupabase()) {
        try {
          await _supabaseService.saveActivityDetail(activity);
        } catch (e) {
          if (kDebugMode) {
            print('Error saving activity detail to Supabase: $e');
            print('Changes will be synced when online');
          }
          // Queue for sync when online
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving activity detail: $e');
      }
      rethrow;
    }
  }
  
  /// Saves activity photos
  ///
  /// This method saves activity photos to both SQLite and Supabase.
  Future<void> saveActivityPhotos(int activityId, List<PhotoActivity> photos) async {
    try {
      // Always save to SQLite first
      await _sqliteService.saveActivityPhotos(activityId, photos);
      
      // Try to save to Supabase if enabled and online
      if (await _shouldUseSupabase()) {
        try {
          await _supabaseService.saveActivityPhotos(activityId, photos);
        } catch (e) {
          if (kDebugMode) {
            print('Error saving activity photos to Supabase: $e');
            print('Changes will be synced when online');
          }
          // Queue for sync when online
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving activity photos: $e');
      }
      rethrow;
    }
  }
  
  /// Saves activity streams
  ///
  /// This method saves activity streams to both SQLite and Supabase.
  Future<void> saveStreams(int activityId, StreamsDetailCollection streams) async {
    try {
      // Always save to SQLite first
      await _sqliteService.saveStreams(activityId, streams);
      
      // Try to save to Supabase if enabled and online
      if (await _shouldUseSupabase()) {
        try {
          await _supabaseService.saveStreams(activityId, streams);
        } catch (e) {
          if (kDebugMode) {
            print('Error saving streams to Supabase: $e');
            print('Changes will be synced when online');
          }
          // Queue for sync when online
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving streams: $e');
      }
      rethrow;
    }
  }
  
  /// Deletes activities
  ///
  /// This method deletes activities from both SQLite and Supabase.
  Future<int> deleteActivities(List<int> activityIds) async {
    try {
      // Always delete from SQLite first
      final deletedCount = await _sqliteService.deleteActivities(activityIds);
      
      // Try to delete from Supabase if enabled and online
      if (await _shouldUseSupabase()) {
        try {
          await _supabaseService.deleteActivities(activityIds);
        } catch (e) {
          if (kDebugMode) {
            print('Error deleting activities from Supabase: $e');
            print('Changes will be synced when online');
          }
          // Queue for sync when online
        }
      }
      
      return deletedCount;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting activities: $e');
      }
      return 0;
    }
  }
}
