import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:zwiftdataviewer/screens/worlddetailscreen.dart';
import 'package:zwiftdataviewer/utils/constants.dart' as constants;
import 'package:zwiftdataviewer/utils/theme.dart';
import 'package:zwiftdataviewer/utils/worlddata.dart';

import '../appkeys.dart';
import '../providers/route_provider.dart';
import '../providers/world_calendar_provider.dart';
import '../providers/world_select_provider.dart';
import '../utils/constants.dart';

class RoutesScreen extends ConsumerWidget {
  const RoutesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<Map<DateTime, List<WorldData>>> asyncWorldCalender =
        ref.watch(loadWorldCalendarProvider);

    return const Column(mainAxisSize: MainAxisSize.max, children: <Widget>[

    ]);
  }
}