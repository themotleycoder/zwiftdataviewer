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

// final ThemeData myTheme = ThemeData(
const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF006495),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFCBE6FF),
  onPrimaryContainer: Color(0xFF001E31),
  secondary: Color(0xFF50606F),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFD4E4F6),
  onSecondaryContainer: Color(0xFF0D1D2A),
  tertiary: Color(0xFFA04013),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFFFDBCE),
  onTertiaryContainer: Color(0xFF370E00),
  error: Color(0xFFBA1A1A),
  errorContainer: Color(0xFFFFDAD6),
  onError: Color(0xFFFFFFFF),
  onErrorContainer: Color(0xFF410002),
  background: Color(0xFFFFFFFF),
  onBackground: Color(0xFF1A1C1E),
  surface: Color(0xFFFCFCFF),
  onSurface: Color(0xFF1A1C1E),
  surfaceVariant: Color(0xFFDEE3EA),
  onSurfaceVariant: Color(0xFF42474D),
  outline: Color(0xFF72787E),
  onInverseSurface: Color(0xFFF0F0F3),
  inverseSurface: Color(0xFF2F3133),
  inversePrimary: Color(0xFF90CDFF),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF006495),
  outlineVariant: Color(0xFFC1C7CE),
  scrim: Color(0xFF000000),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF90CDFF),
  onPrimary: Color(0xFF003350),
  primaryContainer: Color(0xFF004B72),
  onPrimaryContainer: Color(0xFFCBE6FF),
  secondary: Color(0xFFB8C8D9),
  onSecondary: Color(0xFF22323F),
  secondaryContainer: Color(0xFF394856),
  onSecondaryContainer: Color(0xFFD4E4F6),
  tertiary: Color(0xFFFFB599),
  onTertiary: Color(0xFF5A1C00),
  tertiaryContainer: Color(0xFF7F2B00),
  onTertiaryContainer: Color(0xFFFFDBCE),
  error: Color(0xFFFFB4AB),
  errorContainer: Color(0xFF93000A),
  onError: Color(0xFF690005),
  onErrorContainer: Color(0xFFFFDAD6),
  background: Color(0xFF1A1C1E),
  onBackground: Color(0xFFE2E2E5),
  surface: Color(0xFF1A1C1E),
  onSurface: Color(0xFFE2E2E5),
  surfaceVariant: Color(0xFF42474D),
  onSurfaceVariant: Color(0xFFC1C7CE),
  outline: Color(0xFF8C9198),
  onInverseSurface: Color(0xFF1A1C1E),
  inverseSurface: Color(0xFFE2E2E5),
  inversePrimary: Color(0xFF006495),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF90CDFF),
  outlineVariant: Color(0xFF42474D),
  scrim: Color(0xFF000000),
);
