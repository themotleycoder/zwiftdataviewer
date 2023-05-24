import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/providers/activity_detail_provider.dart';

class LapSummaryObjectNotifier extends StateNotifier<LapSummaryObject> {
  LapSummaryObjectNotifier()
      : super(LapSummaryObject(0, 0, 0, 0, 0, 0, 0, 0, Colors.grey));

  void selectSummary(LapSummaryObject streams) {
    state = streams;
  }

  LapSummaryObject get summaryObject => state;
}

final lapSummaryObjectProvider =
    StateNotifierProvider<LapSummaryObjectNotifier, LapSummaryObject>(
        (ref) => LapSummaryObjectNotifier());

class LapSummaryObjectPieNotifier extends StateNotifier<LapSummaryObject> {
  LapSummaryObjectPieNotifier()
      : super(LapSummaryObject(0, 0, 0, 0, 0, 0, 0, 0, Colors.grey));

  void selectSummary(LapSummaryObject streams) {
    state = streams;
  }

  LapSummaryObject get summaryObject => state;
}

final lapSummaryObjectPieProvider =
    StateNotifierProvider<LapSummaryObjectPieNotifier, LapSummaryObject>(
        (ref) => LapSummaryObjectPieNotifier());
