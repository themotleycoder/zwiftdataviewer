import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/providers/segment_effort_provider.dart';
import 'package:zwiftdataviewer/screens/segments/segment_detail_screen.dart';
import 'package:zwiftdataviewer/utils/constants.dart';
import 'package:zwiftdataviewer/utils/conversions.dart';
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/utils/ui_helpers.dart';

class SegmentsScreen extends ConsumerWidget {
  const SegmentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uniqueSegmentsAsync = ref.watch(uniqueSegmentsProvider);
    Conversions.units(ref);

    return Scaffold(
      appBar: UIHelpers.buildAppBar('Segments'),
      body: uniqueSegmentsAsync.when(
        data: (segments) {
          if (segments.isEmpty) {
            return const Center(
              child: Text(
                'No segments found. Complete some rides with segments to see them here.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: segments.length,
            itemBuilder: (context, index) {
              final segment = segments[index];
              final segmentId = segment['segment_id'] as int;
              final segmentName = segment['segment_name'] as String;
              final bestTime = segment['best_time'] as int;
              final effortCount = segment['effort_count'] as int;
              final bestPrRank = segment['best_pr_rank'] as int?;
              final averageGrade = segment['average_grade'] as double?;
              final climbCategory = segment['climb_category'] as int?;

              // Format the best time
              final formattedTime = UIHelpers.formatDuration(bestTime);

              // Format the climb category
              String categoryText = '';
              if (climbCategory != null && climbCategory > 0) {
                final Map<int, String> climbingCAT = {1: '4', 2: '3', 3: '2', 4: '1', 5: 'HC'};
                categoryText = 'Cat ${climbingCAT[climbCategory] ?? climbCategory}';
              }

              // Format the average grade
              String gradeText = '';
              if (averageGrade != null) {
                gradeText = '${averageGrade.toStringAsFixed(1)}%';
              }

              return Card(
                elevation: defaultCardElevation,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(
                    segmentName,
                    style: headerFontStyle,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.timer,
                            size: 16,
                            color: zdvmMidBlue[100],
                          ),
                          const SizedBox(width: 4),
                          Text('Best: $formattedTime'),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.repeat,
                            size: 16,
                            color: zdvmMidBlue[100],
                          ),
                          const SizedBox(width: 4),
                          Text('$effortCount ${effortCount == 1 ? 'effort' : 'efforts'}'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (gradeText.isNotEmpty) ...[
                            Icon(
                              Icons.trending_up,
                              size: 16,
                              color: zdvmMidBlue[100],
                            ),
                            const SizedBox(width: 4),
                            Text(gradeText),
                            const SizedBox(width: 16),
                          ],
                          if (categoryText.isNotEmpty) ...[
                            Icon(
                              Icons.landscape,
                              size: 16,
                              color: zdvmMidBlue[100],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              categoryText,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: climbCategory != null && climbCategory > 2
                                    ? Colors.red[700]
                                    : Colors.green[700],
                              ),
                            ),
                          ],
                          if (bestPrRank != null && bestPrRank > 0) ...[
                            const Spacer(),
                            _buildPrBadge(bestPrRank),
                          ],
                        ],
                      ),
                    ],
                  ),
                  onTap: () {
                    // Set the selected segment ID
                    ref.read(selectedSegmentIdProvider.notifier).state = segmentId;
                    
                    // Navigate to the segment detail screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SegmentDetailScreen(
                          segmentId: segmentId,
                          segmentName: segmentName,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error loading segments: $error'),
        ),
      ),
    );
  }

  Widget _buildPrBadge(int prRank) {
    Color color;
    String text;

    switch (prRank) {
      case 1:
        color = zdvYellow;
        text = 'PR';
        break;
      case 2:
        color = Colors.grey[400]!;
        text = '2';
        break;
      case 3:
        color = zdvOrange;
        text = '3';
        break;
      default:
        color = Colors.transparent;
        text = '';
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
