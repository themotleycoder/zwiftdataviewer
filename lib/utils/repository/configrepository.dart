import 'package:zwiftdataviewer/models/ConfigDataModel.dart';

abstract class ConfigRepository {
  Future<ConfigData> loadConfig();

  Future saveConfig(ConfigData config);
}
