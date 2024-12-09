


class Channel {
  final String name;
  final String url;

  Channel({required this.name, required this.url});

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }
}
