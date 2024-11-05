import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<Map<String, dynamic>> fetchRandomVerse() async {
    final response = await http.get(Uri.parse('https://labs.bible.org/api/?passage=random&type=json'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      if (jsonData.isNotEmpty) {
        return jsonData[0];
      } else {
        throw Exception('Failed to load verse');
      }
    } else {
      throw Exception('Failed to load verse');
    }
  }
}
