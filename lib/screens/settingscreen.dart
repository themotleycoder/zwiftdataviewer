import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/providers/config_provider.dart';
import 'package:zwiftdataviewer/utils/constants.dart' as constants;
import 'package:zwiftdataviewer/utils/constants.dart';
import 'package:zwiftdataviewer/utils/database/database_init.dart';
import 'package:zwiftdataviewer/utils/repository/filerepository.dart';
import 'package:zwiftdataviewer/utils/strava_api_helper.dart';
import 'package:zwiftdataviewer/utils/theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ConfigData configData = ConfigData();

    configData = ref.watch(configProvider);

    return Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: Column(children: [
          createCard(
              'FTP',
              Expanded(
                  child: Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: TextField(
                    textAlign: TextAlign.right,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: configData.ftp?.toString() ?? '0',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (value) {
                      configData.ftp = double.parse(value);
                      ref.read(configProvider.notifier).setConfig(configData);

                      // setState(() {
                      //   _configData!.ftp = int.parse(value);
                      //   print(_configData!.ftp);
                      // });
                      // Provider.of<ConfigDataModel>(context, listen: false)
                      //     .configData = _configData;
                    },
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ]),
                // ],
              ))),
          createCard(
            'Metric',
            Switch(
              value: configData.isMetric!,
              onChanged: (value) {
                configData.isMetric = value;
                ref.read(configProvider.notifier).setConfig(configData);
                // setState(() {
                //   _configData!.isMetric = value;
                //   print(_configData!.isMetric);
                // });
                // Provider.of<ConfigDataModel>(context, listen: false)
                //     .configData = _configData;
              },
              activeTrackColor: zdvmLgtBlue,
              activeColor: zdvmMidBlue[100],
            ),
          ),
          createCard(
              'Refresh Route Data',
              IconButton(
                  key: AppKeys.refreshButton,
                  tooltip: 'refresh',
                  icon: const Icon(Icons.refresh),
                  color: zdvmMidBlue[100],
                  onPressed: () => refreshRouteData())),
          createCard(
              'Refresh Calendars Data',
              IconButton(
                  key: AppKeys.refreshButton,
                  tooltip: 'refresh',
                  icon: const Icon(Icons.refresh),
                  color: zdvmMidBlue[100],
                  onPressed: () => refreshCalendarData())),
          // createCard(
          //     'Database Status',
          //     TextButton(
          //         child: const Text('Check Status', style: TextStyle(color: zdvOrange)),
          //         onPressed: () => checkDatabaseStatus(context))),
          // createCard(
          //     'Reset Database',
          //     TextButton(
          //         child: const Text('Reset', style: TextStyle(color: Colors.red)),
          //         onPressed: () => showResetDatabaseDialog(context))),
          // createCard(
          //     'Reset Activity Photos',
          //     TextButton(
          //         child: const Text('Reset Photos', style: TextStyle(color: Colors.orange)),
          //         onPressed: () => showResetPhotosDialog(context))),
          // createCard(
          //     'Strava API Status',
          //     TextButton(
          //         child: const Text('Check Status', style: TextStyle(color: zdvOrange)),
          //         onPressed: () => checkStravaApiStatus(context))),
          // createCard(
          //     'Strava Email Auth',
          //     TextButton(
          //         child: const Text('Use Email Code', style: TextStyle(color: zdvOrange)),
          //         onPressed: () => authenticateWithEmailCode(context))),
          // createCard(
          //     'Reset Strava Auth',
          //     TextButton(
          //         child: const Text('Reset Auth', style: TextStyle(color: Colors.red)),
          //         onPressed: () => showResetStravaAuthDialog(context))),
        ]));
  }

  refreshRouteData() {
    FileRepository().scrapeRouteData();
  }

  refreshCalendarData() {
    FileRepository().scrapeWorldCalendarData();
    FileRepository().scrapeClimbCalendarData();
  }
  
  Future<void> checkDatabaseStatus(BuildContext context) async {
    try {
      final status = await DatabaseInit.checkDatabaseStatus();
      
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Database Status'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('File exists: ${status['file_exists']}'),
                Text('File size: ${status['file_size']} bytes'),
                if (status['file_exists']) ...[
                  const SizedBox(height: 8),
                  Text('Version: ${status['version']['version']}'),
                  Text('Last updated: ${status['version']['last_updated']}'),
                  const SizedBox(height: 8),
                  const Text('Tables:'),
                  ...((status['tables'] as List).map((table) => Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text('- $table'),
                  ))),
                  const SizedBox(height: 8),
                  const Text('Row counts:'),
                  ...(status['row_counts'] as Map<String, int>).entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text('- ${entry.key}: ${entry.value} rows'),
                  )),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error checking database status: $e');
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking database status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> showResetDatabaseDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Database'),
        content: const Text(
          'This will delete all data in the database and recreate it. '
          'This action cannot be undone. Are you sure you want to continue?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await resetDatabase(context);
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  Future<void> resetDatabase(BuildContext context) async {
    try {
      await DatabaseInit.resetDatabase();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Database reset successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error resetting database: $e');
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error resetting database: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> showResetPhotosDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Activity Photos'),
        content: const Text(
          'This will delete all activity photos from the database. '
          'The app will need to re-download photos when viewing activities. '
          'This action cannot be undone. Are you sure you want to continue?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await resetActivityPhotos(context);
            },
            child: const Text('Reset Photos', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }
  
  Future<void> resetActivityPhotos(BuildContext context) async {
    try {
      await DatabaseInit.resetActivityPhotosTable();
      
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Activity photos reset successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error resetting activity photos: $e');
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error resetting activity photos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> checkStravaApiStatus(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      // Get API status
      final status = await StravaApiHelper.checkApiStatus();
      
      // Close loading indicator
      Navigator.of(context).pop();
      
      // Get troubleshooting steps
      final steps = StravaApiHelper.getTroubleshootingSteps(status);
      
      // Show status dialog
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Strava API Status'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('API Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Has token: ${status['has_token']}'),
                Text('Token expired: ${status['token_expired']}'),
                Text('Has refresh token: ${status['has_refresh_token']}'),
                if (status['token_expiry'] != null)
                  Text('Token expires: ${status['token_expiry']}'),
                Text('Client ID set: ${status['client_id_set']}'),
                Text('Client secret set: ${status['client_secret_set']}'),
                Text('Internet connectivity: ${status['connectivity']}'),
                Text('Can reach Strava: ${status['can_reach_strava']}'),
                
                const SizedBox(height: 16),
                const Text('Troubleshooting Steps:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...steps.map((step) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('• $step'),
                )),
                
                if (status['has_token'] && status['token_expired'] && status['has_refresh_token'])
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await refreshStravaToken(context);
                      },
                      child: const Text('Refresh Token'),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Close loading indicator if it's showing
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      if (kDebugMode) {
        print('Error checking Strava API status: $e');
      }
      
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking Strava API status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> refreshStravaToken(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      // Attempt to refresh the token
      final success = await StravaApiHelper.refreshToken();
      
      // Close loading indicator
      Navigator.of(context).pop();
      
      // Show result
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
            ? 'Strava token refreshed successfully' 
            : 'Failed to refresh Strava token'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      // Close loading indicator if it's showing
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      if (kDebugMode) {
        print('Error refreshing Strava token: $e');
      }
      
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error refreshing Strava token: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> showResetStravaAuthDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Strava Authentication'),
        content: const Text(
          'This will clear all Strava authentication tokens. '
          'You will need to re-authenticate with Strava the next time you use the app. '
          'This action cannot be undone. Are you sure you want to continue?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await resetStravaAuth(context);
            },
            child: const Text('Reset Auth', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  Future<void> resetStravaAuth(BuildContext context) async {
    try {
      await StravaApiHelper.clearTokens();
      
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Strava authentication reset successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error resetting Strava authentication: $e');
      }
      
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error resetting Strava authentication: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> authenticateWithEmailCode(BuildContext context) async {
    try {
      final success = await StravaApiHelper.authenticateWithEmailCode(context);
      
      // Show result
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
            ? 'Successfully authenticated with Strava' 
            : 'Failed to authenticate with Strava'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error in email authentication: $e');
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error in email authentication: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Card createCard(String label, Widget widget) {
    return Card(
        elevation: defaultCardElevation,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
            child: Text(label, style: constants.headerTextStyle),
          ),
          widget
        ]));
  }
}
