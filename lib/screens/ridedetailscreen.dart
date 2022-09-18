import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/models/ActivityDetailDataModel.dart';
import 'package:zwiftdataviewer/models/ActivityPhotosDataModel.dart';
import 'package:zwiftdataviewer/models/StreamsDataModel.dart';
import 'package:zwiftdataviewer/stravalib/API/streams.dart';
import 'package:zwiftdataviewer/stravalib/Models/segmentEffort.dart';
import 'package:zwiftdataviewer/stravalib/strava.dart';
import 'package:zwiftdataviewer/utils/constants.dart';
import 'package:zwiftdataviewer/utils/repository/filerepository.dart';
import 'package:zwiftdataviewer/utils/repository/webrepository.dart';
import 'package:zwiftdataviewer/screens/routedetailscreen.dart';
import 'package:zwiftdataviewer/screens/routeprofilechartscreen.dart';
import 'package:zwiftdataviewer/screens/routesectiondetailscreen.dart';
import 'package:zwiftdataviewer/utils/theme.dart';

class DetailScreen extends StatefulWidget {
  final int id;
  final Strava strava;

  const DetailScreen({required this.id, required this.strava})
      : super(key: AppKeys.todoDetailsScreen);

  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  StreamsDetailCollection? streamsDetail;
  final _tab = ValueNotifier(ActivityDetailScreenTab.details);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (context) => ActivityDetailDataModel(
                  webRepository: WebRepository(strava: widget.strava),
                  fileRepository: FileRepository())
                ..loadActivityDetail(widget.id)),
          ChangeNotifierProvider(
              create: (context) => StreamsDataModel(
                  webRepository: WebRepository(strava: widget.strava),
                  fileRepository: FileRepository())
                ..loadStreams(widget.id)),
          ChangeNotifierProvider(
              create: (context) => ActivityPhotosDataModel(
                  webRepository: WebRepository(strava: widget.strava),
                  fileRepository: FileRepository())
                ..loadActivityPhotos(widget.id)),
          ChangeNotifierProvider(create: (context) => ActivitySelectDataModel())
        ],
        child: Consumer<ActivityDetailDataModel>(
            builder: (context, myModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: myModel == null || myModel.activityDetail == null
                  ? const Text("Zwift Data Viewer")
                  : Text(myModel.activityDetail!.name! +
                      " (" +
                      DateFormat.yMd().format(
                          DateTime.parse(myModel.activityDetail!.startDate!)) +
                      ")"),
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              // actions: getActions()
            ),
            body: Container(
                child: Selector<ActivityDetailDataModel,
                        ActivityDetailDataModel>(
                    selector: (context, activityDetailDataModel) =>
                        activityDetailDataModel,
                    builder: (context, activityDetailDataModel, _) {
                      if (activityDetailDataModel.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            key: AppKeys.activitiesLoading,
                          ),
                        );
                      }

                      return ValueListenableBuilder<ActivityDetailScreenTab>(
                        valueListenable: _tab,
                        builder: (context, tab, _) {
                          switch (tab) {
                            case ActivityDetailScreenTab.profile:
                              return RouteProfileChartScreen();
                            case ActivityDetailScreenTab.sections:
                              return RouteSectionDetailScreen();
                            case ActivityDetailScreenTab.details:
                            default:
                              return const RouteDetailScreen(
                                  key: AppKeys.todoDetailsScreen);
                          }
                        },
                      );
                    })),
            bottomNavigationBar:
                ValueListenableBuilder<ActivityDetailScreenTab>(
                    valueListenable: _tab,
                    builder: (context, tab, _) {
                      return BottomNavigationBar(
                        key: AppKeys.tabs,
                        currentIndex:
                            ActivityDetailScreenTab.values.indexOf(tab),
                        onTap: onTabTapped,
                        type: BottomNavigationBarType.fixed,
                        unselectedItemColor: zdvmMidBlue[100],
                        fixedColor: zdvmOrange[100],
                        items: [
                          const BottomNavigationBarItem(
                            icon: Icon(Icons.list, key: AppKeys.activitiesTab),
                            label: "Details",
                          ),
                          const BottomNavigationBarItem(
                            icon: Icon(Icons.show_chart, key: AppKeys.statsTab),
                            label: "Profile",
                          ),
                          const BottomNavigationBarItem(
                            icon: Icon(Icons.calendar_today,
                                key: AppKeys.calendarTab),
                            label: "Sections",
                          ),
                        ],
                      );
                    }),
          );
        }));
  }

  void onTabTapped(int index) {
    // setState(() {
    //   _bottomNavIndex = index;
    // });
    _tab.value = ActivityDetailScreenTab.values[index];
    setState(() {});
  }
}

