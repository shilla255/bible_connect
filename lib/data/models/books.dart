import 'chapter.dart'; // Import the Chapter class from chapter.dart

class Book {
  final String id;
  final String name;
  final String abbreviation;
  final List<Chapter>? chapters;

  Book({
    required this.id,
    required this.name,
    required this.abbreviation,
    this.chapters,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      name: json['name'],
      abbreviation: json['abbreviation'],
      chapters: json['chapters'] != null
          ? (json['chapters'] as List)
          .map((chapter) => Chapter.fromJson(chapter))
          .toList()
          : null,
    );
  }
}
