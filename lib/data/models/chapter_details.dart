class ChapterDetail {
  final String id;
  final String bibleId;
  final String bookId;
  final int chapter;
  final int verseCount;
  final String reference;
  final String text;

  ChapterDetail({
    required this.id,
    required this.bibleId,
    required this.bookId,
    required this.chapter,
    required this.verseCount,
    required this.reference,
    required this.text,
  });

  factory ChapterDetail.fromJson(Map<String, dynamic> json) {
    return ChapterDetail(
      id: json['id'],
      bibleId: json['bibleId'],
      bookId: json['bookId'],
      chapter: json['chapter'],
      verseCount: json['verseCount'],
      reference: json['reference'],
      text: json['text'],
    );
  }
}
