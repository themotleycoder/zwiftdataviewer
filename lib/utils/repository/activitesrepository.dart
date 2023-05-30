import 'package:zwiftdataviewer/stravalib/Models/activity.dart';

import '../../stravalib/Models/summary_activity.dart';

abstract class ActivitiesRepository {
  Future<List<SummaryActivity?>?> loadActivities(int beforeDate, int afterDate);

  Future<DetailedActivity?> loadActivityDetail(int activityId);

  Future<List<PhotoActivity?>> loadActivityPhotos(int activityId);

  Future saveActivities(List<SummaryActivity> activities);
}
