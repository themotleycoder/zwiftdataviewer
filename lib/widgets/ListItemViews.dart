import 'package:flutter/material.dart';
import 'package:zwiftdataviewer/utils/constants.dart' as Constants;

Widget singleDataLineItem(
    String title, IconData icon, String dataPoint, String units) {
  return Container(
      height: Constants.rowHeight,
      padding: const EdgeInsets.all(8.0),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Constants.dividerColor))),
      child:
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Padding(
              padding: const EdgeInsets.only(right: Constants.iconPadding),
              child: Icon(icon,
                  size: Constants.iconSize, color: Constants.iconColor)),
          Text(
            title,
            style: Constants.headerTextStyle,
          ),
        ]),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(dataPoint,
              textAlign: TextAlign.right, style: Constants.bodyTextStyle),
          Text(" $units",
              textAlign: TextAlign.right, style: Constants.inlineBodyTextStyle),
        ])
      ]));
}

// Widget doubleDataLineItem(String title, IconData icon, String label1,
//     String label2, String dataPoint1, String dataPoint2, String units) {
//   return Container(
//     height: Constants.rowHeight,
//     padding: const EdgeInsets.all(8.0),
//     decoration: BoxDecoration(
//         border: Border(bottom: BorderSide(color: Constants.dividerColor))),
//     child:
//         new Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//       new Row(children: [
//         Padding(
//             padding: const EdgeInsets.only(right: Constants.iconPadding),
//             child: new Icon(icon,
//                 size: Constants.iconSize, color: Constants.iconColor)),
//         new Text(title, style: Constants.headerTextStyle),
//       ]),
//       new Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             new Column(children: [
//               new Text(label1 + " ",
//                   textAlign: TextAlign.right,
//                   style: Constants.inlineBodyTextStyle),
//               SizedBox(height: Constants.boxSize),
//               new Text(label2 + " ",
//                   textAlign: TextAlign.right,
//                   style: Constants.inlineBodyTextStyle),
//             ]),
//             new Column(children: [
//               new Text(dataPoint1,
//                   textAlign: TextAlign.right, style: Constants.bodyTextStyle),
//               SizedBox(height: Constants.boxSize),
//               new Text(dataPoint2,
//                   textAlign: TextAlign.right, style: Constants.bodyTextStyle),
//             ]),
//             new Column(children: [
//               new Text(" " + units,
//                   textAlign: TextAlign.right,
//                   style: Constants.inlineBodyTextStyle),
//               SizedBox(height: Constants.boxSize),
//               new Text(" " + units,
//                   textAlign: TextAlign.right,
//                   style: Constants.inlineBodyTextStyle),
//             ])
//           ])
//     ]),
//   );
// }

Widget doubleDataHeaderLineItem(List<String> labels, List<String> dataPoints) {
  return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.fromLTRB(8.0, 4, 8.0, 4),
      // height: 80,
      // padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      // decoration: BoxDecoration(
      //     border: Border(bottom: BorderSide(color: Constants.dividerColor))),
      child: Container(
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
                      children: <Widget>[
                        Text(labels[index], style: Constants.headerTextStyle),
                        Text(dataPoints[index], style: Constants.bodyTextStyle)
                      ],
                    );
                  }))
            ],
          )));
}

Widget doubleDataSingleHeaderLineItem(String title, IconData? icon,
    List<String> labels, List<String> dataPoints, String units) {
  return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.fromLTRB(8.0, 4, 8.0, 4),
      child: Container(
          height: 100,
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
          // decoration: BoxDecoration(
          //     border:
          //         Border(bottom: BorderSide(color: Constants.dividerColor))),
          child: Column(
            children: <Widget>[
              Container(
                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
                  child: Text(title + " (" + units + ")",
                      style: Constants.headerTextStyle)),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(labels.length, (index) {
                    return Column(
                      children: <Widget>[
                        Text(labels[index], style: Constants.headerTextStyle),
                        Text(dataPoints[index], style: Constants.bodyTextStyle)
                      ],
                    );
                  }))
            ],
          )));
}

Widget tripleDataLineItem(String title, IconData icon, List<String> labels,
    List<String> dataPoints, String units) {
  return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.fromLTRB(8.0, 4, 8.0, 4),
      child: Container(
          height: 100,
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
          // decoration: BoxDecoration(
          //     border:
          //         Border(bottom: BorderSide(color: Constants.dividerColor))),
          child: Column(
            children: <Widget>[
              Container(
                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
                  child: Text(title + " (" + units + ")",
                      style: Constants.headerTextStyle)),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(labels.length, (index) {
                    return Column(
                      children: <Widget>[
                        Text(labels[index], style: Constants.headerTextStyle),
                        Text(dataPoints[index], style: Constants.bodyTextStyle)
                      ],
                    );
                  }))
            ],
          )));
}

Widget gridViewItem(
    String title, String label, String dataPoint, String units) {
  return Container(
      padding: EdgeInsets.fromLTRB(0, 8.0, 0, 0),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Constants.dividerColor))),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Column(
          children: <Widget>[
            Text(label + " (" + units + ")", style: Constants.headerTextStyle),
            Text(dataPoint, style: Constants.bodyTextStyle),
          ],
        )
      ]));
}
