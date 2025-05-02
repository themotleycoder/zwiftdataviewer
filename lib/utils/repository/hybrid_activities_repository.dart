import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_strava_api/api/streams.dart';
import 'package:flutter_strava_api/models/activity.dart';
import 'package:flutter_strava_api/models/summary_activity.dart';
import 'package:http/http.dart' as http;
import 'package:zwiftdataviewer/utils/database/database_init.dart';
import 'package:zwiftdataviewer/utils/database/services/activity_service.dart';
import 'package:zwiftdataviewer/utils/repository/activitesrepository.dart';
import 'package:zwiftdataviewer/utils/repository/streamsrepository.dart';
import 'package:zwiftdataviewer/utils/storage/tiered_storage_manager.dart';
import 'package:zwiftdataviewer/utils/supabase/database_sync_service.dart';
import 'package:zwiftdataviewer/utils/supabase/supabase_auth_service.dart';
import 'package:zwiftdataviewer/utils/supabase/supabase_database_service.dart';

/// Hybrid repository for activities
///
/// This repository implements a cache-aside pattern where Supabase is the system of record
/// and SQLite acts as a local cache. When online, data is primarily fetched from Supabase
/// and cached in SQLite. When offline, data is served from the SQLite cache.
/// The repository follows a unidirectional data flow where Supabase is the source of truth.
class HybridActivitiesRepository implements ActivitiesRepository, StreamsRepository {
  final ActivityService _sqliteService = DatabaseInit.activityService;
  final SupabaseDatabaseService _supabaseService = SupabaseDatabaseService();
  final SupabaseAuthService _authService = SupabaseAuthService();
  final DatabaseSyncService _syncService = DatabaseSyncService();
  final TieredStorageManager _storageManager = TieredStorageManager();
  
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
      final initialOnlineStatus = result != ConnectivityResult.none;
      
      // If we think we're online, do an additional check to verify actual internet connectivity
      if (initialOnlineStatus) {
        try {
          // Try to reach a reliable host with a short timeout
          final response = await http.get(
            Uri.parse('https://www.google.com'),
          ).timeout(const Duration(seconds: 5));
          
          _isOnline = response.statusCode >= 200 && response.statusCode < 300;
          if (kDebugMode) {
            print('Internet connectivity check: ${_isOnline ? 'Online' : 'Offline'}');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Internet connectivity check failed: $e');
          }
          _isOnline = false;
        }
      } else {
        _isOnline = false;
      }
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
    final initialOnlineStatus = result != ConnectivityResult.none;
    
    // Do a thorough connectivity check
    if (initialOnlineStatus) {
      await _checkConnectivity();
    } else {
      _isOnline = false;
    }
    
    if (kDebugMode) {
      print('Connectivity changed: ${_isOnline ? 'Online' : 'Offline'}');
    }
    
