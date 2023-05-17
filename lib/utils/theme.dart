import 'package:flutter/material.dart';

const MaterialColor white = MaterialColor(
  0xFFFFFFFF,
  <int, Color>{
    50: Color(0xFFFFFFFF),
    100: Color(0xFFFFFFFF),
    200: Color(0xFFFFFFFF),
    300: Color(0xFFFFFFFF),
    400: Color(0xFFFFFFFF),
    500: Color(0xFFFFFFFF),
    600: Color(0xFFFFFFFF),
    700: Color(0xFFFFFFFF),
    800: Color(0xFFFFFFFF),
    900: Color(0xFFFFFFFF),
  },
);

const Color zdvOrange = Color(0xFFEF672F);
const MaterialColor zdvmOrange = MaterialColor(
  0xFFFFFFFF,
  <int, Color>{
    50: Color(0xFFEF672F),
    100: Color(0xFFEF672F),
    200: Color(0xFFEF672F),
    300: Color(0xFFEF672F),
    400: Color(0xFFEF672F),
    500: Color(0xFFEF672F),
    600: Color(0xFFEF672F),
    700: Color(0xFFEF672F),
    800: Color(0xFFEF672F),
    900: Color(0xFFEF672F),
  },
);

const Color zdvYellow = Color(0xFFFBD84F);
const MaterialColor zdvmYellow = MaterialColor(
  0xFFFFFFFF,
  <int, Color>{
    50: Color(0xFFFBD84F),
    100: Color(0xFFFBD84F),
    200: Color(0xFFFBD84F),
    300: Color(0xFFFBD84F),
    400: Color(0xFFFBD84F),
    500: Color(0xFFFBD84F),
    600: Color(0xFFFBD84F),
    700: Color(0xFFFBD84F),
    800: Color(0xFFFBD84F),
    900: Color(0xFFFBD84F),
  },
);

const Color zdvRed = Color(0xFFDE4842);

const Color zdvDrkBlue = Color(0xFF023047);
const MaterialColor zdvmDrkBlue = MaterialColor(
  0xFFFFFFFF,
  <int, Color>{
    50: Color(0xFF023047),
    100: Color(0xFF023047),
    200: Color(0xFF023047),
    300: Color(0xFF023047),
    400: Color(0xFF023047),
    500: Color(0xFF023047),
    600: Color(0xFF023047),
    700: Color(0xFF023047),
    800: Color(0xFF023047),
    900: Color(0xFF023047),
  },
);

const Color zdvMidBlue = Color(0xFF2892C8);
const MaterialColor zdvmMidBlue = MaterialColor(
  0xFFFFFFFF,
  <int, Color>{
    50: Color(0xFF2892C8),
    100: Color(0xFF2892C8),
    200: Color(0xFF2892C8),
    300: Color(0xFF2892C8),
    400: Color(0xFF2892C8),
    500: Color(0xFF2892C8),
    600: Color(0xFF2892C8),
    700: Color(0xFF2892C8),
    800: Color(0xFF2892C8),
    900: Color(0xFF2892C8),
  },
);

const Color zdvLgtBlue = Color(0xFF8ECAE6);
const MaterialColor zdvmLgtBlue = MaterialColor(
  0xFFFFFFFF,
  <int, Color>{
    50: Color(0xFF8ECAE6),
    100: Color(0xFF8ECAE6),
    200: Color(0xFF8ECAE6),
    300: Color(0xFF8ECAE6),
    400: Color(0xFF8ECAE6),
    500: Color(0xFF8ECAE6),
    600: Color(0xFF8ECAE6),
    700: Color(0xFF8ECAE6),
    800: Color(0xFF8ECAE6),
    900: Color(0xFF8ECAE6),
  },
);

const Color zdvMidGreen = Color(0xFF80D134);
const MaterialColor zdvmMidGreen = MaterialColor(
  0xFFFFFFFF,
  <int, Color>{
    50: Color(0xFF80D134),
    100: Color(0xFF80D134),
    200: Color(0xFF80D134),
    300: Color(0xFF80D134),
    400: Color(0xFF80D134),
    500: Color(0xFF80D134),
    600: Color(0xFF80D134),
    700: Color(0xFF80D134),
    800: Color(0xFF80D134),
    900: Color(0xFF80D134),
  },
);

