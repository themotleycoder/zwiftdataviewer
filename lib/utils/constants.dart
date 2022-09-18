import 'package:flutter/material.dart';
import 'package:zwiftdataviewer/utils/theme.dart';

const int defaultDataDate = 1388563200;

enum HomeScreenTab { activities, stats, calendar, settings }

enum ActivityDetailScreenTab { details, profile, sections }

enum DateFilter {
  all,
  month,
  week,
  year
}

TextStyle headerTextStyle =
    new TextStyle(inherit: true, fontSize: 18.0, color: zdvDrkBlue);
TextStyle bodyTextStyleComplete = new TextStyle(
    inherit: true,
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
    color: zdvMidBlue);
TextStyle bodyTextStyle = new TextStyle(
    inherit: true,
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
    color: zdvDrkBlue);
TextStyle inlineBodyTextStyle =
    new TextStyle(inherit: true, fontSize: 18.0, color: zdvDrkBlue);
TextStyle headerFontStyle = new TextStyle(
  inherit: true,
  fontSize: 18.0,
);
const double iconPadding = 8.0;
const double rowHeight = 80;
const double iconSize = 32.0;
const Color iconColor = zdvmOrange;
const Color dividerColor = Colors.black12;
const double boxSize = 10.0;
Color? calenderColor = Colors.grey[600];
