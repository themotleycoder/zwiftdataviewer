import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:zwiftdataviewer/models/worlddata.dart';
import 'package:zwiftdataviewer/providers/world_calendar_provider.dart';
import 'package:zwiftdataviewer/utils/constants.dart' as constants;

import '../utils/theme.dart';

class WorldEventsCalendarWidget extends StatelessWidget {
  final WidgetRef ref;
  final Map<DateTime, List<WorldData>> worldData;

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
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        // Hides the button to change calendar format
        titleCentered: true,
        // Centers the title
        leftChevronIcon: Opacity(opacity: 0.0, child: Container()),
        // Hides left arrow
        rightChevronIcon:
            Opacity(opacity: 0.0, child: Container()), // Hides right arrow
        // formatButtonTextStyle:
        //     const TextStyle().copyWith(color: Colors.white, fontSize: 16.0),
        // formatButtonDecoration: BoxDecoration(
        //   color: Colors.grey[400],
        //   borderRadius: BorderRadius.circular(8.0),
        // ),
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
        return _getEventsForDay(ref, worldData,
            DateTime.parse(formattedDateTime.replaceAll('Z', '')));
      },
      selectedDayPredicate: (day) {
        return isSameDay(ref.read(selectedWorldDayProvider), day);
      },
    );
  }

  _getEventsForSelectedDay(
      WidgetRef ref, Map<DateTime, List<WorldData>> worldData) {
    var data = _getEventsForDay(ref, worldData);
    ref.read(worldEventsForDayProvider.notifier).setEventsForDay(data ?? []);
  }

  _getEventsForDay(WidgetRef ref, Map<DateTime, List<WorldData>> worldData,
      [DateTime? date]) {
    final DateTime selectedDay = ref.read(selectedWorldDayProvider);
    DateTime? d = date;

    if (d == null) {
      d = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    } else {
      d = DateTime(d.year, d.month, d.day);
    }

    return worldData[d];
  }
}
