import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:flutter_strava_api/API/streams.dart';
import 'package:flutter_strava_api/Models/activity.dart';
import 'package:flutter_strava_api/Models/token.dart';
import 'package:flutter_strava_api/strava.dart';
import 'package:zwiftdataviewer/utils/repository/activitesrepository.dart';
import 'package:zwiftdataviewer/utils/repository/streamsrepository.dart';

import 'package:flutter_strava_api/Models/summary_activity.dart';

import '../../secrets.dart';

class WebRepository implements ActivitiesRepository, StreamsRepository {
  final Strava strava;

  WebRepository({required this.strava});

  @override
  Future<List<SummaryActivity?>?> loadActivities(
      int beforeDate, int afterDate) async {
    await getClient();
    // beforeDate = (beforeDate / 1000).round();
    // afterDate = (afterDate / 1000).round();
    var list =
        await strava.getLoggedInAthleteActivities(beforeDate, afterDate, null)
        //   .then((activities) {
        // if (activities != null && activities.length > 0) {
        //   saveActivities(activities);
        //   return activities;
        // }
        ;
    return list;
  }

  @override
  Future<DetailedActivity> loadActivityDetail(int activityId) async {
    return await strava.getActivityById(activityId.toString());
  }

  @override
  Future<List<PhotoActivity>> loadActivityPhotos(int activityId) async {
    final List<PhotoActivity> photos =
        await strava.getPhotosFromActivityById(activityId);
    return photos;
  }

  @override
  Future<StreamsDetailCollection> loadStreams(int activityId) async {
    return await strava.getStreamsByActivity(activityId.toString());
  }

  @override
  Future saveActivities(List<SummaryActivity> activities) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final File localActivityFile = File('$path/activities.json');
    String content = '[';
    for (int x = 0; x < activities.length; x++) {
      Map<String, dynamic> item = activities[x].toJson();
      if (x > 0) {
        content += ',';
      }
      content += jsonEncode(item);
    }
    content += ']';
    localActivityFile.writeAsStringSync(content);
  }

  Future<Token?> getClient() async {
    bool isAuthOk = false;

    // strava = Strava(globals.isInDebug, secret);
    const prompt = 'auto';

    isAuthOk = await strava.oauth(
        clientId,
        'activity:write,activity:read_all,profile:read_all,profile:write',
        secret,
        prompt);

    if (isAuthOk) {
      Token storedToken = await strava.getStoredToken();
      return storedToken;
    }

    return null;
  }
}
