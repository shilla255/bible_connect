// models/channel.dart
class Channel {
  final String name;
  final String url;

  Channel({required this.name, required this.url});
}

final List<Channel> channels = [
  Channel(name: 'Worship Channel One', url: 'https://webstreaming.viewmedia.tv/web_014/Stream/playlist.m3u8'),
  Channel(name: 'BCS StarCross TV', url: 'https://webstreaming.viewmedia.tv/web_001/Stream/playlist.m3u8'),
  Channel(name: 'Choosen TV', url: 'https://webstreaming-2.viewmedia.tv/web_024/Stream/playlist.m3u8'),
  Channel(name: 'Coza TV', url: 'https://webstreaming-7.viewmedia.tv/web_097/Stream/playlist.m3u8'),
  Channel(name: 'Dova TV', url: 'https://webstreaming-7.viewmedia.tv/web_093/Stream/live93_3/high/playlist.m3u8'),
  Channel(name: 'Synagogue TV', url: 'https://webstreaming.viewmedia.tv/web_038/Stream/playlist.m3u8'),
];
