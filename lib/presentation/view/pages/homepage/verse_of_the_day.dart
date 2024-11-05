import 'package:bible/services/verse_api_service.dart';

class VerseOfTheDayService {
  static Future<Map<String, dynamic>> fetchVerse() async {
    return await ApiService.fetchRandomVerse();
  }
}