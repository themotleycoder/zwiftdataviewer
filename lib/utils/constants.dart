import 'package:flutter/material.dart';
import 'package:zwiftdataviewer/utils/theme.dart';

const int defaultDataDate = 1388563200;

enum HomeScreenTab { activities, stats, calendar, settings }

enum ActivityDetailScreenTab { details, analysis, sections }

enum DateFilter { all, month, week, year }

TextStyle appBarTextStyle =
    const TextStyle(inherit: true, color: zdvDrkBlue, fontSize: 16.0);
TextStyle headerTextStyle =
    const TextStyle(inherit: true, fontSize: 16.0, color: Colors.blueGrey);
TextStyle bodyTextStyleComplete = const TextStyle(
    inherit: true,
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: zdvMidBlue);
TextStyle bodyTextStyle = const TextStyle(
    inherit: true,
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: zdvDrkBlue);
TextStyle inlineBodyTextStyle =
    const TextStyle(inherit: true, fontSize: 16.0, color: Colors.green);
TextStyle headerFontStyle = const TextStyle(
  inherit: true,
  fontSize: 16.0,
);
const double iconPadding = 8.0;
const double rowHeight = 80;
const double iconSize = 32.0;
const Color iconColor = zdvmOrange;
const Color dividerColor = Colors.black12;
const double boxSize = 10.0;
Color? calenderColor = Colors.grey[600];
