import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:zwiftdataviewer/models/climbdata.dart';
import 'package:zwiftdataviewer/models/worlddata.dart';
import 'package:zwiftdataviewer/utils/climbsconfig.dart';
import 'package:zwiftdataviewer/utils/worldsconfig.dart';

/// Service for scraping calendar data from Zwift Insider
class CalendarScraperService {
  static final CalendarScraperService _instance = CalendarScraperService._internal();
  
  // Singleton pattern
  factory CalendarScraperService() => _instance;

  CalendarScraperService._internal();

  /// Scrapes world calendar data from Zwift Insider
  ///
  /// Returns a map of dates to lists of worlds
  Future<Map<DateTime, List<WorldData>>> scrapeWorldCalendarData() async {
    Map<DateTime, List<WorldData>> worlds = {};
    try {
      if (kDebugMode) {
        print('Scraping world calendar data from Zwift Insider');
      }

      final response = await http.get(
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

  /// Scrapes climb calendar data from Zwift Insider
  ///
  /// Returns a map of dates to lists of climbs
  Future<Map<DateTime, List<ClimbData>>> scrapeClimbCalendarData() async {
    Map<DateTime, List<ClimbData>> climbs = {};
    try {
      if (kDebugMode) {
        print('Scraping climb calendar data from Zwift Insider');
      }
      
      final response = await http.get(
        Uri.parse('https://zwiftinsider.com/climb-portal-schedule/'),
        headers: {'User-Agent': 'ZwiftDataViewer App'},
      );
      
      if (response.statusCode == 200) {
        var doc = parser.parse(response.body);
        var vals = doc.getElementsByClassName('day-with-date');

        for (dynamic val in vals) {
          try {
            var dayNumberElements = val.getElementsByClassName('day-number');
            if (dayNumberElements.isEmpty) {
              continue; // Skip if no day number found
            }
            
            int dayNumber = int.parse(dayNumberElements[0].text);
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
                  String climbName = titleElement.text.trim();

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
          } catch (e) {
            if (kDebugMode) {
              print('Error processing climb calendar day: $e');
            }
            // Continue to the next day instead of failing the entire process
            continue;
          }
        }

        if (kDebugMode) {
          print(
              'Successfully scraped climb calendar with ${climbs.length} days');
        }
      } else {
        throw Exception(
            'Failed to load climb calendar: HTTP ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error scraping climb calendar data: $e');
      }
      throw Exception('Failed to scrape climb calendar: $e');
    }

    return climbs;
  }
}