final ThemeData myTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xfff8f8f8),
  primaryColorLight: zdvmOrange,
  primaryColorDark: zdvmOrange,
  canvasColor: const Color(0xfffafafa),
  scaffoldBackgroundColor: const Color(0xfffafafa),
  cardColor: const Color(0xffffffff),
  dividerColor: const Color(0x1f000000),
  highlightColor: const Color(0x66bcbcbc),
  splashColor: const Color(0x66c8c8c8),
  unselectedWidgetColor: const Color(0x8a000000),
  disabledColor: const Color(0x61000000),
  secondaryHeaderColor: const Color(0xfff2f2f2),
  dialogBackgroundColor: const Color(0xffffffff),
  indicatorColor: const Color(0xff808080),
  hintColor: const Color(0x8a000000),
  buttonTheme: const ButtonThemeData(
    textTheme: ButtonTextTheme.normal,
    minWidth: 88,
    height: 36,
    padding: EdgeInsets.only(top: 0, bottom: 0, left: 16, right: 16),
    shape: RoundedRectangleBorder(
      side: BorderSide(
        color: Color(0xff000000),
        width: 0,
        style: BorderStyle.none,
      ),
      borderRadius: BorderRadius.all(Radius.circular(2.0)),
    ),
    alignedDropdown: false,
    buttonColor: Color(0xffe0e0e0),
    disabledColor: Color(0x61000000),
    highlightColor: Color(0x29000000),
    splashColor: Color(0x1f000000),
    focusColor: Color(0x1f000000),
    hoverColor: Color(0x0a000000),
    colorScheme: ColorScheme(
      primary: Color(0xffffffff),
      primaryContainer: Color(0xff4d4d4d),
      secondary: Color(0xff808080),
      secondaryContainer: Color(0xff4d4d4d),
      surface: Color(0xffffffff),
      background: Color(0xffcccccc),
      error: Color(0xffd32f2f),
      onPrimary: Color(0xff000000),
      onSecondary: Color(0xffffffff),
      onSurface: Color(0xff000000),
      onBackground: Color(0xff000000),
      onError: Color(0xffffffff),
      brightness: Brightness.light,
    ),
  ),
  // textTheme: TextTheme(
  //   display4: TextStyle(
  //     color: Color(0x8a000000),
  //     fontSize: null,
  //     fontWeight: FontWeight.w400,
  //     fontStyle: FontStyle.normal,
  //   ),
  //   display3: TextStyle(
  //     color: Color(0x8a000000),
  //     fontSize: null,
  //     fontWeight: FontWeight.w400,
  //     fontStyle: FontStyle.normal,
  //   ),
  //   display2: TextStyle(
  //     color: Color(0x8a000000),
  //     fontSize: null,
  //     fontWeight: FontWeight.w400,
  //     fontStyle: FontStyle.normal,
  //   ),
  //   display1: TextStyle(
  //     color: Color(0x8a000000),
  //     fontSize: null,
  //     fontWeight: FontWeight.w400,
  //     fontStyle: FontStyle.normal,
  //   ),
  //   headline: TextStyle(
  //     color: Color(0xdd000000),
  //     fontSize: null,
  //     fontWeight: FontWeight.w400,
  //     fontStyle: FontStyle.normal,
  //   ),
  //   title: TextStyle(
  //     color: Color(0xdd000000),
  //     fontSize: null,
  //     fontWeight: FontWeight.w400,
  //     fontStyle: FontStyle.normal,
  //   ),
  //   subhead: TextStyle(
  //     color: Color(0xdd000000),
  //     fontSize: null,
  //     fontWeight: FontWeight.w400,
  //     fontStyle: FontStyle.normal,
  //   ),
  //   body2: TextStyle(
  //     color: Color(0xdd000000),
  //     fontSize: null,
  //     fontWeight: FontWeight.w400,
  //     fontStyle: FontStyle.normal,
  //   ),
  //   body1: TextStyle(
  //     color: Color(0xdd000000),
  //     fontSize: null,
  //     fontWeight: FontWeight.w400,
  //     fontStyle: FontStyle.normal,
  //   ),
  //   caption: TextStyle(
  //     color: Color(0x8a000000),
  //     fontSize: null,
  //     fontWeight: FontWeight.w400,
  //     fontStyle: FontStyle.normal,
  //   ),
  //   button: TextStyle(
  //     color: Color(0xdd000000),
  //     fontSize: null,
  //     fontWeight: FontWeight.w400,
  //     fontStyle: FontStyle.normal,
  //   ),
  //   subtitle: TextStyle(
  //     color: Color(0xff000000),
  //     fontSize: null,
  //     fontWeight: FontWeight.w400,
  //     fontStyle: FontStyle.normal,
  //   ),
  //   overline: TextStyle(
  //     color: Color(0xff000000),
  //     fontSize: null,
  //     fontWeight: FontWeight.w400,
  //     fontStyle: FontStyle.normal,
  //   ),
  // ),
  primaryTextTheme: const TextTheme(
    displayLarge: TextStyle(
      color: Color(0x8a000000),
      fontSize: null,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
    ),
    displayMedium: TextStyle(
      color: Color(0x8a000000),
      fontSize: null,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
    ),
    displaySmall: TextStyle(
      color: Color(0x8a000000),
      fontSize: null,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
    ),
    headlineMedium: TextStyle(
      color: Color(0x8a000000),
      fontSize: null,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
    ),
    headlineSmall: TextStyle(
      color: Color(0xdd000000),
      fontSize: null,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
    ),
    titleLarge: TextStyle(
      color: Color(0xdd000000),
      fontSize: null,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
    ),
    titleMedium: TextStyle(
      color: Color(0xdd000000),
      fontSize: null,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
    ),
    bodyLarge: TextStyle(
      color: Color(0xdd000000),
      fontSize: null,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
    ),
    bodyMedium: TextStyle(
      color: Color(0xdd000000),
      fontSize: null,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
    ),
    bodySmall: TextStyle(
      color: Color(0x8a000000),
      fontSize: null,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
    ),
    labelLarge: TextStyle(
      color: Color(0xdd000000),
      fontSize: null,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
    ),
    titleSmall: TextStyle(
      color: Color(0xff000000),
      fontSize: null,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
    ),
    labelSmall: TextStyle(
      color: Color(0xff000000),
      fontSize: null,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
    ),
  ),
  // accentTextTheme: TextTheme(
  //   display4: TextStyle(
  //     color: Color(0xb3ffffff),
  //     fontSize: null,
  //     fontWeight: FontWeight.w400,
  //     fontStyle: FontStyle.normal,
  //   ),
  //   display3: TextStyle(
  //     color: Color(0xb3ffffff),
  //     fontSize: null,
  //     fontWeight: FontWeight.w400,
  //     fontStyle: FontStyle.normal,
  //   ),
  //   display2: TextStyle(
  //     color: Color(0xb3ffffff),
  //     fontSize: null,
  //     fontWeight: FontWeight.w400,
  //     fontStyle: FontStyle.normal,
  //   ),
  //   display1: TextStyle(
  //     color: Color(0xb3ffffff),
  //     fontSize: null,
  //     fontWeight: FontWeight.w400,
  //     fontStyle: FontStyle.normal,
  //   ),
  //   headline: TextStyle(
  //     color: Color(0xffffffff),
  //     fontSize: null,
  //     fontWeight: FontWeight.w400,
  //     fontStyle: FontStyle.normal,
  //   ),
  //   title: TextStyle(
  //     color: Color(0xffffffff),
  //     fontSize: null,
  //     fontWeight: FontWeight.w400,
  //     fontStyle: FontStyle.normal,
  //   ),
  //   subhead: TextStyle(
  //     color: Color(0xffffffff),
  //     fontSize: null,
  //     fontWeight: FontWeight.w400,
  //     fontStyle: FontStyle.normal,
  //   ),
  //   body2: TextStyle(
  //     color: Color(0xffffffff),
  //     fontSize: null,
  //     fontWeight: FontWeight.w400,
  //     fontStyle: FontStyle.normal,
  //   ),
  //   body1: TextStyle(
  //     color: Color(0xffffffff),
  //     fontSize: null,
  //     fontWeight: FontWeight.w400,
  //     fontStyle: FontStyle.normal,
  //   ),
  //   caption: TextStyle(
  //     color: Color(0xb3ffffff),
  //     fontSize: null,
  //     fontWeight: FontWeight.w400,
  //     fontStyle: FontStyle.normal,
  //   ),
  //   button: TextStyle(
  //     color: Color(0xffffffff),
  //     fontSize: null,
  //     fontWeight: FontWeight.w400,
  //     fontStyle: FontStyle.normal,
  //   ),
  //   subtitle: TextStyle(
  //     color: Color(0xffffffff),
  //     fontSize: null,
  //     fontWeight: FontWeight.w400,
  //     fontStyle: FontStyle.normal,
  //   ),
  //   overline: TextStyle(
  //     color: Color(0xffffffff),
  //     fontSize: null,
  //     fontWeight: FontWeight.w400,
  //     fontStyle: FontStyle.normal,
  //   ),
  // ),
  // inputDecorationTheme: InputDecorationTheme(
  //   labelStyle: TextStyle(
  //     color: Color(0xdd000000),
  //     fontSize: null,
  //     fontWeight: FontWeight.w400,
  //     fontStyle: FontStyle.normal,
  //   ),
  //   helperStyle: TextStyle(
  //     color: Color(0xdd000000),
  //     fontSize: null,
  //     fontWeight: FontWeight.w400,
  //     fontStyle: FontStyle.normal,
  //   ),
  //   hintStyle: TextStyle(
  //     color: Color(0xdd000000),
  //     fontSize: null,
  //     fontWeight: FontWeight.w400,
  //     fontStyle: FontStyle.normal,
  //   ),
  //   errorStyle: TextStyle(
  //     color: Color(0xdd000000),
  //     fontSize: null,
  //     fontWeight: FontWeight.w400,
  //     fontStyle: FontStyle.normal,
  //   ),
  //   errorMaxLines: null,
  //   hasFloatingPlaceholder: true,
  //   isDense: false,
  //   contentPadding: EdgeInsets.only(top: 12, bottom: 12, left: 0, right: 0),
  //   isCollapsed: false,
  //   prefixStyle: TextStyle(
  //     color: Color(0xdd000000),
  //     fontSize: null,
  //     fontWeight: FontWeight.w400,
  //     fontStyle: FontStyle.normal,
  //   ),
  //   suffixStyle: TextStyle(
  //     color: Color(0xdd000000),
  //     fontSize: null,
  //     fontWeight: FontWeight.w400,
  //     fontStyle: FontStyle.normal,
  //   ),
  //   counterStyle: TextStyle(
  //     color: Color(0xdd000000),
  //     fontSize: null,
  //     fontWeight: FontWeight.w400,
  //     fontStyle: FontStyle.normal,
  //   ),
  //   filled: false,
  //   fillColor: Color(0x00000000),
  //   errorBorder: UnderlineInputBorder(
  //     borderSide: BorderSide(
  //       color: Color(0xff000000),
  //       width: 1,
  //       style: BorderStyle.solid,
  //     ),
  //     borderRadius: BorderRadius.all(Radius.circular(4.0)),
  //   ),
  //   focusedBorder: UnderlineInputBorder(
  //     borderSide: BorderSide(
  //       color: Color(0xff000000),
  //       width: 1,
  //       style: BorderStyle.solid,
  //     ),
  //     borderRadius: BorderRadius.all(Radius.circular(4.0)),
  //   ),
  //   focusedErrorBorder: UnderlineInputBorder(
  //     borderSide: BorderSide(
  //       color: Color(0xff000000),
  //       width: 1,
  //       style: BorderStyle.solid,
  //     ),
  //     borderRadius: BorderRadius.all(Radius.circular(4.0)),
  //   ),
  //   disabledBorder: UnderlineInputBorder(
  //     borderSide: BorderSide(
  //       color: Color(0xff000000),
  //       width: 1,
  //       style: BorderStyle.solid,
  //     ),
  //     borderRadius: BorderRadius.all(Radius.circular(4.0)),
  //   ),
  //   enabledBorder: UnderlineInputBorder(
  //     borderSide: BorderSide(
  //       color: Color(0xff000000),
  //       width: 1,
  //       style: BorderStyle.solid,
  //     ),
  //     borderRadius: BorderRadius.all(Radius.circular(4.0)),
  //   ),
  //   border: UnderlineInputBorder(
  //     borderSide: BorderSide(
  //       color: Color(0xff000000),
  //       width: 1,
  //       style: BorderStyle.solid,
  //     ),
  //     borderRadius: BorderRadius.all(Radius.circular(4.0)),
  //   ),
  // ),
  iconTheme: const IconThemeData(
    color: Color(0xFF219EBC),
    opacity: 1,
    size: 24,
  ),
  primaryIconTheme: const IconThemeData(
    color: Color(0xFF219EBC),
    opacity: 1,
    size: 24,
  ),
  // sliderTheme: SliderThemeData(
  //   activeTrackColor: null,
  //   inactiveTrackColor: null,
  //   disabledActiveTrackColor: null,
  //   disabledInactiveTrackColor: null,
  //   activeTickMarkColor: null,
  //   inactiveTickMarkColor: null,
  //   disabledActiveTickMarkColor: null,
  //   disabledInactiveTickMarkColor: null,
  //   thumbColor: null,
  //   disabledThumbColor: null,
  //   thumbShape: null(),
  //   overlayColor: null,
  //   valueIndicatorColor: null,
  //   valueIndicatorShape: null(),
  //   showValueIndicator: null,
  //   valueIndicatorTextStyle: TextStyle(
  //     color: Color(0xffffffff),
  //     fontSize: null,
  //     fontWeight: ontWeight.w400,
  //     fontStyle: FontStyle.normal,
  //   ),
  // ),
  tabBarTheme: const TabBarTheme(
    indicatorSize: TabBarIndicatorSize.tab,
    labelColor: Color(0xdd000000),
    unselectedLabelColor: Color(0xb2000000),
  ),
  chipTheme: const ChipThemeData(
    backgroundColor: Color(0x1f000000),
    brightness: Brightness.light,
    deleteIconColor: Color(0xde000000),
    disabledColor: Color(0x0c000000),
    labelPadding: EdgeInsets.only(top: 0, bottom: 0, left: 8, right: 8),
    labelStyle: TextStyle(
      color: Color(0xde000000),
      fontSize: null,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
    ),
    padding: EdgeInsets.only(top: 4, bottom: 4, left: 4, right: 4),
    secondaryLabelStyle: TextStyle(
      color: Color(0x3d000000),
      fontSize: null,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
    ),
    secondarySelectedColor: Color(0x3dffffff),
    selectedColor: Color(0x3d000000),
    shape: StadiumBorder(
        side: BorderSide(
      color: Color(0xff000000),
      width: 0,
      style: BorderStyle.none,
    )),
  ),
  dialogTheme: const DialogTheme(
      shape: RoundedRectangleBorder(
    side: BorderSide(
      color: Color(0xff000000),
      width: 0,
      style: BorderStyle.none,
    ),
    borderRadius: BorderRadius.all(Radius.circular(0.0)),
  )), checkboxTheme: CheckboxThemeData(
 fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
 if (states.contains(MaterialState.disabled)) { return null; }
 if (states.contains(MaterialState.selected)) { return const Color(0xff666666); }
 return null;
 }),
 ), radioTheme: RadioThemeData(
 fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
 if (states.contains(MaterialState.disabled)) { return null; }
 if (states.contains(MaterialState.selected)) { return const Color(0xff666666); }
 return null;
 }),
 ), switchTheme: SwitchThemeData(
 thumbColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
 if (states.contains(MaterialState.disabled)) { return null; }
 if (states.contains(MaterialState.selected)) { return const Color(0xff666666); }
 return null;
 }),
 trackColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
 if (states.contains(MaterialState.disabled)) { return null; }
 if (states.contains(MaterialState.selected)) { return const Color(0xff666666); }
 return null;
 }),
 ), bottomAppBarTheme: const BottomAppBarTheme(color: Color(0x00ffffff)), colorScheme: ColorScheme.fromSwatch(primarySwatch: zdvmOrange)
      .copyWith(secondary: zdvmOrange).copyWith(background: const Color(0xffeeeef0)).copyWith(error: const Color(0xffd32f2f)),
);
