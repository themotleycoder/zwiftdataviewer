import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/screens/routeanalysisscreen.dart';
import 'package:zwiftdataviewer/screens/routedetailscreen.dart';
import 'package:zwiftdataviewer/screens/routesectiondetailscreen.dart';
import 'package:zwiftdataviewer/utils/constants.dart' as constants;
import 'package:zwiftdataviewer/utils/theme.dart';

import '../providers/activity_detail_provider.dart';
import '../providers/tabs_provider.dart';

// class DetailScreen extends StatefulWidget {
//   final int id;
//   final Strava strava;
//
//   const DetailScreen({required this.id, required this.strava})
//       : super(key: AppKeys.todoDetailsScreen);
//
//   _DetailScreenState createState() => _DetailScreenState();
// }

class DetailScreen extends ConsumerWidget {
  // StreamsDetailCollection? streamsDetail;
  //final _tab = ValueNotifier(ActivityDetailScreenTab.details);

  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailPageTabs = ref.watch(detailTabsNotifier.notifier);
    final tabIndex = ref.watch(detailTabsNotifier);

    // final asyncActivityDetail = ref.watch(activityDetailFromStreamProvider(
    //     ref.read(selectedActivityProvider).id!));

    // AsyncValue<DetailedActivity> asyncActivityDetail = ref.watch(
    //     activityDetailFromStreamProvider(
    //         ref.read(selectedActivityProvider).id));

    final activityDetail = ref.watch(stravaActivityDetailsProvider);

    //ref.read(activityDetailProvider.notifier).setActivityDetail(asyncActivityDetail.data!.value);

    // return asyncActivityDetail.when(
    //   data: (activityDetail) => Text('Activity detail loaded: $activityDetail'),
    //   loading: () => CircularProgressIndicator(),
    //   error: (error, stackTrace) => Text('Error: $error'),
    // );

    // var streamProvider = ref.watch(streamsProvider.notifier);
    // streamProvider.loadStreams(activity.id!);
    //
    // AsyncValue<StreamsDetailCollection> asyncStreamsDetailCollection = ref.watch(streamsProvider);

    // return MultiProvider(
    // providers: [
    // ChangeNotifierProvider(
    //     create: (context) => ActivityDetailDataModel(
    //         webRepository: WebRepository(strava: widget.strava),
    //         fileRepository: FileRepository())
    //       ..loadActivityDetail(widget.id)),
    //   ChangeNotifierProvider(
    //       create: (context) => StreamsDataModel(
    //           webRepository: WebRepository(strava: widget.strava),
    //           fileRepository: FileRepository())
    //         ..loadStreams(widget.id)),
    //   ChangeNotifierProvider(
    //       create: (context) => ActivityPhotosDataModel(
    //           webRepository: WebRepository(strava: widget.strava),
    //           fileRepository: FileRepository())
    //         ..loadActivityPhotos(widget.id)),
    //   ChangeNotifierProvider(
    //       create: (context) => ActivitySelectDataModel()),
    //   ChangeNotifierProvider(create: (context) => LapSelectDataModel()),
    //   ChangeNotifierProvider(
    //       create: (context) => SummaryActivitySelectDataModel())
    // ],
    return Scaffold(
        appBar:
            // asyncActivityDetail.when(data: (DetailedActivity activityDetail) {
            AppBar(
                title: Text("${activityDetail.name} ",
                    // "(${DateFormat.yMd().format(
                    // DateTime.parse(activityDetail.startDate))})",
                    style: constants.appBarTextStyle),
                backgroundColor: Colors.white,
                elevation: 0.0,
                leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                    })),
        // }, error: (Object error, StackTrace stackTrace) {
        //   print(stackTrace);
        //   return null;
        // }, loading: () {
        //   return AppBar(
        //       title:
        //           Text("Zwift Data Viewer", style: constants.appBarTextStyle),
        //       backgroundColor: zdvMidBlue,
        //       elevation: 0.0,
        //       leading: IconButton(
        //           icon: const Icon(Icons.arrow_back, color: Colors.white),
        //           onPressed: () {
        //             Navigator.pop(context);
        //           }));
        // }),

        //     //     appBar: AppBar(
        //     // title: activityDetail == null
        //     // ? Text("Zwift Data Viewer",
        //     //     style: constants.appBarTextStyle) : Text(
        //     // "${activityDetail.name} (${DateFormat.yMd().format(
        //     // DateTime.parse(activityDetail.startDate??''))})",
        //     style: constants.appBarTextStyle),
        // backgroundColor: zdvMidBlue,
        // elevation: 0.0,
        // leading: IconButton(
        // icon: Icon(Icons.arrow_back, color: Colors.white),
        // onPressed: () {
        // Navigator.pop(context);
        // },
        // )
        // // actions: getActions()
        // ),
        body: Stack(children: [
          Container(
            child: getView(tabIndex),
          )
        ]),
        // Selector<ActivityDetailDataModel, ActivityDetailDataModel>(
        //     selector: (context, activityDetailDataModel) =>
        //         activityDetailDataModel,
        //     builder: (context, activityDetailDataModel, _) {
        //       if (activityDetailDataModel.isLoading) {
        //         return const Center(
        //           child: CircularProgressIndicator(
        //             key: AppKeys.activitiesLoading,
        //           ),
        //         );
        //       }

        // ValueListenableBuilder<ActivityDetailScreenTab>(
        //   valueListenable: _tab,
        //   builder: (context, tab, _) {
        //     switch (tab) {
        //       case ActivityDetailScreenTab.analysis:
        //         return const RouteAnalysisScreen();
        //       case ActivityDetailScreenTab.sections:
        //         return RouteSectionDetailScreen();
        //       default:
        //         return const RouteDetailScreen(
        //             key: AppKeys.todoDetailsScreen);
        //     }
        //   },
        // ),
        // }),
        bottomNavigationBar:
            // ValueListenableBuilder<ActivityDetailScreenTab>(
            //     valueListenable: _tab,
            //     builder: (context, tab, _) {
            BottomNavigationBar(
          elevation: constants.cardElevation,
          key: AppKeys.tabs,
          currentIndex: tabIndex,
          onTap: (index) =>
              ref.read(detailTabsNotifier.notifier).setIndex(index),
          type: BottomNavigationBarType.fixed,
          unselectedItemColor: zdvmMidBlue[100],
          fixedColor: zdvmMidGreen[100],
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.list, key: AppKeys.activitiesTab),
              label: "Details",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insights, key: AppKeys.analysisTab),
              label: "Analysis",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today, key: AppKeys.sectionsTab),
              label: "Sections",
            ),
          ],
        ));
  }

  Widget getView(int index) {
    switch (index) {
      case 1:
        return const RouteAnalysisScreen();
      case 2:
        return const RouteSectionDetailScreen();
      case 0:
      default:
        return const RouteDetailScreen();
    }
  }
}
