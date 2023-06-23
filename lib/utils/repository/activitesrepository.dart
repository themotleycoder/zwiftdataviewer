import 'package:zwiftdataviewer/strava_lib/Models/activity.dart';

import '../../strava_lib/Models/summary_activity.dart';

abstract class ActivitiesRepository {
  Future<List<SummaryActivity?>?> loadActivities(int beforeDate, int afterDate);

  Future<DetailedActivity?> loadActivityDetail(int activityId);

  Future<List<PhotoActivity?>> loadActivityPhotos(int activityId);

  Future saveActivities(List<SummaryActivity> activities);
}
