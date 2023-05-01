import 'package:flutter/cupertino.dart';
import 'package:zwiftdataviewer/utils/constants.dart' as constants;

import '../utils/theme.dart';

class IconDataObject {
  final String title;
  final String data;
  final IconData icon;
  final String? units;

  IconDataObject(this.title, this.data, this.icon, {this.units});
}

Widget IconHeaderDataRow(List<IconDataObject> dataObjects) {
  return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(dataObjects.length, (index) {
        return IconHeaderData(dataObjects[index].title, dataObjects[index].data,
            dataObjects[index].icon,
            units: dataObjects[index].units);
      })); //);
}

Widget IconHeaderData(String title, String data, IconData icon,
    {String? units}) {
  return Container(
      width: 180,
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(10),
      //   border: Border.all(
      //     color: Colors.grey,
      //     width: 1,
      //   ),
      // ),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            // color: Colors.yellow,
            width: 50,
            height: 50,
            child: Icon(icon, color: zdvMidBlue, size: 30),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(title, style: constants.headerTextStyle),
              Row(children: [
                Text(data, style: constants.bodyTextStyle),
                Text(" ${units ?? ''}", style: constants.headerTextStyle)
              ]),
            ],
          ),
        ],
      ));
}
