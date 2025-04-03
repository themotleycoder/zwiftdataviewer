import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/providers/activity_select_provider.dart';
import 'package:zwiftdataviewer/providers/segment_effort_provider.dart';
import 'package:zwiftdataviewer/utils/constants.dart';
import 'package:zwiftdataviewer/utils/conversions.dart';
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/utils/ui_helpers.dart';

class SegmentDetailScreen extends ConsumerWidget {
  final int segmentId;
  final String segmentName;

  const SegmentDetailScreen({
    Key? key,
    required this.segmentId,
    required this.segmentName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ensure the selected segment ID is set
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentSelectedId = ref.read(selectedSegmentIdProvider);
      if (currentSelectedId != segmentId) {
        ref.read(selectedSegmentIdProvider.notifier).state = segmentId;
      }
    });
    
    final segmentEffortsAsync = ref.watch(segmentEffortsProvider);
    final statisticsAsync = ref.watch(segmentEffortsStatisticsProvider(segmentId));
    final Map<String, String> units = Conversions.units(ref);

    return Scaffold(
      appBar: UIHelpers.buildAppBar(
        segmentName,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
      ),
      body: Column(
        children: [
          // Statistics card
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: statisticsAsync.when(
              data: (stats) {
                if (stats.isEmpty) {
                  return const SizedBox.shrink();
                }

                final count = stats['count'] as int? ?? 0;
                final bestTime = stats['best_time'] as int? ?? 0;
                final averageTime = stats['average_time'] as double? ?? 0;
                final firstAttempt = stats['first_attempt'] as String? ?? '';
                final lastAttempt = stats['last_attempt'] as String? ?? '';
                final averagePower = stats['average_power'] as double? ?? 0;
                final averageHeartrate = stats['average_heartrate'] as double? ?? 0;

                return Card(
                  elevation: defaultCardElevation,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Segment Statistics',
                          style: headerFontStyle,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatItem(
                              'Attempts',
                              count.toString(),
                              Icons.repeat,
                            ),
                            _buildStatItem(
                              'Best Time',
                              UIHelpers.formatDuration(bestTime),
                              Icons.timer,
                            ),
                            _buildStatItem(
                              'Average Time',
                              UIHelpers.formatDuration(averageTime.toInt()),
                              Icons.access_time,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (averagePower > 0)
                              _buildStatItem(
                                'Avg Power',
                                '${averagePower.toInt()} W',
                                Icons.flash_on,
                              ),
                            if (averageHeartrate > 0)
                              _buildStatItem(
                                'Avg HR',
                                '${averageHeartrate.toInt()} bpm',
                                Icons.favorite,
                                color: Colors.red,
                              ),
                            const Spacer(),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          'First attempt: ${_formatDate(firstAttempt)}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          'Last attempt: ${_formatDate(lastAttempt)}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const Card(
                elevation: defaultCardElevation,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, stackTrace) => Card(
                elevation: defaultCardElevation,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error loading statistics: $error'),
                ),
              ),
            ),
          ),

          // Title for efforts list
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Text(
                  'All Attempts',
                  style: headerFontStyle.copyWith(fontSize: 18),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
              ],
            ),
          ),
          
          // Efforts list
          Expanded(
            child: segmentEffortsAsync.when(
              data: (efforts) {
                if (efforts.isEmpty) {
                  return UIHelpers.buildEmptyStateWidget(
                    'No segment efforts found.',
                    icon: Icons.landscape,
                  );
                }

                return ListView.builder(
                  itemCount: efforts.length,
                  itemBuilder: (context, index) {
                    final extendedEffort = efforts[index];
                    final effort = extendedEffort.effort;
                    final activityId = extendedEffort.activityId;
                    final elapsedTime = effort.elapsedTime ?? 0;
                    final startDate = effort.startDate;
                    final averageWatts = effort.averageWatts;
                    final averageHeartrate = effort.averageHeartrate;
                    final prRank = effort.prRank;

                    return Card(
                      elevation: defaultCardElevation,
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        leading: _buildRankIndicator(index + 1, prRank),
                        title: Row(
                          children: [
                            Text(
                              UIHelpers.formatDuration(elapsedTime),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _formatDate(startDate ?? ''),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Row(
                          children: [
                            if (averageWatts != null) ...[
                              Icon(
                                Icons.flash_on,
                                size: 16,
                                color: zdvmMidBlue[100],
                              ),
                              const SizedBox(width: 4),
                              Text('${averageWatts.toInt()} W'),
                              const SizedBox(width: 16),
                            ],
                            if (averageHeartrate != null) ...[
                              const Icon(
                                Icons.favorite,
                                size: 16,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text('${averageHeartrate.toInt()} bpm'),
                            ],
                          ],
                        ),
                        onTap: () {
                          // Navigate to activity detail screen
                          if (activityId != 0) {
                            // Set the selected activity ID
                            ref.read(selectedActivityProvider.notifier).selectActivityById(activityId);
                            
                            // Navigate to the activity detail screen
                            Navigator.pushNamed(context, '/detail');
                          }
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Text('Error loading segment efforts: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(
          icon,
          color: color ?? zdvmMidBlue[100],
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildRankIndicator(int rank, int? prRank) {
    Color backgroundColor;
    Color textColor = Colors.white;

    if (rank == 1) {
      backgroundColor = zdvYellow;
    } else if (rank == 2) {
      backgroundColor = Colors.grey[400]!;
    } else if (rank == 3) {
      backgroundColor = zdvOrange;
    } else {
      backgroundColor = zdvmMidBlue[100]!;
    }

    // If it's a PR, add a star or trophy icon
    Widget? badge;
    if (prRank != null && prRank > 0 && prRank <= 3) {
      badge = Positioned(
        right: 0,
        top: 0,
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: backgroundColor, width: 1),
          ),
          child: Icon(
            Icons.star,
            size: 12,
            color: prRank == 1 ? zdvYellow : (prRank == 2 ? Colors.grey[400] : zdvOrange),
          ),
        ),
      );
    }

    return Stack(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              rank.toString(),
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        if (badge != null) badge,
      ],
    );
  }

  String _formatDate(String isoDate) {
    if (isoDate.isEmpty) return '';
    
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return isoDate;
    }
  }
}
