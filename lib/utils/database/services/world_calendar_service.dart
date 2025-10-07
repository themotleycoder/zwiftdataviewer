import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:zwiftdataviewer/models/climbdata.dart';
import 'package:zwiftdataviewer/models/worlddata.dart';
import 'package:zwiftdataviewer/utils/database/database_helper.dart';

/// Service for managing world calendar and climb calendar data in SQLite
///
/// This service provides methods for storing and retrieving calendar data
/// from the local SQLite database, replacing the file-based storage.
class WorldCalendarService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Singleton pattern
  static final WorldCalendarService _instance = WorldCalendarService._internal();
  factory WorldCalendarService() => _instance;
  WorldCalendarService._internal();

  /// Gets the database instance
  Future<Database> get _database async => await _dbHelper.database;

  /// Loads world calendar data from the database
  ///
  /// Returns a map where keys are dates (normalized to year/month/day only)
  /// and values are lists of WorldData for that date.
  Future<Map<DateTime, List<WorldData>>> loadWorldCalendarData() async {
    try {
      final db = await _database;
      final List<Map<String, dynamic>> results = await db.query('world_calendar');

      final Map<DateTime, List<WorldData>> calendarData = {};

      for (final row in results) {
        // Parse and normalize the date
        final dateStr = row['calendar_date'] as String;
        final parsedDate = DateTime.parse(dateStr);
        final normalizedDate = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);

        // Create WorldData object
        final worldData = WorldData(
          row['world_id'] as int,
          null, // sport field not used
          row['world_name'] as String,
          row['world_url'] as String?,
        );

        // Add to map
        if (!calendarData.containsKey(normalizedDate)) {
          calendarData[normalizedDate] = [];
        }
        calendarData[normalizedDate]!.add(worldData);
      }

      if (kDebugMode) {
        debugPrint('Loaded ${results.length} world calendar entries covering ${calendarData.length} dates');
      }

      return calendarData;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading world calendar data from database: $e');
      }
      return {};
    }
  }

  /// Saves world calendar data to the database
  ///
  /// Clears existing data and inserts new data. Uses a transaction for atomicity.
  Future<void> saveWorldCalendarData(Map<DateTime, List<WorldData>> calendarData) async {
    try {
      final db = await _database;

      await db.transaction((txn) async {
        // Clear existing data
        await txn.delete('world_calendar');

        // Insert new data
        int insertCount = 0;
        for (final entry in calendarData.entries) {
          final date = entry.key;
          final worlds = entry.value;

          // Normalize date to year/month/day only (no time)
          final normalizedDate = DateTime(date.year, date.month, date.day);
          final dateStr = normalizedDate.toIso8601String().split('T')[0];

          for (final world in worlds) {
            await txn.insert(
              'world_calendar',
              {
                'calendar_date': dateStr,
                'world_id': world.id,
                'world_name': world.name,
                'world_url': world.url,
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            insertCount++;
          }
        }

        if (kDebugMode) {
          debugPrint('Saved $insertCount world calendar entries to database');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving world calendar data to database: $e');
      }
      rethrow;
    }
  }

  /// Loads climb calendar data from the database
  ///
  /// Returns a map where keys are dates (normalized to year/month/day only)
  /// and values are lists of ClimbData for that date.
  Future<Map<DateTime, List<ClimbData>>> loadClimbCalendarData() async {
    try {
      final db = await _database;
      final List<Map<String, dynamic>> results = await db.query('climb_calendar');

      final Map<DateTime, List<ClimbData>> calendarData = {};

      for (final row in results) {
        // Parse and normalize the date
        final dateStr = row['calendar_date'] as String;
        final parsedDate = DateTime.parse(dateStr);
        final normalizedDate = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);

        // Create ClimbData object
        final climbData = ClimbData(
          row['climb_id'] as int,
          null, // sport field not used
          row['climb_name'] as String,
          row['climb_url'] as String?,
        );

        // Add to map
        if (!calendarData.containsKey(normalizedDate)) {
          calendarData[normalizedDate] = [];
        }
        calendarData[normalizedDate]!.add(climbData);
      }

      if (kDebugMode) {
        debugPrint('Loaded ${results.length} climb calendar entries covering ${calendarData.length} dates');
      }

      return calendarData;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading climb calendar data from database: $e');
      }
      return {};
    }
  }

  /// Saves climb calendar data to the database
  ///
  /// Clears existing data and inserts new data. Uses a transaction for atomicity.
  Future<void> saveClimbCalendarData(Map<DateTime, List<ClimbData>> calendarData) async {
    try {
      final db = await _database;

      await db.transaction((txn) async {
        // Clear existing data
        await txn.delete('climb_calendar');

        // Insert new data
        int insertCount = 0;
        for (final entry in calendarData.entries) {
          final date = entry.key;
          final climbs = entry.value;

          // Normalize date to year/month/day only (no time)
          final normalizedDate = DateTime(date.year, date.month, date.day);
          final dateStr = normalizedDate.toIso8601String().split('T')[0];

          for (final climb in climbs) {
            await txn.insert(
              'climb_calendar',
              {
                'calendar_date': dateStr,
                'climb_id': climb.id,
                'climb_name': climb.name,
                'climb_url': climb.url,
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            insertCount++;
          }
        }

        if (kDebugMode) {
          debugPrint('Saved $insertCount climb calendar entries to database');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving climb calendar data to database: $e');
      }
      rethrow;
    }
  }

  /// Clears all world calendar data from the database
  Future<void> clearWorldCalendarData() async {
    try {
      final db = await _database;
      await db.delete('world_calendar');
      if (kDebugMode) {
        debugPrint('Cleared all world calendar data');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error clearing world calendar data: $e');
      }
      rethrow;
    }
  }

  /// Clears all climb calendar data from the database
  Future<void> clearClimbCalendarData() async {
    try {
      final db = await _database;
      await db.delete('climb_calendar');
      if (kDebugMode) {
        debugPrint('Cleared all climb calendar data');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error clearing climb calendar data: $e');
      }
      rethrow;
    }
  }

  /// Gets the count of world calendar entries
  Future<int> getWorldCalendarCount() async {
    try {
      final db = await _database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM world_calendar');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting world calendar count: $e');
      }
      return 0;
    }
  }

  /// Gets the count of climb calendar entries
  Future<int> getClimbCalendarCount() async {
    try {
      final db = await _database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM climb_calendar');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting climb calendar count: $e');
      }
      return 0;
    }
  }
}
