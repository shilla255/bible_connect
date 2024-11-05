import 'package:bible/theme/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeData> {
  static const String _themeKey = 'isDarkTheme';

  ThemeNotifier() : super(lightTheme) {
    _loadTheme();
  }

  // Load theme from SharedPreferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkTheme = prefs.getBool(_themeKey) ?? false;
    state = isDarkTheme ? darkTheme : lightTheme;
  }

  // Toggle theme and save preference
  void toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (state.brightness == Brightness.dark) {
      state = lightTheme;
      await prefs.setBool(_themeKey, false);
    } else {
      state = darkTheme;
      await prefs.setBool(_themeKey, true);
    }
  }
}
