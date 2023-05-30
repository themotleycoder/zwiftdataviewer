import 'package:zwiftdataviewer/stravalib/Models/summary_activity.dart';

class StatsType {
  static const String TotalDistance = "TotalDistance";
  static const String AvgDistance = "AvgDistance";
  static const String TotalElevation = "TotalElevation";
  static const String AvgElevation = "AvgElevation";
  static const String LongestDistance = "LongestDistance";
  static const String HighestElevation = "HighestElevation";
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
      distance += activity.distance!;
      elevation += activity.totalElevationGain!;
      if (activity.distance! > longestDistance) {
        longestDistance = activity.distance!;
      }
      if (activity.totalElevationGain! > highestElevation) {
        highestElevation = activity.totalElevationGain!;
      }
    }
    data[StatsType.TotalDistance] = distance;
    data[StatsType.AvgDistance] = distance / activities.length;
    data[StatsType.TotalElevation] = elevation;
    data[StatsType.AvgElevation] = elevation / activities.length;
    data[StatsType.LongestDistance] = longestDistance;
    data[StatsType.HighestElevation] = highestElevation;

    return data;
  }
}
