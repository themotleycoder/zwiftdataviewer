import 'package:flutter/material.dart';
import 'package:flutter_strava_api/globals.dart' as globals;
import 'package:flutter_strava_api/models/token.dart';
import 'package:flutter_strava_api/strava.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zwiftdataviewer/secrets.dart';
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:flutter_strava_api/api/email_auth.dart';

/// A screen for handling Strava's email code verification authentication flow
class StravaEmailAuthScreen extends StatefulWidget {
  const StravaEmailAuthScreen({Key? key}) : super(key: key);

  @override
  State<StravaEmailAuthScreen> createState() => _StravaEmailAuthScreenState();
}

class _StravaEmailAuthScreenState extends State<StravaEmailAuthScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSuccess = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  /// Save the token and the expiry date
  Future<void> _saveToken(Token token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('strava_accessToken', token.accessToken ?? '');
    prefs.setInt('strava_expire', token.expiresAt ?? 0);
    prefs.setString('strava_scope', token.scope ?? '');
    prefs.setString('strava_refreshToken', token.refreshToken ?? '');

    globals.token = token;
    debugPrint('Token saved!');
  }

  /// Verify the email code and exchange it for an access token
  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter the verification code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Exchange the email code for a token
      final token = await EmailAuth.exchangeEmailCodeForToken(
        clientId,
        clientSecret,
        code,
      );

      if (token != null) {
        // Save the token
        await _saveToken(token);
        
        setState(() {
          _isLoading = false;
          _isSuccess = true;
        });
        
        // Close the screen after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context).pop(true); // Return true to indicate success
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Invalid verification code. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  /// Launch the Strava authorization page
  Future<void> _launchStravaAuth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Launch the authorization URL
      final authUrl = 'https://www.strava.com/oauth/authorize'
          '?client_id=$clientId'
          '&redirect_uri=http://localhost'
          '&response_type=code'
          '&approval_prompt=auto'
          '&scope=activity:write,activity:read_all,profile:read_all';
      
      // Launch the URL in the browser
      await launchUrl(Uri.parse(authUrl), mode: LaunchMode.externalApplication);
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error launching Strava authentication: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Strava Authentication'),
        backgroundColor: zdvmMidBlue[100],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            
            // Strava logo or icon
            Center(
              child: Image.network(
                'https://www.strava.com/images/common/strava-logo.png',
                height: 60,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.directions_bike,
                    size: 60,
                    color: zdvOrange,
                  );
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Instructions
            const Text(
              'Strava now uses email verification for authentication.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            const Text(
              '1. Click the button below to open Strava login\n'
              '2. Enter your Strava email and password\n'
              '3. Strava will send a verification code to your email\n'
              '4. Enter that code below',
              style: TextStyle(fontSize: 14),
            ),
            
            const SizedBox(height: 24),
            
            // Button to launch Strava auth
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _launchStravaAuth,
              icon: const Icon(Icons.login),
              label: const Text('Open Strava Login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: zdvmMidBlue[100],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Divider
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Enter Verification Code'),
                ),
                Expanded(child: Divider()),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Code input field
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Verification Code',
                hintText: 'Enter the code sent to your email',
                border: const OutlineInputBorder(),
                errorText: _errorMessage,
              ),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _verifyCode(),
            ),
            
            const SizedBox(height: 16),
            
            // Verify button
            ElevatedButton(
              onPressed: _isLoading || _isSuccess ? null : _verifyCode,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : _isSuccess
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check),
                            SizedBox(width: 8),
                            Text('Authentication Successful'),
                          ],
                        )
                      : const Text('Verify Code'),
              style: ElevatedButton.styleFrom(
                backgroundColor: zdvOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Success message
            if (_isSuccess)
              const Card(
                color: Colors.green,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 48,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Authentication Successful!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Returning to the app...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
