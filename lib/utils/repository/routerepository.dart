import 'package:zwiftdataviewer/models/RouteDataModel.dart';

abstract class RouteRepository {
  Future<Map<int?, List<RouteData>>> loadRouteData();
  Future saveRouteData(Map<int?, List<RouteData>> routeData);
  Future<Map<int?, List<RouteData>>> scrapeRouteData();
}
