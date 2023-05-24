import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/utils/repository/filerepository.dart';

final routeProvider =
    StateNotifierProvider<RouteNotifier, Map<int, List<RouteData>>>(
        (ref) => RouteNotifier());

class RouteNotifier extends StateNotifier<Map<int, List<RouteData>>> {
  RouteNotifier() : super(<int, List<RouteData>>{});

  FileRepository repository = FileRepository();

  Map<int, List<RouteData>> get routeData => state;

  set routeData(Map<int, List<RouteData>> routeData) {
    state = routeData;
    save();
  }

// Future<Future<void>> loadRouteData() async {
  // _isLoading = true;
  // notifyListeners();

  load() async {
    state = await repository.loadRouteData() as Map<int, List<RouteData>>;
  }

  save() async {
    await repository.saveRouteData(state);
  }

//   loadRouteData().then((loadedRouteData) {
//     _routeData = loadedRouteData.cast<int, List<RouteData>>();
//     // _isLoading = false;
//     // notifyListeners();
//   }).catchError((err) {
//     // _isLoading = false;
//     // notifyListeners();
//   });
// }

// Future saveRouteData(Map<int, List<RouteData>> routeData) async {
//   // _isLoading = true;
//   // notifyListeners();
//
//   return repository.saveRouteData(routeData).then((temp) {
//     // _isLoading = false;
//     // notifyListeners();
//   }).catchError((err) {
//     // _isLoading = false;
//     // notifyListeners();
//   });
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
