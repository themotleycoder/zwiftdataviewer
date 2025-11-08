import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_strava_api/api/streams.dart';
import 'package:flutter_strava_api/models/segmentEffort.dart';
import 'package:zwiftdataviewer/providers/activity_detail_provider.dart';
import 'package:zwiftdataviewer/providers/segment_streams_provider.dart';
import 'package:zwiftdataviewer/utils/constants.dart' as constants;
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/widgets/climb_profile_widget.dart';

/// Tab screen that displays segment efforts (climbs/KOMs) for the selected activity
///
/// This screen shows:
/// - All segment efforts from the activity
/// - Personal times and PRs
/// - Segment details including climb category
/// - KOM/QOM times for comparison
class RouteAnalysisClimbsScreen extends ConsumerWidget {
  const RouteAnalysisClimbsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get activity detail which contains segment efforts
    final activityDetail = ref.watch(stravaActivityDetailsProvider);

    if (activityDetail.segmentEfforts == null || activityDetail.segmentEfforts!.isEmpty) {
      return _buildNoSegmentsView(context);
    }

    // Filter to climb segments (exclude descents)
    final climbSegments = activityDetail.segmentEfforts!.where((effort) {
      final segment = effort.segment;
      if (segment == null) return false;

      // Exclude descents (negative average grade)
      if (segment.averageGrade != null && segment.averageGrade! < 0) {
        return false;
      }

      // Exclude segments with "descent" in the name
      final name = segment.name?.toLowerCase() ?? '';
      if (name.contains('descent') || name.contains('downhill')) {
        return false;
      }

      // Include if it has a climb category (Strava: 1=Cat4, 2=Cat3, 3=Cat2, 4=Cat1, 5=HC)
      if (segment.climbCategory != null && segment.climbCategory! >= 1) {
        return true;
      }

      // Include if name suggests it's a climb/KOM
      return name.contains('climb') ||
          name.contains('hill') ||
          name.contains('mountain') ||
          name.contains('kom') ||
          name.contains('qom') ||
          name.contains('alpe') ||
          name.contains('col') ||
          name.contains('epic') ||
          name.contains('volcano') ||
          name.contains('titans') ||
          name.contains('ven-top') ||
          name.contains('ventoux') ||
          name.contains('box hill') ||
          name.contains('leith') ||
          name.contains('innsbruck') ||
          name.contains('sgurr');
    }).toList();

    if (climbSegments.isEmpty) {
      return _buildNoClimbSegmentsView(context);
    }

