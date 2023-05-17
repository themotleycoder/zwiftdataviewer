import 'package:flutter/widgets.dart';
import 'package:zwiftdataviewer/utils/repository/routerepository.dart';
import 'package:zwiftdataviewer/utils/worlddata.dart';

class RouteDataModel extends ChangeNotifier {
  final RouteRepository repository;
  late Map<int, List<RouteData>> _routeData;
  int _worldFilter = 0;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Map<int, List<RouteData>> get routeData => _routeData;

  routeType _routeFilter = routeType.basiconly;

  set filterWorldId(int worldId) {
    _worldFilter = worldId;
  }

  set filter(routeType filter) {
    _routeFilter = filter;
    // notifyListeners();
  }

  set routeData(Map<int, List<RouteData>> routeData) {
    _routeData = routeData;
    saveRouteData(_routeData);
  }

  Future<Future<void>> loadRouteData() async {
    _isLoading = true;
    notifyListeners();

    return repository.loadRouteData().then((loadedRouteData) {
      _routeData = loadedRouteData.cast<int, List<RouteData>>();
      _isLoading = false;
      notifyListeners();
    }).catchError((err) {
      _isLoading = false;
      notifyListeners();
    });
  }

  Future saveRouteData(Map<int, List<RouteData>> routeData) async {
    _isLoading = true;
    notifyListeners();

    return repository.saveRouteData(routeData).then((temp) {
      _isLoading = false;
      notifyListeners();
    }).catchError((err) {
      _isLoading = false;
      notifyListeners();
    });
  }

  Future updateRouteData() async {
    _isLoading = true;
    notifyListeners();

    return repository.saveRouteData(_routeData).then((temp) {
      _isLoading = false;
      notifyListeners();
    }).catchError((err) {
      _isLoading = false;
      notifyListeners();
    });
  }

  RouteDataModel({required this.repository});

  List<RouteData> get filteredRoutes {
    return _routeData[_worldFilter]!.where((route) {
      switch (_routeFilter) {
        // case routeType.eventonly:
        //   return route.eventOnly?.toLowerCase() == "event only";
        // case routeType.basiconly:
        //   return route.eventOnly?.toLowerCase() != "event only";
        default:
          return true;
      }
    }).toList();
  }
}

class RouteData {
  String? url;
  String? world;
  String? distance;
  String? altitude;
  String? eventOnly;
  String? routeName;
  bool? completed = false;
  int? id;
  int? imageId;

  RouteData(this.url, this.world, this.distance, this.altitude, this.eventOnly,
      this.routeName, this.id);

  RouteData.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    world = json['world'];
    distance = json['distance'];
    altitude = json['altitude'];
    eventOnly = json['eventOnly'];
    routeName = json['routeName'];
    completed = json['completed'];
    id = json['id'];
    imageId = json['imageId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['world'] = world;
    data['distance'] = distance;
    data['altitude'] = altitude;
    data['eventOnly'] = eventOnly;
    data['routeName'] = routeName;
    data['completed'] = completed;
    data['id'] = id;
    data['imageId'] = imageId;
    return data;
  }
}
