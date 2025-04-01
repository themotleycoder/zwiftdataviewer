import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/models/climbdata.dart';
import 'package:zwiftdataviewer/utils/climbsconfig.dart';

// Notifier for the selected climb.
//
// This notifier keeps track of which climb is currently selected,
// and provides methods to update the selection.
class ClimbSelectNotifier extends StateNotifier<ClimbData> {
  // Creates a ClimbSelectNotifier with Bealach na Bà as the initial selected climb.
  ClimbSelectNotifier()
      : super(ClimbData(1, ClimbId.bealachnaba, 'Bealach na Bà',
            'https://zwiftinsider.com/portal/bealach-na-ba/'));

  // Sets the selected climb.
  //
  // @param climbSelect The climb to select
  set climbSelect(ClimbData climbSelect) {
    state = climbSelect;
  }

  // Gets the currently selected climb.
  ClimbData get climbSelect => state;
}

// Provider for the selected climb.
//
// This provider gives access to the currently selected climb,
// which is used to display climb details and related information.
final selectedClimbProvider =
    StateNotifierProvider<ClimbSelectNotifier, ClimbData>(
        (ref) => ClimbSelectNotifier());
