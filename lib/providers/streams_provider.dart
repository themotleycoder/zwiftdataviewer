import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/api/streams.dart';
import 'package:flutter_strava_api/globals.dart' as globals;
import 'package:flutter_strava_api/globals.dart';
import 'package:flutter_strava_api/strava.dart';
import 'package:path_provider/path_provider.dart';

import '../secrets.dart';
import '../utils/repository/filerepository.dart';
import '../utils/repository/webrepository.dart';

class StreamsNotifier extends StateNotifier<StreamsDetailCollection> {
  StreamsNotifier() : super(StreamsDetailCollection());

  // final Strava strava = Strava(isInDebug, secret);
  // final FileRepository? fileRepository = FileRepository();
  
  // final WebRepository? webRepository =
  //     WebRepository(
  //       strava: Strava(isInDebug, client_secret),
  //       cache: Strava.cache
  //     );

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

final streamsProvider = FutureProvider.autoDispose
    .family<StreamsDetailCollection, int>((ref, id) async {
  final FileRepository fileRepository = FileRepository();

  final cacheDir = await getApplicationDocumentsDirectory();
  final cache = Cache(cacheDir.path);
  // final strava = Strava(isInDebug, client_secret);
  final WebRepository webRepository =
      WebRepository(
        strava: Strava(isInDebug, client_secret),
        cache: cache
      );

  StreamsDetailCollection retvalue = StreamsDetailCollection();
  try {
    if (globals.isInDebug) {
      // Remove the force unwrap (!) operator which was causing the error
      retvalue = await fileRepository.loadStreams(id);
    } else {
      retvalue = await webRepository.loadStreams(id);
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error in streamsProvider: $e');
    }
    // Return an empty StreamsDetailCollection in case of error
    retvalue = StreamsDetailCollection();
  }
  return retvalue;
});

// final streamsProvider =
//     StateNotifierProvider<StreamsNotifier, StreamsDetailCollection>((ref) {
//   return StreamsNotifier();
// });
