import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_strava_api/globals.dart' as globals;
import 'package:flutter_strava_api/models/token.dart';
import 'package:flutter_strava_api/strava.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zwiftdataviewer/screens/strava_email_auth_screen.dart';
import 'package:zwiftdataviewer/secrets.dart';

/// Helper class for Strava API operations and troubleshooting
class StravaApiHelper {
  /// Checks the status of the Strava API connection
  /// 
  /// Returns a map with diagnostic information about the current Strava API connection
  static Future<Map<String, dynamic>> checkApiStatus() async {
    final Map<String, dynamic> status = {
      'has_token': false,
      'token_expired': true,
      'has_refresh_token': false,
      'client_id_set': clientId.isNotEmpty,
      'client_secret_set': clientSecret.isNotEmpty,
      'token_expiry': null,
      'scopes': null,
      'connectivity': false,
      'can_reach_strava': false,
    };

    // Check token status
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('strava_accessToken');
      final refreshToken = prefs.getString('strava_refreshToken');
      final expiresAt = prefs.getInt('strava_expire');
      final scope = prefs.getString('strava_scope');

      status['has_token'] = accessToken != null && accessToken.isNotEmpty;
      status['has_refresh_token'] = refreshToken != null && refreshToken.isNotEmpty;
      
      if (expiresAt != null) {
        final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
        status['token_expiry'] = expiryDate.toIso8601String();
        status['token_expired'] = expiryDate.isBefore(DateTime.now());
      }
      
      status['scopes'] = scope;
    } catch (e) {
      debugPrint('Error checking token status: $e');
    }

    // Check connectivity
    try {
      // Check if we can reach the internet
      try {
        final result = await InternetAddress.lookup('google.com');
        status['connectivity'] = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } on SocketException catch (_) {
        status['connectivity'] = false;
      }

      // Check if we can reach Strava (only if we have internet connectivity)
      if (status['connectivity']) {
        try {
          final result = await InternetAddress.lookup('www.strava.com');
          status['can_reach_strava'] = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
        } on SocketException catch (_) {
          status['can_reach_strava'] = false;
        }
      }
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
    }

    return status;
  }

  /// Attempts to refresh the Strava API token
  /// 
  /// Returns true if successful, false otherwise
  static Future<bool> refreshToken() async {
    try {
      final Strava strava = Strava(kDebugMode, clientSecret);
      
      // Get the stored token
      Token storedToken = await strava.getStoredToken();
      
      // Check if we have a refresh token
      if (storedToken.refreshToken == null || storedToken.refreshToken!.isEmpty) {
        debugPrint('No refresh token available, cannot refresh');
        return false;
      }
      
      // Attempt to refresh the token
      final isAuthOk = await strava.oauth(
        clientId,
        'activity:write,activity:read_all,profile:read_all',
        clientSecret,
        'auto',
      );
      
      return isAuthOk;
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      return false;
    }
  }
  
  /// Authenticate with Strava using the new email verification flow
  /// 
  /// This method shows a screen that guides the user through the email verification process.
  /// Returns true if authentication was successful, false otherwise.
  static Future<bool> authenticateWithEmailCode(BuildContext context) async {
    try {
      // Show the email authentication screen
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => const StravaEmailAuthScreen(),
        ),
      );
      
      // Return true if authentication was successful
      return result ?? false;
    } catch (e) {
      debugPrint('Error in email authentication: $e');
      return false;
    }
  }

  /// Clears all Strava API tokens from storage
  /// 
  /// This forces a complete re-authentication on the next API call
  static Future<void> clearTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('strava_accessToken');
      await prefs.remove('strava_expire');
      await prefs.remove('strava_scope');
      await prefs.remove('strava_refreshToken');
      
      // Also clear the token in memory
      globals.token = Token();
      
      debugPrint('Strava tokens cleared successfully');
    } catch (e) {
      debugPrint('Error clearing tokens: $e');
    }
  }

  /// Provides troubleshooting steps based on the API status
  /// 
  /// Returns a list of recommended actions to fix Strava API issues
  static List<String> getTroubleshootingSteps(Map<String, dynamic> status) {
    final List<String> steps = [];
    
    // Check connectivity issues first
    if (!status['connectivity']) {
      steps.add('Check your internet connection');
      return steps;
    }
    
    // Check if we can reach Strava
    if (!status['can_reach_strava']) {
      steps.add('Cannot reach Strava servers. There might be a temporary outage or network issue');
      steps.add('Try again later or check Strava status page');
      return steps;
    }
    
    // Check API credentials
    if (!status['client_id_set'] || !status['client_secret_set']) {
      steps.add('Strava API credentials are not properly set in secrets.dart');
      steps.add('Update the client ID and client secret with valid values from https://www.strava.com/settings/api');
      return steps;
    }
    
    // Check token status
    if (!status['has_token']) {
      steps.add('No Strava access token found. You need to authenticate with Strava');
      steps.add('Try using the new email verification authentication method');
      return steps;
    }
    
    // Check if token is expired
    if (status['token_expired']) {
      if (status['has_refresh_token']) {
        steps.add('Your Strava access token is expired, but a refresh token is available');
        steps.add('Try refreshing the token or using the new email verification authentication method');
      } else {
        steps.add('Your Strava access token is expired and no refresh token is available');
        steps.add('Use the new email verification authentication method');
      }
      return steps;
    }
    
    // If we get here, the token should be valid
    steps.add('Your Strava API credentials and token appear to be valid');
    steps.add('If you\'re still experiencing issues, check if your Strava API application is still active');
    steps.add('Visit https://www.strava.com/settings/api to verify your application status');
    
    return steps;
  }
}
