import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:zwiftdataviewer/models/climbdata.dart';
import 'package:zwiftdataviewer/providers/climb_calendar_provider.dart';

/// Improved calendar widget for climbs with colored day circles
class ImprovedClimbCalendarWidget extends ConsumerStatefulWidget {
  final Map<DateTime, List<ClimbData>> climbData;

  const ImprovedClimbCalendarWidget(this.climbData, {super.key});

  @override
  ConsumerState<ImprovedClimbCalendarWidget> createState() =>
      _ImprovedClimbCalendarWidgetState();
}

class _ImprovedClimbCalendarWidgetState
    extends ConsumerState<ImprovedClimbCalendarWidget> {
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();
  }

  /// Color mapping for different climbs
  static const Map<String, Color> climbColors = {
    'Alpe du Zwift': Color(0xFF1976D2), // Blue
    'AdZ': Color(0xFF1976D2), // Blue
    'Ventoux': Color(0xFF1565C0), // Dark Blue
    'Ven-Top': Color(0xFF1565C0), // Dark Blue
    'Radio Tower': Color(0xFF4CAF50), // Green
    'Epic KOM': Color(0xFFEC407A), // Pink
    'Innsbruck KOM': Color(0xFF4CAF50), // Green
    'Box Hill': Color(0xFF1565C0), // Dark Blue
    'Yorkshire KOM': Color(0xFF1565C0), // Dark Blue
    'Fuego Flats': Color(0xFFFFA726), // Orange
    'Volcano': Color(0xFFF44336), // Red
    'Titans Grove': Color(0xFF26A69A), // Teal
    'Jungle Circuit': Color(0xFF66BB6A), // Light Green
  };

  /// Get the primary color for a day based on its climbs
  Color _getDayColor(DateTime day) {
    final normalizedDate = DateTime(day.year, day.month, day.day);
    final climbs = widget.climbData[normalizedDate];

    if (climbs == null || climbs.isEmpty) {
      return Colors.grey.shade200;
    }

    // Return the color of the first climb
    final climbName = climbs.first.name ?? '';

    // Try to match climb name
    for (final entry in climbColors.entries) {
      if (climbName.contains(entry.key)) {
        return entry.value;
      }
    }

    return Colors.grey.shade400;
  }

  /// Check if day is today
  bool _isToday(DateTime day) {
    final now = DateTime.now();
    return day.year == now.year && day.month == now.month && day.day == now.day;
  }

  /// Check if day is selected
  bool _isSelected(DateTime day) {
    final selected = ref.read(selectedClimbDayProvider);
    return day.year == selected.year &&
        day.month == selected.month &&
        day.day == selected.day;
  }

  /// Navigate to previous month
  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  /// Navigate to next month
  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  /// Handle day selection
  void _onDaySelected(DateTime day) {
    ref.read(selectedClimbDayProvider.notifier).selectDay(day);

    // Update events for the selected day
    final normalizedDate = DateTime(day.year, day.month, day.day);
    final climbs = widget.climbData[normalizedDate] ?? [];
    ref.read(climbEventsForDayProvider.notifier).setEventsForDay(climbs);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildWeekdayHeaders(),
        _buildCalendarGrid(),
        const SizedBox(height: 24),
      ],
    );
  }

  /// Build the month/year header with navigation
  Widget _buildHeader() {
    final monthYear = DateFormat('MMMM yyyy').format(_focusedMonth);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              monthYear,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build weekday headers (M T W T F S S)
  Widget _buildWeekdayHeaders() {
    const weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekdays
            .map((day) => SizedBox(
                  width: 48,
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  /// Build the calendar grid with colored circles
  Widget _buildCalendarGrid() {
    // Get first and last day of the month
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);

    // Calculate starting weekday (0 = Monday, 6 = Sunday)
    int startWeekday = firstDay.weekday - 1; // Convert to 0-based index

    // Build list of all days to display
    List<DateTime?> days = [];

    // Add empty cells for days before month starts
    for (int i = 0; i < startWeekday; i++) {
      days.add(null);
    }

    // Add all days of the month
    for (int day = 1; day <= lastDay.day; day++) {
      days.add(DateTime(_focusedMonth.year, _focusedMonth.month, day));
    }

    // Build grid
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          if (day == null) {
            return const SizedBox.shrink();
          }

          final color = _getDayColor(day);
          final isToday = _isToday(day);
          final isSelected = _isSelected(day);

          return _buildDayCircle(day, color, isToday, isSelected);
        },
      ),
    );
  }

  /// Build individual day circle
  Widget _buildDayCircle(
    DateTime day,
    Color color,
    bool isToday,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => _onDaySelected(day),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: isToday
              ? Border.all(color: Colors.orange, width: 3)
              : (isSelected
                  ? Border.all(color: Colors.white, width: 3)
                  : null),
        ),
        child: Center(
          child: Text(
            day.day.toString().padLeft(2, '0'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color.computeLuminance() > 0.5
                  ? Colors.black
                  : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
