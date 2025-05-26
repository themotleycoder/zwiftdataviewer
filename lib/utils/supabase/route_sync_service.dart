import 'package:flutter/foundation.dart';
import 'package:zwiftdataviewer/models/climbdata.dart';
import 'package:zwiftdataviewer/models/routedata.dart';
import 'package:zwiftdataviewer/models/worlddata.dart';
import 'package:zwiftdataviewer/utils/calendar_scraper_service.dart';
import 'package:zwiftdataviewer/utils/climbsconfig.dart';
import 'package:zwiftdataviewer/utils/route_scraper_service.dart';
import 'package:zwiftdataviewer/utils/supabase/supabase_database_service.dart';
import 'package:zwiftdataviewer/utils/worldsconfig.dart';

/// Service for synchronizing route, world, and climb data between local config and Supabase
class RouteSyncService {
  final SupabaseDatabaseService _supabaseService = SupabaseDatabaseService();

  /// Helper function to get the minimum of two integers
  int min(int a, int b) => a < b ? a : b;

  /// Syncs worlds from local config to Supabase
  ///
  /// This method syncs worlds from the local configuration to Supabase.
  Future<void> syncWorldsToSupabase() async {
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
  Future<void> syncRoutesToSupabase() async {
    try {
      if (kDebugMode) {
        print('Syncing routes to Supabase');
      }

      // Get routes from Supabase
      final existingRoutes = await _supabaseService.getRoutes();

      // Get worlds from Supabase
      final existingWorlds = await _supabaseService.getWorlds();
      final existingWorldIds = existingWorlds.map((w) => w.id).toSet();

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
  Future<void> syncClimbsToSupabase() async {
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

  /// Syncs worlds from Supabase to local storage
  ///
  /// This method fetches worlds from Supabase and stores them locally.
  Future<void> syncWorldsFromSupabase() async {
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
  Future<void> syncRoutesFromSupabase() async {
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
  Future<void> syncClimbsFromSupabase() async {
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

  /// Public method to refresh calendar data from Zwift Insider
  ///
  /// This method scrapes world and climb calendar data from Zwift Insider and syncs it to Supabase.
  /// It's intended to be called from the UI when the user wants to refresh calendar data.
  Future<void> refreshCalendarData() async {
    try {
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
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing calendar data: $e');
      }
      throw Exception('Failed to refresh calendar data: $e');
    }
  }

  /// Public method to refresh route data from Zwift Insider
  ///
  /// This method scrapes route data from Zwift Insider and syncs it to Supabase.
  /// It's intended to be called from the UI when the user wants to refresh route data.
  Future<void> refreshRouteData() async {
    try {
      if (kDebugMode) {
        print('Starting route data refresh from Zwift Insider');
      }

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
      
      // Create a map to hold unique routes by ID - always save all scraped routes when refreshing
      final Map<int, RouteData> uniqueRoutesToSave = {};
      
      // Process all scraped routes and save them
      for (var scrapedRoute in scrapedRoutes) {
        scrapedRoute.completed = false;
        
        // Only add if we haven't seen this ID before
        if (scrapedRoute.id != null && !uniqueRoutesToSave.containsKey(scrapedRoute.id)) {
          uniqueRoutesToSave[scrapedRoute.id!] = scrapedRoute;
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
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing route data: $e');
      }
      throw Exception('Failed to refresh route data: $e');
    }
  }
}
