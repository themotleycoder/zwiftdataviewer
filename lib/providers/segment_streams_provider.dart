import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/globals.dart' as globals;
import 'package:http/http.dart' as http;
import '../models/segment_streams.dart';

/// Provider for fetching segment elevation streams
/// This provides the exact elevation profile for each segment from Strava
final segmentStreamsProvider = FutureProvider.autoDispose.family<SegmentStreams, int>((ref, segmentId) async {
  if (segmentId <= 0) {
    return SegmentStreams();
  }

  try {
    final header = globals.createHeader();

    if (header.containsKey('88')) {
      // Token not known
      return SegmentStreams();
    }

    final String reqStreams =
        'https://www.strava.com/api/v3/segments/$segmentId/streams?keys=distance,altitude&key_by_type=true';
    final rep = await http.get(Uri.parse(reqStreams), headers: header);

    if (rep.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(rep.body);
      return SegmentStreams.fromJson(jsonResponse);
    }

    return SegmentStreams();
  } catch (e) {
    print('Error fetching segment streams for $segmentId: $e');
    return SegmentStreams();
  }
});
