class AudioChapterDetail {
  final String id;
  final String bibleId;
  final String number;
  final String bookId;
  final String resourceUrl;
  final int expiresAt; // Ensure this is an int if it is returned as int
  final String reference;

  AudioChapterDetail({
    required this.id,
    required this.bibleId,
    required this.number,
    required this.bookId,
    required this.resourceUrl,
    required this.expiresAt,
    required this.reference,
  });

  factory AudioChapterDetail.fromJson(Map<String, dynamic> json) {
    // Check if expiresAt is a string and convert to int if necessary
    int expiresAt = json['expiresAt'] is String ? int.parse(json['expiresAt']) : json['expiresAt'];
    return AudioChapterDetail(
      id: json['id'],
      bibleId: json['bibleId'],
      number: json['number'],
      bookId: json['bookId'],
      resourceUrl: json['resourceUrl'],
      expiresAt: expiresAt,
      reference: json['reference'],
    );
  }
}
