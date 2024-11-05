class Bible {
  final String id;
  final String name;
  final String abbreviation;
  final String language;

  Bible({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.language,
  });

  factory Bible.fromJson(Map<String, dynamic> json) {
    return Bible(
      id: json['id'],
      name: json['name'],
      abbreviation: json['abbreviation'],
      language: json['language']['name'],
    );
  }
}
