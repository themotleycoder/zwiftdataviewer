import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/providers/connectivity_provider.dart';

/// A widget that displays the current connectivity status
///
/// This widget shows an indicator when the app is offline.
/// It can be placed in the app bar or other prominent locations.
class ConnectivityStatusWidget extends ConsumerWidget {
  const ConnectivityStatusWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityState = ref.watch(connectivityProvider);
    
    // Only show something when offline
    if (connectivityState == ConnectivityState.offline) {
      return _buildOfflineIndicator(context);
    }
    
    // Return an empty container when online or unknown
    return const SizedBox.shrink();
  }
  
  /// Builds the offline indicator
  Widget _buildOfflineIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.red.shade700,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off,
            color: Colors.white,
            size: 16.0,
          ),
          const SizedBox(width: 4.0),
          Text(
            'Offline',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// A widget that displays a banner when the app is offline
///
/// This widget shows a banner at the top of the screen when the app is offline.
/// It can be used to provide more context about the offline state.
class ConnectivityBanner extends ConsumerWidget {
  const ConnectivityBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityState = ref.watch(connectivityProvider);
    
    // Only show the banner when offline
    if (connectivityState == ConnectivityState.offline) {
      return Container(
        width: double.infinity,
        color: Colors.red.shade700,
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        child: Row(
          children: [
            const Icon(
              Icons.cloud_off,
              color: Colors.white,
              size: 16.0,
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                'You are offline. Some features may be limited.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // Force a connectivity check
                ref.read(connectivityProvider.notifier).checkConnectivity();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    // Return an empty container when online or unknown
    return const SizedBox.shrink();
  }
}
