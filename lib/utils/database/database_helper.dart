import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  static const int _currentVersion = 4; // Incremented version number

  // Singleton pattern
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'zwift_data.db');
    
    return await openDatabase(
      path,
      version: _currentVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create version tracking table
    await db.execute('''
      CREATE TABLE db_version (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        version INTEGER NOT NULL,
        last_updated TEXT NOT NULL,
        description TEXT
      )
    ''');
    
    // Insert initial version record
    await db.insert('db_version', {
      'id': 1,
      'version': version,
      'last_updated': DateTime.now().toIso8601String(),
      'description': 'Initial database creation'
    });
    
    // Create tables
    await db.execute('''
      CREATE TABLE activities (
        id INTEGER PRIMARY KEY,
        resource_state INTEGER,
        athlete_id INTEGER,
        name TEXT,
        distance REAL,
        moving_time INTEGER,
        elapsed_time INTEGER,
        total_elevation_gain REAL,
        type TEXT,
        sport_type TEXT,
        start_date TEXT,
        start_date_local TEXT,
        timezone TEXT,
        utc_offset REAL,
        location_city TEXT,
        location_state TEXT,
        location_country TEXT,
        achievement_count INTEGER,
        kudos_count INTEGER,
        comment_count INTEGER,
        athlete_count INTEGER,
        photo_count INTEGER,
        trainer INTEGER,
        commute INTEGER,
        manual INTEGER,
        private INTEGER,
        visibility TEXT,
        flagged INTEGER,
        gear_id TEXT,
        start_latlng TEXT,
        end_latlng TEXT,
        average_speed REAL,
        max_speed REAL,
        average_cadence REAL,
        average_watts REAL,
        max_watts INTEGER,
        weighted_average_watts INTEGER,
        kilojoules REAL,
        device_watts INTEGER,
        has_heartrate INTEGER,
        average_heartrate REAL,
        max_heartrate REAL,
        heartrate_opt_out INTEGER,
        display_hide_heartrate_option INTEGER,
        elev_high REAL,
        elev_low REAL,
        upload_id INTEGER,
        upload_id_str TEXT,
        external_id TEXT,
        from_accepted_tag INTEGER,
        pr_count INTEGER,
        total_photo_count INTEGER,
        has_kudoed INTEGER,
        json_data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE activity_details (
        id INTEGER PRIMARY KEY,
        json_data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE activity_photos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        activity_id INTEGER,
        photo_id INTEGER,
        unique_id TEXT,
        json_data TEXT,
        FOREIGN KEY (activity_id) REFERENCES activities (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE activity_streams (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        activity_id INTEGER,
        json_data TEXT,
        FOREIGN KEY (activity_id) REFERENCES activities (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE segment_efforts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        activity_id INTEGER,
        segment_id INTEGER,
        segment_name TEXT,
        elapsed_time INTEGER,
        moving_time INTEGER,
        start_date TEXT,
        start_date_local TEXT,
        distance REAL,
        start_index INTEGER,
        end_index INTEGER,
        average_watts REAL,
        average_cadence REAL,
        average_heartrate REAL,
        max_heartrate REAL,
        pr_rank INTEGER,
        hidden INTEGER,
        elevation_difference REAL,
        average_grade REAL,
        climb_category INTEGER,
        json_data TEXT,
        FOREIGN KEY (activity_id) REFERENCES activities (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for faster queries
    await _createIndexes(db);
  }

  Future<void> _createIndexes(Database db) async {
    // Existing indexes
    await db.execute('CREATE INDEX idx_activities_start_date ON activities(start_date)');
    await db.execute('CREATE INDEX idx_activities_type ON activities(type)');
    await db.execute('CREATE INDEX idx_activities_sport_type ON activities(sport_type)');
    await db.execute('CREATE INDEX idx_activity_photos_activity_id ON activity_photos(activity_id)');
    await db.execute('CREATE INDEX idx_activity_streams_activity_id ON activity_streams(activity_id)');
    
    // Additional indexes for frequently queried fields
    await db.execute('CREATE INDEX idx_activities_name ON activities(name)');
    await db.execute('CREATE INDEX idx_activities_distance ON activities(distance)');
    await db.execute('CREATE INDEX idx_activities_moving_time ON activities(moving_time)');
    await db.execute('CREATE INDEX idx_activities_total_elevation_gain ON activities(total_elevation_gain)');
    await db.execute('CREATE INDEX idx_activities_average_watts ON activities(average_watts)');
    await db.execute('CREATE INDEX idx_activities_weighted_average_watts ON activities(weighted_average_watts)');
    await db.execute('CREATE INDEX idx_activities_has_heartrate ON activities(has_heartrate)');
    
    // Index for activity photos unique_id
    await db.execute('CREATE INDEX idx_activity_photos_unique_id ON activity_photos(unique_id)');
    
    // Indexes for segment efforts
    await db.execute('CREATE INDEX idx_segment_efforts_activity_id ON segment_efforts(activity_id)');
    await db.execute('CREATE INDEX idx_segment_efforts_segment_id ON segment_efforts(segment_id)');
    await db.execute('CREATE INDEX idx_segment_efforts_segment_name ON segment_efforts(segment_name)');
    await db.execute('CREATE INDEX idx_segment_efforts_elapsed_time ON segment_efforts(elapsed_time)');
    await db.execute('CREATE INDEX idx_segment_efforts_start_date ON segment_efforts(start_date)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      // Handle database migrations here when schema changes
      if (kDebugMode) {
        print('Database upgrade from $oldVersion to $newVersion');
      }
      
      // Migration logic for version 2
      if (oldVersion < 2) {
        // Create version tracking table if it doesn't exist
        await db.execute('''
          CREATE TABLE IF NOT EXISTS db_version (
            id INTEGER PRIMARY KEY CHECK (id = 1),
            version INTEGER NOT NULL,
            last_updated TEXT NOT NULL,
            description TEXT
          )
        ''');
        
        // Check if version record exists
        final List<Map<String, dynamic>> versionRecords = await db.query('db_version');
        if (versionRecords.isEmpty) {
          // Insert initial version record
          await db.insert('db_version', {
            'id': 1,
            'version': 2,
            'last_updated': DateTime.now().toIso8601String(),
            'description': 'Added version tracking and additional indexes'
          });
        } else {
          // Update version record
          await db.update('db_version', {
            'version': 2,
            'last_updated': DateTime.now().toIso8601String(),
            'description': 'Added version tracking and additional indexes'
          }, where: 'id = 1');
        }
        
        // Create additional indexes
        await db.execute('CREATE INDEX IF NOT EXISTS idx_activities_name ON activities(name)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_activities_distance ON activities(distance)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_activities_moving_time ON activities(moving_time)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_activities_total_elevation_gain ON activities(total_elevation_gain)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_activities_average_watts ON activities(average_watts)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_activities_weighted_average_watts ON activities(weighted_average_watts)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_activities_has_heartrate ON activities(has_heartrate)');
      }
      
      if (oldVersion < 3) {
        // Migration to version 3 - Add unique_id column to activity_photos table
        try {
          // Check if the column already exists
          final List<Map<String, dynamic>> columns = await db.rawQuery('PRAGMA table_info(activity_photos)');
          bool uniqueIdExists = false;
          for (var column in columns) {
            if (column['name'] == 'unique_id') {
              uniqueIdExists = true;
              break;
            }
          }
          
          if (!uniqueIdExists) {
            // Add the unique_id column
            await db.execute('ALTER TABLE activity_photos ADD COLUMN unique_id TEXT');
            if (kDebugMode) {
              print('Added unique_id column to activity_photos table');
            }
            
            // Create an index on the unique_id column
            await db.execute('CREATE INDEX idx_activity_photos_unique_id ON activity_photos(unique_id)');
            if (kDebugMode) {
              print('Created index on unique_id column in activity_photos table');
            }
          } else {
            if (kDebugMode) {
              print('unique_id column already exists in activity_photos table');
            }
            
            // Check if the index exists
            final List<Map<String, dynamic>> indexes = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='index' AND name='idx_activity_photos_unique_id'");
            if (indexes.isEmpty) {
              // Create the index if it doesn't exist
              await db.execute('CREATE INDEX idx_activity_photos_unique_id ON activity_photos(unique_id)');
              if (kDebugMode) {
                print('Created index on unique_id column in activity_photos table');
              }
            } else {
              if (kDebugMode) {
                print('Index on unique_id column already exists in activity_photos table');
              }
            }
          }
          
          // Update version record
          await db.update('db_version', {
            'version': 3,
            'last_updated': DateTime.now().toIso8601String(),
            'description': 'Added unique_id column to activity_photos table'
          }, where: 'id = 1');
          
          if (kDebugMode) {
            print('Migration to version 3 completed successfully');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error during migration to version 3: $e');
          }
          // Continue with other migrations even if this one fails
        }
      }
      
      if (oldVersion < 4) {
        // Migration to version 4 - Add segment_efforts table
        try {
          // Create segment_efforts table
          await db.execute('''
            CREATE TABLE IF NOT EXISTS segment_efforts (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              activity_id INTEGER,
              segment_id INTEGER,
              segment_name TEXT,
              elapsed_time INTEGER,
              moving_time INTEGER,
              start_date TEXT,
              start_date_local TEXT,
              distance REAL,
              start_index INTEGER,
              end_index INTEGER,
              average_watts REAL,
              average_cadence REAL,
              average_heartrate REAL,
              max_heartrate REAL,
              pr_rank INTEGER,
              hidden INTEGER,
              elevation_difference REAL,
              average_grade REAL,
              climb_category INTEGER,
              json_data TEXT,
              FOREIGN KEY (activity_id) REFERENCES activities (id) ON DELETE CASCADE
            )
          ''');
          
          if (kDebugMode) {
            print('Created segment_efforts table');
          }
          
          // Create indexes for segment_efforts table
          await db.execute('CREATE INDEX IF NOT EXISTS idx_segment_efforts_activity_id ON segment_efforts(activity_id)');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_segment_efforts_segment_id ON segment_efforts(segment_id)');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_segment_efforts_segment_name ON segment_efforts(segment_name)');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_segment_efforts_elapsed_time ON segment_efforts(elapsed_time)');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_segment_efforts_start_date ON segment_efforts(start_date)');
          
          if (kDebugMode) {
            print('Created indexes for segment_efforts table');
          }
          
          // Update version record
          await db.update('db_version', {
            'version': 4,
            'last_updated': DateTime.now().toIso8601String(),
            'description': 'Added segment_efforts table'
          }, where: 'id = 1');
          
          if (kDebugMode) {
            print('Migration to version 4 completed successfully');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error during migration to version 4: $e');
          }
          // Continue with other migrations even if this one fails
        }
      }
    }
  }

  // Method to check and perform migrations
  Future<void> checkAndMigrate() async {
    final db = await database;
    final version = await db.getVersion();
    if (version < _currentVersion) {
      await _onUpgrade(db, version, _currentVersion);
      await db.setVersion(_currentVersion);
      
      // Update version record
      try {
        await db.update('db_version', {
          'version': _currentVersion,
          'last_updated': DateTime.now().toIso8601String(),
        }, where: 'id = 1');
      } catch (e) {
        // Table might not exist in very old versions
        if (kDebugMode) {
          print('Error updating version record: $e');
        }
      }
    }
  }
  
  // Get database version history
  Future<Map<String, dynamic>> getVersionInfo() async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> versionRecords = await db.query('db_version');
      if (versionRecords.isNotEmpty) {
        return versionRecords.first;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting version info: $e');
      }
    }
    return {
      'version': await db.getVersion(),
      'last_updated': 'Unknown',
      'description': 'Version record not found'
    };
  }
  
  // Log a migration event
  Future<void> logMigration(int version, String description) async {
    final db = await database;
    try {
      await db.update('db_version', {
        'version': version,
        'last_updated': DateTime.now().toIso8601String(),
        'description': description
      }, where: 'id = 1');
    } catch (e) {
      if (kDebugMode) {
        print('Error logging migration: $e');
      }
    }
  }

  // Helper method to close the database
  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
  
  // Helper method to check if the database file exists
  Future<bool> databaseFileExists() async {
    final String path = join(await getDatabasesPath(), 'zwift_data.db');
    final file = File(path);
    final exists = await file.exists();
    if (kDebugMode) {
      print('Database file path: $path');
      print('Database file exists: $exists');
    }
    return exists;
  }
  
  // Helper method to get database file size
  Future<int> getDatabaseFileSize() async {
    final String path = join(await getDatabasesPath(), 'zwift_data.db');
    final file = File(path);
    if (await file.exists()) {
      final size = await file.length();
      if (kDebugMode) {
        print('Database file size: $size bytes');
      }
      return size;
    }
    return 0;
  }
  
  // Helper method to reset the activity photos table
  Future<void> resetActivityPhotosTable() async {
    final db = await database;
    
    try {
      await db.transaction((txn) async {
        // Delete all records from the activity_photos table
        final count = await txn.delete('activity_photos');
        
        if (kDebugMode) {
          print('Deleted $count records from activity_photos table');
        }
        
        // Reset the SQLite sequence for the table
        await txn.execute('DELETE FROM sqlite_sequence WHERE name = ?', ['activity_photos']);
        
        if (kDebugMode) {
          print('Reset sequence for activity_photos table');
        }
      });
      
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
  
  // Helper method to get table row counts
  Future<Map<String, int>> getTableRowCounts() async {
    final db = await database;
    final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name NOT IN ('android_metadata', 'sqlite_sequence')");
    
    final Map<String, int> counts = {};
    for (var table in tables) {
      final tableName = table['name'] as String;
      final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $tableName')) ?? 0;
      counts[tableName] = count;
    }
    
    return counts;
  }
}
