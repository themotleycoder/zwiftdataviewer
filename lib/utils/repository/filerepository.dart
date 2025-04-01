import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_strava_api/api/streams.dart';
import 'package:flutter_strava_api/models/activity.dart';
import 'package:flutter_strava_api/models/summary_activity.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zwiftdataviewer/models/climbdata.dart';
import 'package:zwiftdataviewer/models/routedata.dart';
import 'package:zwiftdataviewer/models/worlddata.dart';
import 'package:zwiftdataviewer/utils/climbsconfig.dart';
import 'package:zwiftdataviewer/utils/constants.dart' as constants;
import 'package:zwiftdataviewer/utils/repository/activitesrepository.dart';
import 'package:zwiftdataviewer/utils/repository/configrepository.dart';
import 'package:zwiftdataviewer/utils/repository/routerepository.dart';
import 'package:zwiftdataviewer/utils/repository/streamsrepository.dart';
import 'package:zwiftdataviewer/utils/repository/worldcalendarrepository.dart';
import 'package:zwiftdataviewer/utils/worldsconfig.dart';

import '../../providers/config_provider.dart';

class FileRepository
    implements
        ActivitiesRepository,
        StreamsRepository,
        ConfigRepository,
        WorldCalendarRepository,
        RouteRepository {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localActivityFile async {
    const path = 'assets/testjson/';
    return File('$path/activities.json');
  }

  Future<File> get _localConfigFile async {
    final path = await _localPath;
    return File('$path/config.json');
  }

  Future<File> get _localRoutesFile async {
    final path = await _localPath;
    return File('$path/routes.json');
  }

  Future<File> get _localWorldCalendarFile async {
    final path = await _localPath;
    return File('$path/worldcalendar.json');
  }

  Future<File> get _localClimbCalendarFile async {
    final path = await _localPath;
    return File('$path/climbcalendar.json');
  }

  @override
  Future<List<SummaryActivity>> loadActivities(
      int beforeDate, int afterDate) async {
    List<SummaryActivity> activities = <SummaryActivity>[];
    try {
      final String jsonStr =
          await rootBundle.loadString('assets/testjson/activities_test.json');
      final jsonResponse = json.decode(jsonStr);
      for (var obj in jsonResponse) {
        activities.add(SummaryActivity.fromJson(obj));
      }
    } catch (e) {
      if (kDebugMode) {
        print('file load error$e.toString()');
      }
    }
    return activities;
  }

  @override
  Future<DetailedActivity> loadActivityDetail(int activityId) async {
    try {
      final String jsonStr =
          await rootBundle.loadString('assets/testjson/activity_test.json');
      final Map<String, dynamic> jsonResponse = json.decode(jsonStr);
      final DetailedActivity activity = DetailedActivity.fromJson(jsonResponse);
      return activity;
    } catch (e) {
      if (kDebugMode) {
        print('file load error$e');
      }
      return DetailedActivity();
    }
  }

  @override
  Future<List<PhotoActivity>> loadActivityPhotos(int activityId) async {
    PhotoActivity photoActivity;
    List<PhotoActivity> retVal = [];
    try {
      final String jsonStr =
          await rootBundle.loadString('assets/testjson/photos_test.json');
      if (kDebugMode) {
        print('');
      }
      final List<dynamic> jsonResponse = json.decode(jsonStr);
      for (Map m in jsonResponse) {
        photoActivity = PhotoActivity.fromJson(m);
        retVal.add(photoActivity);
      }
      return retVal;
    } catch (e) {
      if (kDebugMode) {
        print('file load error$e');
      }
      return [];
    }
  }

  @override
  Future<StreamsDetailCollection> loadStreams(int activityId) async {
    try {
      final String jsonStr =
          await rootBundle.loadString('assets/testjson/streams_test.json');
      final jsonResponse = json.decode(jsonStr);

      if (jsonResponse != null && jsonResponse is Map<String, dynamic>) {
        final StreamsDetailCollection streams =
            StreamsDetailCollection.fromJson(jsonResponse);
        return streams;
      } else {
        if (kDebugMode) {
          print('Invalid JSON structure in streams_test.json');
        }
        return StreamsDetailCollection();
      }
    } catch (e) {
      if (kDebugMode) {
        print('file load error: $e');
      }
      // Return an empty StreamsDetailCollection instead of null
      return StreamsDetailCollection();
    }
  }

  @override
  Future saveActivities(List<SummaryActivity> activities) async {
    final file = await _localActivityFile;
    String content = '[';
    for (int x = 0; x < activities.length; x++) {
      Map<String, dynamic> item = activities[x].toJson();
      if (x > 0) {
        content += ',';
      }
      content += jsonEncode(item);
    }
    content += ']';
    file.writeAsStringSync(content);
  }

  @override
  Future<ConfigData> loadConfig() async {
    final file = await _localConfigFile;
    try {
      final string = await file.readAsString();
      return ConfigData.fromJson(const JsonDecoder().convert(string));
    } catch (e) {
      final ConfigData config = ConfigData();
      config.lastSyncDate = constants.defaultDataDate;
      config.isMetric = false;
      await saveConfig(config);
      return config;
    }
  }

  @override
  Future saveConfig(ConfigData config) async {
    final file = await _localConfigFile;
    String content = jsonEncode(config.toJson()).toString();
    file.writeAsStringSync(content);
  }

  @override
  Future<Map<int, List<RouteData>>> loadRouteData() async {
    Map<int, List<RouteData>> routes = {};
    final file = await _localRoutesFile;
    try {
      final string = await file.readAsString();
      final json = const JsonDecoder().convert(string);
      for (var obj in json) {
        RouteData route = RouteData.fromJson(obj);
        if (route.eventOnly?.toLowerCase() != 'run only' &&
            route.eventOnly?.toLowerCase() != 'run only, event only') {
          if (!routes.containsKey(route.id)) {
            routes[route.id!] = <RouteData>[];
          }
          routes[route.id]?.add(route);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('file load error - scraping route data');
      }
      routes = await scrapeRouteData();
      saveRouteData(routes);
    }

    return routes;
  }

  @override
  Future saveRouteData(Map<int, List<RouteData>> routeData) async {
    final file = await _localRoutesFile;
    String content = '[';
    bool hasContent = false;
    routeData.forEach((key, worldRoute) {
      if (hasContent) {
        content += ',';
      }
      for (int x = 0; x < worldRoute.length; x++) {
        Map<String, dynamic> item = worldRoute[x].toJson();
        if (x > 0) {
          content += ',';
        }
        content += jsonEncode(item);
      }
      hasContent = true;
    });

    content += ']';
    file.writeAsStringSync(content);
  }

  @override
  Future<Map<int, List<RouteData>>> scrapeRouteData() async {
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

    final Map<int, List<RouteData>> routes = {};
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
            final int id = worldLookupByName[world] ?? 0;
            if (id == 0 && kDebugMode) {
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
                altitudeMeters, eventOnly, routeName, id);

            // Filter out run-only routes and add to the map
            if (route.eventOnly?.toLowerCase() != 'run only' &&
                route.eventOnly?.toLowerCase() != 'run only, event only') {
              if (!routes.containsKey(id)) {
                routes[id] = <RouteData>[];
              }
              routes[id]?.add(route);
            }
          } catch (e) {
            if (kDebugMode) {
              print('Error processing route row: $e');
            }
            // Continue to the next row instead of failing the entire process
            continue;
          }
        }

        // Save the scraped data
        await saveRouteData(routes);

        if (kDebugMode) {
          print(
              'Successfully scraped ${routes.values.expand((x) => x).length} routes');
        }
      } else {
        throw Exception('Failed to load routes: HTTP ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error scraping route data: $e');
      }
      throw Exception('Failed to scrape routes: $e');
    }

    return routes;
  }

  // World Calendar Portal Methods

  @override
  Future<Map<DateTime, List<WorldData>>> loadWorldCalendarData() async {
    Map<DateTime, List<WorldData>> calendarData = {};
    final file = await _localWorldCalendarFile;
    try {
      final string = await file.readAsString();
      final Map<String, dynamic> json = const JsonDecoder().convert(string);
      json.forEach((key, worldRoute) {
        List<WorldData> list = [];
        for (dynamic w in worldRoute) {
          list.add(WorldData(w['id'], null, w['name'], w['url']));
        }
        calendarData[DateTime.parse(key)] = list;
      });
    } catch (e) {
      if (kDebugMode) {
        print('file load error - scraping world calendar data');
      }
      calendarData = await scrapeWorldCalendarData();
      saveWorldCalendarData(calendarData);
    }

    return calendarData;
  }

  @override
  Future saveWorldCalendarData(Map<DateTime, List<WorldData>> routeData) async {
    final file = await _localWorldCalendarFile;
    String content = '{';
    bool hasContent = false;
    routeData.forEach((key, worldRoute) {
      if (hasContent) {
        content += ',';
      }

      String dateTime = key.toString();

      content += jsonEncode(dateTime);
      content += ':[';

      for (int x = 0; x < worldRoute.length; x++) {
        Map<String, dynamic> item = worldRoute[x].toJson();
        if (x > 0) {
          content += ',';
        }
        content += jsonEncode(item);
      }
      content += ']';

      hasContent = true;
    });

    content += '}';
    file.writeAsStringSync(content);
  }

  @override
  Future<Map<DateTime, List<WorldData>>> scrapeWorldCalendarData() async {
    // First, try to delete any existing cached file
    try {
      final file = await _localWorldCalendarFile;
      if (await file.exists()) {
        await file.delete();
        if (kDebugMode) {
          print('Deleted cached world calendar data file');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting cached world calendar data: $e');
      }
    }

    Map<DateTime, List<WorldData>> worlds = {};
    try {
      final response = await Client().get(
        Uri.parse('https://zwiftinsider.com/schedule/'),
        headers: {'User-Agent': 'ZwiftDataViewer App'},
      );

      if (response.statusCode == 200) {
        var doc = parser.parse(response.body);
        var dayElements = doc.getElementsByClassName('day-with-date');

        if (dayElements.isEmpty) {
          throw Exception('Could not find calendar days on Zwift Insider');
        }

        for (dynamic dayElement in dayElements) {
          try {
            var dayNumberElements =
                dayElement.getElementsByClassName('day-number');
            if (dayNumberElements.isEmpty) {
              continue; // Skip if no day number found
            }

            // Parse the day number
            int dayNumber;
            try {
              dayNumber = int.parse(dayNumberElements[0].text);
            } catch (e) {
              if (kDebugMode) {
                print('Error parsing day number: ${dayNumberElements[0].text}');
              }
              continue;
            }

            // Create the date for this day
            DateTime key =
                DateTime(DateTime.now().year, DateTime.now().month, dayNumber);

            // Find all world names within this day
            List<WorldData> worldData = [];
            var titleElements =
                dayElement.getElementsByClassName('spiffy-title');

            for (var titleElement in titleElements) {
              String worldName = titleElement.text.trim();

              // Clean up the world name
              worldName = worldName
                  .replaceAll('&#039;', "'")
                  .replaceAll('&quot;', '"')
                  .replaceAll('&amp;', '&')
                  .replaceAll("'", "'");

              // Look up the world ID
              int? worldId = worldLookupByName[worldName];

              if (worldId != null && allWorldsConfig.containsKey(worldId)) {
                // Add the world from the config
                worldData.add(allWorldsConfig[worldId]!);
              } else {
                if (kDebugMode) {
                  print('Unknown world: $worldName');
                }
                // Skip unknown worlds
              }
            }

            if (worldData.isNotEmpty) {
              worlds[key] = worldData;
            }
          } catch (e) {
            if (kDebugMode) {
              print('Error processing calendar day: $e');
            }
            // Continue to the next day instead of failing the entire process
            continue;
          }
        }

        // Save the scraped data
        await saveWorldCalendarData(worlds);

        if (kDebugMode) {
          print(
              'Successfully scraped world calendar with ${worlds.length} days');
        }
      } else {
        throw Exception(
            'Failed to load world calendar: HTTP ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error scraping world calendar data: $e');
      }
      throw Exception('Failed to scrape world calendar: $e');
    }

    return worlds;
  }

  // Climb Calendar Portal Methods

  Future<Map<DateTime, List<ClimbData>>> loadClimbCalendarData() async {
    Map<DateTime, List<ClimbData>> calendarData = {};
    final file = await _localClimbCalendarFile;
    try {
      final string = await file.readAsString();
      final Map<String, dynamic> json = const JsonDecoder().convert(string);
      json.forEach((key, climbRoute) {
        List<ClimbData> list = [];
        for (dynamic w in climbRoute) {
          list.add(ClimbData(w['id'], null, w['name'], w['url']));
        }
        calendarData[DateTime.parse(key)] = list;
      });
    } catch (e) {
      if (kDebugMode) {
        print('file load error - scraping climb calendar data');
      }
      calendarData = await scrapeClimbCalendarData();
      saveClimbCalendarData(calendarData);
    }

    return calendarData;
  }

  Future saveClimbCalendarData(Map<DateTime, List<ClimbData>> routeData) async {
    final file = await _localClimbCalendarFile;
    String content = '{';
    bool hasContent = false;
    routeData.forEach((key, worldRoute) {
      if (hasContent) {
        content += ',';
      }

      String dateTime = key.toString();

      content += jsonEncode(dateTime);
      content += ':[';

      for (int x = 0; x < worldRoute.length; x++) {
        Map<String, dynamic> item = worldRoute[x].toJson();
        if (x > 0) {
          content += ',';
        }
        content += jsonEncode(item);
      }
      content += ']';

      hasContent = true;
    });

    content += '}';
    file.writeAsStringSync(content);
  }

  Future<Map<DateTime, List<ClimbData>>> scrapeClimbCalendarData() async {
    // First, try to delete any existing cached file
    try {
      final file = await _localClimbCalendarFile;
      if (await file.exists()) {
        await file.delete();
        if (kDebugMode) {
          print('Deleted cached climb calendar data file');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting cached climb calendar data: $e');
      }
    }

    Map<DateTime, List<ClimbData>> climbs = {};
    final response = await Client()
        .get(Uri.parse('https://zwiftinsider.com/climb-portal-schedule/'));
    if (response.statusCode == 200) {
      var doc = parser.parse(response.body);
      var vals = doc.getElementsByClassName('day-with-date');

      for (dynamic val in vals) {
        int dayNumber =
            int.parse(val.getElementsByClassName('day-number')[0].innerHtml);
        DateTime key =
            DateTime(DateTime.now().year, DateTime.now().month, dayNumber);

        // Find all spiffy-title elements within this day
        List<ClimbData> climbData = [];
        var eventGroups = val.getElementsByClassName('spiffy-event-group');

        if (eventGroups.isNotEmpty) {
          for (var eventGroup in eventGroups) {
            var titleElements =
                eventGroup.getElementsByClassName('spiffy-title');

            for (var titleElement in titleElements) {
              String climbName = titleElement.innerHtml;

              // Decode HTML entities and normalize apostrophes
              climbName = climbName
                  .replaceAll('&#039;', "'")
                  .replaceAll('&quot;', '"')
                  .replaceAll('&amp;', '&')
                  .replaceAll("'", "'");

              // Extract the URL from the parent element if possible
              String url = '';
              try {
                var linkElement = titleElement.parent?.parent;
                if (linkElement != null &&
                    linkElement.attributes.containsKey('href')) {
                  url = linkElement.attributes['href'] ?? '';
                }
              } catch (e) {
                url = 'https://zwiftinsider.com/climb-portal-schedule/';
              }

              // Try to find the climb in the lookup map
              int? climbId = climbLookupByName[climbName];

              if (climbId != null && allClimbsConfig.containsKey(climbId)) {
                // Use the climb from the config
                climbData.add(allClimbsConfig[climbId]!);
              } else {
                // For climbs not in the lookup map, create a temporary ClimbData object
                // with ID 0 (which corresponds to ClimbId.all in the enum)
                if (kDebugMode) {
                  print('Unknown climb: $climbName');
                }

                climbData.add(ClimbData(0, ClimbId.others, climbName, url));
              }
            }
          }
        }

        if (climbData.isNotEmpty) {
          climbs[key] = climbData;
        }
      }
      saveClimbCalendarData(climbs);
    } else {
      throw Exception('Failed to load climb calendar data');
    }
    return climbs;
  }
}
