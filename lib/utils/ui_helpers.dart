import 'package:flutter/material.dart';
import 'package:zwiftdataviewer/utils/theme.dart';

/// Utility class providing standardized UI elements for consistent appearance
/// across the application.
class UIHelpers {
  /// Creates a standardized loading widget with an optional key.
  ///
  /// @param key Optional key for the widget
  /// @return A centered CircularProgressIndicator
  static Widget buildLoadingIndicator({Key? key}) {
    return Center(
      child: CircularProgressIndicator(
        key: key,
        color: zdvMidBlue,
      ),
    );
  }

  /// Creates a standardized error widget with a retry option.
  ///
  /// @param message The error message to display
  /// @param onRetry Callback function when the retry button is pressed
  /// @return A widget displaying the error message and a retry button
  static Widget buildErrorWidget(String message, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: zdvMidBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  /// Creates a standardized empty state widget.
  ///
  /// @param message The message to display
  /// @param icon Optional icon to display
  /// @return A widget displaying the empty state message and icon
  static Widget buildEmptyStateWidget(String message, {IconData? icon}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.info_outline,
            size: 48,
            color: zdvmMidBlue[100],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Creates a standardized app bar with a title and optional actions.
  ///
  /// @param title The title of the app bar
  /// @param actions Optional list of action widgets
  /// @param leading Optional leading widget
  /// @return An AppBar widget
  static AppBar buildAppBar(
    String title, {
    List<Widget>? actions,
    Widget? leading,
  }) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0.0,
      actions: actions,
      leading: leading,
    );
  }
}
