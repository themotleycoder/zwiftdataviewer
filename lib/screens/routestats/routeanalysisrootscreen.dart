import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/theme.dart';
import 'routeanalysistabclimbsscreen.dart';
import 'routeanalysistabpowercolumnchartscreen.dart';
import 'routeanalysistabpowertimepiechartscreen.dart';
import 'routeanalysistabprofilechartscreen.dart';

class RouteAnalysisScreen extends ConsumerStatefulWidget {
  const RouteAnalysisScreen({super.key});

  @override
  RouteAnalysisScreenState createState() => RouteAnalysisScreenState();
}

class RouteAnalysisScreenState extends ConsumerState<RouteAnalysisScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final controller = TabController(length: 4, vsync: this);

    //final DetailedActivity detailedActivity = ref.watch(activityDetailProvider.notifier).activityDetail;

    // return Consumer<ActivityDetailDataModel>(
    //     builder: (context, myModel, child) {
    //   return Selector<ActivityDetailDataModel, bool>(
    //       selector: (context, model) => model.isLoading,
    //       builder: (context, isLoading, _) {
    //         if (isLoading) {
    //           return const Center(
    //             child: CircularProgressIndicator(
    //               key: AppKeys.activitiesLoading,
    //             ),
    //           );
    //         }
    return Column(children: <Widget>[
      TabBar(
        indicatorColor: Colors.transparent,
        unselectedLabelColor: zdvMidBlue,
        //Colors.white,
        labelColor: zdvmMidGreen[100],
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
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
          Tab(
            icon: Icon(Icons.landscape),
            // text: 'Climbs',
          ),
        ],
      ),
      Expanded(
          child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
        child: TabBarView(
          controller: controller,
          children: const <Widget>[
            RouteAnalysisProfileChartScreen(),
            RouteAnalysisWattsDataView(),
            RouteAnalysisPowerTimePieChartScreen(), // Fixed class name
            RouteAnalysisClimbsScreen(),
          ],
        ),
      ))
    ]);
  }
}
