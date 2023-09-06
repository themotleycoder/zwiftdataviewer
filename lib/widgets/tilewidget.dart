import 'package:flutter/material.dart';
import 'package:zwiftdataviewer/utils/constants.dart' as constants;

Widget layoutTile(Widget childWidget) {
  return Expanded(
      child: Container(
          margin: const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0),
          padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
          decoration: const BoxDecoration(
              color: constants.tileBackgroundColor,
              borderRadius: BorderRadius.all(
                  Radius.circular(constants.roundedCornerSize))),
          child: childWidget));
}
