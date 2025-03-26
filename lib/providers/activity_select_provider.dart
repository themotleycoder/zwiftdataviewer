import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/models/athlete.dart';
import 'package:flutter_strava_api/models/summary_activity.dart';

// Define an empty SummaryActivity to use as the initial state
final SummaryActivity emptyActivity = SummaryActivity(
  resourceState: 1,
  athlete: Athlete(
    id: 0,
    resourceState: 0,
  ),
  name: '',
  distance: 0,
  movingTime: 0,
  elapsedTime: 0,
  totalElevationGain: 0,
  type: 'Bike',
  id: 0,
  externalId: '0',
  uploadId: 0,
  startDate: DateTime.now(),
  startDateLocal: DateTime.now(),
  timezone: 'UTC',
  utcOffset: 0,
  locationCountry: '',
  startLatlng: LatLng(lat: 0, lng: 0),
  endLatlng: LatLng(lat: 0, lng: 0),
  achievementCount: 0,
  kudosCount: 0,
  commentCount: 0,
  athleteCount: 1,
  photoCount: 0,
  trainer: false,
  commute: false,
  manual: false,
  private: false,
  visibility: 'everyone',
  flagged: false,
  fromAcceptedTag: false,
  averageSpeed: 0,
  maxSpeed: 0,
  averageCadence: 0,
  averageWatts: 0,
  weightedAverageWatts: 0,
  kilojoules: 0,
  deviceWatts: false,
  hasHeartrate: false,
  averageHeartrate: 0,
  maxHeartrate: 0,
  heartrateOptOut: false,
  displayHideHeartrateOption: false,
  elevHigh: 0,
  elevLow: 0,
  prCount: 0,
  totalPhotoCount: 0,
  hasKudoed: false,
  sportType: 'cycling',
  maxWatts: 0,
  uploadIdStr: '',
);

class ActivitySelectNotifier extends StateNotifier<SummaryActivity> {
  ActivitySelectNotifier() : super(emptyActivity);

  void selectActivity(SummaryActivity activitySelect) {
    state = activitySelect;
  }

  SummaryActivity get activitySelect => state;
}

final selectedActivityProvider =
    StateNotifierProvider<ActivitySelectNotifier, SummaryActivity>(
        (ref) => ActivitySelectNotifier());
