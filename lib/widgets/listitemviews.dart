import 'package:flutter/material.dart';
import 'package:zwiftdataviewer/utils/constants.dart' as constants;

Widget singleDataLineItem(
    String title, IconData icon, String dataPoint, String units) {
  return Container(
      height: constants.rowHeight,
      padding: const EdgeInsets.all(8.0),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: constants.dividerColor))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Padding(
              padding: const EdgeInsets.only(right: constants.iconPadding),
              child: Icon(icon,
                  size: constants.iconSize, color: constants.iconColor)),
          Text(
            title,
            style: constants.headerTextStyle,
          ),
        ]),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(dataPoint,
              textAlign: TextAlign.right, style: constants.bodyTextStyle),
          Text(' $units',
              textAlign: TextAlign.right, style: constants.inlineBodyTextStyle),
        ])
      ]));
}

Widget singleDataHeaderLineItem(String dataPoint) {
  // return Card(
  //     color: Colors.white,
  //     elevation: defaultCardElevation,
  //     margin: const EdgeInsets.fromLTRB(8.0, 4, 8.0, 4),
  return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      // color: Colors.red,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(dataPoint,
              style: constants.bodyTextStyle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center),
        ],
      ));
  // ));
}

Widget columnStackedDataHeaderLineItem(
    List<String> labels, List<String> dataPoints) {
  return Container(
      // height: 80,
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(labels.length, (index) {
            return Container(
                padding: const EdgeInsets.fromLTRB(0, 0.0, 0.0, 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(labels[index].toUpperCase(),
                        style: constants.headerTextStyle),
                    Text(dataPoints[index], style: constants.bodyTextStyle)
                  ],
                ));
          })));
}

Widget doubleDataHeaderLineItem(List<String> labels, List<String> dataPoints) {
  // return Card(
  //     color: Colors.white,
  //     elevation: defaultCardElevation,
  //     margin: const EdgeInsets.fromLTRB(8.0, 4, 8.0, 4),
  return Container(
      height: 80,
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      child: Column(
        children: <Widget>[
          // Container(
          //     padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
          //     child: Text(title + " (" + units + ")",
          //         style: Constants.headerTextStyle)),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(labels.length, (index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(labels[index], style: constants.headerTextStyle),
                    Text(dataPoints[index], style: constants.bodyTextStyle)
                  ],
                );
              }))
        ],
      ));
}

Widget doubleDataSingleHeaderLineItem(String title, IconData? icon,
    List<String> labels, List<String> dataPoints, String units) {
  // return Card(
  //     elevation: defaultCardElevation,
  //     color: Colors.white,
  //     margin: const EdgeInsets.fromLTRB(8.0, 4, 8.0, 4),
  //     child:
  return Container(
      height: 100,
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      // decoration: BoxDecoration(
      //     border:
      //         Border(bottom: BorderSide(color: Constants.dividerColor))),
      child: Column(
        children: <Widget>[
          Container(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
              child: Text('$title ($units)', style: constants.headerTextStyle)),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(labels.length, (index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(labels[index], style: constants.headerTextStyle),
                    Text(dataPoints[index], style: constants.bodyTextStyle)
                  ],
                );
              }))
        ],
      ));
  // );
}

Widget tripleDataSingleHeaderLineItem(
    List<String> labels, List<String> dataPoints) {
  // return Card(
  //     elevation: defaultCardElevation,
  //     color: Colors.white,
  //     margin: const EdgeInsets.fromLTRB(8.0, 4, 8.0, 4),
  //     child:
  return Container(
      height: 100,
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      // margin: const EdgeInsets.fromLTRB(8.0, 4, 8.0, 4),
      // decoration: BoxDecoration(
      //     border:
      //         Border(bottom: BorderSide(color: Constants.dividerColor))),
      // child: Column(
      //   children: <Widget>[
      // Container(
      //     padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
      //     child: Text(title, style: constants.headerTextStyle)),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(labels.length, (index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(labels[index], style: constants.headerTextStyle),
                Text(dataPoints[index], style: constants.bodyTextStyle)
              ],
            );
          }))
      // ],
      // ));
      );
}

// Widget tripleDataLineItem(String title, IconData? icon, List<String> labels,
//     List<String> dataPoints, String units) {
//   // return Card(
//   //     color: Colors.white,
//   //     elevation: defaultCardElevation,
//   //     margin: const EdgeInsets.fromLTRB(8.0, 4, 8.0, 4),
//   //     child:
//   return Container(
//       // height: 100,
//       // padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
//       // decoration: BoxDecoration(
//       //     border:
//       //         Border(bottom: BorderSide(color: Constants.dividerColor))),
//       child: Column(
//         children: <Widget>[
//           Container(
//               padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
//               child: Text("$title ($units)", style: constants.headerTextStyle)),
//           Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: List.generate(labels.length, (index) {
//                 return Expanded(
//                     child: layoutTile(
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           children: <Widget>[
//                             Text(labels[index],
//                                 style: constants.headerTextStyle),
//                             Text(dataPoints[index],
//                                 style: constants.bodyTextStyle)
//                           ],
//                         )));
//               }))
//         ],
//       ));
//   // );
// }

Widget gridViewItem(
    String title, String label, String dataPoint, String units) {
  return Container(
      padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 0),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: constants.dividerColor))),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Column(
          children: <Widget>[
            Text('$label ($units)', style: constants.headerTextStyle),
            Text(dataPoint, style: constants.bodyTextStyle),
          ],
        )
      ]));
}
