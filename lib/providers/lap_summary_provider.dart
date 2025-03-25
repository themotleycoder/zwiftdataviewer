import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/models/activity.dart';

import '../utils/theme.dart';
import 'activity_detail_provider.dart';
import 'config_provider.dart';

/// Provider for lap summary objects
///
/// This provider creates a list of lap summary objects from a detailed activity.
/// It uses the user's FTP setting to determine the color coding for power zones.
final lapsProvider = FutureProvider.autoDispose
    .family<List<LapSummaryObject>, DetailedActivity>((ref, activity) async {
  try {
    final ftp = ref.watch(configProvider).ftp ?? 0.0;
    List<LapSummaryObject> retValue = [];
    
    // Create a lap summary object for each lap in the activity
    for (var lap in activity.laps ?? []) {
      retValue.add(LapSummaryObject(
        0,
        lap.lapIndex,
        lap.distance,
        lap.movingTime,
        lap.totalElevationGain,
        lap.averageCadence,
        lap.averageWatts,
        lap.averageSpeed,
        getColorForWatts(lap.averageWatts, ftp),
      ));
    }
    
    return retValue;
  } catch (e) {
    print('Error creating lap summaries: $e');
    return []; // Return empty list on error
  }
});

/// Determines the color for a power value based on FTP zones
///
/// This function returns a color that represents the power zone
/// for the given watts value relative to the user's FTP.
/// 
/// @param watts The power value in watts
/// @param ftp The user's Functional Threshold Power
/// @return A color representing the power zone
Color getColorForWatts(double watts, double ftp) {
  if (ftp <= 0) return Colors.grey; // Avoid division by zero
  
  if (watts < ftp * .60) {
    return Colors.grey; // Zone 1: Recovery
  } else if (watts >= ftp * .60 && watts <= ftp * .75) {
    return zdvMidBlue; // Zone 2: Endurance
  } else if (watts > ftp * .75 && watts <= ftp * .89) {
    return zdvMidGreen; // Zone 3: Tempo
  } else if (watts > ftp * .89 && watts <= ftp * 1.04) {
    return zdvYellow; // Zone 4: Threshold
  } else if (watts > ftp * 1.04 && watts <= ftp * 1.18) {
    return zdvOrange; // Zone 5: VO2 Max
  } else if (watts > ftp * 1.18) {
    return zdvRed; // Zone 6: Anaerobic
  } else {
    return Colors.grey; // Default
  }
}
