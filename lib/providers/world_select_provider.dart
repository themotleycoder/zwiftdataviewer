import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/models/worlddata.dart';
import 'package:zwiftdataviewer/utils/worldsconfig.dart';

/// Notifier for the selected world.
///
/// This notifier keeps track of which world is currently selected,
/// and provides methods to update the selection.
class WorldSelectNotifier extends StateNotifier<WorldData> {
  /// Creates a WorldSelectNotifier with Watopia as the initial selected world.
  WorldSelectNotifier()
      : super(WorldData(1, GuestWorldId.watopia, 'Watopia',
            'https://zwiftinsider.com/watopia/'));

  /// Sets the selected world.
  ///
  /// @param worldSelect The world to select
  set worldSelect(WorldData worldSelect) {
    state = worldSelect;
  }

  /// Gets the currently selected world.
  WorldData get worldSelect => state;
}

/// Provider for the selected world.
///
/// This provider gives access to the currently selected world,
/// which is used to display world details and related information.
final selectedWorldProvider =
    StateNotifierProvider<WorldSelectNotifier, WorldData>(
        (ref) => WorldSelectNotifier());
