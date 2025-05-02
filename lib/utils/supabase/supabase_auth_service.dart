import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_strava_api/globals.dart' as globals;
import 'package:flutter_strava_api/models/token.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

      if (kDebugMode) {
        print('Attempting to sign in with Strava token for athlete ID: $athleteId');
      }

      // For simplicity in this implementation, we're using the Strava token directly
      // In a production environment, you would typically have a secure backend service
      // that would exchange the Strava token for a Supabase JWT
      
      // Sign in with custom token (in a real implementation, this would be a JWT)
      // Use a fixed email and password for the existing Supabase user
      const email = 'jdm@duck.com';
      // Use a fixed password that was set when the user was created
      // In a production environment, you would use a more secure method
      const password = 'mypassword'; // Replace with the actual password
      
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
        
        // Save authentication info to SharedPreferences for persistence
        await _saveAuthInfo(email, password, athleteId, stravaToken.accessToken!);
        
        if (kDebugMode) {
          print('Updated user metadata with Strava athlete ID: $athleteId');
          print('Saved authentication info to SharedPreferences');
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
          
          // Save authentication info to SharedPreferences for persistence
          await _saveAuthInfo(email, password, athleteId, stravaToken.accessToken!);
          
          if (kDebugMode) {
            print('Signed up with Strava token: ${response.user?.id}');
            print('Saved authentication info to SharedPreferences');
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
  
  /// Saves authentication information to SharedPreferences
  ///
  /// This method saves the email, password, athlete ID, and Strava token
  /// to SharedPreferences for persistence across app restarts and cache clearing.
  Future<void> _saveAuthInfo(String email, String password, int athleteId, String stravaToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('supabase_email', email);
      await prefs.setString('supabase_password', password);
      await prefs.setInt('strava_athlete_id', athleteId);
      await prefs.setString('strava_token', stravaToken);
      
      if (kDebugMode) {
        print('Authentication info saved to SharedPreferences');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving authentication info to SharedPreferences: $e');
      }
      // Continue even if saving fails
    }
  }
  
  /// Attempts to restore authentication from SharedPreferences
  ///
  /// This method tries to sign in using saved credentials from SharedPreferences.
  /// It should be called when the app starts or when authentication is needed.
  Future<bool> tryRestoreAuth() async {
    try {
      // Check if we're already authenticated
      final isAuth = await isAuthenticated();
      if (isAuth) {
        if (kDebugMode) {
          print('Already authenticated with Supabase');
        }
        return true;
      }
      
      if (kDebugMode) {
        print('Attempting to restore authentication from SharedPreferences');
      }
      
      // Get saved authentication info
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('supabase_email');
      final password = prefs.getString('supabase_password');
      final athleteId = prefs.getInt('strava_athlete_id');
      final stravaToken = prefs.getString('strava_token');
      
      if (email == null || password == null || athleteId == null || stravaToken == null) {
        if (kDebugMode) {
          print('No saved authentication info found');
        }
        return false;
      }
      
      // Try to sign in with saved credentials
      try {
        final response = await SupabaseConfig.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        
        if (kDebugMode) {
          print('Restored authentication from SharedPreferences: ${response.user?.id}');
        }
        
        // Update the user's metadata with the Strava athlete ID
        await SupabaseConfig.client.auth.updateUser(
          UserAttributes(
            data: {
              'strava_athlete_id': athleteId,
              'strava_token': stravaToken,
            },
          ),
        );
        
        _authStateController.add(true);
        return true;
      } catch (e) {
        if (kDebugMode) {
          print('Failed to restore authentication: $e');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error trying to restore authentication: $e');
      }
      return false;
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