    return _buildSegmentEffortsView(context, ref, climbSegments);
  }

  /// Builds the segment efforts view
  Widget _buildSegmentEffortsView(BuildContext context, WidgetRef ref, List<SegmentEffort> segments) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Summary card
        _buildSegmentSummaryCard(context, segments),
        const SizedBox(height: 16),

        // Individual segment efforts
        ...segments.map((effort) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildSegmentEffortCard(context, ref, effort),
          );
        }),
      ],
    );
  }

  /// Builds summary card for segment efforts
  Widget _buildSegmentSummaryCard(BuildContext context, List<SegmentEffort> segments) {
    final totalElevation = segments.fold<double>(
      0.0,
      (sum, effort) => sum + (effort.segment?.elevationHigh ?? 0.0) - (effort.segment?.elevationLow ?? 0.0),
    );

    final prCount = segments.where((effort) => effort.prRank == 1).length;

    return Card(
      elevation: 0,
      color: constants.tileBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.landscape, color: zdvmMidGreen[100], size: 24),
                const SizedBox(width: 8),
                Text(
                  'Climbs Completed',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryStat(
                  context,
                  'Segments',
                  '${segments.length}',
                  Icons.flag,
                ),
                _buildSummaryStat(
                  context,
                  'Total Climb',
                  '${totalElevation.toStringAsFixed(0)}m',
                  Icons.arrow_upward,
                ),
                _buildSummaryStat(
                  context,
                  'PRs',
                  '$prCount',
                  Icons.star,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a single summary statistic
  Widget _buildSummaryStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: zdvMidBlue, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: zdvmMidGreen[100],
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// Builds a card for a single segment effort
  Widget _buildSegmentEffortCard(
    BuildContext context,
    WidgetRef ref,
    SegmentEffort effort,
  ) {
    final segment = effort.segment;
    if (segment == null || segment.id == null) return const SizedBox.shrink();

    // Calculate elapsed time in readable format
    final elapsedSeconds = effort.elapsedTime ?? 0;
    final minutes = elapsedSeconds ~/ 60;
    final seconds = elapsedSeconds % 60;
    final timeString = '$minutes:${seconds.toString().padLeft(2, '0')}';

    final elevationGain = (segment.elevationHigh ?? 0.0) - (segment.elevationLow ?? 0.0);
    final isPR = effort.prRank == 1;

    // Fetch segment streams from Strava API to get the exact elevation profile
    final segmentStreamsAsync = ref.watch(segmentStreamsProvider(segment.id!));

    return segmentStreamsAsync.when(
      data: (segmentStreams) {
        // Extract elevation and gradient data from segment streams
        List<double>? elevationData;
        List<double>? gradientData;

        if (segmentStreams.altitude?.data != null) {
          elevationData = segmentStreams.altitude!.data!
              .map((e) => (e as num).toDouble())
              .toList();

          // Calculate gradients from elevation data
          gradientData = segmentStreams.calculateGradients();

          print('DEBUG: Segment ${segment.name} (ID: ${segment.id})');
          print('DEBUG: Fetched ${elevationData.length} elevation points');
          print('DEBUG: Calculated ${gradientData.length} gradient points');

          if (gradientData.isNotEmpty) {
            final minGrad = gradientData.reduce((a, b) => a < b ? a : b);
            final maxGrad = gradientData.reduce((a, b) => a > b ? a : b);
            final avgGrad = gradientData.reduce((a, b) => a + b) / gradientData.length;
            print('DEBUG: Gradient range: $minGrad% to $maxGrad%');
            print('DEBUG: Average gradient: ${avgGrad.toStringAsFixed(1)}%');
          }
        } else {
          print('DEBUG: No elevation data for segment ${segment.name}');
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: ClimbProfileWidget(
            segmentName: segment.name ?? 'Unknown Segment',
            distance: segment.distance ?? 0.0,
            elevationGain: elevationGain,
            averageGrade: segment.averageGrade ?? 0.0,
            maxGrade: segment.maximumGrade,
            timeString: timeString,
            isPR: isPR,
            elevationData: elevationData,
            gradientData: gradientData,
          ),
        );
      },
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: ClimbProfileWidget(
          segmentName: segment.name ?? 'Unknown Segment',
          distance: segment.distance ?? 0.0,
          elevationGain: elevationGain,
          averageGrade: segment.averageGrade ?? 0.0,
          maxGrade: segment.maximumGrade,
          timeString: timeString,
          isPR: isPR,
        ),
      ),
      error: (error, stack) {
        print('ERROR: Failed to load segment streams for ${segment.name}: $error');
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: ClimbProfileWidget(
            segmentName: segment.name ?? 'Unknown Segment',
            distance: segment.distance ?? 0.0,
            elevationGain: elevationGain,
            averageGrade: segment.averageGrade ?? 0.0,
            maxGrade: segment.maximumGrade,
            timeString: timeString,
            isPR: isPR,
          ),
        );
      },
    );
  }

  /// Builds view when no segments are found
  Widget _buildNoSegmentsView(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.landscape_outlined, color: Colors.grey[400], size: 64),
            const SizedBox(height: 16),
            Text(
              'No Segment Data',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This activity doesn\'t have segment effort data.\n\n'
              'This could be because:\n'
              '• Activity details haven\'t loaded yet\n'
              '• No segments were matched during the ride\n'
              '• Segment matching is disabled in Strava',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds view when no climb segments are found
  Widget _buildNoClimbSegmentsView(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.landscape_outlined, color: Colors.grey[400], size: 64),
            const SizedBox(height: 16),
            Text(
              'No Climb Segments',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No climb or KOM segments were completed during this activity.\n\n'
              'The activity has segments, but none are categorized as climbs.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
