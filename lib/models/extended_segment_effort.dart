import 'package:flutter_strava_api/models/segmentEffort.dart';

/// A wrapper class for SegmentEffort that includes the activity ID.
///
/// This class is used to store segment efforts with their associated activity ID,
/// which is not included in the original SegmentEffort class from the Strava API.
class ExtendedSegmentEffort {
  /// The ID of the activity this segment effort belongs to.
  final int activityId;
  
  /// The original segment effort from the Strava API.
  final SegmentEffort effort;

  /// Creates an ExtendedSegmentEffort.
  ///
  /// @param activityId The ID of the activity this segment effort belongs to
  /// @param effort The original SegmentEffort from the Strava API
  ExtendedSegmentEffort({
    required this.activityId,
    required this.effort,
  });

  /// Creates an ExtendedSegmentEffort from a SegmentEffort and an activity ID.
  ///
  /// @param activityId The ID of the activity this segment effort belongs to
  /// @param segmentEffort The original SegmentEffort from the Strava API
  static ExtendedSegmentEffort fromSegmentEffort(
    int activityId,
    SegmentEffort segmentEffort,
  ) {
    return ExtendedSegmentEffort(
      activityId: activityId,
      effort: segmentEffort,
    );
  }
  
  // Convenience getters to access SegmentEffort properties
  int? get id => effort.id;
  int? get resourceState => effort.resourceState;
  String? get name => effort.name;
  int? get elapsedTime => effort.elapsedTime;
  int? get movingTime => effort.movingTime;
  String? get startDate => effort.startDate;
  String? get startDateLocal => effort.startDateLocal;
  double? get distance => effort.distance;
  int? get startIndex => effort.startIndex;
  int? get endIndex => effort.endIndex;
  double? get averageCadence => effort.averageCadence;
  double? get averageWatts => effort.averageWatts;
  bool? get deviceWatts => effort.deviceWatts;
  double? get averageHeartrate => effort.averageHeartrate;
  double? get maxHeartrate => effort.maxHeartrate;
  dynamic get segment => effort.segment;
  int? get prRank => effort.prRank;
  bool? get hidden => effort.hidden;
}
