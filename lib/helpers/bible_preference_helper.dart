import 'package:shared_preferences/shared_preferences.dart';

class BiblePreference {
  static const _keySelectedBible = 'selectedBible';

  static Future<void> saveSelectedBible(String bibleId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedBible, bibleId);
  }

  static Future<String?> getSelectedBible() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySelectedBible);
  }

  static Future<void> clearSelectedBible() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySelectedBible);
  }
}
