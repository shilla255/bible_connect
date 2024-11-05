class AudioBook {
  final String id;
  final String bibleId;
  final String abbreviation;
  final String name;
  final String nameLong;
 // final List<AudioChapter> chapters;

  AudioBook({
    required this.id,
    required this.bibleId,
    required this.abbreviation,
    required this.name,
    required this.nameLong,
  //  required this.chapters,
  });

  factory AudioBook.fromJson(Map<String, dynamic> json) {
    var chapterList = json['chapters'] as List? ?? [];
    // List<AudioChapter> chapters = chapterList.map((item) => AudioChapter.fromJson(item)).toList();

    return AudioBook(
      id: json['id'] ?? '',
      bibleId: json['bibleId'] ?? '',
      abbreviation: json['abbreviation'] ?? '',
      name: json['name'] ?? '',
      nameLong: json['nameLong'] ?? '',
      // chapters: chapters,
    );
  }
}

// class AudioChapter {
//   final String id;
//   final String bibleId;
//   final String number;
//   final String bookId;
//   final String reference;
//
//   AudioChapter({
//     required this.id,
//     required this.bibleId,
//     required this.number,
//     required this.bookId,
//     required this.reference,
//   });
//
//   factory AudioChapter.fromJson(Map<String, dynamic> json) {
//     return AudioChapter(
//       id: json['id'] ?? '',
//       bibleId: json['bibleId'] ?? '',
//       number: json['number'] ?? '',
//       bookId: json['bookId'] ?? '',
//       reference: json['reference'] ?? '',
//     );
//   }
// }

