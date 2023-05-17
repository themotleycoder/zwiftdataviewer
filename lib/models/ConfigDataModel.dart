import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zwiftdataviewer/utils/repository/configrepository.dart';

import '../providers/config_provider.dart';

class ConfigDataModel extends ChangeNotifier {
  final ConfigRepository repository;
  ConfigData? _configData;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  ConfigData? get configData => _configData;

  set configData(ConfigData? configData) {
    _configData = configData!;
    saveConfig(_configData!);
  }

  Future<void> loadConfig() async {
    _isLoading = true;
    notifyListeners();

    try {
      final loadedConfig = await repository.loadConfig();
      _configData = loadedConfig;
    } catch (error) {
      // handle error here
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Future<Null>> saveConfig(ConfigData config) async {
    _isLoading = true;
    notifyListeners();

    return repository.saveConfig(config).then((temp) {
      // _configData = loadedConfig;
      _isLoading = false;
      notifyListeners();
    }).catchError((err) {
      _isLoading = false;
      notifyListeners();
    });
  }

  ConfigDataModel({required this.repository});
}

// class ConfigData {
//   int? lastSyncDate;
//   bool? isMetric = false;
//   int? ftp;
//   bool? dataLoaded = false;
//
//   ConfigData();
//
//   ConfigData.fromJson(Map<String, dynamic> json) {
//     lastSyncDate = json['lastSyncDate'];
//     isMetric = json['isMetric'] ?? false;
//     ftp = json['ftp'] ?? 100;
//     dataLoaded = json['dataLoaded'] ?? false;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['lastSyncDate'] = lastSyncDate;
//     data['isMetric'] = isMetric;
//     data['ftp'] = ftp;
//     data['dataLoaded'] = dataLoaded;
//     return data;
//   }
// }

Future<void> storeAfterParameter(int lastRequestTime) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('after_param', lastRequestTime);
}

// Retrieve the stored after parameter
Future<int?> getAfterParameter() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('after_param') ??
      1420070400; //default is Thursday, January 1, 2015 12:00:00 AM
}
