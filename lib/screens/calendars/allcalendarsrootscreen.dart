import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/screens/calendars/climbcalendarscreen.dart';
import 'package:zwiftdataviewer/screens/calendars/worldcalendarscreen.dart';

import '../../utils/theme.dart';

class AllCalendarsRootScreen extends ConsumerStatefulWidget {
  const AllCalendarsRootScreen({super.key});

  @override
  ConsumerState<AllCalendarsRootScreen> createState() {
    return _AllStatsRootScreenState();
  }
}

class _AllStatsRootScreenState extends ConsumerState<AllCalendarsRootScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final controller = TabController(length: 2, vsync: this);

    return Column(children: <Widget>[
      TabBar(
        indicatorColor: Colors.transparent,
        unselectedLabelColor: zdvMidBlue,
        //Colors.white,
        labelColor: zdvmMidGreen[100],
        indicatorSize: TabBarIndicatorSize.tab,
        controller: controller,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(
            icon: Icon(Icons.language),
            // text: 'Profile',
          ),
          Tab(
            icon: Icon(Icons.terrain),
            // text: 'Power',
          ),
        ],
      ),
      Expanded(
          child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
        child: TabBarView(
          controller: controller,
          children: const <Widget>[
            WorldCalendarScreen(),
            ClimbCalendarScreen(),
            // ),
          ],
        ),
      ))
    ]);
  }
}
