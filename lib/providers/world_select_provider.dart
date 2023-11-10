import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/models/worlddata.dart';

import '../utils/worlddata.dart';

class WorldSelectNotifier extends StateNotifier<WorldData> {
  WorldSelectNotifier()
      : super(WorldData(1, GuestWorldId.watopia, 'Watopia',
            'https://zwiftinsider.com/watopia/'));

  set worldSelect(WorldData worldSelect) {
    state = worldSelect;
  }

  WorldData get worldSelect => state;
}

final selectedWorldProvider =
    StateNotifierProvider<WorldSelectNotifier, WorldData>(
        (ref) => WorldSelectNotifier());


