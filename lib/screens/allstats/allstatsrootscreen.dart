import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/screens/allstats/allstatsscreentabdistancesummary.dart';
import 'package:zwiftdataviewer/screens/allstats/allstatsscreentabdistelev.dart';
import 'package:zwiftdataviewer/screens/allstats/allstatsscreentabheartsummary.dart';
import 'package:zwiftdataviewer/screens/allstats/allstatsscreentabscatter.dart';
import 'package:zwiftdataviewer/screens/allstats/allstatsscreentabwattssummary.dart';
import 'package:zwiftdataviewer/utils/theme.dart';

// A screen that displays various statistics tabs.
//
// This screen serves as a container for different statistics views,
// allowing the user to switch between them using a tab bar.
class AllStatsRootScreen extends ConsumerStatefulWidget {
  // Creates an AllStatsRootScreen instance.
  //
  // @param key An optional key for this widget
  const AllStatsRootScreen({super.key});

  @override
  ConsumerState<AllStatsRootScreen> createState() => _AllStatsRootScreenState();
}

// The state for the AllStatsRootScreen.
//
// This state manages the tab controller and builds the tab bar and tab views.
class _AllStatsRootScreenState extends ConsumerState<AllStatsRootScreen>
    with TickerProviderStateMixin {
  // The tab controller for managing the tabs.
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      TabBar(
        indicatorColor: Colors.transparent,
        unselectedLabelColor: zdvMidBlue,
        labelColor: zdvmMidGreen[100],
        indicatorSize: TabBarIndicatorSize.tab,
        controller: _tabController,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(
            icon: Tooltip(
              message: 'Elevation profile',
              child: Icon(Icons.terrain),
            ),
          ),
          Tab(
            icon: Tooltip(
              message: 'Power data',
              child: Icon(Icons.bolt),
            ),
          ),
          Tab(
            icon: Tooltip(
              message: 'Heart rate data',
              child: Icon(Icons.favorite_border),
            ),
          ),
          Tab(
            icon: Tooltip(
              message: 'Distance summary',
              child: Icon(Icons.route),
            ),
          ),
          Tab(
            icon: Tooltip(
              message: 'Watts summary',
              child: Icon(Icons.electric_bolt),
            ),
          ),
        ],
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
          child: TabBarView(
            controller: _tabController,
            children: const <Widget>[
              AllStatsScreenTabDistElev(),
              AllStatsScreenTabScatter(),
              AllStatsScreenTabHeartSummary(),
              AllStatsScreenTabDistanceSummary(),
              AllStatsScreenTabWattsSummary(),
            ],
          ),
        ),
      )
    ]);
  }
}
