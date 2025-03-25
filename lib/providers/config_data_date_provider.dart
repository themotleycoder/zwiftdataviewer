import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for configuration date
///
/// This provider manages the date used for filtering data in the application.
/// It uses SharedPreferences for persistence.
final configDateProvider = StateNotifierProvider<ConfigDateNotifier, int>(
    (ref) => ConfigDateNotifier());

/// Notifier for configuration date
///
/// This class manages the state of the configuration date,
/// which is used for filtering data in the application.
class ConfigDateNotifier extends StateNotifier<int> {
  /// Creates a ConfigDateNotifier with a default date of January 1, 2015.
  ConfigDateNotifier() : super(1420070400) {
    // Load the saved date when the notifier is created
    load().then((value) {
      state = value;
    });
  }

  /// Gets the current date value.
  int get date => state;

  /// Sets a new date value and saves it to SharedPreferences.
  ///
  /// @param afterDate The new date value as a Unix timestamp
  void setDate(int afterDate) {
    state = afterDate;
    save();
  }

  /// Loads the date value from SharedPreferences.
  ///
  /// @return The loaded date value, or January 1, 2015 if not found
  Future<int> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('after_param') ??
          1420070400; // Default is Thursday, January 1, 2015 12:00:00 AM
    } catch (e) {
      print('Error loading config date: $e');
      return 1420070400; // Return default on error
    }
  }

  /// Saves the current date value to SharedPreferences.
  Future<void> save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('after_param', state);
    } catch (e) {
      print('Error saving config date: $e');
    }
  }
}
