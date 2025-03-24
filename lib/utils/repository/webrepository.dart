import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_strava_api/api/streams.dart';
import 'package:flutter_strava_api/models/activity.dart';
import 'package:flutter_strava_api/models/summary_activity.dart';
import 'package:flutter_strava_api/strava.dart';
import 'package:zwiftdataviewer/utils/repository/activitesrepository.dart';
import 'package:zwiftdataviewer/utils/repository/streamsrepository.dart';
import '../../secrets.dart';

class WebRepository implements ActivitiesRepository, StreamsRepository {
  final Strava strava;
  final Cache cache;

  WebRepository({required this.strava, required this.cache});

  @override
  Future<List<SummaryActivity>> loadActivities(int beforeDate, int afterDate) async {
    try {
      await _ensureAuthenticated();
      final cachedActivities = await cache.getActivities(beforeDate, afterDate);
      if (cachedActivities != null) {
        return cachedActivities;
      }
      final activities = await strava.getLoggedInAthleteActivities(beforeDate, afterDate, null);
      await cache.saveActivities(activities);
      return activities;
    } catch (e) {
      if (kDebugMode) {
        if (kDebugMode) {
          print('Error loading activities: $e');
        }
      }
      rethrow;
    }
  }

  @override
  Future<DetailedActivity> loadActivityDetail(int activityId) async {
    try {
      await _ensureAuthenticated();
      final cachedActivity = await cache.getActivityDetail(activityId);
      if (cachedActivity != null) {
        return cachedActivity;
      }
      final activity = await strava.getActivityById(activityId.toString());
      await cache.saveActivityDetail(activity);
      return activity;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading activity detail: $e');
      }
      rethrow;
    }
  }

  @override
  Future<List<PhotoActivity>> loadActivityPhotos(int activityId) async {
    try {
      await _ensureAuthenticated();
      final cachedPhotos = await cache.getActivityPhotos(activityId);
      if (cachedPhotos != null) {
        return cachedPhotos;
      }
      final photos = await strava.getPhotosFromActivityById(activityId);
      await cache.saveActivityPhotos(activityId, photos);
      return photos;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading activity photos: $e');
      }
      rethrow;
    }
  }

  @override
  Future<StreamsDetailCollection> loadStreams(int activityId) async {
    try {
      await _ensureAuthenticated();
      final cachedStreams = await cache.getStreams(activityId);
      if (cachedStreams != null) {
        return cachedStreams;
      }
      final streams = await strava.getStreamsByActivity(activityId.toString());
      if (streams != null) {
        await cache.saveStreams(activityId, streams);
        return streams;
      } else {
        if (kDebugMode) {
          print('Streams data is null for activity $activityId');
        }
        return StreamsDetailCollection();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading streams: $e');
      }
      // Return an empty StreamsDetailCollection instead of rethrowing
      return StreamsDetailCollection();
    }
  }

  @override
  Future<void> saveActivities(List<SummaryActivity> activities) async {
    await cache.saveActivities(activities);
  }

  Future<void> _ensureAuthenticated() async {
    if (!strava.isAuthenticated()) {
      final isAuthOk = await strava.oauth(
        client_id,
        'activity:write,activity:read_all,profile:read_all,profile:write',
        client_secret,
        'auto',
      );
      if (!isAuthOk) {
        throw Exception('Authentication failed');
      }
    }
  }
}

class Cache {
  final String _cacheDir;

  Cache(this._cacheDir);

  Future<List<SummaryActivity>?> getActivities(int beforeDate, int afterDate) async {
    final file = File('$_cacheDir/activities_${beforeDate}_$afterDate.json');
    if (await file.exists()) {
      final content = await file.readAsString();
      final List<dynamic> json = jsonDecode(content);
      return json.map((e) => SummaryActivity.fromJson(e)).toList();
    }
    return null;
  }

  Future<void> saveActivities(List<SummaryActivity> activities) async {
    final file = File('$_cacheDir/activities_${activities.first.startDate.millisecondsSinceEpoch}_${activities.last.startDate.millisecondsSinceEpoch}.json');
    await file.writeAsString(jsonEncode(activities.map((e) => e.toJson()).toList()));
  }

  Future<DetailedActivity?> getActivityDetail(int activityId) async {
    final file = File('$_cacheDir/activity_$activityId.json');
    if (await file.exists()) {
      final content = await file.readAsString();
      return DetailedActivity.fromJson(jsonDecode(content));
    }
    return null;
  }

  Future<void> saveActivityDetail(DetailedActivity activity) async {
    final file = File('$_cacheDir/activity_${activity.id}.json');
    await file.writeAsString(jsonEncode(activity.toJson()));
  }

  Future<List<PhotoActivity>?> getActivityPhotos(int activityId) async {
    final file = File('$_cacheDir/photos_$activityId.json');
    if (await file.exists()) {
      final content = await file.readAsString();
      final List<dynamic> json = jsonDecode(content);
      return json.map((e) => PhotoActivity.fromJson(e)).toList();
    }
    return null;
  }

  Future<void> saveActivityPhotos(int activityId, List<PhotoActivity> photos) async {
    final file = File('$_cacheDir/photos_$activityId.json');
    await file.writeAsString(jsonEncode(photos.map((e) => e.toJson()).toList()));
  }

  Future<StreamsDetailCollection?> getStreams(int activityId) async {
    final file = File('$_cacheDir/streams_$activityId.json');
    if (await file.exists()) {
      try {
        final content = await file.readAsString();
        final jsonData = jsonDecode(content);
        if (jsonData != null) {
          return StreamsDetailCollection.fromJson(jsonData);
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error parsing streams JSON: $e');
        }
      }
    }
    return null;
  }

  Future<void> saveStreams(int activityId, StreamsDetailCollection streams) async {
    try {
      final file = File('$_cacheDir/streams_$activityId.json');
      final jsonData = streams.toJson();
      if (jsonData != null) {
        await file.writeAsString(jsonEncode(jsonData));
      } else {
        if (kDebugMode) {
          print('Cannot save null streams data');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving streams: $e');
      }
    }
  }
}
