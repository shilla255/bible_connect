import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:bible/services/audio_service.dart';
import '../../../../data/models/audio_chapter_detail.dart';

class AudioPlayerPage extends StatefulWidget {
  final String audioBibleId;
  final String chapterId;

  const AudioPlayerPage({super.key, required this.audioBibleId, required this.chapterId});

  @override
  _AudioPlayerPageState createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> with SingleTickerProviderStateMixin {
  late Future<AudioChapterDetail> futureAudioChapterDetail;
  late AudioPlayer audioPlayer;
  late AnimationController _iconController;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool isPlaying = false;
  double playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    futureAudioChapterDetail = MyAudioService().fetchAudioChapterDetail(widget.audioBibleId, widget.chapterId);
    audioPlayer = AudioPlayer();

    futureAudioChapterDetail.then((audioChapterDetail) {
      audioPlayer.play(UrlSource(audioChapterDetail.resourceUrl)); // Autoplay
    });

    audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        _duration = duration;
      });
    });

    audioPlayer.onPositionChanged.listen((Duration position) {
      setState(() {
        _position = position;
      });
    });

    audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
        if (isPlaying) {
          _iconController.forward();
        } else {
          _iconController.reverse();
        }
      });
    });
  }

  @override
  void dispose() {
    _iconController.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
  final theme = Theme.of(context);

  return Scaffold(
    extendBodyBehindAppBar: true,
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: theme.brightness == Brightness.dark
              ? [Colors.blue[900]!, Colors.blue[600]!, Colors.blue[400]!]
              : [Colors.blue[400]!, Colors.blue[600]!, Colors.blue[900]!],
        ),
      ),
      child: FutureBuilder<AudioChapterDetail>(
        future: futureAudioChapterDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No audio chapter available', style: TextStyle(color: Colors.white)));
          } else {
            final audioChapterDetail = snapshot.data!;
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        CupertinoIcons.book,
                        size: 100,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      audioChapterDetail.reference,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 60),
                    Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.white,
                            inactiveTrackColor: Colors.white.withOpacity(0.3),
                            thumbColor: Colors.white,
                            trackHeight: 4.0,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                            overlayColor: Colors.white.withOpacity(0.4),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
                          ),
                          child: Slider(
                            min: 0,
                            max: _duration.inSeconds.toDouble(),
                            value: _position.inSeconds.toDouble(),
                            onChanged: (double value) async {
                              final position = Duration(seconds: value.toInt());
                              await audioPlayer.seek(position);
                              await audioPlayer.resume();
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(_position),
                                style: TextStyle(color: Colors.white.withOpacity(0.7)),
                              ),
                              Text(
                                _formatDuration(_duration - _position),
                                style: TextStyle(color: Colors.white.withOpacity(0.7)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.replay_10, color: Colors.white, size: 40),
                          onPressed: () async {
                            await audioPlayer.seek(_position - const Duration(seconds: 10));
                          },
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () {
                            if (isPlaying) {
                              audioPlayer.pause();
                            } else {
                              audioPlayer.play(UrlSource(audioChapterDetail.resourceUrl));
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: AnimatedIcon(
                              icon: AnimatedIcons.play_pause,
                              progress: _iconController,
                              size: 50,
                              color: Colors.blue[900],
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          icon: const Icon(Icons.forward_10, color: Colors.white, size: 40),
                          onPressed: () async {
                            await audioPlayer.seek(_position + const Duration(seconds: 10));
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.speed, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          DropdownButton<double>(
                            value: playbackSpeed,
                            dropdownColor: Colors.blue[900],
                            underline: Container(),
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                            items: [0.5, 1.0, 1.5, 2.0].map((double value) {
                              return DropdownMenuItem<double>(
                                value: value,
                                child: Text(
                                  '${value}x',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                            onChanged: (double? value) {
                              setState(() {
                                playbackSpeed = value!;
                                // audioPlayer.setPlaybackRate(playbackRate: playbackSpeed);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    ),
  );
}
}