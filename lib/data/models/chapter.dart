class Chapter {
  final String id;
  final String number;
  final ChapterDetail? detail;

  Chapter({
    required this.id,
    required this.number,
    this.detail,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'],
      number: json['number'],
      detail: json['detail'] != null ? ChapterDetail.fromJson(json['detail']) : null,
    );
  }
}

class ChapterDetail {
  final String id;
  final String number;
  final String title;
  final String content;
  final String reference;
  final ChapterNavigation? next;
  final ChapterNavigation? previous;

  ChapterDetail({
    required this.id,
    required this.number,
    required this.title,
    required this.content,
    required this.reference,
    this.next,
    this.previous,
  });

  factory ChapterDetail.fromJson(Map<String, dynamic> json) {
    return ChapterDetail(
      id: json['id'],
      number: json['number'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      reference: json['reference'] ?? '',
      next: json['next'] != null ? ChapterNavigation.fromJson(json['next']) : null,
      previous: json['previous'] != null ? ChapterNavigation.fromJson(json['previous']) : null,
    );
  }
}

class ChapterNavigation {
  final String id;
  final String bookId;
  final String number;

  ChapterNavigation({
    required this.id,
    required this.bookId,
    required this.number,
  });

  factory ChapterNavigation.fromJson(Map<String, dynamic> json) {
    return ChapterNavigation(
      id: json['id'],
      bookId: json['bookId'],
      number: json['number'],
    );
  }
}
