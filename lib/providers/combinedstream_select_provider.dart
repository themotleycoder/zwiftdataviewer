import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../strava_lib/API/streams.dart';

class CombinedStreamSelectNotifier extends StateNotifier<CombinedStreams> {
  CombinedStreamSelectNotifier() : super(CombinedStreams(0, 0, 0, 0, 0, 0, 0));

  void selectStream(CombinedStreams streams) {
    state = streams;
  }

  CombinedStreams get streams => state;
}

final combinedStreamSelectNotifier =
    StateNotifierProvider<CombinedStreamSelectNotifier, CombinedStreams>(
        (ref) => CombinedStreamSelectNotifier());
