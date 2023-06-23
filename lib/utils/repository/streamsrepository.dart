import 'package:zwiftdataviewer/strava_lib/API/streams.dart';

abstract class StreamsRepository {
  Future<StreamsDetailCollection?> loadStreams(int activityId);
}
