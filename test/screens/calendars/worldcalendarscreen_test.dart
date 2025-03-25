import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:zwiftdataviewer/models/worlddata.dart';
import 'package:zwiftdataviewer/providers/world_calendar_provider.dart';
import 'package:zwiftdataviewer/screens/calendars/worldcalendarscreen.dart';
import 'package:zwiftdataviewer/utils/worldsconfig.dart';

// Mock data for testing
final mockWorldData = {
  DateTime(2025, 3, 24): [
    const WorldData(1, GuestWorldId.watopia, 'Watopia',
        'https://zwiftinsider.com/watopia/'),
    const WorldData(
        3, GuestWorldId.london, 'London', 'https://zwiftinsider.com/london/'),
  ],
  DateTime(2025, 3, 25): [
    const WorldData(2, GuestWorldId.richmond, 'Richmond',
        'https://zwiftinsider.com/richmond/'),
  ],
};

void main() {
  testWidgets('WorldCalendarScreen shows events for current day',
      (WidgetTester tester) async {
    // Create a test provider container with overrides
    final container = ProviderContainer(
      overrides: [
        // Override the loadWorldCalendarProvider to return mock data
        loadWorldCalendarProvider.overrideWith((ref) async => mockWorldData),
      ],
    );

    // Add a listener to the worldEventsForDayProvider to set the events
    // This simulates what happens in the real app when the calendar loads
    container.listen<DateTime>(
      selectedWorldDayProvider,
      (previous, current) {
        final events =
            mockWorldData[DateTime(current.year, current.month, current.day)] ??
                [];
        container
            .read(worldEventsForDayProvider.notifier)
            .setEventsForDay(events);
      },
    );

    // Build our app and trigger a frame
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: WorldCalendarScreen(),
          ),
        ),
      ),
    );

    // Initial load shows loading indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for the future to complete
    await tester.pumpAndSettle();

    // After loading, the calendar should be visible
    expect(find.byType(TableCalendar), findsOneWidget);

    // The events for the current day should be loaded automatically
    // and displayed in the list
    expect(find.text('Watopia'), findsAtLeastNWidgets(1));
    expect(find.text('London'), findsOneWidget);

    // Verify that cards are shown
    expect(find.byType(Card), findsAtLeastNWidgets(2));
  });
}
