import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/screens/AllStatsScreenDistElev.dart';
import 'package:zwiftdataviewer/screens/allstatsscreenheartsummary.dart';

import '../utils/constants.dart';
import '../utils/theme.dart';
import 'allstatsscreendistancesummary.dart';
import 'allstatsscreenscatter.dart';
import 'allstatsscreenwattssummary.dart';

class AllStatsRootScreen extends ConsumerStatefulWidget {
  const AllStatsRootScreen({super.key});

  @override
  ConsumerState<AllStatsRootScreen> createState() {
    return _AllStatsRootScreenState();
  }
}

class _AllStatsRootScreenState extends ConsumerState<AllStatsRootScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final controller = TabController(length: 5, vsync: this);

    return Column(children: <Widget>[
      Container(
          color: const Color(0xFFFCFCFF),
          child: TabBar(
            indicatorColor: Colors.transparent,
            unselectedLabelColor: zdvMidBlue,//Colors.white,
            labelColor: zdvmMidGreen[100],
            indicatorSize: TabBarIndicatorSize.tab,
            controller: controller,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(
                icon: Icon(Icons.terrain),
                // text: 'Profile',
              ),
              Tab(
                icon: Icon(Icons.bolt),
                // text: 'Power',
              ),
              Tab(
                icon: Icon(Icons.favorite_border),
                // text: 'Time',
              ),
              Tab(
                icon: Icon(Icons.route),
                // text: 'Time',
              ),
              Tab(
                icon: Icon(Icons.electric_bolt),
                // text: 'Time',
              ),
            ],
          )),
      Expanded(
          child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
        child: TabBarView(
          controller: controller,
          children: const <Widget>[
            Card(
              elevation: defaultCardElevation,
              child: AllStatsScreenDistElev(),
            ),
            Card(
              elevation: defaultCardElevation,
              child: AllStatsScreenScatter(),
            ),
            Card(
              elevation: defaultCardElevation,
              child: AllStatsScreenHeartSummary(),
            ),
            Card(
              elevation: defaultCardElevation,
              child: AllStatsScreenDistanceSummary(),
            ),
            Card(
              elevation: defaultCardElevation,
              child: AllStatsScreenWattsSummary(),
            ),
          ],
        ),
      ))
    ]);
  }
}
