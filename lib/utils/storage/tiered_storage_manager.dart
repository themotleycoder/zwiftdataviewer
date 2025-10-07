import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_strava_api/api/streams.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zwiftdataviewer/utils/database/database_init.dart';
import 'package:zwiftdataviewer/utils/database/services/activity_service.dart';
import 'package:zwiftdataviewer/utils/database/services/segment_effort_service.dart';
import 'package:zwiftdataviewer/utils/supabase/supabase_database_service.dart';

/// Manager for tiered storage approach
///
/// This class implements a tiered storage approach where frequently accessed data
/// is stored in SQLite and the complete dataset is in Supabase. It provides methods
/// for determining which data should be stored in SQLite based on access frequency
/// and importance.
class TieredStorageManager {
  static final TieredStorageManager _instance = TieredStorageManager._internal();
  final ActivityService _sqliteService = DatabaseInit.activityService;
  final SegmentEffortService _sqliteSegmentEffortService = DatabaseInit.segmentEffortService;
  final SupabaseDatabaseService _supabaseService = SupabaseDatabaseService();
  
  // Constants for storage tiers
  static const int _maxActivitiesInSqlite = 100; // Maximum number of activities to store in SQLite
  static const int _maxPhotosPerActivity = 10; // Maximum number of photos per activity to store in SQLite
  static const Duration _activityRetentionPeriod = Duration(days: 90); // How long to keep activities in SQLite
  
  // Access frequency tracking
  final Map<int, int> _activityAccessCount = {}; // Maps activity ID to access count
  final Map<int, DateTime> _activityLastAccessed = {}; // Maps activity ID to last access time
  
  // Singleton pattern
  factory TieredStorageManager() => _instance;
  
  TieredStorageManager._internal() {
    _loadAccessStats();
    
    // Schedule periodic cleanup
    Timer.periodic(const Duration(days: 1), (_) => _cleanupOldData());
  }
  
  /// Loads access statistics from SharedPreferences
  Future<void> _loadAccessStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load activity access counts
      final accessCountJson = prefs.getString('activity_access_counts');
      if (accessCountJson != null) {
        final Map<String, dynamic> counts = Map<String, dynamic>.from(
          jsonDecode(accessCountJson) as Map<String, dynamic>
        );
        
        counts.forEach((key, value) {
          _activityAccessCount[int.parse(key)] = value as int;
        });
      }
      
      // Load activity last accessed times
      final lastAccessedJson = prefs.getString('activity_last_accessed');
      if (lastAccessedJson != null) {
        final Map<String, dynamic> times = Map<String, dynamic>.from(
          jsonDecode(lastAccessedJson) as Map<String, dynamic>
        );
        
        times.forEach((key, value) {
          _activityLastAccessed[int.parse(key)] = DateTime.parse(value as String);
        });
      }
      
