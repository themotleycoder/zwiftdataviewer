import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/screens/AllStatsScreenDistElev.dart';

import '../utils/constants.dart';
import '../utils/theme.dart';
import 'allstatsscreenscatter.dart';

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
    // Map<String, double> summaryData;

    final controller = TabController(length: 3, vsync: this);
    // final activities = ref.watch(activitiesProvider);

    // return MultiProvider(
    //     providers: [
    //       ChangeNotifierProvider(
    //           create: (context) => SummaryActivitySelectDataModel()),
    //     ],
    //     child: Selector<ActivitiesDataModel, List<SummaryActivity>>(
    //         selector: (_, model) => model.dateFilteredActivities,
    //         builder: (context, activities, _) {
    //           //summaryData = stats.SummaryData.createSummaryData(activities);
              return Column(children: <Widget>[
                Container(
                    color: zdvMidBlue,
                    child: TabBar(
                      indicatorColor: Colors.transparent,
                      unselectedLabelColor: Colors.white,
                      labelColor: zdvmOrange[100],
                      indicatorSize: TabBarIndicatorSize.tab,
                      controller: controller,
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
                          icon: Icon(Icons.schedule),
                          // text: 'Time',
                        ),
                      ],
                    )),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
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
                        // child: AllStatsScreenDistElev(),
                      ),
                    ],
                  ),
                ))
              ]);
            // }));
    // });
  }
}
