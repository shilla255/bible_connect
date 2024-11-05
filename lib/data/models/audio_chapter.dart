class AudioChapter {
  final String id;
  final String bibleId;
  final String number;
  final String bookId;
  final String reference;
  final String resourceUrl;

  AudioChapter({
    required this.id,
    required this.bibleId,
    required this.number,
    required this.bookId,
    required this.reference,
    required this.resourceUrl,
  });

  factory AudioChapter.fromJson(Map<String, dynamic> json) {
    return AudioChapter(
      id: json['id'],
      bibleId: json['bibleId'],
      number: json['number'],
      bookId: json['bookId'],
      reference: json['reference'],
      resourceUrl: json['resourceUrl'] ?? '',
    );
  }
}
