import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zwiftdataviewer/models/ActivityDetailDataModel.dart';
import 'package:zwiftdataviewer/stravalib/Models/segmentEffort.dart';
import 'package:zwiftdataviewer/utils/conversions.dart';
import 'package:zwiftdataviewer/stravalib/API/streams.dart';
import 'package:zwiftdataviewer/utils/constants.dart' as Constants;
import 'package:zwiftdataviewer/utils/theme.dart';

class RouteSectionDetailScreen extends StatefulWidget {
  RouteSectionDetailScreen();
  final Map<int, String> _climbingCAT = {
    1: '4',
    2: '3',
    3: '1',
    4: '1',
    5: 'HC'
  };

  @override
  _RouteSectionDetailScreenState createState() =>
      _RouteSectionDetailScreenState();
}

class _RouteSectionDetailScreenState extends State<RouteSectionDetailScreen> {
  List<SegmentEffort>? _segmentEfforts;
  CombinedStreams? selectionModel;

  Widget createIcon(int prRank) {
    Color? col = Colors.white;
    String text = '';
    if (prRank == 1) {
      col = zdvYellow;
      text = 'PR';
    } else if (prRank == 2) {
      col = Colors.grey[400];
      text = '2';
    } else if (prRank == 3) {
      col = zdvOrange;
      text = '3';
    }

    return new Stack(children: <Widget>[
      Icon(Icons.bookmark, size: 48.0, color: col),
      Positioned.fill(
          child: Align(
        alignment: Alignment.center,
        child: Text(text,
            style: new TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 16.0,
              color: Colors.white,
            )),
      ))
    ]);
  }

  Row createSubTitle(SegmentEffort segmentEffort, Map<String, String> units) {
    String distance =
        Conversions.metersToDistance(context, segmentEffort.distance ?? 0)
            .toStringAsFixed(2);
    String elevation = Conversions.metersToHeight(
            context, segmentEffort.segment?.elevationHigh ?? 0)
        .toStringAsFixed(0);
    String grade =
        (segmentEffort.segment?.averageGrade ?? 0).toStringAsFixed(0);

    String category = widget
        ._climbingCAT[(segmentEffort.segment?.climbCategory ?? 0)]
        .toString();
    if (category != 'null') {
      category = 'cat ' + category;
    } else {
      category = '';
    }

    return Row(children: [
      Wrap(
        spacing: 20,
        children: [
          Text(distance + units['distance']!),
          Text(elevation + units['height']!),
          Text(grade + '%'),
          Text(category,
              style: new TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              )),
        ],
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> units = Conversions.units(context);
    return Consumer<ActivityDetailDataModel>(
        builder: (context, myModel, child) {
      _segmentEfforts = myModel.activityDetail?.segmentEfforts;

      return Container(
        child: ListView.separated(
          itemCount: _segmentEfforts == null ? 0 : _segmentEfforts!.length,
          separatorBuilder: (BuildContext context, int index) => Container(
              // padding: EdgeInsets.all(5.0),
              // child: Center(),
              // color: Colors.white,
              // margin: EdgeInsets.all(1.0),
              ),
          itemBuilder: (BuildContext context, int index) {
            return Container(
              padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
              child: Center(
                  child: InkWell(
                child: Card(
                    color: Colors.white,
                    elevation: 0,
                    child: ListTile(
                      leading: createIcon(_segmentEfforts![index].prRank!),
                      title: Text(_segmentEfforts![index].segment!.name ?? "",
                          style: Constants.headerFontStyle),
                      subtitle: createSubTitle(_segmentEfforts![index], units),
                      // trailing: Icon(
                      //   Icons.arrow_forward_ios,
                      //   color: Constants.zdvMidBlue[100],
                      // ),
                      // onTap: () {
                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (_) {
                      //         return DetailScreen(
                      //           id: _activities[index].id,
                      //           // onRemove: () {
                      //           //   Navigator.pop(context);
                      //           //   onRemove(context, todo);
                      //           // },
                      //         );
                      //       },
                      //     ),
                      //   );
                      // },
                      // onItemClick(_activities[index], context);
                    )),
              )),
              // margin: EdgeInsets.all(1.0),
            );
          },
        ),
      );

      // _chartData = createDataSet(myModel);
      // return Selector<StreamsDataModel, bool>(
      //     selector: (context, model) => model.isLoading,
      //     builder: (context, isLoading, _) {
      // if (isLoading) {
      //   return Center(
      //     child: CircularProgressIndicator(
      //       key: AppKeys.activitiesLoading,
      //     ),
      //   );
      // }
      // return Column(children: [
      //   Container(
      //       height: 200.0,
      //       padding: EdgeInsets.all(8.0),
      //       child: Expanded(
      //           child: charts.LineChart(
      //         _chartData,
      //         customSeriesRenderers: [
      //           new charts.LineRendererConfig(
      //               // ID used to link series to this renderer.
      //               customRendererId: 'customArea',
      //               includeArea: true,
      //               stacked: true),
      //           new charts.LineRendererConfig(
      //               // ID used to link series to this renderer.
      //               customRendererId: 'customArea2',
      //               includeArea: false,
      //               stacked: true),
      //         ],
      //         defaultRenderer:
      //             new charts.LineRendererConfig(includeArea: false),
      //         animate: true,
      //         primaryMeasureAxis: new charts.NumericAxisSpec(
      //             tickProviderSpec:
      //                 new charts.StaticNumericTickProviderSpec(
      //           // Create the ticks to be used the domain axis.
      //           <charts.TickSpec<num>>[
      //             new charts.TickSpec(0, label: ''),
      //             new charts.TickSpec(1, label: ''),
      //             new charts.TickSpec(2, label: ''),
      //             new charts.TickSpec(3, label: ''),
      //             new charts.TickSpec(4, label: ''),
      //           ],
      //         )),
      //         disjointMeasureAxes:
      //             new LinkedHashMap<String, charts.NumericAxisSpec>.from({
      //           'axis 1': new charts.NumericAxisSpec(),
      //           'axis 2': new charts.NumericAxisSpec(),
      //           'axis 3': new charts.NumericAxisSpec(),
      //           'axis 4': new charts.NumericAxisSpec(),
      //         }),
      //         selectionModels: [
      //           new charts.SelectionModelConfig(
      //             type: charts.SelectionModelType.info,
      //             changedListener: _onSelectionChanged,
      //           )
      //         ],
      //         behaviors: [
      //           // new charts.InitialSelection(selectedDataConfig: [
      //           // new charts.SeriesDatumConfig<String>('Elevation', '0')
      //           // ])
      //           new charts.LinePointHighlighter(
      //               showHorizontalFollowLine:
      //                   charts.LinePointHighlighterFollowLineType.none,
      //               showVerticalFollowLine: charts
      //                   .LinePointHighlighterFollowLineType.nearest),
      //           new charts.SelectNearest(
      //               eventTrigger: charts.SelectionTrigger.tapAndDrag)
      //         ],
      //       ))),
      //   ProfileDataView()
      // ]);
    });
    // });
  }
}

// class ProfileDataView extends StatefulWidget {
//   // CombinedStreams selectedSeries;

//   // ProfileDataView(this.selectedSeries);

//   @override
//   _ProfileDataViewState createState() => _ProfileDataViewState();
// }

// class _ProfileDataViewState extends State<ProfileDataView> {
//   //Map<String, String> units = Conversions.units(context);

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ActivitySelectDataModel>(
//         builder: (context, myModel, child) {
//       CombinedStreams selectedSeries = myModel.selectedStream;
//       return Expanded(
//         flex: 1,
//         child: GridView.count(
//           primary: false,
//           padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
//           crossAxisSpacing: 8,
//           mainAxisSpacing: 8,
//           childAspectRatio: MediaQuery.of(context).size.height / 300,
//           crossAxisCount: 2,
//           children: <Widget>[
//             gridViewItem(
//                 '',
//                 'Distance',
//                 Conversions.metersToDistance(
//                         context, selectedSeries?.distance ?? 0)
//                     .toStringAsFixed(2),
//                 units['distance']),
//             gridViewItem(
//                 '',
//                 'Elevation',
//                 Conversions.metersToHeight(
//                         context, selectedSeries?.altitude ?? 0)
//                     .toStringAsFixed(0),
//                 units['height']),
//             gridViewItem('', 'Heartrate',
//                 (selectedSeries?.heartrate ?? 0).toString(), 'bpm'),
//             gridViewItem(
//                 '', 'Power', (selectedSeries?.watts ?? 0).toString(), 'w'),
//             gridViewItem('', 'Cadence',
//                 (selectedSeries?.cadence ?? 0).toString() ?? "0", 'rpm'),
//             gridViewItem('', 'Grade',
//                 (selectedSeries?.gradeSmooth ?? 0).toString() ?? "0", '%'),
//           ],
//         ),
//       );
//     });
//   }

//   Widget gridViewItem(
//       String title, String label, String dataPoint, String units) {
//     return Container(
//         padding: EdgeInsets.fromLTRB(0, 8.0, 0, 0),
//         decoration: BoxDecoration(
//             border: Border(bottom: BorderSide(color: Constants.dividerColor))),
//         child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//           Column(
//             children: <Widget>[
//               Text(label + " (" + units + ")",
//                   style: Constants.headerTextStyle),
//               Text(dataPoint, style: Constants.bodyTextStyle),
//             ],
//           )
//         ]));
//   }
// }