// Flutter code sample for ExpansionPanelList

// Here is a simple example of how to implement ExpansionPanelList.

// import 'package:flutter/material.dart';

// void main() => runApp(MyApp());

// /// This Widget is the main application widget.
// class MyApp extends StatelessWidget {
//   static const String _title = 'Flutter Code Sample';

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: _title,
//       home: Scaffold(
//         appBar: AppBar(title: const Text(_title)),
//         body: MyStatefulWidget(),
//       ),
//     );
//   }
// }

// stores ExpansionPanel state information
class Item {
  Item({
    required this.expandedValue,
    required this.headerValue,
    this.isExpanded = false,
  });

  String expandedValue;
  String headerValue;
  bool isExpanded;
}

List<Item> generateItems(List<SegmentEffort> segmentEfforts) {
  return List.generate(segmentEfforts.length, (int index) {
    return Item(
      headerValue: segmentEfforts[index].name!,
      expandedValue: 'This is item number $index',
    );
  });
}

// class MyStatefulWidget extends StatefulWidget {
//   final List<SegmentEffort> segmentEfforts;

//   MyStatefulWidget(this.segmentEfforts);

//   @override
//   _MyStatefulWidgetState createState() =>
//       _MyStatefulWidgetState(segmentEfforts);
// }

// class _MyStatefulWidgetState extends State<MyStatefulWidget> {
//   List<Item> _data = [];
//   final List<SegmentEffort> _segmentEfforts;

//   _MyStatefulWidgetState(this._segmentEfforts);

//   @override
//   Widget build(BuildContext context) {
//     _data = generateItems(_segmentEfforts);
//     return SingleChildScrollView(
//       child: Container(
//         child: _buildPanel(),
//       ),
//     );
//   }

//   Widget _buildPanel() {
//     return ExpansionPanelList(
//       expansionCallback: (int index, bool isExpanded) {
//         setState(() {
//           _data[index].isExpanded = !isExpanded;
//         });
//       },
//       children: _data.map<ExpansionPanel>((Item item) {
//         return ExpansionPanel(
//           headerBuilder: (BuildContext context, bool isExpanded) {
//             return ListTile(
//               title: Text(item.headerValue),
//             );
//           },
//           body: ListTile(
//               title: Text(item.expandedValue),
//               subtitle: Text('To delete this panel, tap the trash can icon'),
//               trailing: Icon(Icons.delete),
//               onTap: () {
//                 setState(() {
//                   _data.removeWhere((currentItem) => item == currentItem);
//                 });
//               }),
//           isExpanded: item.isExpanded,
//         );
//       }).toList(),
//     );
//   }
// }

// class MapSample extends StatefulWidget {
//   @override
//   State<MapSample> createState() => MapSampleState();
// }

// class MapSampleState extends State<MapSample> {
//   Completer<GoogleMapController> _controller = Completer();

//   static final CameraPosition _kGooglePlex = CameraPosition(
//     target: LatLng(37.42796133580664, -122.085749655962),
//     zoom: 14.4746,
//   );

//   static final CameraPosition _kLake = CameraPosition(
//       bearing: 192.8334901395799,
//       target: LatLng(37.43296265331129, -122.08832357078792),
//       tilt: 59.440717697143555,
//       zoom: 19.151926040649414);

//   @override
//   Widget build(BuildContext context) {
//     return new Scaffold(
//       body: GoogleMap(
//         mapType: MapType.hybrid,
//         initialCameraPosition: _kGooglePlex,
//         onMapCreated: (GoogleMapController controller) {
//           _controller.complete(controller);
//         },
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _goToTheLake,
//         label: Text('To the lake!'),
//         icon: Icon(Icons.directions_boat),
//       ),
//     );
//   }

//   Future<void> _goToTheLake() async {
//     final GoogleMapController controller = await _controller.future;
//     controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
//   }
// }

class DistanceValue {
  final double distance;
  final double value;

  DistanceValue(this.distance, this.value);
}
