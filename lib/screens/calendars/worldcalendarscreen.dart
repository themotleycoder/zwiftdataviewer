import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/models/worlddata.dart';
import 'package:zwiftdataviewer/providers/world_calendar_provider.dart';
import 'package:zwiftdataviewer/providers/world_select_provider.dart';
import 'package:zwiftdataviewer/screens/worlddetailscreen.dart';
import 'package:zwiftdataviewer/utils/constants.dart';
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/utils/ui_helpers.dart';
import 'package:zwiftdataviewer/utils/worldsconfig.dart';
import 'package:zwiftdataviewer/widgets/worldeventscalendarwidget.dart';

// A screen that displays a calendar of Zwift world events.
//
// This screen shows a calendar with the scheduled Zwift worlds for each day,
// and a list of world events for the selected day.
class WorldCalendarScreen extends ConsumerStatefulWidget {
  const WorldCalendarScreen({super.key});

  @override
  ConsumerState<WorldCalendarScreen> createState() =>
      _WorldCalendarScreenState();
}

class _WorldCalendarScreenState extends ConsumerState<WorldCalendarScreen> {
  @override
  Widget build(BuildContext context) {
    final AsyncValue<Map<DateTime, List<WorldData>>> asyncWorldCalender =
        ref.watch(loadWorldCalendarProvider);

    return Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
      asyncWorldCalender.when(data: (Map<DateTime, List<WorldData>> worldData) {
        // Initialize events for the current day after the data is loaded
        // Using a post-frame callback to avoid modifying the provider during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final selectedDay = ref.read(selectedWorldDayProvider);
          final DateTime d =
              DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
          final events = worldData[d] ?? [];
          ref.read(worldEventsForDayProvider.notifier).setEventsForDay(events);
        });

        return WorldEventsCalendarWidget(ref, worldData);
      }, error: (Object error, StackTrace stackTrace) {
        // Log error for debugging
        debugPrint('Error loading world calendar data: $error');
        return UIHelpers.buildErrorWidget(
          'Failed to load world calendar data',
          () => ref.refresh(loadWorldCalendarProvider),
        );
      }, loading: () {
        return UIHelpers.buildLoadingIndicator(
          key: AppKeys.activitiesLoading,
        );
      }),
      const SizedBox(height: 8.0),
      Expanded(child: _buildEventList(ref, context)),
    ]);
  }
}

// Builds a list of world event cards for the selected day.
//
// This function creates a list of cards, each representing a world event
// for the selected day. Each card displays the world name and an icon,
// and tapping on a card navigates to the world detail screen.
//
// @param ref The WidgetRef used to access providers
// @param context The BuildContext for navigation
// @return A ListView containing the world event cards
Widget _buildEventList(WidgetRef ref, BuildContext context) {
  final List<WorldData> selectedEvents = ref.watch(worldEventsForDayProvider);
  final List<Widget> list = selectedEvents
      .map((world) => _buildWorldCard(world, ref, context))
      .toList();

  // Always add Watopia as it's always available
  if (!selectedEvents.any((world) => world.id == 1)) {
    list.add(_buildWatopiaCard(ref, context));
  }

  // If there are no events (even after adding Watopia), show an empty state
  if (list.isEmpty) {
    return Center(
      child: UIHelpers.buildEmptyStateWidget(
        'No world events for this day',
        icon: Icons.map,
      ),
    );
  }

  return ListView(
    children: list,
  );
}

// Builds a card for a world event.
//
// @param world The WorldData for the card
// @param ref The WidgetRef used to access providers
// @param context The BuildContext for navigation
// @return A Card widget for the world
Widget _buildWorldCard(WorldData world, WidgetRef ref, BuildContext context) {
  final worldName = allWorldsConfig[world.id]?.name ?? 'Unknown World';

  return Card(
    color: Colors.white,
    elevation: defaultCardElevation,
    margin: const EdgeInsets.all(8.0),
    semanticContainer: true,
    child: InkWell(
      borderRadius: BorderRadius.circular(4.0),
      child: ListTile(
        leading: const Icon(Icons.map, size: 32.0, color: zdvOrange),
        title: Text(worldName),
        subtitle: const Text('Guest World'),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: zdvmMidBlue[100],
        ),
        onTap: () => _navigateToWorldDetail(world.id!, ref, context),
      ),
    ),
  );
}

// Builds a card specifically for Watopia.
//
// @param ref The WidgetRef used to access providers
// @param context The BuildContext for navigation
// @return A Card widget for Watopia
Widget _buildWatopiaCard(WidgetRef ref, BuildContext context) {
  return Card(
    color: Colors.white,
    elevation: defaultCardElevation,
    margin: const EdgeInsets.all(8.0),
    semanticContainer: true,
    child: InkWell(
      borderRadius: BorderRadius.circular(4.0),
      child: ListTile(
        leading: const Icon(Icons.map, size: 32.0, color: zdvYellow),
        title: Text(allWorldsConfig[1]?.name ?? 'Watopia'),
        subtitle: const Text('Always Available'),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: zdvmMidBlue[100],
        ),
        onTap: () => _navigateToWorldDetail(1, ref, context),
      ),
    ),
  );
}

// Navigates to the world detail screen for the specified world.
//
// @param worldId The ID of the world to show details for
// @param ref The WidgetRef used to access providers
// @param context The BuildContext for navigation
void _navigateToWorldDetail(int worldId, WidgetRef ref, BuildContext context) {
  final worldData = allWorldsConfig[worldId];
  if (worldData != null) {
    ref.read(selectedWorldProvider.notifier).worldSelect = worldData;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const WorldDetailScreen(),
      ),
    );
  }
}
