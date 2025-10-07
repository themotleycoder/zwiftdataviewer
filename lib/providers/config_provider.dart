import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/repository/filerepository.dart';

final configProvider = StateNotifierProvider<ConfigNotifier, ConfigData>((ref) {
  final config = ConfigData();
  return ConfigNotifier(config)..load();
});

class ConfigNotifier extends StateNotifier<ConfigData> {
  final FileRepository repository = FileRepository();

  ConfigNotifier(super.state);

  void setConfig(ConfigData configData) {
    state = configData;
    save();
  }

  // Loads configuration data from storage
  //
  // This method attempts to load the configuration from the repository.
  // If an error occurs, it logs the error and keeps using the default config.
  Future<void> load() async {
    try {
      final loadedConfig = await repository.loadConfig();
      state = loadedConfig;
    } catch (error) {
      if (kDebugMode) {
        print('Error loading config: $error');
      }
      // Keep using the default config
    }
  }

  // Saves configuration data to storage
  //
  // This method attempts to save the current configuration to the repository.
  // If an error occurs, it logs the error.
  Future<void> save() async {
    try {
      await repository.saveConfig(state);
    } catch (error) {
      if (kDebugMode) {
        print('Error saving config: $error');
      }
      // Consider notifying the user that settings couldn't be saved
    }
  }
}

// Represents the configuration data for the application.
//
// This class stores user preferences and application settings.
class ConfigData {
  // The timestamp of the last data synchronization.
  int? lastSyncDate;

  // Whether to use metric units (true) or imperial units (false).
  bool? isMetric = false;

  // The user's Functional Threshold Power in watts.
  double? ftp;

  // Whether data has been loaded.
  bool? dataLoaded = false;

  // Creates a new ConfigData instance with default values.
  ConfigData();

  // Creates a ConfigData instance from a JSON map.
  //
  // @param json The JSON map containing configuration data
  ConfigData.fromJson(Map<String, dynamic> json) {
    lastSyncDate = json['lastSyncDate'];
    isMetric = json['isMetric'] ?? false;
    ftp = json['ftp'] ?? 100;
    dataLoaded = json['dataLoaded'] ?? false;
  }

  // Converts this ConfigData instance to a JSON map.
  //
  // @return A map containing the configuration data
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lastSyncDate'] = lastSyncDate;
    data['isMetric'] = isMetric;
    data['ftp'] = ftp;
    data['dataLoaded'] = dataLoaded;
    return data;
  }

  // Creates a copy of this ConfigData instance with the given fields replaced.
  //
  // @param lastSyncDate The new lastSyncDate value, or null to keep the current value
  // @param isMetric The new isMetric value, or null to keep the current value
  // @param ftp The new ftp value, or null to keep the current value
  // @param dataLoaded The new dataLoaded value, or null to keep the current value
  // @return A new ConfigData instance with the updated fields
  ConfigData copyWith({
    int? lastSyncDate,
    bool? isMetric,
    double? ftp,
    bool? dataLoaded,
  }) {
    final result = ConfigData();
    result.lastSyncDate = lastSyncDate ?? this.lastSyncDate;
    result.isMetric = isMetric ?? this.isMetric;
    result.ftp = ftp ?? this.ftp;
    result.dataLoaded = dataLoaded ?? this.dataLoaded;
    return result;
  }
}
