import 'package:flutter_strava_api/API/streams.dart';

abstract class StreamsRepository {
  Future<StreamsDetailCollection?> loadStreams(int activityId);
}
