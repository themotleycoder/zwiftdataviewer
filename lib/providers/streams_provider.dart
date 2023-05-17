import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/stravalib/globals.dart' as globals;

import '../secrets.dart';
import '../stravalib/API/streams.dart';
import '../stravalib/globals.dart';
import '../stravalib/strava.dart';
import '../utils/repository/filerepository.dart';
import '../utils/repository/webrepository.dart';

class StreamsNotifier extends StateNotifier<StreamsDetailCollection> {
  StreamsNotifier() : super(StreamsDetailCollection());

  // final Strava strava = Strava(isInDebug, secret);
  final FileRepository? fileRepository = FileRepository();
  final WebRepository? webRepository =
      WebRepository(strava: Strava(isInDebug, secret));

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
}

final streamsProvider = FutureProvider.autoDispose.family<StreamsDetailCollection, int>((ref, id) async {
  final FileRepository fileRepository = FileRepository();
  final WebRepository webRepository =
      WebRepository(strava: Strava(isInDebug, secret));

  StreamsDetailCollection retvalue = StreamsDetailCollection();
  if (globals.isInDebug) {
    retvalue = (await fileRepository.loadStreams(id))!;
  } else {
    print('WOULD CALL WEB SVC NOW! - loadStreams');
    retvalue = await webRepository.loadStreams(id);
  }
  return retvalue;
});

// final streamsProvider =
//     StateNotifierProvider<StreamsNotifier, StreamsDetailCollection>((ref) {
//   return StreamsNotifier();
// });
