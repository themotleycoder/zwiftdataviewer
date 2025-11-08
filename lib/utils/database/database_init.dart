import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:zwiftdataviewer/utils/database/database_helper.dart';
import 'package:zwiftdataviewer/utils/database/services/activity_service.dart';
import 'package:zwiftdataviewer/utils/database/services/segment_effort_service.dart';
import 'package:zwiftdataviewer/utils/database/services/climb_analysis_service.dart';

// Initializes the SQLite database and provides access to database services.
class DatabaseInit {
  static final DatabaseInit _instance = DatabaseInit._internal();
  static bool _initialized = false;

  static late final ActivityService activityService;
  static late final SegmentEffortService segmentEffortService;
  static late final ClimbAnalysisService climbAnalysisService;
  static late final String _cacheDir;

  // Singleton pattern
  factory DatabaseInit() => _instance;

  DatabaseInit._internal();

  // Initializes the database and services.
  // Must be called before using any database services.
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize the database helper
      final dbHelper = DatabaseHelper();
      await dbHelper.database;
      
      // Check and perform migrations if needed
      await dbHelper.checkAndMigrate();
      
      // Log database version info
      final versionInfo = await dbHelper.getVersionInfo();
      if (kDebugMode) {
        print('Database version: ${versionInfo['version']}');
        print('Last updated: ${versionInfo['last_updated']}');
        print('Description: ${versionInfo['description']}');
      }
      
      // Set up cache directory for backward compatibility
      final appDocDir = await getApplicationDocumentsDirectory();
      _cacheDir = join(appDocDir.path, 'zwift_data_cache');
      
      // Create cache directory if it doesn't exist
      final cacheDir = Directory(_cacheDir);
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }
      
      // Initialize services
      activityService = ActivityService();
      segmentEffortService = SegmentEffortService();
      climbAnalysisService = ClimbAnalysisService();

      _initialized = true;
      if (kDebugMode) {
        print('Database initialized successfully');
      }
      
      // Clean up old cache files
      await cleanupOldCache();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing database: $e');
      }
      rethrow;
    }
  }
  
  // Resets the database by deleting it and recreating it.
  // Use with caution as this will delete all data.
  static Future<void> resetDatabase() async {
    if (!_initialized) {
      throw StateError('Database not initialized');
    }
    
    try {
      // Close the database
      final dbHelper = DatabaseHelper();
      await dbHelper.close();
      
      // Delete the database file
      final dbPath = join(await getDatabasesPath(), 'zwift_data.db');
      final dbFile = File(dbPath);
      if (await dbFile.exists()) {
        await dbFile.delete();
        if (kDebugMode) {
          print('Database file deleted');
        }
      }
      
      // Reinitialize the database
      _initialized = false;
      await initialize();
      
      if (kDebugMode) {
        print('Database reset successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error resetting database: $e');
      }
      rethrow;
    }
  }

  // Cleans up old cache files (older than 7 days)
  static Future<void> cleanupOldCache() async {
    try {
      final cacheDir = Directory(_cacheDir);
      if (await cacheDir.exists()) {
        final now = DateTime.now();
        await for (var entity in cacheDir.list()) {
          if (entity is File) {
            final stat = await entity.stat();
            if (now.difference(stat.modified) > const Duration(days: 7)) {
              try {
                await entity.delete();
                if (kDebugMode) {
                  print('Deleted old cache file: ${entity.path}');
                }
              } catch (e) {
                if (kDebugMode) {
                  print('Error deleting cache file ${entity.path}: $e');
                }
              }
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error cleaning up old cache: $e');
      }
      // Don't rethrow, this is a non-critical operation
    }
  }

  // Returns the cache directory path for backward compatibility
  static String get cacheDir => _cacheDir;

  // Checks if the database has been initialized
  static bool get isInitialized => _initialized;
  
  // Checks the database status and returns information about it
  static Future<Map<String, dynamic>> checkDatabaseStatus() async {
    final result = <String, dynamic>{};
    
    try {
      final dbHelper = DatabaseHelper();
      
      // Check if database file exists
      final exists = await dbHelper.databaseFileExists();
      result['file_exists'] = exists;
      
      // Get database file size
      final size = await dbHelper.getDatabaseFileSize();
      result['file_size'] = size;
      
      if (exists) {
        // Get database version info
        final versionInfo = await dbHelper.getVersionInfo();
        result['version'] = versionInfo;
        
        // Get list of tables
        final db = await dbHelper.database;
        final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name NOT IN ('android_metadata', 'sqlite_sequence')");
        result['tables'] = tables.map((t) => t['name']).toList();
        
        // Get row counts for each table
        final counts = await dbHelper.getTableRowCounts();
        result['row_counts'] = counts;
      }
      
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking database status: $e');
      }
      return {'error': e.toString()};
    }
  }
  
  // Reset the activity photos table
  static Future<void> resetActivityPhotosTable() async {
    try {
      final dbHelper = DatabaseHelper();
      await dbHelper.resetActivityPhotosTable();
      
      if (kDebugMode) {
        print('Activity photos table reset successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error resetting activity photos table: $e');
      }
      rethrow;
    }
  }
}
