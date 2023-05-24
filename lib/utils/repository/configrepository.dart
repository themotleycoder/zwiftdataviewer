import '../../providers/config_provider.dart';

abstract class ConfigRepository {
  Future<ConfigData> loadConfig();

  Future saveConfig(ConfigData config);
}
