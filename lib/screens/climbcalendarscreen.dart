import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zwiftdataviewer/models/climbdata.dart';
import 'package:zwiftdataviewer/providers/climb_calendar_provider.dart';
import 'package:zwiftdataviewer/providers/climb_select_provider.dart';
import 'package:zwiftdataviewer/utils/climbsconfig.dart';
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/widgets/climbeventscalendarwidget.dart';

import '../appkeys.dart';
import '../utils/constants.dart';

class ClimbCalendarScreen extends ConsumerWidget {
  const ClimbCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Map<DateTime, List<ClimbData>>> asyncClimbCalender =
        ref.watch(loadClimbCalendarProvider);

    return Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
      asyncClimbCalender.when(data: (Map<DateTime, List<ClimbData>> climbData) {
        return ClimbEventsCalendarWidget(ref, climbData);
      }, error: (Object error, StackTrace stackTrace) {
        print(error);
        return const Text('Error loading data');
      }, loading: () {
        return const Center(
          child: CircularProgressIndicator(
            key: AppKeys.activitiesLoading,
          ),
        );
      }),
      const SizedBox(height: 8.0),
      Expanded(child: _buildEventList(ref, context)),
    ]);
  }
}

Widget _buildEventList(WidgetRef ref, BuildContext context) {
  final List<ClimbData> selectedEvents = ref.watch(climbEventsForDayProvider);
  // ref.read(routeProvider.notifier).load();
  final List<Widget> list = selectedEvents
      .map((climb) => Card(
          color: Colors.white,
          elevation: defaultCardElevation,
          margin: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
          child: InkWell(
            child: ListTile(
                leading: const Icon(Icons.map, size: 32.0, color: zdvOrange),
                title: Text(allClimbsConfig[climb.id]!.name ?? "NA"),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: zdvmMidBlue[100],
                ),
                onTap: () {
                  ref.read(selectedClimbProvider.notifier).state =
                      allClimbsConfig[climb.id] as ClimbData;
                  launchMyUrl(allClimbsConfig[climb.id]!.url ?? "NA");
                }),
          )))
      .toList();

  return ListView(
    children: list,
  );
}

void launchMyUrl(String url) async {
  String site = url.substring(url.indexOf('//') + 2);
  String path = site.substring(site.indexOf('/'));
  site = site.substring(0, site.indexOf('/'));
  final Uri uri = Uri.https(site, path);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch $uri';
  }
}
