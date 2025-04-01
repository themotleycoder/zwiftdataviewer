import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/api/streams.dart';

// Notifier for the selected combined stream.
//
// This notifier keeps track of which combined stream is currently selected,
// and provides methods to update the selection.
class CombinedStreamSelectNotifier extends StateNotifier<CombinedStreams> {
  // Creates a CombinedStreamSelectNotifier with default values.
  CombinedStreamSelectNotifier() : super(CombinedStreams(0, 0, 0, 0, 0, 0, 0));

  // Selects a new combined stream.
  //
  // @param streams The combined stream to select
  void selectStream(CombinedStreams streams) {
    state = streams;
  }

  // Gets the currently selected combined stream.
  CombinedStreams get streams => state;
}

// Provider for the selected combined stream.
//
// This provider gives access to the currently selected combined stream,
// which is used to display stream details and related information.
final combinedStreamSelectNotifier =
    StateNotifierProvider<CombinedStreamSelectNotifier, CombinedStreams>(
        (ref) => CombinedStreamSelectNotifier());
