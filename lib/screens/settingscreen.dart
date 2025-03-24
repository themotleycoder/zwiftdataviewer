import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/providers/config_provider.dart';
import 'package:zwiftdataviewer/utils/constants.dart';
import 'package:zwiftdataviewer/utils/repository/filerepository.dart';
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/utils/ui_helpers.dart';

/// A screen that displays application settings.
///
/// This screen allows the user to configure various settings such as FTP,
/// measurement units, and refresh data.

class SettingsScreen extends ConsumerWidget {
  /// Creates a SettingsScreen instance.
  ///
  /// @param key An optional key for this widget
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configData = ref.watch(configProvider);

    return Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // FTP Setting
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        final updatedConfig = configData.copyWith(
                          ftp: double.tryParse(value) ?? configData.ftp,
                        );
                        ref.read(configProvider.notifier).setConfig(updatedConfig);
                      }
                    },
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                  ),
                ),
              ),
              tooltip: 'Your Functional Threshold Power in watts',
            ),
            // Metric/Imperial Setting
            createCard(
              'Metric',
              Switch(
                value: configData.isMetric ?? true,
                onChanged: (value) {
                  final updatedConfig = configData.copyWith(
                    isMetric: value,
                  );
                  ref.read(configProvider.notifier).setConfig(updatedConfig);
                },
                activeTrackColor: zdvmLgtBlue,
                activeColor: zdvmMidBlue[100],
              ),
              tooltip: 'Toggle between metric (km) and imperial (miles) units',
            ),
            // Refresh Route Data
            createCard(
              'Refresh Route Data',
              IconButton(
                key: AppKeys.refreshButton,
                tooltip: 'Refresh route data from Zwift',
                icon: const Icon(Icons.refresh),
                color: zdvmMidBlue[100],
                onPressed: () {
                  refreshRouteData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Route data refresh started'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              tooltip: 'Update route data from Zwift servers',
            ),
            
            // Refresh Calendar Data
            createCard(
              'Refresh Calendars Data',
              IconButton(
                key: const Key('refreshCalendarButton'),
                tooltip: 'Refresh calendar data from Zwift',
                icon: const Icon(Icons.refresh),
                color: zdvmMidBlue[100],
                onPressed: () {
                  refreshCalendarData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Calendar data refresh started'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              tooltip: 'Update world and climb calendar data from Zwift servers',
            ),
        ]));
  }

  /// Refreshes route data from Zwift.
  ///
  /// This method triggers a scrape of route data from Zwift servers.
  void refreshRouteData() {
    FileRepository().scrapeRouteData();
  }

  /// Refreshes calendar data from Zwift.
  ///
  /// This method triggers a scrape of world and climb calendar data from Zwift servers.
  void refreshCalendarData() {
    FileRepository().scrapeWorldCalendarData();
    FileRepository().scrapeClimbCalendarData();
  }

  /// Creates a card with a label and a widget.
  ///
  /// @param label The label text for the card
  /// @param widget The widget to display in the card
  /// @param tooltip Optional tooltip for the card
  /// @return A Card widget
  Card createCard(String label, Widget widget, {String? tooltip}) {
    final cardContent = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
          child: Text(
            label, 
            style: headerTextStyle,
          ),
        ),
        widget
      ],
    );
    
    return Card(
      elevation: defaultCardElevation,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: tooltip != null
          ? Tooltip(
              message: tooltip,
              child: cardContent,
            )
          : cardContent,
    );
  }
}
