import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../secrets.dart';
import '../stravalib/API/streams.dart';
import '../stravalib/Models/activity.dart';
import '../stravalib/globals.dart';
import '../stravalib/strava.dart';
import '../utils/repository/filerepository.dart';
import '../utils/repository/webrepository.dart';
import 'package:zwiftdataviewer/stravalib/globals.dart' as globals;

class StreamsNotifier extends StateNotifier<StreamsDetailCollection> {
  StreamsNotifier() : super(StreamsDetailCollection());

  // final Strava strava = Strava(isInDebug, secret);
  final FileRepository? fileRepository = FileRepository();
  final WebRepository? webRepository = WebRepository(strava: Strava(isInDebug, secret));

  get streams => state;

  void addStream(StreamsDetailCollection stream) {
    state = stream;
  }

  void setStreams(StreamsDetailCollection streams) {
    state = streams;
  }

  // void addStreams(List<StreamsDetailCollection> streams) {
  //   state = [...state, ...streams];
  // }

  // void removeStream(StreamsDetailCollection stream) {
  //   state = state.where((element) => element.id != stream.id).toList();
  // }

  void updateStream(StreamsDetailCollection stream) {
    state = stream;
  }

  Future loadStreams(int activityId) async {
    // _isLoading = true;
    // notifyListeners();
    if (globals.isInDebug) {
      fileRepository?.loadStreams(activityId).then((streams) {
        setStreams(streams!);
        // _streamsDetailCollection = streams;
        // _isLoading = false;
        // notifyListeners();
      });

      // _streamsDetailCollection = StreamsDetailCollection.fromJson(
      //     await fileUtils.fetchLocalJsonData("streams_test.json"));
      // _isLoading = false;
      // notifyListeners();
    } else {
      print('WOULD CALL WEB SVC NOW! - loadStreams');
      webRepository?.loadStreams(activityId).then((streams) {
        setStreams(streams!);
        // _isLoading = false;
        // notifyListeners();
      });
    }
  }
}

final streamsProvider =
    StateNotifierProvider<StreamsNotifier, StreamsDetailCollection>((ref) {
  return StreamsNotifier();
});
