import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final configDateProvider = StateNotifierProvider<ConfigDateNotifier, int>(
    (ref) => ConfigDateNotifier());

class ConfigDateNotifier extends StateNotifier<int> {
  ConfigDateNotifier() : super(1420070400);

  int get date => state;

  void setDate(int afterDate) {
    state = afterDate;
    save();
  }

  load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('after_param') ??
        1420070400; //default is Thursday, January 1, 2015 12:00:00 AM
  }

  save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('after_param', state);
  }
}
