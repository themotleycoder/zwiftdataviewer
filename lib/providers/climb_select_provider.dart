import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/models/climbdata.dart';
import 'package:zwiftdataviewer/utils/climbsconfig.dart';

class ClimbSelectNotifier extends StateNotifier<ClimbData> {
  ClimbSelectNotifier()
      : super(ClimbData(1, ClimbId.bealachnaba, 'Bealach na Bà',
            'https://zwiftinsider.com/portal/bealach-na-ba/'));

  set worldSelect(ClimbData climbSelect) {
    state = climbSelect;
  }

  ClimbData get climbSelect => state;
}

final selectedClimbProvider =
    StateNotifierProvider<ClimbSelectNotifier, ClimbData>(
        (ref) => ClimbSelectNotifier());
