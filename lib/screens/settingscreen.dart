import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zwiftdataviewer/utils/database/database_init.dart';
import 'package:zwiftdataviewer/utils/repository/filerepository.dart';
import 'package:zwiftdataviewer/utils/repository/hybrid_activities_repository.dart';
import 'package:zwiftdataviewer/utils/supabase/database_sync_service.dart';
import 'package:zwiftdataviewer/utils/supabase/supabase_auth_service.dart';
import 'package:zwiftdataviewer/utils/theme.dart';

// Provider for Supabase enabled state
final supabaseEnabledProvider = StateProvider<bool>((ref) => true);

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isMetric = true;
  int _ftp = 0;
  bool _isSupabaseEnabled = true;
  bool _isSyncing = false;
  SyncState _syncState = SyncState.idle;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkSupabaseStatus();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isMetric = prefs.getBool('isMetric') ?? true;
      _ftp = prefs.getInt('ftp') ?? 0;
      _isSupabaseEnabled = prefs.getBool('supabaseEnabled') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isMetric', _isMetric);
    await prefs.setInt('ftp', _ftp);
    await prefs.setBool('supabaseEnabled', _isSupabaseEnabled);
  }

  Future<void> _checkSupabaseStatus() async {
    try {
      final hybridRepo = HybridActivitiesRepository();
      setState(() {
        _isSupabaseEnabled = hybridRepo.isSupabaseEnabled;
        _isSyncing = hybridRepo.syncService.isSyncing;
        _syncState = hybridRepo.syncService.currentState;
      });

      // Listen for sync state changes
      hybridRepo.syncService.syncStateChanges.listen((state) {
        if (mounted) {
          setState(() {
            _syncState = state;
            _isSyncing = hybridRepo.syncService.isSyncing;
          });
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error checking Supabase status: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.center,
      child: Column(
        children: [
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
                    hintText: _ftp.toString(),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (value) {
                    setState(() {
                      _ftp = int.tryParse(value) ?? 0;
                    });
                    _saveSettings();
                  },
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
              ),
            ),
          ),
          createCard(
            'Metric',
            Switch(
              value: _isMetric,
              onChanged: (value) {
                setState(() {
                  _isMetric = value;
                });
                _saveSettings();
              },
              activeTrackColor: zdvmLgtBlue,
              activeColor: zdvmMidBlue[100],
            ),
          ),
          createCard(
            'Use Supabase',
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Switch(
                  value: _isSupabaseEnabled,
                  onChanged: (value) async {
                    final hybridRepo = HybridActivitiesRepository();
                    await hybridRepo.setSupabaseEnabled(value);
                    
                    setState(() {
                      _isSupabaseEnabled = value;
                    });
                    _saveSettings();
                    
                    if (value) {
                      // If enabling Supabase, check if we need to perform initial migration
                      final authService = SupabaseAuthService();
                      final isAuthenticated = await authService.isAuthenticated();
                      if (isAuthenticated) {
                        // Show migration dialog
                        // ignore: use_build_context_synchronously
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Migrate Data to Supabase?'),
                            content: const Text(
                              'Would you like to migrate your existing data to Supabase? '
                              'This will allow you to access your data from multiple devices.'
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Skip'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  await _performInitialMigration();
                                },
                                child: const Text('Migrate'),
                              ),
                            ],
                          ),
                        );
                      }
                    }
                  },
                  activeTrackColor: zdvmLgtBlue,
                  activeColor: zdvmMidBlue[100],
                ),
                if (_isSyncing)
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const SizedBox(height: 4),
                        Text(_getSyncStateText(), style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 4),
                        const LinearProgressIndicator(),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (_isSupabaseEnabled)
            createCard(
              'Sync Data',
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Sync to Supabase',
                    icon: const Icon(Icons.cloud_upload),
                    color: zdvmMidBlue[100],
                    onPressed: _isSyncing ? null : () => _syncToSupabase(),
                  ),
                  IconButton(
                    tooltip: 'Sync from Supabase',
                    icon: const Icon(Icons.cloud_download),
                    color: zdvmMidBlue[100],
                    onPressed: _isSyncing ? null : () => _syncFromSupabase(),
                  ),
                ],
              ),
            ),
          createCard(
            'Refresh Route Data',
            IconButton(
              tooltip: 'refresh',
              icon: const Icon(Icons.refresh),
              color: zdvmMidBlue[100],
              onPressed: () => refreshRouteData(),
            ),
          ),
          createCard(
            'Refresh Calendars Data',
            IconButton(
              tooltip: 'refresh',
              icon: const Icon(Icons.refresh),
              color: zdvmMidBlue[100],
              onPressed: () => refreshCalendarData(),
            ),
          ),
          createCard(
            'Database Status',
            TextButton(
              child: const Text('Check Status', style: TextStyle(color: zdvOrange)),
              onPressed: () => checkDatabaseStatus(context),
            ),
          ),
          createCard(
            'Reset Database',
            TextButton(
              child: const Text('Reset', style: TextStyle(color: Colors.red)),
              onPressed: () => showResetDatabaseDialog(context),
            ),
          ),
        ],
      ),
    );
  }

  String _getSyncStateText() {
    switch (_syncState) {
      case SyncState.migrating:
        return 'Migrating data...';
      case SyncState.syncingToSupabase:
        return 'Syncing to Supabase...';
      case SyncState.syncingFromSupabase:
        return 'Syncing from Supabase...';
      case SyncState.completed:
        return 'Sync completed';
      case SyncState.error:
        return 'Sync error';
      case SyncState.idle:
      default:
        return 'Idle';
    }
  }

  Future<void> _performInitialMigration() async {
    try {
      final syncService = DatabaseSyncService();
      await syncService.performInitialMigration();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data migration completed'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error performing initial migration: $e');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error migrating data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _syncToSupabase() async {
    try {
      final syncService = DatabaseSyncService();
      await syncService.syncToSupabase();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data synced to Supabase'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing to Supabase: $e');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error syncing to Supabase: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _syncFromSupabase() async {
    try {
      final syncService = DatabaseSyncService();
      await syncService.syncFromSupabase();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data synced from Supabase'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing from Supabase: $e');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error syncing from Supabase: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

  Card createCard(String label, Widget widget) {
    return Card(
      elevation: 2.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          widget
        ],
      ),
    );
  }
}
