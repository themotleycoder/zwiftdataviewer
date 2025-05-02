import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/utils/repository/hybrid_activities_repository.dart';

/// Provider for connectivity status
///
/// This provider exposes the online/offline status of the app.
/// It can be used to show a visual indicator to the user.
final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, ConnectivityState>((ref) {
  return ConnectivityNotifier();
});

/// Connectivity notifier
///
/// This notifier manages the connectivity state and provides methods
/// to update it.
class ConnectivityNotifier extends StateNotifier<ConnectivityState> {
  ConnectivityNotifier() : super(ConnectivityState.unknown) {
    _initialize();
  }

  /// Initialize the connectivity state
  Future<void> _initialize() async {
    try {
      final hybridRepo = HybridActivitiesRepository();
      final isOnline = hybridRepo.isOnline;
      
      if (kDebugMode) {
        print('Initial connectivity state: ${isOnline ? 'Online' : 'Offline'}');
      }
      
      state = isOnline ? ConnectivityState.online : ConnectivityState.offline;
      
      // Set up a periodic check for connectivity status
      Future.delayed(const Duration(seconds: 5), () => _checkConnectivity());
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing connectivity provider: $e');
      }
      state = ConnectivityState.offline;
    }
  }
  
  /// Check the current connectivity status
  Future<void> _checkConnectivity() async {
    try {
      final hybridRepo = HybridActivitiesRepository();
      final isOnline = hybridRepo.isOnline;
      final newState = isOnline ? ConnectivityState.online : ConnectivityState.offline;
      
      // Only update state if it changed
      if (state != newState) {
        if (kDebugMode) {
          print('Connectivity state changed: ${state.name} -> ${newState.name}');
        }
        state = newState;
      }
      
      // Schedule next check
      Future.delayed(const Duration(seconds: 30), () => _checkConnectivity());
    } catch (e) {
      if (kDebugMode) {
        print('Error checking connectivity: $e');
      }
      
      // If there's an error, assume we're offline
      if (state != ConnectivityState.offline) {
        state = ConnectivityState.offline;
      }
      
      // Schedule next check
      Future.delayed(const Duration(seconds: 30), () => _checkConnectivity());
    }
  }
  
  /// Force a connectivity check
  Future<void> checkConnectivity() async {
    await _checkConnectivity();
  }
}

/// Connectivity state
///
/// This enum represents the current connectivity state of the app.
enum ConnectivityState {
  /// The app is online and can connect to remote services
  online,
  
  /// The app is offline and cannot connect to remote services
  offline,
  
  /// The connectivity state is unknown
  unknown,
}
