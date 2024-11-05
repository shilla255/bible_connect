class AudioBible {
  final String id;
  final String abbreviation;
  final String name;
  final String language;
  final String updatedAt;

  AudioBible({
    required this.id,
    required this.abbreviation,
    required this.name,
    required this.language,
    required this.updatedAt,
  });

  factory AudioBible.fromJson(Map<String, dynamic> json) {
    return AudioBible(
      id: json['id'] ?? '',
      abbreviation: json['abbreviation'] ?? '',
      name: json['name'] ?? '',
      language: json['language']['name'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}
