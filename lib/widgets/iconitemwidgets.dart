import 'package:flutter/cupertino.dart';
import 'package:zwiftdataviewer/utils/constants.dart' as constants;
import 'package:zwiftdataviewer/widgets/tilewidget.dart';

import '../utils/theme.dart';

class IconDataObject {
  final String title;
  final String data;
  final IconData icon;
  final String? units;

  IconDataObject(this.title, this.data, this.icon, {this.units});
}

Widget iconHeaderDataRow(List<IconDataObject> dataObjects) {
  return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(dataObjects.length, (index) {
        return iconHeaderData(dataObjects[index].title, dataObjects[index].data,
            dataObjects[index].icon,
            units: dataObjects[index].units);
      })); //);
}

Widget iconHeaderData(String title, String data, IconData icon,
    {String? units}) {
  return layoutTile(Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: <Widget>[
      SizedBox(
        // color: Colors.yellow,
        width: 48,
        height: 48,
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
