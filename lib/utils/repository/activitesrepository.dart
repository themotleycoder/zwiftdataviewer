import 'package:flutter_strava_api/Models/activity.dart';
import 'package:flutter_strava_api/Models/summary_activity.dart';

abstract class ActivitiesRepository {
  Future<List<SummaryActivity?>?> loadActivities(int beforeDate, int afterDate);

  Future<DetailedActivity?> loadActivityDetail(int activityId);

  Future<List<PhotoActivity?>> loadActivityPhotos(int activityId);

  Future saveActivities(List<SummaryActivity> activities);
}
