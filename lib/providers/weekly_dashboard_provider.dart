import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/models/summary_activity.dart';
import 'package:zwiftdataviewer/providers/config_provider.dart';
import 'package:zwiftdataviewer/widgets/activitieslistview.dart';
import 'package:zwiftdataviewer/utils/theme.dart';

// Provider for weekly goal in kilometers
final weeklyGoalProvider = StateProvider<double>((ref) => 155.0);

// Provider for calculating weekly dashboard data
final weeklyDashboardProvider = FutureProvider<WeeklyDashboardData>((ref) async {
  final activities = await ref.watch(combinedActivitiesProvider.future);
  final config = ref.watch(configProvider);
  final weeklyGoal = ref.watch(weeklyGoalProvider);

  // Get FTP from config, default to 229 if not set
  final ftp = config.ftp ?? 231.0;

  // Get start and end of current week (Monday to Sunday)
  final now = DateTime.now();
  final currentWeekday = now.weekday; // 1 = Monday, 7 = Sunday
  final startOfWeek = now.subtract(Duration(days: currentWeekday - 1));
  final monday = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
  final sunday = monday.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

  // Filter activities for current week
  final weekActivities = activities.where((activity) {
    return activity.startDate.isAfter(monday) && activity.startDate.isBefore(sunday);
  }).toList();

  // Create daily data structure
  final dailyData = List.generate(7, (index) {
    final dayDate = monday.add(Duration(days: index));
    final dayActivities = weekActivities.where((activity) {
      final activityDate = activity.startDate;
      return activityDate.year == dayDate.year &&
             activityDate.month == dayDate.month &&
             activityDate.day == dayDate.day;
    }).toList();

    return DailyActivityData(
      date: dayDate,
      activities: dayActivities,
      ftp: ftp,
    );
  });

  // Calculate weekly totals
  double totalDistance = 0;
  for (var activity in weekActivities) {
    totalDistance += activity.distance / 1000; // Convert meters to km
  }

  return WeeklyDashboardData(
    dailyData: dailyData,
    weeklyGoal: weeklyGoal,
    totalDistance: totalDistance,
    recentActivities: activities.take(5).toList(),
  );
});

// Data class for weekly dashboard
class WeeklyDashboardData {
  final List<DailyActivityData> dailyData;
  final double weeklyGoal;
  final double totalDistance;
  final List<SummaryActivity> recentActivities;

  WeeklyDashboardData({
    required this.dailyData,
    required this.weeklyGoal,
    required this.totalDistance,
    required this.recentActivities,
  });

  double get progress => weeklyGoal > 0 ? (totalDistance / weeklyGoal).clamp(0.0, 1.0) : 0.0;
  bool get goalMet => totalDistance >= weeklyGoal;
}

// Data class for daily activity
class DailyActivityData {
  final DateTime date;
  final List<SummaryActivity> activities;
  final double ftp;
  final Map<int, double> powerZoneMinutes;
  final double totalMinutes;
  final double totalDistanceMeters;

  DailyActivityData({
    required this.date,
    required this.activities,
    required this.ftp,
  }) : powerZoneMinutes = {},
       totalMinutes = _calculateTotalMinutes(activities),
       totalDistanceMeters = _calculateTotalDistance(activities) {
    _calculatePowerZones();
  }

  static double _calculateTotalMinutes(List<SummaryActivity> activities) {
    double total = 0;
    for (var activity in activities) {
      total += (activity.movingTime?.toDouble() ?? 0) / 60;
    }
    return total;
  }

  static double _calculateTotalDistance(List<SummaryActivity> activities) {
    double total = 0;
    for (var activity in activities) {
      total += activity.distance;
    }
    return total;
  }

  void _calculatePowerZones() {
    // Initialize power zones (1-6) in the map
    powerZoneMinutes[1] = 0;
    powerZoneMinutes[2] = 0;
    powerZoneMinutes[3] = 0;
    powerZoneMinutes[4] = 0;
    powerZoneMinutes[5] = 0;
    powerZoneMinutes[6] = 0;

    debugPrint('📊 Calculating power zones for ${activities.length} activities on ${date.toString().substring(0, 10)} (FTP: $ftp)');

    for (var activity in activities) {
      final movingTime = activity.movingTime?.toDouble() ?? 0;

      // Get average watts for the activity
      final avgWatts = activity.averageWatts?.toDouble() ?? 0;

      if (avgWatts > 0) {
        // Determine which zone the activity falls into
        final zone = _getZoneForWatts(avgWatts);
        powerZoneMinutes[zone] = (powerZoneMinutes[zone] ?? 0) + (movingTime / 60);
        debugPrint('  Activity "${activity.name}": ${avgWatts}W → Zone $zone (${(movingTime / 60).toStringAsFixed(1)} min)');
      } else {
        // If no power data, distribute to Zone 1 (recovery)
        powerZoneMinutes[1] = (powerZoneMinutes[1] ?? 0) + (movingTime / 60);
        debugPrint('  Activity "${activity.name}": NO POWER DATA → Zone 1 (${(movingTime / 60).toStringAsFixed(1)} min)');
      }
    }

    // Show final zone distribution
    final zonesWithTime = powerZoneMinutes.entries.where((e) => e.value > 0).toList();
    if (zonesWithTime.isNotEmpty) {
      debugPrint('  Final zones: ${zonesWithTime.map((e) => 'Z${e.key}:${e.value.toStringAsFixed(0)}min').join(", ")}');
    }
  }

  int _getZoneForWatts(double watts) {
    // Match the logic from routeanalysistabpowertimepiechartscreen.dart
    // Zone boundaries use >= for lower bound and < for upper bound
    if (watts < ftp * 0.60) {
      return 1; // Zone 1: < 60%
    } else if (watts >= ftp * 0.60 && watts < ftp * 0.75) {
      return 2; // Zone 2: 60-75%
    } else if (watts >= ftp * 0.75 && watts < ftp * 0.90) {
      return 3; // Zone 3: 75-89%
    } else if (watts >= ftp * 0.90 && watts < ftp * 1.05) {
      return 4; // Zone 4: 89-104%
    } else if (watts >= ftp * 1.05 && watts < ftp * 1.19) {
      return 5; // Zone 5: 104-118%
    } else {
      return 6; // Zone 6: >= 118%
    }
  }

  bool get isRestDay => activities.isEmpty;

  Color getZoneColor(int zone) {
    switch (zone) {
      case 1: return Colors.grey;
      case 2: return zdvMidBlue;
      case 3: return zdvMidGreen;
      case 4: return zdvYellow;
      case 5: return zdvOrange;
      case 6: return zdvRed;
      default: return Colors.grey;
    }
  }
}
