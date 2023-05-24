import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/repository/filerepository.dart';

final configProvider = StateNotifierProvider<ConfigNotifier, ConfigData>((ref) {
  final config = ConfigData();
  return ConfigNotifier(config)..load();
});

class ConfigNotifier extends StateNotifier<ConfigData> {
  final FileRepository repository = FileRepository();

  ConfigNotifier(ConfigData state) : super(state);

  void setConfig(ConfigData configData) {
    state = configData;
    save();
  }

  load() async {
    try {
      final loadedConfig = await repository.loadConfig();
      state = loadedConfig;
    } catch (error) {
      // handle error here
    }
  }

  save() async {
    try {
      await repository.saveConfig(state);
    } catch (error) {
      // handle error here
    }
  }
}

class ConfigData {
  int? lastSyncDate;
  bool? isMetric = false;
  double? ftp;
  bool? dataLoaded = false;

  ConfigData();

  ConfigData.fromJson(Map<String, dynamic> json) {
    lastSyncDate = json['lastSyncDate'];
    isMetric = json['isMetric'] ?? false;
    ftp = json['ftp'] ?? 100;
    dataLoaded = json['dataLoaded'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lastSyncDate'] = lastSyncDate;
    data['isMetric'] = isMetric;
    data['ftp'] = ftp;
    data['dataLoaded'] = dataLoaded;
    return data;
  }
}
