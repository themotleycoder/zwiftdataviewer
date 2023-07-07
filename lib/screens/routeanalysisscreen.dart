import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/screens/routeanalysispowercolumnchartscreen.dart';
import 'package:zwiftdataviewer/screens/routeanalysispowertimepiechartscreen.dart';
import 'package:zwiftdataviewer/screens/routeanalysisprofilechartscreen.dart';

import '../utils/constants.dart';
import '../utils/theme.dart';

class RouteAnalysisScreen extends ConsumerStatefulWidget {
  const RouteAnalysisScreen({super.key});

  @override
  _RouteAnalysisScreenState createState() => _RouteAnalysisScreenState();
}

class _RouteAnalysisScreenState extends ConsumerState<RouteAnalysisScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final controller = TabController(length: 3, vsync: this);

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
        unselectedLabelColor: zdvMidBlue,//Colors.white,
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
        ],
      ),
      Expanded(
          child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
        child: TabBarView(
          controller: controller,
          children: const <Widget>[
            Card(
              elevation: defaultCardElevation,
              child: RouteAnalysisProfileChartScreen(),
            ),
            Card(
              elevation: defaultCardElevation,
              child: WattsDataView(),
            ),
            Card(
              elevation: defaultCardElevation,
              child: TimeDataView(),
            ),
          ],
        ),
      ))
    ]);
    // });
    // });
  }
}
