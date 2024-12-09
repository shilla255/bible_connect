import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: Colors.indigo.shade600,
    secondary: Colors.purple.shade500,
    tertiary: Colors.pink.shade400,
    surface: Colors.white,
    error: Colors.red.shade600,
  ),
  scaffoldBackgroundColor: Colors.grey.shade50,

  // AppBar Theme with Gradient
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
    ),
    iconTheme: IconThemeData(color: Colors.white),
    systemOverlayStyle: SystemUiOverlayStyle.light,
    // flexibleSpace: Container(
    //   decoration: BoxDecoration(
    //     gradient: LinearGradient(
    //       begin: Alignment.topLeft,
    //       end: Alignment.bottomRight,
    //       colors: [
    //         Colors.indigo.shade600,
    //         Colors.purple.shade500,
    //       ],
    //     ),
    //   ),
    // ),
  ),

  // Card Theme with Subtle Gradient
  cardTheme: CardTheme(
    elevation: 8,
    shadowColor: Colors.purple.shade100,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: Colors.white,
    clipBehavior: Clip.antiAlias,
  ),

  // Button Themes with Gradient
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      shadowColor: Colors.purple.shade200,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
    ).copyWith(
      backgroundColor: WidgetStateProperty.all(Colors.transparent),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.pressed)
            ? Colors.white.withOpacity(0.1)
            : null;
      }),
    ),
  ),

  // Input Decoration with Enhanced Focus States
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey.shade100,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.purple.shade400, width: 3),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    labelStyle: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500),
    floatingLabelStyle: TextStyle(color: Colors.purple.shade500, fontWeight: FontWeight.bold),
  ),

  // Enhanced Text Theme
  textTheme: TextTheme(
    displayLarge: TextStyle(
      color: Colors.grey.shade900,
      fontSize: 36,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
    ),
    displayMedium: TextStyle(
      color: Colors.grey.shade900,
      fontSize: 32,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.3,
    ),
    bodyLarge: TextStyle(
      color: Colors.grey.shade800,
      fontSize: 18,
      height: 1.6,
      letterSpacing: 0.2,
    ),
    bodyMedium: TextStyle(
      color: Colors.grey.shade800,
      fontSize: 16,
      height: 1.6,
      letterSpacing: 0.1,
    ),
  ),

  // Modern Divider Theme
  dividerTheme: DividerThemeData(
    color: Colors.grey.shade200,
    thickness: 2,
    space: 32,
  ),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: Colors.purple.shade300,
    secondary: Colors.pink.shade300,
    tertiary: Colors.indigo.shade300,
    surface: const Color(0xFF1E1E2E),
    error: Colors.red.shade300,
  ),
  scaffoldBackgroundColor: const Color(0xFF0F0F17),

  // AppBar Theme with Dark Gradient
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
    ),
    iconTheme: IconThemeData(color: Colors.white),
    systemOverlayStyle: SystemUiOverlayStyle.light,
  ),

  // Card Theme with Glowing Effect
  cardTheme: CardTheme(
    elevation: 12,
    shadowColor: Colors.purple.shade900.withOpacity(0.5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: const Color(0xFF1E1E2E),
    clipBehavior: Clip.antiAlias,
  ),

  // Button Themes with Gradient
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      shadowColor: Colors.purple.shade900,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
    ).copyWith(
      backgroundColor: WidgetStateProperty.all(Colors.transparent),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.pressed)
            ? Colors.white.withOpacity(0.1)
            : null;
      }),
    ),
  ),

  // Input Decoration with Neon Accents
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF2D2D44),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF3D3D54), width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF3D3D54), width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.purple.shade300, width: 3),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    labelStyle: TextStyle(color: Colors.grey.shade300, fontWeight: FontWeight.w500),
    floatingLabelStyle: TextStyle(color: Colors.purple.shade300, fontWeight: FontWeight.bold),
  ),

  // Enhanced Dark Text Theme
  textTheme: TextTheme(
    displayLarge: const TextStyle(
      color: Colors.white,
      fontSize: 36,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
    ),
    displayMedium: const TextStyle(
      color: Colors.white,
      fontSize: 32,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.3,
    ),
    bodyLarge: TextStyle(
      color: Colors.grey.shade100,
      fontSize: 18,
      height: 1.6,
      letterSpacing: 0.2,
    ),
    bodyMedium: TextStyle(
      color: Colors.grey.shade100,
      fontSize: 16,
      height: 1.6,
      letterSpacing: 0.1,
    ),
  ),

  // Modern Dark Divider Theme
  dividerTheme: const DividerThemeData(
    color: Color(0xFF3D3D54),
    thickness: 2,
    space: 32,
  ),
);