      if (kDebugMode) {
        print('Loaded access stats for ${_activityAccessCount.length} activities');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading access stats: $e');
      }
      // Continue even if loading fails
    }
  }
  
  /// Saves access statistics to SharedPreferences
  Future<void> _saveAccessStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Convert access counts to JSON
      final Map<String, dynamic> accessCountJson = {};
      _activityAccessCount.forEach((key, value) {
        accessCountJson[key.toString()] = value;
      });
      
      // Convert last accessed times to JSON
      final Map<String, dynamic> lastAccessedJson = {};
      _activityLastAccessed.forEach((key, value) {
        lastAccessedJson[key.toString()] = value.toIso8601String();
      });
      
      // Save to SharedPreferences
      await prefs.setString('activity_access_counts', jsonEncode(accessCountJson));
      await prefs.setString('activity_last_accessed', jsonEncode(lastAccessedJson));
      
      if (kDebugMode) {
        print('Saved access stats for ${_activityAccessCount.length} activities');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving access stats: $e');
      }
      // Continue even if saving fails
    }
  }
  
  /// Records an activity access
  ///
  /// This method records that an activity was accessed, incrementing its access count
  /// and updating its last access time.
  Future<void> recordActivityAccess(int activityId) async {
    // Increment access count
    _activityAccessCount[activityId] = (_activityAccessCount[activityId] ?? 0) + 1;
    
    // Update last access time
    _activityLastAccessed[activityId] = DateTime.now();
    
    // Save access stats periodically (not on every access to avoid performance issues)
    if (_activityAccessCount[activityId]! % 5 == 0) {
      await _saveAccessStats();
    }
  }
  
  /// Gets the access score for an activity
  ///
  /// This method calculates an access score for an activity based on its access count
  /// and last access time. Higher scores indicate more frequently accessed activities.
  double _getActivityAccessScore(int activityId) {
    final accessCount = _activityAccessCount[activityId] ?? 0;
    final lastAccessed = _activityLastAccessed[activityId] ?? DateTime(2000);
    
    // Calculate days since last access
    final daysSinceLastAccess = DateTime.now().difference(lastAccessed).inDays;
    
    // Calculate score: access count divided by days since last access (plus 1 to avoid division by zero)
    // This gives higher scores to activities that are accessed frequently and recently
    return accessCount / (daysSinceLastAccess + 1);
  }
  
  /// Cleans up old data from SQLite
  ///
  /// This method removes old or infrequently accessed data from SQLite to save space.
  Future<void> _cleanupOldData() async {
    try {
      if (kDebugMode) {
        print('Starting cleanup of old data from SQLite');
      }
      
      // Get all activities from SQLite
      final activities = await _sqliteService.loadActivities(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        DateTime(2000).millisecondsSinceEpoch ~/ 1000,
      );
      
      if (activities == null || activities.isEmpty) {
        if (kDebugMode) {
          print('No activities to clean up');
        }
        return;
      }
      
      // Calculate scores for all activities
      final Map<int, double> activityScores = {};
      for (final activity in activities) {
        if (activity?.id != null) {
          activityScores[activity!.id] = _getActivityAccessScore(activity.id);
        }
      }
      
      // Sort activities by score (descending)
      final sortedActivityIds = activityScores.keys.toList()
        ..sort((a, b) => activityScores[b]!.compareTo(activityScores[a]!));
      
      // Keep only the top N activities
      if (sortedActivityIds.length > _maxActivitiesInSqlite) {
        final activitiesToRemove = sortedActivityIds.sublist(_maxActivitiesInSqlite);
        
        if (kDebugMode) {
          print('Removing ${activitiesToRemove.length} activities from SQLite');
        }
        
        // Remove activities from SQLite
        await _sqliteService.deleteActivities(activitiesToRemove);
      }
      
      // Also remove activities older than retention period
      final retentionCutoff = DateTime.now().subtract(_activityRetentionPeriod);
      final activitiesToCheck = sortedActivityIds.take(_maxActivitiesInSqlite).toList();
      
      final List<int> oldActivities = [];
      for (final activityId in activitiesToCheck) {
        final activity = activities.firstWhere(
          (a) => a?.id == activityId,
          orElse: () => null,
        );
        
        if (activity != null) {
          final startDate = DateTime.parse(activity.startDate.toString());
          if (startDate.isBefore(retentionCutoff)) {
            oldActivities.add(activityId);
          }
        }
      }
      
      if (oldActivities.isNotEmpty) {
        if (kDebugMode) {
          print('Removing ${oldActivities.length} old activities from SQLite');
        }
        
        // Remove old activities from SQLite
        await _sqliteService.deleteActivities(oldActivities);
      }
      
      if (kDebugMode) {
        print('Cleanup completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error cleaning up old data: $e');
      }
      // Continue even if cleanup fails
    }
  }
  
  /// Determines if an activity should be cached in SQLite
  ///
  /// This method determines if an activity should be cached in SQLite based on
  /// its access frequency and importance.
  Future<bool> shouldCacheActivity(int activityId) async {
    // Always cache recently accessed activities
    final lastAccessed = _activityLastAccessed[activityId];
    if (lastAccessed != null) {
      final daysSinceLastAccess = DateTime.now().difference(lastAccessed).inDays;
      if (daysSinceLastAccess < 30) {
        return true;
      }
    }
    
    // Cache activities with high access scores
    final score = _getActivityAccessScore(activityId);
    if (score > 0.5) {
      return true;
    }
    
    // Check if we have room for more activities
    final activities = await _sqliteService.loadActivities(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      DateTime(2000).millisecondsSinceEpoch ~/ 1000,
    );
    
    if (activities == null || activities.length < _maxActivitiesInSqlite) {
      return true;
    }
    
    // If we're at capacity, only cache if this activity has a higher score than the lowest-scored cached activity
    final Map<int, double> activityScores = {};
    for (final activity in activities) {
      if (activity?.id != null) {
        activityScores[activity!.id] = _getActivityAccessScore(activity.id);
      }
    }
    
    // Find the lowest score
    final lowestScore = activityScores.values.reduce((a, b) => a < b ? a : b);
    
    // Cache if this activity's score is higher than the lowest score
    return score > lowestScore;
  }
  
  /// Determines if activity photos should be cached in SQLite
  ///
  /// This method determines if photos for an activity should be cached in SQLite
  /// based on the activity's access frequency and importance.
  Future<bool> shouldCacheActivityPhotos(int activityId) async {
    // Only cache photos for activities that are cached
    final shouldCacheActivity = await this.shouldCacheActivity(activityId);
    if (!shouldCacheActivity) {
      return false;
    }
    
    // Cache photos for frequently accessed activities
    final score = _getActivityAccessScore(activityId);
    return score > 1.0; // Higher threshold for photos
  }
  
  /// Gets the maximum number of photos to cache for an activity
  ///
  /// This method determines how many photos to cache for an activity based on
  /// its access frequency and importance.
  int getMaxPhotosToCache(int activityId) {
    final score = _getActivityAccessScore(activityId);
    
    // Scale the number of photos based on the access score
    if (score > 2.0) {
      return _maxPhotosPerActivity;
    } else if (score > 1.0) {
      return _maxPhotosPerActivity ~/ 2;
    } else {
      return 3; // Minimum number of photos to cache
    }
  }
  
  /// Determines if activity streams should be cached in SQLite
  ///
  /// This method determines if streams for an activity should be cached in SQLite
  /// based on the activity's access frequency and importance.
  Future<bool> shouldCacheActivityStreams(int activityId) async {
    // Only cache streams for activities that are cached
    final shouldCacheActivity = await this.shouldCacheActivity(activityId);
    if (!shouldCacheActivity) {
      return false;
    }
    
    // Cache streams for frequently accessed activities
    final score = _getActivityAccessScore(activityId);
    return score > 0.8; // Medium threshold for streams
  }
  
  /// Determines if segment efforts should be cached in SQLite
  ///
  /// This method determines if segment efforts for an activity should be cached in SQLite
  /// based on the activity's access frequency and importance.
  Future<bool> shouldCacheSegmentEfforts(int activityId) async {
    // Only cache segment efforts for activities that are cached
    final shouldCacheActivity = await this.shouldCacheActivity(activityId);
    if (!shouldCacheActivity) {
      return false;
    }
    
    // Cache segment efforts for frequently accessed activities
    final score = _getActivityAccessScore(activityId);
    return score > 0.8; // Medium threshold for segment efforts
  }
  
  /// Optimizes storage for an activity
  ///
  /// This method optimizes storage for an activity by determining what data should
  /// be cached in SQLite and what data should be stored only in Supabase.
  Future<void> optimizeStorageForActivity(int activityId) async {
    try {
      // Record access
      await recordActivityAccess(activityId);
      
      // Check if activity should be cached
      final shouldCache = await shouldCacheActivity(activityId);
      if (!shouldCache) {
        // Remove activity from SQLite if it's already there
        await _sqliteService.deleteActivities([activityId]);
        return;
      }
      
      // Check if photos should be cached
      final shouldCachePhotos = await shouldCacheActivityPhotos(activityId);
      if (!shouldCachePhotos) {
        // Remove photos from SQLite if they're already there
        await _sqliteService.saveActivityPhotos(activityId, []);
      } else {
        // Limit the number of photos cached
        final maxPhotos = getMaxPhotosToCache(activityId);
        final photos = await _supabaseService.getActivityPhotos(activityId);
        if (photos.length > maxPhotos) {
          // Cache only the first N photos
          await _sqliteService.saveActivityPhotos(activityId, photos.take(maxPhotos).toList());
        }
      }
      
      // Check if streams should be cached
      final shouldCacheStreams = await shouldCacheActivityStreams(activityId);
      if (!shouldCacheStreams) {
        // Remove streams from SQLite if they're already there
        await _sqliteService.saveStreams(activityId, StreamsDetailCollection());
      }
      
      // Check if segment efforts should be cached
      final shouldCacheEfforts = await shouldCacheSegmentEfforts(activityId);
      if (!shouldCacheEfforts) {
        // Remove segment efforts from SQLite if they're already there
        await _sqliteSegmentEffortService.deleteSegmentEffortsForActivity(activityId);
      }
      
      if (kDebugMode) {
        print('Optimized storage for activity $activityId:');
        print('- Cache activity: $shouldCache');
        print('- Cache photos: $shouldCachePhotos');
        print('- Cache streams: $shouldCacheStreams');
        print('- Cache segment efforts: $shouldCacheEfforts');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error optimizing storage for activity $activityId: $e');
      }
      // Continue even if optimization fails
    }
  }
}
