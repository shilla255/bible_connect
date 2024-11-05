class Verse {
  final String id;
  final String orgId;
  final String bibleId;
  final String bookId;
  final String chapterId;
  final String reference;
  final List<dynamic> content; // Changed to List<dynamic>

  Verse({
    required this.id,
    required this.orgId,
    required this.bibleId,
    required this.bookId,
    required this.chapterId,
    required this.reference,
    required this.content, // Initialize content
  });

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      id: json['id'] ?? '',
      orgId: json['orgId'] ?? '',
      bibleId: json['bibleId'] ?? '',
      bookId: json['bookId'] ?? '',
      chapterId: json['chapterId'] ?? '',
      reference: json['reference'] ?? '',
      content: json['content'] ?? [], // Parse content field
    );
  }
}
