import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/models/routedata.dart';
import 'package:zwiftdataviewer/utils/repository/filerepository.dart';

final routeDataProvider = FutureProvider<Map<int, List<RouteData>>>((ref) async {
  return loadRouteDataFromFile();
});

Future<Map<int, List<RouteData>>> loadRouteDataFromFile() async {
  FileRepository repository = FileRepository();
  return await repository.loadRouteData();

}

