import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/models/routedata.dart';
import 'package:zwiftdataviewer/utils/repository/filerepository.dart';
import 'package:zwiftdataviewer/utils/supabase/database_sync_service.dart';
import 'package:zwiftdataviewer/utils/supabase/supabase_database_service.dart';

// Provider for route data
//
// This provider fetches route data from the Supabase database.
// It contains information about all available routes in Zwift.
// Falls back to file repository if Supabase fails.
final routeDataProvider =
    FutureProvider<Map<int, List<RouteData>>>((ref) async {
  try {
    // Try to load from Supabase first
    return await loadRouteDataFromSupabase();
  } catch (e) {
    // Log the error for debugging purposes
    if (kDebugMode) {
      print('Error loading route data from Supabase: $e');
    }
    
    try {
      // Fall back to file repository if Supabase fails
      if (kDebugMode) {
        print('Falling back to file repository for route data');
      }
      return await loadRouteDataFromFile();
    } catch (fallbackError) {
      // Log the fallback error
      if (kDebugMode) {
        print('Error loading route data from file: $fallbackError');
      }
      
      // Return empty data instead of rethrowing
      // This allows the UI to show an empty state rather than an error
      return {};
    }
  }
});

// Loads route data from the Supabase database
//
// This function fetches route data from the Supabase database.
// It's extracted as a separate function to allow for reuse.
Future<Map<int, List<RouteData>>> loadRouteDataFromSupabase() async {
  try {
    SupabaseDatabaseService service = SupabaseDatabaseService();
    List<RouteData> routes = await service.getRoutes();
    
    // Deduplicate routes based on route name and world
    routes = _deduplicateRoutes(routes);
    
    // Group routes by world ID
    Map<int, List<RouteData>> routesByWorld = {};
    for (var route in routes) {
      if (route.id != null) {
        if (!routesByWorld.containsKey(route.id)) {
          routesByWorld[route.id!] = [];
        }
        routesByWorld[route.id!]!.add(route);
      }
    }
    
    return routesByWorld;
  } catch (e) {
    if (kDebugMode) {
      print('Error in loadRouteDataFromSupabase: $e');
    }
    rethrow; // Let the provider handle the error
  }
}

// Deduplicates routes based on ID
//
// This function removes duplicate routes from the list.
// Routes are considered duplicates if they have the same ID.
// Only the first occurrence of each unique route is kept.
List<RouteData> _deduplicateRoutes(List<RouteData> routes) {
  if (routes.isEmpty) return routes;
  
  if (kDebugMode) {
    print('Deduplicating ${routes.length} routes');
  }
  
  // Use a map to track unique routes by ID
  final Map<int, RouteData> uniqueRoutesById = {};
  
  for (var route in routes) {
    // Only add the route if we haven't seen this ID before and ID is not null
    if (route.id != null && !uniqueRoutesById.containsKey(route.id)) {
      uniqueRoutesById[route.id!] = route;
    }
  }
  
  final result = uniqueRoutesById.values.toList();
  
  if (kDebugMode) {
    print('Deduplicated to ${result.length} unique routes (removed ${routes.length - result.length} duplicates)');
  }
  
  return result;
}

// Loads route data from the file repository
//
// This function fetches route data from the file repository.
// It's used as a fallback when Supabase is unavailable.
Future<Map<int, List<RouteData>>> loadRouteDataFromFile() async {
  try {
    FileRepository repository = FileRepository();
    return await repository.loadRouteData();
  } catch (e) {
    if (kDebugMode) {
      print('Error in loadRouteDataFromFile: $e');
    }
    rethrow; // Let the provider handle the error
  }
}

// Refreshes route data from Zwift Insider
//
// This function refreshes route data from Zwift Insider and saves it to Supabase.
// It uses the DatabaseSyncService to handle the refresh.
Future<void> refreshRouteData() async {
  try {
    if (kDebugMode) {
      print('Refreshing route data from Zwift Insider');
    }
    
    // Use the DatabaseSyncService to refresh route data
    final syncService = DatabaseSyncService();
    await syncService.refreshRouteData();
    
    if (kDebugMode) {
      print('Route data refreshed successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error refreshing route data: $e');
    }
    rethrow;
  }
}
