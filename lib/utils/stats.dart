import 'package:zwiftdataviewer/strava_lib/Models/summary_activity.dart';

class StatsType {
  static const String totalDistance = "TotalDistance";
  static const String avgDistance = "AvgDistance";
  static const String totalElevation = "TotalElevation";
  static const String avgElevation = "AvgElevation";
  static const String longestDistance = "LongestDistance";
  static const String highestElevation = "HighestElevation";
}

class SummaryData {
  static Map<String, double> createSummaryData(
      List<SummaryActivity> activities) {
    Map<String, double> data = <String, double>{};
    double distance = 0.0;
    double elevation = 0.0;
    double longestDistance = 0.0;
    double highestElevation = 0.0;
    for (var activity in activities) {
      distance += activity.distance;
      elevation += activity.totalElevationGain;
      if (activity.distance > longestDistance) {
        longestDistance = activity.distance;
      }
      if (activity.totalElevationGain > highestElevation) {
        highestElevation = activity.totalElevationGain;
      }
    }
    data[StatsType.totalDistance] = distance;
    data[StatsType.avgDistance] = distance / activities.length;
    data[StatsType.totalElevation] = elevation;
    data[StatsType.avgElevation] = elevation / activities.length;
    data[StatsType.longestDistance] = longestDistance;
    data[StatsType.highestElevation] = highestElevation;

    return data;
  }
}
