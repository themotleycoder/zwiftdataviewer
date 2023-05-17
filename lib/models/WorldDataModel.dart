import 'package:flutter/widgets.dart';
import 'package:zwiftdataviewer/utils/repository/worldcalendarrepository.dart';
import 'package:zwiftdataviewer/utils/worlddata.dart';

class WorldDataModel extends ChangeNotifier {
  final WorldCalendarRepository repository;

  Map<int, List<WorldData>>? _worldData;

  Map<int, List<WorldData>>? get worldData => _worldData;

  Map<DateTime, List<WorldData>>? _worldCalendarData;

  Map<DateTime, List<WorldData>>? get worldCalendarData => _worldCalendarData;

  // int _worldFilter;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // routeType _routeFilter;

  // set filterWorldId(int worldId) {
  //   _worldFilter = worldId;
  // }

  // set filter(routeType filter) {
  //   _routeFilter = filter;
  //   notifyListeners();
  // }

  set routeData(Map<int, List<WorldData>> worldData) {
    _worldData = worldData;
    // saveRouteData(_worldData);
  }

  Future<Future<void>> loadWorldCalendarData() async {
    _isLoading = true;
    notifyListeners();

    return repository.loadWorldCalendarData().then((loadedWorldCalendarData) {
      _worldCalendarData = loadedWorldCalendarData;
      _isLoading = false;
      notifyListeners();
    }).catchError((err) {
      _isLoading = false;
      notifyListeners();
    });
  }

  Future saveRouteData(Map<DateTime, List<WorldData>> worldCalendarData) async {
    _isLoading = true;
    notifyListeners();

    return repository.saveWorldCalendarData(worldCalendarData).then((temp) {
      _isLoading = false;
      notifyListeners();
    }).catchError((err) {
      _isLoading = false;
      notifyListeners();
    });
  }

  WorldDataModel({required this.repository});
}

class WorldData {
  int? id;
  GuestWorldId? guestWorldId;
  String? name;
  String? url;

  WorldData(this.id, this.guestWorldId, this.name, this.url);

  WorldData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    // guestWorldId = json['guestWorldId'];
    name = json['name'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['guestWorldId'] = guestWorldId.toString();
    data['name'] = name;
    data['url'] = url;
    return data;
  }
}
