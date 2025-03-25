import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/models/routedata.dart';
import 'package:zwiftdataviewer/utils/repository/filerepository.dart';

/// Provider for route data
///
/// This provider fetches route data from the file repository.
/// It contains information about all available routes in Zwift.
final routeDataProvider =
    FutureProvider<Map<int, List<RouteData>>>((ref) async {
  try {
    return await loadRouteDataFromFile();
  } catch (e) {
    // Log the error for debugging purposes
    if (kDebugMode) {
      print('Error loading route data: $e');
    }

    // Return empty data instead of rethrowing
    // This allows the UI to show an empty state rather than an error
    return {};
  }
});

/// Loads route data from the file repository
///
/// This function fetches route data from the file repository.
/// It's extracted as a separate function to allow for reuse.
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
