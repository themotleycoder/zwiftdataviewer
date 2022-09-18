import 'package:zwiftdataviewer/stravalib/API/streams.dart';

abstract class StreamsRepository {
  Future<StreamsDetailCollection?> loadStreams(int activityId);
}
