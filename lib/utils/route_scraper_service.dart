import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zwiftdataviewer/models/routedata.dart';
import 'package:zwiftdataviewer/models/worlddata.dart';
import 'package:zwiftdataviewer/utils/worldsconfig.dart';

/// Service for scraping route data from Zwift Insider
class RouteScraperService {
  static final RouteScraperService _instance = RouteScraperService._internal();
  
  // Singleton pattern
  factory RouteScraperService() => _instance;

  RouteScraperService._internal();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localRoutesFile async {
    final path = await _localPath;
    return File('$path/routes.json');
  }

  /// Scrapes route data from Zwift Insider
  ///
  /// Returns a map with 'worlds' and 'routes' keys
  Future<Map<String, dynamic>> scrapeRouteData() async {
    // First, try to delete any existing cached file
    try {
      final file = await _localRoutesFile;
      if (await file.exists()) {
        await file.delete();
        if (kDebugMode) {
          print('Deleted cached routes data file');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting cached routes data: $e');
      }
    }

    final Map<int, List<RouteData>> routesByWorld = {};
    final Map<String, WorldData> worldsMap = {};
    
    try {
      final response = await Client().get(
        Uri.parse('https://zwiftinsider.com/routes/'),
        headers: {'User-Agent': 'ZwiftDataViewer App'},
      );

      if (response.statusCode == 200) {
        var doc = parser.parse(response.body);
        var tableContainer = doc.getElementsByClassName('wpv-loop js-wpv-loop');

        if (tableContainer.isEmpty) {
          throw Exception('Could not find route table on Zwift Insider');
        }

        var rows = tableContainer[0].children;

        var routeId = 0;

        for (dynamic row in rows) {
          try {
            // Find the route name and URL from the first cell with an anchor tag
            var routeNameCell = row.querySelector('td a');
            if (routeNameCell == null) {
              continue; // Skip this row if no link found
            }

            String routeName = routeNameCell.text ?? 'NA';
            String url = routeNameCell.attributes['href'] ?? '';

            // Clean up the route name
            routeName = routeName
                .replaceAll('&#039;', "'")
                .replaceAll('&quot;', '"')
                .replaceAll('&amp;', '&')
                .replaceAll("'", "'")
                .trim();

            // Get the cells in this row
            var cells = row.getElementsByTagName('td');
            if (cells.length < 6) {
              if (kDebugMode) {
                print(
                    'Skipping row with insufficient cells for route: $routeName');
              }
              continue;
            }

            // Extract data from the appropriate cells
            final String world = cells[1].text?.trim() ?? '';
            final String distance = cells[2].text?.trim() ?? '0km';
            final String altitude = cells[3].text?.trim() ?? '0m';

            // Event only status might be in different positions depending on the table structure
            String eventOnly = '';
            if (cells.length > 5) {
              eventOnly = cells[5].text?.trim() ?? '';
            }
            if (eventOnly.isEmpty && cells.length > 7) {
              eventOnly = cells[7].text?.trim() ?? '';
            }

            // Look up the world ID
            final int worldId = worldLookupByName[world] ?? 0;
            if (worldId == 0 && kDebugMode) {
              if (kDebugMode) {
                print('Unknown world: $world for route: $routeName');
              }
            }

            // Parse distance and altitude
            double distanceMeters = 0;
            try {
              // Handle different distance formats
              if (distance.contains('(')) {
                // Format like "29.6km (18.4 miles)"
                final metricPart = distance.split('(')[0].trim();

                if (metricPart.toLowerCase().contains('km')) {
                  // Extract numeric value and convert km to meters
                  final distanceStr =
                      metricPart.replaceAll(RegExp(r'[^\d.]'), '');
                  distanceMeters = double.parse(distanceStr) * 1000;
                } else if (metricPart.toLowerCase().contains('m')) {
                  // Extract numeric value for meters
                  final distanceStr =
                      metricPart.replaceAll(RegExp(r'[^\d.]'), '');
                  distanceMeters = double.parse(distanceStr);
                } else {
                  // Default to km if no unit specified
                  final distanceStr =
                      metricPart.replaceAll(RegExp(r'[^\d.]'), '');
                  distanceMeters = double.parse(distanceStr) * 1000;
                }
              } else {
                // Format without parentheses
                if (distance.toLowerCase().contains('km')) {
                  // Extract numeric value and convert km to meters
                  final distanceStr =
                      distance.replaceAll(RegExp(r'[^\d.]'), '');
                  distanceMeters = double.parse(distanceStr) * 1000;
                } else if (distance.toLowerCase().contains('m') &&
                    !distance.toLowerCase().contains('km')) {
                  // Extract numeric value for meters
                  final distanceStr =
                      distance.replaceAll(RegExp(r'[^\d.]'), '');
                  distanceMeters = double.parse(distanceStr);
                } else {
                  // Default to km if no unit specified
                  final distanceStr =
                      distance.replaceAll(RegExp(r'[^\d.]'), '');
                  distanceMeters = double.parse(distanceStr) * 1000;
                }
              }
            } catch (e) {
              if (kDebugMode) {
                print(
                    'Error parsing distance for route $routeName: $distance - $e');
              }
            }

            double altitudeMeters = 0;
            try {
              // Handle different altitude formats
              if (altitude.contains('(')) {
                // Format like "204m (669')"
                final metricPart = altitude.split('(')[0].trim();

                if (metricPart.toLowerCase().contains('m')) {
                  // Extract numeric value for meters
                  final altitudeStr =
                      metricPart.replaceAll(RegExp(r'[^\d.]'), '');
                  altitudeMeters =
                      altitudeStr.isEmpty ? 0 : double.parse(altitudeStr);
                } else {
                  // Default case
                  final altitudeStr =
                      metricPart.replaceAll(RegExp(r'[^\d.]'), '');
                  altitudeMeters =
                      altitudeStr.isEmpty ? 0 : double.parse(altitudeStr);
                }
              } else {
                // Format without parentheses
                if (altitude.toLowerCase().contains('m')) {
                  // Extract numeric value for meters
                  final altitudeStr =
                      altitude.replaceAll(RegExp(r'[^\d.]'), '');
                  altitudeMeters =
                      altitudeStr.isEmpty ? 0 : double.parse(altitudeStr);
                } else {
                  // Default case
                  final altitudeStr =
                      altitude.replaceAll(RegExp(r'[^\d.]'), '');
                  altitudeMeters =
                      altitudeStr.isEmpty ? 0 : double.parse(altitudeStr);
                }
              }
            } catch (e) {
              if (kDebugMode) {
                print(
                    'Unusual altitude value for route $routeName: $altitude - $e');
              }
            }



            // Create the route data object
            final RouteData route = RouteData(url, world, distanceMeters,
                altitudeMeters, eventOnly, routeName, routeId);

            // Set additional properties
            route.completed = false;
            route.imageId = routeId;

            // Filter out run-only routes and add to the map
            if (route.eventOnly?.toLowerCase() != 'run only' &&
                route.eventOnly?.toLowerCase() != 'run only, event only') {
              if (!routesByWorld.containsKey(worldId)) {
                routesByWorld[worldId] = <RouteData>[];
              }
              routesByWorld[worldId]?.add(route);
              
              // Add world to worldsMap if not already present
              if (!worldsMap.containsKey(world) && worldId > 0) {
                worldsMap[world] = WorldData(
                  worldId,
                  null, // GuestWorldId will be set later
                  world,
                  'https://zwiftinsider.com/worlds/$world',
                );
              }
            }

            routeId+=1;

          } catch (e) {
            if (kDebugMode) {
              print('Error processing route row: $e');
            }
            // Continue to the next row instead of failing the entire process
            continue;
          }
        }


        if (kDebugMode) {
          print(
              'Successfully scraped ${routesByWorld.values.expand((x) => x).length} routes and ${worldsMap.length} worlds');
        }
      } else {
        throw Exception('Failed to load routes: HTTP ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error scraping route data: $e');
      }
      return {
        'worlds': <WorldData>[],
        'routes': <RouteData>[],
      };
    }

    return {
      'worlds': worldsMap.values.toList(),
      'routes': routesByWorld.values.expand((routes) => routes).toList(),
    };
  }
}
