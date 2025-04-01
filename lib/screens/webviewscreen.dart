import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// A screen that launches a URL in the default browser.
//
// This screen provides a simple interface to launch URLs in the
// device's default browser instead of using an in-app WebView.
class WebViewScreen extends StatelessWidget {
  // The URL to open in the browser.
  final String url;

  // The title to display in the app bar.
  final String title;

  // Creates a WebViewScreen instance.
  //
  // @param url The URL to open in the browser
  // @param title The title to display in the app bar
  // @param key An optional key for this widget
  const WebViewScreen({
    required this.url,
    required this.title,
    super.key,
  });

  // Launches the URL in the default browser
  Future<void> _launchUrl() async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Launch the URL when the screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _launchUrl();
      // Return to previous screen after launching URL
      Navigator.of(context).pop();
    });

    // Show a loading screen briefly before returning
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Opening in browser...'),
          ],
        ),
      ),
    );
  }
}
