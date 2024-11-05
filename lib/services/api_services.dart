import 'dart:convert';
import 'package:bible/data/models/books.dart';
import 'package:http/http.dart' as http;
import '../data/models/bible.dart';
import '../data/models/chapter.dart';

class BibleApiService {
  final String baseUrl = "https://api.scripture.api.bible/v1/bibles";
  final String apiToken = "3cfa647db90259904574ed5cc1795e8f"; // Replace with your actual API token

  Future<List<Book>> fetchBooks({
    required String bibleId,
    bool includeChapters = false,
    bool includeChaptersAndSections = false,
  }) async {
    final queryParams = {
      'include-chapters': includeChapters.toString(),
      'include-chapters-and-sections': includeChaptersAndSections.toString(),
    };

    final uri = Uri.parse('$baseUrl/$bibleId/books').replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: {
        'api-key': apiToken,
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['data'];
      return data.map((book) => Book.fromJson(book)).toList();
    } else {
      throw Exception('Failed to load books: ${response.statusCode} ${response.body}');
    }
  }

  Future<List<Chapter>> fetchChapters({
    required String bibleId,
    required String bookId,
  }) async {
    final uri = Uri.parse('$baseUrl/$bibleId/books/$bookId/chapters');

    final response = await http.get(
      uri,
      headers: {
        'api-key': apiToken,
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['data'];
      return data.map((chapter) => Chapter.fromJson(chapter)).toList();
    } else {
      throw Exception('Failed to load chapters: ${response.statusCode} ${response.body}');
    }
  }

  Future<ChapterDetail> fetchChapterDetails({
    required String bibleId,
    required String chapterId,
  }) async {
    final uri = Uri.parse('$baseUrl/$bibleId/chapters/$chapterId');

    final response = await http.get(
      uri,
      headers: {
        'api-key': apiToken,
        'Accept': 'application/json', // Ensure the response is JSON
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body)['data'];
      return ChapterDetail.fromJson(data); // Parse the entire ChapterDetail object
    } else {
      throw Exception('Failed to load chapter details: ${response.statusCode} ${response.body}');
    }
  }


  Future<List<Bible>> fetchBibles() async {
    final uri = Uri.parse(baseUrl);

    final response = await http.get(
      uri,
      headers: {
        'api-key': apiToken,
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['data'];
      return data.map((bible) => Bible.fromJson(bible)).toList();
    } else {
      throw Exception('Failed to load bibles: ${response.statusCode} ${response.body}');
    }
  }
}
