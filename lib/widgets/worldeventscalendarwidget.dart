import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:zwiftdataviewer/models/worlddata.dart';
import 'package:zwiftdataviewer/providers/world_calendar_provider.dart';

/// Improved calendar widget with colored day circles matching Zwift's design
class ImprovedWorldCalendarWidget extends ConsumerStatefulWidget {
  final Map<DateTime, List<WorldData>> worldData;

  const ImprovedWorldCalendarWidget(this.worldData, {super.key});

  /// Color mapping for world pairings (matching Zwift schedule image)
  static const Map<String, Color> pairingColors = {
    'London/Yorkshire': Color(0xFF1565C0), // Dark Blue
    'Makuri Islands/New York': Color(0xFFEC407A), // Pink
    'France/Paris': Color(0xFF1976D2), // Blue
    'Richmond/London': Color(0xFF000000), // Black
    'Innsbruck/Richmond': Color(0xFF4CAF50), // Green
    'Scotland/Makuri Islands': Color(0xFFFFA726), // Orange
    'Watopia': Color(0xFF26A69A), // Teal (always available)
  };

  /// Get the pairing name from the list of worlds
  static String getPairingName(List<WorldData> worlds) {
    if (worlds.isEmpty) return '';

    // Sort world names to create consistent pairing string
    final names = worlds.map((w) => w.name ?? '').toSet().toList()..sort();

    // Check against known pairings
    final pairingStr = names.join('/');

    // Match known pairings
    if ((names.contains('London') && names.contains('Yorkshire')) ||
        (names.contains('Yorkshire') && names.contains('London'))) {
      return 'London/Yorkshire';
    } else if ((names.contains('Makuri Islands') && names.contains('New York')) ||
               (names.contains('New York') && names.contains('Makuri Islands'))) {
      return 'Makuri Islands/New York';
    } else if ((names.contains('France') && names.contains('Paris')) ||
               (names.contains('Paris') && names.contains('France'))) {
      return 'France/Paris';
    } else if ((names.contains('Richmond') && names.contains('London')) ||
               (names.contains('London') && names.contains('Richmond'))) {
      return 'Richmond/London';
    } else if ((names.contains('Innsbruck') && names.contains('Richmond')) ||
               (names.contains('Richmond') && names.contains('Innsbruck'))) {
      return 'Innsbruck/Richmond';
    } else if ((names.contains('Scotland') && names.contains('Makuri Islands')) ||
               (names.contains('Makuri Islands') && names.contains('Scotland'))) {
      return 'Scotland/Makuri Islands';
    }

    return pairingStr;
  }

  /// Get the color for a list of worlds based on their pairing
  static Color getColorForWorlds(List<WorldData> worlds) {
    if (worlds.isEmpty) {
      return Colors.grey.shade200;
    }

    final pairingName = getPairingName(worlds);
    return pairingColors[pairingName] ?? Colors.grey.shade400;
  }

  @override
  ConsumerState<ImprovedWorldCalendarWidget> createState() =>
      _ImprovedWorldCalendarWidgetState();
}

class _ImprovedWorldCalendarWidgetState
    extends ConsumerState<ImprovedWorldCalendarWidget> {
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();
  }

  /// Get the primary color for a day based on its world pairing
  Color _getDayColor(DateTime day) {
    final normalizedDate = DateTime(day.year, day.month, day.day);
    final worlds = widget.worldData[normalizedDate];
    return ImprovedWorldCalendarWidget.getColorForWorlds(worlds ?? []);
  }

  /// Check if day is today
  bool _isToday(DateTime day) {
    final now = DateTime.now();
    return day.year == now.year && day.month == now.month && day.day == now.day;
  }

  /// Check if day is selected
  bool _isSelected(DateTime day) {
    final selected = ref.read(selectedWorldDayProvider);
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
    ref.read(selectedWorldDayProvider.notifier).selectDay(day);

    // Update events for the selected day
    final normalizedDate = DateTime(day.year, day.month, day.day);
    final worlds = widget.worldData[normalizedDate] ?? [];
    ref.read(worldEventsForDayProvider.notifier).setEventsForDay(worlds);
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
          // IconButton(
          //   icon: const Icon(Icons.chevron_left),
          //   onPressed: _previousMonth,
          //   iconSize: 32,
          // ),
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
          // IconButton(
          //   icon: const Icon(Icons.chevron_right),
          //   onPressed: _nextMonth,
          //   iconSize: 32,
          // ),
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
