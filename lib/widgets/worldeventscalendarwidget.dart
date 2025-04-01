import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:zwiftdataviewer/models/worlddata.dart';
import 'package:zwiftdataviewer/providers/world_calendar_provider.dart';
import 'package:zwiftdataviewer/utils/constants.dart' as constants;
import 'package:zwiftdataviewer/utils/theme.dart';

// A widget that displays a calendar of Zwift world events.
//
// This widget shows a calendar with markers for days that have scheduled
// Zwift worlds. When a day is selected, it updates the worldEventsForDayProvider
// with the events for that day.
class WorldEventsCalendarWidget extends StatelessWidget {
  // The WidgetRef used to access providers.
  final WidgetRef ref;

  // The map of dates to world events.
  final Map<DateTime, List<WorldData>> worldData;

  // Creates a WorldEventsCalendarWidget.
  //
  // @param ref The WidgetRef used to access providers
  // @param worldData The map of dates to world events
  // @param key An optional key for this widget
  const WorldEventsCalendarWidget(this.ref, this.worldData, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: const CalendarStyle(
        outsideDaysVisible: false,
        isTodayHighlighted: true,
        todayDecoration:
            BoxDecoration(shape: BoxShape.circle, color: zdvLgtBlue),
        selectedDecoration:
            BoxDecoration(shape: BoxShape.circle, color: zdvOrange),
        markerDecoration:
            BoxDecoration(shape: BoxShape.circle, color: zdvMidBlue),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekendStyle:
            const TextStyle().copyWith(color: constants.calenderColor),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible:
            false, // Hides the button to change calendar format
        titleCentered: true, // Centers the title
        leftChevronVisible: false, // Hides left arrow
        rightChevronVisible: false, // Hides right arrow
      ),
      firstDay: DateTime.utc(2010, 10, 16),
      focusedDay: DateTime.now(),
      lastDay: DateTime.utc(2030, 3, 14),
      onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
        var day = ref.read(selectedWorldDayProvider);
        if (!isSameDay(day, selectedDay)) {
          ref.read(selectedWorldDayProvider.notifier).selectDay(selectedDay);
        }
        _getEventsForSelectedDay(ref, worldData);
      },
      eventLoader: (DateTime dateTime) {
        final formattedDateTime =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
        final DateTime parsedDate =
            DateTime.parse(formattedDateTime.replaceAll('Z', ''));
        return _getEventsForDay(ref, worldData, parsedDate) ?? [];
      },
      selectedDayPredicate: (day) {
        return isSameDay(ref.read(selectedWorldDayProvider), day);
      },
    );
  }

  // Updates the worldEventsForDayProvider with the events for the selected day.
  //
  // @param ref The WidgetRef used to access providers
  // @param worldData The map of dates to world events
  void _getEventsForSelectedDay(
      WidgetRef ref, Map<DateTime, List<WorldData>> worldData) {
    var data = _getEventsForDay(ref, worldData);
    ref.read(worldEventsForDayProvider.notifier).setEventsForDay(data ?? []);
  }

  // Gets the events for a specific day.
  //
  // @param ref The WidgetRef used to access providers
  // @param worldData The map of dates to world events
  // @param date Optional date to get events for. If null, uses the selected day
  // @return The list of world events for the day, or null if none
  List<WorldData>? _getEventsForDay(
      WidgetRef ref, Map<DateTime, List<WorldData>> worldData,
      [DateTime? date]) {
    final DateTime selectedDay = ref.read(selectedWorldDayProvider);
    final DateTime d = date != null
        ? DateTime(date.year, date.month, date.day)
        : DateTime(selectedDay.year, selectedDay.month, selectedDay.day);

    return worldData[d];
  }
}
