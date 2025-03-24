import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_strava_api/api/streams.dart';
import 'package:flutter_strava_api/models/activity.dart';
import 'package:flutter_strava_api/models/summary_activity.dart';
import 'package:flutter_strava_api/globals.dart';
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
    final Map<int, List<RouteData>> routes = {};
    final response =
        await Client().get(Uri.parse('https://zwiftinsider.com/routes/'));
    if (response.statusCode == 200) {
      var doc = parser.parse(response.body);
      var vals = doc.getElementsByClassName("wpv-loop js-wpv-loop")[0].children;
      for (dynamic val in vals) {
        int index = 1;
        String routeName = "NA";
        String url = val.children[index].innerHtml ?? "";
        try {
          routeName = url.substring(url.indexOf('>') + 1, url.indexOf('</a>'));
        } catch (e) {
          if (isInDebug) {
            if (kDebugMode) {
              print('html parse error - scraping route data');
            }
          }
          index -= 1;
          url = val.children[index].innerHtml ?? "";
          routeName = url.substring(url.indexOf('>') + 1, url.indexOf('</a>'));
        }
        url = url.substring(url.indexOf('https'), url.indexOf('/">'));
        final String world = val.children[index + 1].innerHtml ?? "";
        final String distance = val.children[index + 2].innerHtml ?? "";
        final String altitude = val.children[index + 3].innerHtml ?? "";
        final String leadin = val.children[index + 4].innerHtml ?? "";
        final String eventOnly =
            val.children[index + 5].innerHtml ?? val.children[index + 7] ?? "";
        final int id = worldLookupByName[world] ?? 0;

        final double distanceMeters =
            double.parse(distance.substring(0, distance.indexOf('km'))) * 1000;
        //final double distanceMiles = double.parse((distanceKM * 0.621371).toStringAsFixed(0)).toDouble();

        final double altitudeMeters = double.parse(altitude == ""
            ? "0.0"
            : altitude.substring(0, altitude.indexOf('m')));
        // final double altitudeFeet = double.parse((altitudeMeters * 3.28084).toStringAsFixed(0)).toDouble();

        final RouteData route = RouteData(url, world, distanceMeters,
            altitudeMeters, eventOnly, routeName, id);

        if (route.eventOnly?.toLowerCase() != 'run only' &&
            route.eventOnly?.toLowerCase() != 'run only, event only') {
          if (!routes.containsKey(id)) {
            routes[id] = <RouteData>[];
          }
          routes[id]?.add(route);
        }
      }
      saveRouteData(routes);
    } else {
      throw Exception();
    }
    return routes;
  }

  /// World Calendar Portal Methods

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
      content += ":[";

      for (int x = 0; x < worldRoute.length; x++) {
        Map<String, dynamic> item = worldRoute[x].toJson();
        if (x > 0) {
          content += ',';
        }
        content += jsonEncode(item);
      }
      content += "]";

      hasContent = true;
    });

    content += '}';
    file.writeAsStringSync(content);
  }

  @override
  Future<Map<DateTime, List<WorldData>>> scrapeWorldCalendarData() async {
    Map<DateTime, List<WorldData>> worlds = {};
    final response =
        await Client().get(Uri.parse('https://zwiftinsider.com/schedule/'));
    if (response.statusCode == 200) {
      // final String htmlStr =
      //     await rootBundle.loadString('assets/testjson/worldcalendar.html');

      var doc = parser.parse(response.body);
      var vals = doc.getElementsByClassName("day-with-date");
      for (dynamic val in vals) {
        int dayNumber =
            int.parse(val.getElementsByClassName("day-number")[0].innerHtml);
        DateTime key =
            DateTime(DateTime.now().year, DateTime.now().month, dayNumber);
        List<dynamic> locations = val.getElementsByClassName("spiffy-title");
        List<WorldData> worldData = [];
        for (dynamic location in locations) {
          worldData
              .add(allWorldsConfig[worldLookupByName[location.innerHtml]]!);
        }

        worlds[key] = worldData;
      }
      saveWorldCalendarData(worlds);
    } else {
      throw Exception();
    }
    return worlds;
  }

  /// Climb Calendar Portal Methods

  @override
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

  @override
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
      content += ":[";

      for (int x = 0; x < worldRoute.length; x++) {
        Map<String, dynamic> item = worldRoute[x].toJson();
        if (x > 0) {
          content += ',';
        }
        content += jsonEncode(item);
      }
      content += "]";

      hasContent = true;
    });

    content += '}';
    file.writeAsStringSync(content);
  }

  @override
  Future<Map<DateTime, List<ClimbData>>> scrapeClimbCalendarData() async {
    Map<DateTime, List<ClimbData>> climbs = {};
    final response = await Client()
        .get(Uri.parse('https://zwiftinsider.com/climb-portal-schedule/'));
    if (response.statusCode == 200) {
      // final String htmlStr =
      //     await rootBundle.loadString('assets/testjson/worldcalendar.html');

      var doc = parser.parse(response.body);
      var vals = doc.getElementsByClassName("day-with-date");
      for (dynamic val in vals) {
        int dayNumber =
            int.parse(val.getElementsByClassName("day-number")[0].innerHtml);
        DateTime key =
            DateTime(DateTime.now().year, DateTime.now().month, dayNumber);
        List<dynamic> locations = val.getElementsByClassName("spiffy-title");
        List<ClimbData> climbData = [];
        for (dynamic location in locations) {
          String str = location.innerHtml;
          str = str.replaceAll('’', '\'');
          climbData.add(allClimbsConfig[climbLookupByName[str]]!);
        }

        climbs[key] = climbData;
      }
      saveClimbCalendarData(climbs);
    } else {
      throw Exception();
    }
    return climbs;
  }
}