    // If we just came online and Supabase is enabled, sync changes
    if (_isOnline && wasOffline && _isSupabaseEnabled) {
      if (kDebugMode) {
        print('Device just came online, attempting to sync changes to Supabase');
      }
      
      // Try to restore authentication first
      try {
        final authService = SupabaseAuthService();
        final isAuthenticated = await authService.isAuthenticated();
        
        if (!isAuthenticated) {
          if (kDebugMode) {
            print('Not authenticated with Supabase, attempting to restore authentication');
          }
          
          final authRestored = await authService.tryRestoreAuth();
          if (authRestored) {
            if (kDebugMode) {
              print('Authentication restored successfully');
            }
          } else {
            if (kDebugMode) {
              print('Failed to restore authentication');
            }
            return;
          }
        }
        
        // Now sync changes
        await _syncService.syncToSupabase();
      } catch (e) {
        if (kDebugMode) {
          print('Error during connectivity change handling: $e');
        }
      }
    }
  }
  
  /// Checks if Supabase should be used
  ///
  /// This method checks if Supabase is enabled and if the device is online.
  Future<bool> _shouldUseSupabase() async {
    if (!_isSupabaseEnabled) {
      if (kDebugMode) print('Supabase disabled in settings');
      return false;
    }
    if (!_isOnline) {
      if (kDebugMode) print('Device is offline');
      return false;
    }
    
    // Check if authenticated with Supabase
    try {
      final isAuth = await _authService.isAuthenticated();
      if (!isAuth && kDebugMode) {
        if (kDebugMode) {
          print('Not authenticated with Supabase');
        }
      }
      return isAuth;
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
      // Cache-aside pattern: Try to get from Supabase first when online
      if (await _shouldUseSupabase()) {
        try {
          final activities = await _supabaseService.getActivities(beforeDate, afterDate);
          
          if (activities.isNotEmpty) {
            // Cache the results in SQLite for offline access
            await _sqliteService.saveActivities(activities);
            
            // Don't optimize storage for each activity during initial load
            // This will be done lazily when activity details are requested
            if (kDebugMode) {
              print('Retrieved ${activities.length} activities from Supabase and cached in SQLite (lazy optimization)');
            }
            
            return activities;
          }
          
          if (kDebugMode) {
            print('No activities found in Supabase, checking SQLite cache');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error loading activities from Supabase: $e');
            print('Falling back to SQLite cache');
          }
        }
      }
      
      // Offline mode or Supabase fetch failed: Use SQLite cache
      final sqliteActivities = await _sqliteService.loadActivities(beforeDate, afterDate);
      
      if (kDebugMode) {
        print('Retrieved ${sqliteActivities?.length ?? 0} activities from SQLite cache');
      }
      
      return sqliteActivities;
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
      // Record access to optimize storage for this activity
      // This is done when details are requested, implementing lazy optimization
      await _storageManager.recordActivityAccess(activityId);
      
      // Cache-aside pattern: Try to get from Supabase first when online
      if (await _shouldUseSupabase()) {
        try {
          final activityDetail = await _supabaseService.getActivityDetail(activityId);
          if (activityDetail != null) {
            // Cache the result in SQLite for offline access
            await _sqliteService.saveActivityDetail(activityDetail);
            
            // Now that details are requested, optimize storage for this activity
            // This implements lazy optimization
            await _storageManager.optimizeStorageForActivity(activityId);
            
            if (kDebugMode) {
              print('Retrieved activity detail for ID $activityId from Supabase and cached in SQLite with optimized storage');
            }
            
            return activityDetail;
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error loading activity detail from Supabase: $e');
            print('Falling back to SQLite cache');
          }
        }
      }
      
      // Offline mode or Supabase fetch failed: Use SQLite cache
      final sqliteActivityDetail = await _sqliteService.loadActivityDetail(activityId);
      
      if (kDebugMode) {
        print('Retrieved activity detail for ID $activityId from SQLite cache');
      }
      
      return sqliteActivityDetail;
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
      // Record access to optimize storage for this activity
      // This is done when photos are requested, implementing lazy optimization
      await _storageManager.recordActivityAccess(activityId);
      
      // Cache-aside pattern: Try to get from Supabase first when online
      if (await _shouldUseSupabase()) {
        try {
          final photos = await _supabaseService.getActivityPhotos(activityId);
          if (photos.isNotEmpty) {
            // Cache the results in SQLite for offline access
            await _sqliteService.saveActivityPhotos(activityId, photos);
            
            // Now that photos are requested, optimize storage for this activity
            // This implements lazy optimization
            await _storageManager.optimizeStorageForActivity(activityId);
            
            if (kDebugMode) {
              print('Retrieved ${photos.length} photos for activity ID $activityId from Supabase and cached in SQLite with optimized storage');
            }
            
            return photos;
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error loading activity photos from Supabase: $e');
            print('Falling back to SQLite cache');
          }
        }
      }
      
      // Offline mode or Supabase fetch failed: Use SQLite cache
      final sqlitePhotos = await _sqliteService.loadActivityPhotos(activityId);
      
      if (kDebugMode) {
        print('Retrieved ${sqlitePhotos.length} photos for activity ID $activityId from SQLite cache');
      }
      
      return sqlitePhotos;
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
      // Unidirectional data flow: Supabase is the source of truth
      // Save to Supabase first when online
      if (await _shouldUseSupabase()) {
        try {
          await _supabaseService.saveActivities(activities);
          
          if (kDebugMode) {
            print('Saved ${activities.length} activities to Supabase');
          }
          
          // Then cache in SQLite
          await _sqliteService.saveActivities(activities);
          
          if (kDebugMode) {
            print('Cached ${activities.length} activities in SQLite');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error saving activities to Supabase: $e');
            print('Saving to SQLite only, will sync to Supabase when online');
          }
          
          // If Supabase save fails, save to SQLite and queue for sync
          await _sqliteService.saveActivities(activities);
          
          // Mark these activities for sync when online
          // This would require a new table to track pending changes
          // For now, we'll rely on the periodic sync
        }
      } else {
        // Offline mode: Save to SQLite only
        await _sqliteService.saveActivities(activities);
        
        if (kDebugMode) {
          print('Offline mode: Saved ${activities.length} activities to SQLite only');
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
      // Record access to optimize storage for this activity
      // This is done when streams are requested, implementing lazy optimization
      await _storageManager.recordActivityAccess(activityId);
      
      // Cache-aside pattern: Try to get from Supabase first when online
      if (await _shouldUseSupabase()) {
        try {
          final streams = await _supabaseService.getStreams(activityId);
          if (streams != null && streams.streams?.isNotEmpty == true) {
            // Cache the result in SQLite for offline access
            await _sqliteService.saveStreams(activityId, streams);
            
            // Now that streams are requested, optimize storage for this activity
            // This implements lazy optimization
            await _storageManager.optimizeStorageForActivity(activityId);
            
            if (kDebugMode) {
              print('Retrieved streams for activity ID $activityId from Supabase and cached in SQLite with optimized storage');
            }
            
            return streams;
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error loading streams from Supabase: $e');
            print('Falling back to SQLite cache');
          }
        }
      }
      
      // Offline mode or Supabase fetch failed: Use SQLite cache
      final sqliteStreams = await _sqliteService.loadStreams(activityId);
      
      if (kDebugMode) {
        print('Retrieved streams for activity ID $activityId from SQLite cache');
      }
      
      return sqliteStreams;
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
  /// This method saves activity details to Supabase first, then caches in SQLite.
  Future<void> saveActivityDetail(DetailedActivity activity) async {
    try {
      // Unidirectional data flow: Supabase is the source of truth
      // Save to Supabase first when online
      if (await _shouldUseSupabase()) {
        try {
          await _supabaseService.saveActivityDetail(activity);
          
          if (kDebugMode) {
            print('Saved activity detail for ID ${activity.id} to Supabase');
          }
          
          // Then cache in SQLite
          await _sqliteService.saveActivityDetail(activity);
          
          if (kDebugMode) {
            print('Cached activity detail for ID ${activity.id} in SQLite');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error saving activity detail to Supabase: $e');
            print('Saving to SQLite only, will sync to Supabase when online');
          }
          
          // If Supabase save fails, save to SQLite and queue for sync
          await _sqliteService.saveActivityDetail(activity);
        }
      } else {
        // Offline mode: Save to SQLite only
        await _sqliteService.saveActivityDetail(activity);
        
        if (kDebugMode) {
          print('Offline mode: Saved activity detail for ID ${activity.id} to SQLite only');
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
  /// This method saves activity photos to Supabase first, then caches in SQLite.
  Future<void> saveActivityPhotos(int activityId, List<PhotoActivity> photos) async {
    try {
      // Unidirectional data flow: Supabase is the source of truth
      // Save to Supabase first when online
      if (await _shouldUseSupabase()) {
        try {
          await _supabaseService.saveActivityPhotos(activityId, photos);
          
          if (kDebugMode) {
            print('Saved ${photos.length} photos for activity ID $activityId to Supabase');
          }
          
          // Then cache in SQLite
          await _sqliteService.saveActivityPhotos(activityId, photos);
          
          if (kDebugMode) {
            print('Cached ${photos.length} photos for activity ID $activityId in SQLite');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error saving activity photos to Supabase: $e');
            print('Saving to SQLite only, will sync to Supabase when online');
          }
          
          // If Supabase save fails, save to SQLite and queue for sync
          await _sqliteService.saveActivityPhotos(activityId, photos);
        }
      } else {
        // Offline mode: Save to SQLite only
        await _sqliteService.saveActivityPhotos(activityId, photos);
        
        if (kDebugMode) {
          print('Offline mode: Saved ${photos.length} photos for activity ID $activityId to SQLite only');
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
  /// This method saves activity streams to Supabase first, then caches in SQLite.
  Future<void> saveStreams(int activityId, StreamsDetailCollection streams) async {
    try {
      // Unidirectional data flow: Supabase is the source of truth
      // Save to Supabase first when online
      if (await _shouldUseSupabase()) {
        try {
          await _supabaseService.saveStreams(activityId, streams);
          
          if (kDebugMode) {
            print('Saved streams for activity ID $activityId to Supabase');
          }
          
          // Then cache in SQLite
          await _sqliteService.saveStreams(activityId, streams);
          
          if (kDebugMode) {
            print('Cached streams for activity ID $activityId in SQLite');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error saving streams to Supabase: $e');
            print('Saving to SQLite only, will sync to Supabase when online');
          }
          
          // If Supabase save fails, save to SQLite and queue for sync
          await _sqliteService.saveStreams(activityId, streams);
        }
      } else {
        // Offline mode: Save to SQLite only
        await _sqliteService.saveStreams(activityId, streams);
        
        if (kDebugMode) {
          print('Offline mode: Saved streams for activity ID $activityId to SQLite only');
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
  /// This method deletes activities from Supabase first, then from SQLite.
  Future<int> deleteActivities(List<int> activityIds) async {
    try {
      // Unidirectional data flow: Supabase is the source of truth
      // Delete from Supabase first when online
      if (await _shouldUseSupabase()) {
        try {
          final deletedCount = await _supabaseService.deleteActivities(activityIds);
          
          if (kDebugMode) {
            print('Deleted $deletedCount activities from Supabase');
          }
          
          // Then delete from SQLite
          final sqliteDeletedCount = await _sqliteService.deleteActivities(activityIds);
          
          if (kDebugMode) {
            print('Deleted $sqliteDeletedCount activities from SQLite');
          }
          
          return deletedCount;
        } catch (e) {
          if (kDebugMode) {
            print('Error deleting activities from Supabase: $e');
            print('Deleting from SQLite only, will sync to Supabase when online');
          }
          
          // If Supabase delete fails, delete from SQLite and queue for sync
          final sqliteDeletedCount = await _sqliteService.deleteActivities(activityIds);
          return sqliteDeletedCount;
        }
      } else {
        // Offline mode: Delete from SQLite only
        final sqliteDeletedCount = await _sqliteService.deleteActivities(activityIds);
        
        if (kDebugMode) {
          print('Offline mode: Deleted $sqliteDeletedCount activities from SQLite only');
        }
        
        return sqliteDeletedCount;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting activities: $e');
      }
      return 0;
    }
  }
}
