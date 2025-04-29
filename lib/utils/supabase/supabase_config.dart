import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zwiftdataviewer/secrets.dart';

/// Configuration for Supabase
///
/// This class provides access to the Supabase client and configuration.
class SupabaseConfig {
  static final SupabaseConfig _instance = SupabaseConfig._internal();
  static bool _initialized = false;

  // Singleton pattern
  factory SupabaseConfig() => _instance;

  SupabaseConfig._internal();

  /// Initializes Supabase with the provided URL and anonymous key.
  ///
  /// This must be called before using any Supabase functionality.
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Get Supabase URL and key from Secrets
      final supabaseUrl = Secrets.supabaseUrl;
      final supabaseAnonKey = Secrets.supabaseAnonKey;

      if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
        throw Exception('Supabase URL or anonymous key is empty');
      }

      // Initialize Supabase
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: kDebugMode,
      );

      _initialized = true;
      if (kDebugMode) {
        print('Supabase initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing Supabase: $e');
      }
      rethrow;
    }
  }

  /// Gets the Supabase client instance.
  static SupabaseClient get client {
    if (!_initialized) {
      throw StateError('Supabase not initialized');
    }
    return Supabase.instance.client;
  }

  /// Checks if Supabase has been initialized.
  static bool get isInitialized => _initialized;
}
