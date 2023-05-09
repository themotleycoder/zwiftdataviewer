import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActivitySelectNotifier extends StateNotifier<int> {
  ActivitySelectNotifier()
      : super(0);

  void setActivitySelect(int activitySelect) {
    state = activitySelect;
  }

  int get activitySelect => state;
}

final activitySelectProvider =
    StateNotifierProvider<ActivitySelectNotifier, int>(
        (ref) => ActivitySelectNotifier());