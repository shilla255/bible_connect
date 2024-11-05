import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bible/data/models/Audio.dart';
import 'package:bible/data/models/audio_book.dart';
import 'package:bible/data/models/audio_chapter.dart';
import 'package:bible/data/models/audio_chapter_detail.dart';

class MyAudioService {
  final String baseUrl = 'https://api.scripture.api.bible/v1/audio-bibles';
  final String apiToken = '3cfa647db90259904574ed5cc1795e8f';

  Future<List<AudioBible>> fetchAudioBibles() async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'api-key': apiToken,
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => AudioBible.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load audio Bibles: ${response.reasonPhrase}');
    }
  }

  Future<List<AudioBook>> fetchAudioBooks(String bibleId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$bibleId/books'),
      headers: {
        'api-key': apiToken,
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => AudioBook.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load audio books: ${response.reasonPhrase}');
    }
  }

  Future<List<AudioChapter>> fetchChapters(String bibleId, String bookId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$bibleId/books/$bookId/chapters'),
      headers: {
        'api-key': apiToken,
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => AudioChapter.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load chapters: ${response.reasonPhrase}');
    }
  }

  Future<AudioChapter> fetchAudioChapter(String chapterId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/chapters/$chapterId'),
      headers: {
        'api-key': apiToken,
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body)['data'];
      return AudioChapter.fromJson(data);
    } else {
      throw Exception('Failed to load audio chapter: ${response.reasonPhrase}');
    }
  }

  Future<AudioChapterDetail> fetchAudioChapterDetail(String audioBibleId, String chapterId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$audioBibleId/chapters/$chapterId'),
      headers: {
        'api-key': apiToken,
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body)['data'];
      return AudioChapterDetail.fromJson(data);
    } else {
      throw Exception('Failed to load audio chapter details: ${response.reasonPhrase}');
    }
  }
}

