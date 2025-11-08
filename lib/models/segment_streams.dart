import 'package:flutter_strava_api/api/streams.dart' as strava_streams;

/// Simple class to hold segment elevation profile data
class SegmentStreams {
  strava_streams.Stream? distance;
  strava_streams.Stream? altitude;

  SegmentStreams({this.distance, this.altitude});

  SegmentStreams.fromJson(Map<String, dynamic> json) {
    distance = json["distance"] != null ? strava_streams.Stream.fromJson(json["distance"]) : null;
    altitude = json["altitude"] != null ? strava_streams.Stream.fromJson(json["altitude"]) : null;
  }

  /// Calculate gradient data from elevation and distance
  List<double> calculateGradients() {
    if (altitude?.data == null || distance?.data == null) {
      return [];
    }

    final altData = altitude!.data!;
    final distData = distance!.data!;
    final gradients = <double>[];

    for (int i = 0; i < altData.length; i++) {
      if (i == 0) {
        gradients.add(0.0);
      } else {
        final elevDiff = (altData[i] as num).toDouble() - (altData[i-1] as num).toDouble();
        final distDiff = (distData[i] as num).toDouble() - (distData[i-1] as num).toDouble();

        if (distDiff > 0) {
          final gradient = (elevDiff / distDiff) * 100;
          gradients.add(gradient);
        } else {
          gradients.add(gradients.isNotEmpty ? gradients.last : 0.0);
        }
      }
    }

    return gradients;
  }
}
