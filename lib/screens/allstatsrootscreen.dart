import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zwiftdataviewer/screens/AllStatsScreenDistElev.dart';
import '../models/ActivitiesDataModel.dart';
import '../stravalib/Models/activity.dart';
import '../utils/theme.dart';
import 'allstatsscreenscatter.dart';

class AllStatsRootScreen extends StatefulWidget {
  const AllStatsRootScreen({super.key});

  @override
  _AllStatsRootScreenState createState() => _AllStatsRootScreenState();
}

class _AllStatsRootScreenState extends State<AllStatsRootScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    // Map<String, double> summaryData;

    final controller = TabController(length: 3, vsync: this);

    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (context) => SummaryActivitySelectDataModel()),
        ],
        child: Selector<ActivitiesDataModel, List<SummaryActivity>>(
            selector: (_, model) => model.dateFilteredActivities,
            builder: (context, activities, _) {
              // summaryData = SummaryData.createSummaryData(activities);
              return Column(children: <Widget>[
                TabBar(
                  indicatorColor: Colors.transparent,
                  unselectedLabelColor: zdvmMidBlue[100],
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
                ),
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.fromLTRB(4, 0, 4, 4),
                  child: TabBarView(
                    controller: controller,
                    children: const <Widget>[
                      Card(
                        elevation: 0,
                        child: AllStatsScreenDistElev(),
                      ),
                      Card(
                        elevation: 0,
                        child: AllStatsScreenScatter(),
                      ),
                      Card(
                        elevation: 0,
                        // child: AllStatsScreenDistElev(),
                      ),
                    ],
                  ),
                ))
              ]);
            }));
    // });
  }
}