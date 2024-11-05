import 'dart:convert';
import 'package:http/http.dart' as http;


import '../data/models/quote.dart';

Future<List<Quote>> fetchQuotes() async {
  final response = await http.get(Uri.parse('https://zenquotes.io/api/quotes'));

  if (response.statusCode == 200) {
    List<dynamic> quotesJson = json.decode(response.body);
    return quotesJson.map((json) => Quote.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load quotes');
  }
}
