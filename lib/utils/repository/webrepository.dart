import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:zwiftdataviewer/stravalib/Models/activity.dart';
import 'package:zwiftdataviewer/stravalib/API/streams.dart';
import 'package:zwiftdataviewer/stravalib/Models/token.dart';
import 'package:zwiftdataviewer/stravalib/strava.dart';
import 'package:zwiftdataviewer/utils/repository/activitesrepository.dart';
import 'package:zwiftdataviewer/utils/repository/streamsrepository.dart';
import 'package:zwiftdataviewer/secrets.dart';

class WebRepository implements ActivitiesRepository, StreamsRepository {
  final Strava strava;

  WebRepository({required this.strava});

  @override
  Future<List<SummaryActivity?>?> loadActivities(
      int beforeDate, int afterDate) async {
    await getClient();
    beforeDate = (beforeDate / 1000).round();
    afterDate = (afterDate / 1000).round();
    return await strava.getLoggedInAthleteActivities(
            beforeDate, afterDate, null)
        //   .then((activities) {
        // if (activities != null && activities.length > 0) {
        //   saveActivities(activities);
        //   return activities;
        // }
        ;
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
    if (null != activities) {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final File _localActivityFile = File('$path/activities.json');
      String content = '[';
      for (int x = 0; x < activities.length; x++) {
        Map<String, dynamic> item = activities[x].toJson();
        if (x > 0) {
          content += ',';
        }
        content += jsonEncode(item);
      }
      content += ']';
      _localActivityFile.writeAsStringSync(content);
    }
  }

  Future<Token?> getClient() async {
    bool isAuthOk = false;

    // strava = Strava(globals.isInDebug, secret);
    final prompt = 'auto';

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
