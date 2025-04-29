import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_strava_api/globals.dart' as globals;
import 'package:flutter_strava_api/models/token.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zwiftdataviewer/utils/supabase/supabase_config.dart';

/// Service for handling Supabase authentication using Strava tokens
///
/// This service provides methods for signing in with a Strava token,
/// signing out, and checking authentication state.
class SupabaseAuthService {
  static final SupabaseAuthService _instance = SupabaseAuthService._internal();
  final _authStateController = StreamController<bool>.broadcast();

  // Singleton pattern
  factory SupabaseAuthService() => _instance;

  SupabaseAuthService._internal();

  /// Stream of authentication state changes
  Stream<bool> get authStateChanges => _authStateController.stream;

  /// Checks if the user is currently authenticated with Supabase
  Future<bool> isAuthenticated() async {
    try {
      final session = SupabaseConfig.client.auth.currentSession;
      return session != null && !session.isExpired;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking authentication state: $e');
      }
      return false;
    }
  }

  /// Signs in with a Strava token
  ///
  /// This method uses the Strava token to authenticate with Supabase.
  /// It creates a custom JWT token that Supabase can validate.
  Future<void> signInWithStravaToken(Token stravaToken, int athleteId) async {
    try {
      if (stravaToken.accessToken == null || stravaToken.accessToken!.isEmpty) {
        throw Exception('Strava access token is null or empty');
      }

      // For simplicity in this implementation, we're using the Strava token directly
      // In a production environment, you would typically have a secure backend service
      // that would exchange the Strava token for a Supabase JWT
      
      // Sign in with custom token (in a real implementation, this would be a JWT)
      // Use a fixed email and password for the existing Supabase user
      final email = 'jdm@duck.com';
      // Use a fixed password that was set when the user was created
      // In a production environment, you would use a more secure method
      final password = 'mypassword'; // Replace with the actual password
      
      try {
        // Try to sign in first
        final response = await SupabaseConfig.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        
        if (kDebugMode) {
          print('Signed in with Strava token: ${response.user?.id}');
        }
        
        // Update the user's metadata with the Strava athlete ID
        await SupabaseConfig.client.auth.updateUser(
          UserAttributes(
            data: {
              'strava_athlete_id': athleteId,
              'strava_token': stravaToken.accessToken,
            },
          ),
        );
        
        if (kDebugMode) {
          print('Updated user metadata with Strava athlete ID: $athleteId');
        }
        
        _authStateController.add(true);
      } catch (signInError) {
        if (kDebugMode) {
          print('Sign in failed, attempting to sign up: $signInError');
        }
        
        // If sign in fails, try to sign up
        try {
          final response = await SupabaseConfig.client.auth.signUp(
            email: email,
            password: password,
            data: {
              'strava_athlete_id': athleteId,
              'strava_token': stravaToken.accessToken,
            },
          );
          
          if (kDebugMode) {
            print('Signed up with Strava token: ${response.user?.id}');
          }
          
          _authStateController.add(true);
        } catch (signUpError) {
          if (kDebugMode) {
            print('Sign up failed: $signUpError');
          }
          rethrow;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error signing in with Strava token: $e');
      }
      _authStateController.add(false);
      rethrow;
    }
  }

  /// Signs out the current user
  Future<void> signOut() async {
    try {
      await SupabaseConfig.client.auth.signOut();
      _authStateController.add(false);
      if (kDebugMode) {
        print('Signed out from Supabase');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out: $e');
      }
      rethrow;
    }
  }

  /// Gets the current user ID
  String? get currentUserId {
    try {
      return SupabaseConfig.client.auth.currentUser?.id;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current user ID: $e');
      }
      return null;
    }
  }

  /// Gets the current Strava athlete ID
  int? get currentAthleteId {
    try {
      final userData = SupabaseConfig.client.auth.currentUser?.userMetadata;
      if (userData != null && userData.containsKey('strava_athlete_id')) {
        return int.tryParse(userData['strava_athlete_id'].toString());
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current athlete ID: $e');
      }
      return null;
    }
  }

  /// Generates a secure password from the Strava token and athlete ID
  ///
  /// This is a simple implementation for demonstration purposes.
  /// In a production environment, you would use a more secure method.
  String _generateSecurePassword(String token, String athleteId) {
    final bytes = utf8.encode('$token:$athleteId:zwiftdataviewer');
    final digest = base64.encode(bytes);
    return digest.substring(0, 20); // Use first 20 chars for password
  }

  /// Refreshes the Supabase session if needed
  Future<void> refreshSessionIfNeeded() async {
    try {
      final session = SupabaseConfig.client.auth.currentSession;
      if (session == null) {
        if (kDebugMode) {
          print('No session to refresh');
        }
        return;
      }

      if (session.isExpired) {
        if (kDebugMode) {
          print('Session expired, refreshing...');
        }
        
        // In a real implementation, you would refresh the session
        // For now, we'll just sign in again with the Strava token
        if (globals.token.accessToken != null) {
          // Get athlete ID from user metadata or use a default
          final athleteId = currentAthleteId ?? 0;
          if (athleteId > 0) {
            await signInWithStravaToken(globals.token, athleteId);
          } else {
            if (kDebugMode) {
              print('Cannot refresh session: No athlete ID available');
            }
            await signOut();
          }
        } else {
          if (kDebugMode) {
            print('Cannot refresh session: No Strava token available');
          }
          await signOut();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing session: $e');
      }
      // If refresh fails, sign out
      await signOut();
    }
  }
}
