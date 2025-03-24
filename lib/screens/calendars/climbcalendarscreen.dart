import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/models/climbdata.dart';
import 'package:zwiftdataviewer/providers/climb_calendar_provider.dart';
import 'package:zwiftdataviewer/providers/climb_select_provider.dart';
import 'package:zwiftdataviewer/utils/climbsconfig.dart';
import 'package:zwiftdataviewer/utils/constants.dart';
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/utils/ui_helpers.dart';
import 'package:zwiftdataviewer/widgets/climbeventscalendarwidget.dart';

/// A screen that displays a calendar of Zwift climb events.
///
/// This screen shows a calendar with the scheduled Zwift climbs for each day,
/// and a list of climb events for the selected day.
class ClimbCalendarScreen extends ConsumerWidget {
  /// Creates a ClimbCalendarScreen instance.
  ///
  /// @param key An optional key for this widget
  const ClimbCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Map<DateTime, List<ClimbData>>> asyncClimbCalender =
        ref.watch(loadClimbCalendarProvider);

    return Column(
      mainAxisSize: MainAxisSize.max, 
      children: <Widget>[
        asyncClimbCalender.when(
          data: (Map<DateTime, List<ClimbData>> climbData) {
            return ClimbEventsCalendarWidget(ref, climbData);
          }, 
          error: (Object error, StackTrace stackTrace) {
            // Log error for debugging
            debugPrint('Error loading climb calendar data: $error');
            return UIHelpers.buildErrorWidget(
              'Failed to load climb calendar data',
              () => ref.refresh(loadClimbCalendarProvider),
            );
          }, 
          loading: () {
            return UIHelpers.buildLoadingIndicator(
              key: AppKeys.activitiesLoading,
            );
          }
        ),
      const SizedBox(height: 8.0),
      Expanded(child: _buildEventList(ref, context)),
    ]);
  }
}

/// Builds a list of climb event cards for the selected day.
///
/// This function creates a list of cards, each representing a climb event
/// for the selected day. Each card displays the climb name and an icon,
/// and tapping on a card opens the climb details in a web browser.
///
/// @param ref The WidgetRef used to access providers
/// @param context The BuildContext for navigation
/// @return A ListView containing the climb event cards
Widget _buildEventList(WidgetRef ref, BuildContext context) {
  final List<ClimbData> selectedEvents = ref.watch(climbEventsForDayProvider);
  
  if (selectedEvents.isEmpty) {
    return Center(
      child: UIHelpers.buildEmptyStateWidget(
        'No climb events for this day',
        icon: Icons.terrain,
      ),
    );
  }
  
  final List<Widget> list = selectedEvents
      .map((climb) => _buildClimbCard(climb, ref, context))
      .toList();

  return ListView(
    children: list,
  );
}

/// Builds a card for a climb event.
///
/// @param climb The ClimbData for the card
/// @param ref The WidgetRef used to access providers
/// @param context The BuildContext for navigation
/// @return A Card widget for the climb
Widget _buildClimbCard(ClimbData climb, WidgetRef ref, BuildContext context) {
  final climbName = allClimbsConfig[climb.id]?.name ?? 'Unknown Climb';
  
  return Card(
    color: Colors.white,
    elevation: defaultCardElevation,
    margin: const EdgeInsets.all(8.0),
    semanticContainer: true,
    child: InkWell(
      borderRadius: BorderRadius.circular(4.0),
      child: ListTile(
        leading: const Icon(Icons.terrain, size: 32.0, color: zdvOrange),
        title: Text(climbName),
        subtitle: const Text('Tap to view details'),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: zdvmMidBlue[100],
        ),
        onTap: () {
          ref.read(selectedClimbProvider.notifier).state =
              allClimbsConfig[climb.id] as ClimbData;
          launchMyUrl(allClimbsConfig[climb.id]?.url ?? 'NA');
        },
      ),
    ),
  );
}

/// Launches a URL in the default browser.
///
/// This function parses the URL and launches it in the default browser.
/// If the URL cannot be launched, an error is thrown.
///
/// @param url The URL to launch
Future<void> launchMyUrl(String url) async {
  try {
    String site = url.substring(url.indexOf('//') + 2);
    String path = site.substring(site.indexOf('/'));
    site = site.substring(0, site.indexOf('/'));
    final Uri uri = Uri.https(site, path);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $uri');
    }
  } catch (e) {
    debugPrint('Error launching URL: $e');
  }
}
