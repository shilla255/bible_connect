import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: Colors.blue.shade600,
    secondary: Colors.teal.shade500,
    tertiary: Colors.orange.shade400,
    surface: Colors.white,
    error: Colors.red.shade600,
  ),
  scaffoldBackgroundColor: Colors.grey.shade50,

  // AppBar Theme
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.blue.shade600,
    elevation: 2,
    centerTitle: true,
    titleTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
    iconTheme: const IconThemeData(color: Colors.white),
  ),

  // Card Theme
  cardTheme: CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: Colors.white,
  ),

  // Button Themes
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
    ),
  ),

  // Input Decoration
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey.shade100,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),

  // Text Theme
  textTheme: TextTheme(
    displayLarge: TextStyle(
      color: Colors.grey.shade900,
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
    displayMedium: TextStyle(
      color: Colors.grey.shade900,
      fontSize: 28,
      fontWeight: FontWeight.bold,
    ),
    bodyLarge: TextStyle(
      color: Colors.grey.shade800,
      fontSize: 16,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      color: Colors.grey.shade800,
      fontSize: 14,
      height: 1.5,
    ),
  ),

  // Divider Theme
  dividerTheme: DividerThemeData(
    color: Colors.grey.shade200,
    thickness: 1,
    space: 24,
  ),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: Colors.blue.shade400,
    secondary: Colors.teal.shade400,
    tertiary: Colors.orange.shade300,
    surface: Colors.grey.shade800,
    error: Colors.red.shade400,
  ),
  scaffoldBackgroundColor: Colors.grey.shade900,

  // AppBar Theme
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey.shade900,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
    iconTheme: const IconThemeData(color: Colors.white),
  ),

  // Card Theme
  cardTheme: CardTheme(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: Colors.grey.shade800,
  ),

  // Button Themes
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
    ),
  ),

  // Input Decoration
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey.shade800,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade700),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade700),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.blue.shade300, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),

  // Text Theme
  textTheme: TextTheme(
    displayLarge: TextStyle(
      color: Colors.grey.shade100,
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
    displayMedium: TextStyle(
      color: Colors.grey.shade100,
      fontSize: 28,
      fontWeight: FontWeight.bold,
    ),
    bodyLarge: TextStyle(
      color: Colors.grey.shade300,
      fontSize: 16,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      color: Colors.grey.shade300,
      fontSize: 14,
      height: 1.5,
    ),
  ),

  // Divider Theme
  dividerTheme: DividerThemeData(
    color: Colors.grey.shade700,
    thickness: 1,
    space: 24,
  ),
);