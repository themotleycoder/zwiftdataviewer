import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/models/summary_activity.dart';
import 'package:intl/intl.dart';
import 'package:zwiftdataviewer/providers/activity_select_provider.dart';
import 'package:zwiftdataviewer/providers/tabs_provider.dart';
import 'package:zwiftdataviewer/providers/weekly_dashboard_provider.dart';
import 'package:zwiftdataviewer/screens/homescreen.dart';
import 'package:zwiftdataviewer/screens/ridedetailscreen.dart';
import 'package:zwiftdataviewer/utils/constants.dart' as constants;
import 'package:zwiftdataviewer/utils/conversions.dart';
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/widgets/weekly_bar_chart.dart';

class DashboardHomeScreen extends ConsumerWidget {
  const DashboardHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardData = ref.watch(weeklyDashboardProvider);

    return dashboardData.when(
      data: (data) => _buildDashboard(context, ref, data),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: zdvOrange),
            const SizedBox(height: 16),
            Text('Error loading dashboard: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(weeklyDashboardProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, WidgetRef ref, WeeklyDashboardData data) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Weekly Goal Section
          _buildWeeklyGoalSection(context, ref, data),

          const SizedBox(height: 16),

          // Weekly Bar Chart
          WeeklyBarChart(dailyData: data.dailyData),

          const SizedBox(height: 24),

          // Activities Section Header
          _buildActivitiesHeader(context, ref),

          // Recent Activities List
          _buildRecentActivitiesList(context, ref, data.recentActivities),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildWeeklyGoalSection(BuildContext context, WidgetRef ref, WeeklyDashboardData data) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: constants.tileBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Goal header with edit button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'WEEKLY GOAL',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                  letterSpacing: 1.2,
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit, size: 18, color: Colors.grey[600]),
                onPressed: () => _showEditGoalDialog(context, ref),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Goal progress
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${data.weeklyGoal.round()} km',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: zdvDrkBlue,
                ),
              ),
              if (data.goalMet)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.check_circle,
                    color: zdvMidGreen,
                    size: 28,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: data.progress,
              minHeight: 32,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColor(data.progress),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Current progress text
          Text(
            '${data.totalDistance.round()}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: zdvDrkBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesHeader(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Activities',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: zdvDrkBlue,
            ),
          ),
          TextButton.icon(
            onPressed: () {
              // Navigate to full activities list
              ref.read(homeTabsNotifier.notifier).setIndex(HomeScreenTab.activities.index);
            },
            icon: const Icon(Icons.arrow_forward, color: zdvMidBlue, size: 20),
            label: const Text(
              'View All',
              style: TextStyle(color: zdvMidBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitiesList(BuildContext context, WidgetRef ref, List<SummaryActivity> activities) {
    if (activities.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.directions_bike, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No activities yet',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    final units = Conversions.units(ref);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: constants.tileBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.grey[300],
        ),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: zdvMidBlue,
              child: Text(
                activity.name.substring(0, 2).toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              activity.name,
              style: const TextStyle(
                color: zdvDrkBlue,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Row(
              children: [
                Text(
                  '${Conversions.metersToDistance(ref, activity.distance).toStringAsFixed(1)} ${units['distance']}',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
                const SizedBox(width: 12),
                Text(
                  DateFormat('MMM d').format(activity.startDateLocal),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: zdvMidBlue, size: 16),
            onTap: () {
              ref.read(detailTabsNotifier.notifier).setIndex(0);
              ref.read(selectedActivityProvider.notifier).selectActivity(activity);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DetailScreen(),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) return zdvMidGreen;
    if (progress >= 0.75) return zdvYellow;
    if (progress >= 0.5) return zdvOrange;
    return zdvMidBlue;
  }

  void _showEditGoalDialog(BuildContext context, WidgetRef ref) {
    final currentGoal = ref.read(weeklyGoalProvider);
    final controller = TextEditingController(text: currentGoal.round().toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Weekly Goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Distance (km)',
            suffixText: 'km',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newGoal = double.tryParse(controller.text);
              if (newGoal != null && newGoal > 0) {
                ref.read(weeklyGoalProvider.notifier).state = newGoal;
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
