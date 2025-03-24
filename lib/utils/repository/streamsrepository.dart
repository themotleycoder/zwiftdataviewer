import 'package:flutter_strava_api/api/streams.dart';

abstract class StreamsRepository {
  Future<StreamsDetailCollection> loadStreams(int activityId);
}
