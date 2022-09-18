import 'package:flutter/widgets.dart';
import 'package:zwiftdataviewer/stravalib/API/streams.dart';
import 'package:zwiftdataviewer/stravalib/strava.dart';
import 'package:zwiftdataviewer/stravalib/globals.dart' as globals;
import 'package:zwiftdataviewer/utils/repository/filerepository.dart';
import 'package:zwiftdataviewer/utils/repository/webrepository.dart';

enum VisibilityFilter { all, active, completed }

class StreamsDataModel extends ChangeNotifier {
  final WebRepository webRepository;
  final FileRepository fileRepository;
  StreamsDetailCollection? _streamsDetailCollection;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  StreamsDetailCollection? get combinedStreams => _streamsDetailCollection;

  CombinedStreams? selectedSeriesData;

  CombinedStreams? get selectedSeries => this.selectedSeriesData;

  setSelectedSeries(CombinedStreams selectedSeries) {
    this.selectedSeriesData = selectedSeries;
    notifyListeners();
  }

  StreamsDataModel({
    required this.webRepository,
    required this.fileRepository,
    // VisibilityFilter filter,
    StreamsDetailCollection? streamsDetailCollection,
    Strava? strava,
  });

  Future loadStreams(int activityId) async {
    _isLoading = true;
    notifyListeners();
    if (globals.isInDebug) {
      fileRepository.loadStreams(activityId).then((streams) {
        _streamsDetailCollection = streams;
        _isLoading = false;
        notifyListeners();
      });

      // _streamsDetailCollection = StreamsDetailCollection.fromJson(
      //     await fileUtils.fetchLocalJsonData("streams_test.json"));
      // _isLoading = false;
      // notifyListeners();
    } else {
      print('WOULD CALL WEB SVC NOW! - loadStreams');
      webRepository.loadStreams(activityId).then((streams) {
        _streamsDetailCollection = streams;
        _isLoading = false;
        notifyListeners();
      });
    }
  }
}
