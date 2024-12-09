import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';

class VideoStreamWidget extends StatefulWidget {
  final String streamUrl;
  final String? title;

  const VideoStreamWidget({
    super.key,
    required this.streamUrl,
    this.title,
  });

  @override
  _VideoStreamWidgetState createState() => _VideoStreamWidgetState();
}

class _VideoStreamWidgetState extends State<VideoStreamWidget> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _showControls = true;
  bool _isFullScreen = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.streamUrl))
      ..initialize().then((_) {
        setState(() {
          _duration = _controller.value.duration;
          _isPlaying = true;
          _controller.play();
        });
      });

    // Add listener for position updates
    _controller.addListener(() {
      if (mounted) {
        setState(() {
          _position = _controller.value.position;
        });
      }
    });

    // Auto-hide controls after 3 seconds
    _startHideTimer();
  }

  void _startHideTimer() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _showControls && _isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
        _startHideTimer();
      }
      _isPlaying = !_isPlaying;
    });
  }

  void _seekTo(Duration position) {
    _controller.seekTo(position);
  }

  void _skipForward() {
    final newPosition = _position + const Duration(seconds: 10);
    if (newPosition <= _duration) {
      _seekTo(newPosition);
    }
  }

  void _skipBackward() {
    final newPosition = _position - const Duration(seconds: 10);
    if (newPosition >= Duration.zero) {
      _seekTo(newPosition);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            setState(() {
              _showControls = !_showControls;
              if (_showControls) {
                _startHideTimer();
              }
            });
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Video Player
              Center(
                child: _controller.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      )
                    : const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
              ),

              // Gradient overlays for better visibility
              if (_showControls) ...[
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.center,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.center,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              // Top bar with back button and title
              if (_showControls)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        if (widget.title != null) ...[
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              widget.title!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

              // Center play/pause button
              if (_showControls)
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildControlButton(
                        Icons.replay_10,
                        _skipBackward,
                        size: 40,
                      ),
                      const SizedBox(width: 32),
                      _buildControlButton(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        _togglePlayPause,
                        size: 64,
                      ),
                      const SizedBox(width: 32),
                      _buildControlButton(
                        Icons.forward_10,
                        _skipForward,
                        size: 40,
                      ),
                    ],
                  ),
                ),

              // Bottom controls
              if (_showControls)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Progress bar
                        SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 2,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 12,
                            ),
                            trackShape: CustomTrackShape(),
                          ),
                          child: Slider(
                            value: _position.inMilliseconds.clamp(0, _duration.inMilliseconds).toDouble(),
                            min: 0,
                            max: _duration.inMilliseconds.toDouble(),
                            onChanged: (value) {
                              _seekTo(Duration(milliseconds: value.toInt()));
                            },
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Bottom row with time and controls
                        Row(
                          children: [
                            // Time
                            Text(
                              '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const Spacer(),

                            // Rotation and fullscreen
                            IconButton(
                              icon: const Icon(Icons.screen_rotation, color: Colors.white),
                              onPressed: () {
                                SystemChrome.setPreferredOrientations([
                                  DeviceOrientation.landscapeRight,
                                  DeviceOrientation.landscapeLeft,
                                ]);
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isFullScreen = !_isFullScreen;
                                  if (_isFullScreen) {
                                    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
                                    SystemChrome.setPreferredOrientations([
                                      DeviceOrientation.landscapeRight,
                                      DeviceOrientation.landscapeLeft,
                                    ]);
                                  } else {
                                    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
                                    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onPressed, {double size = 32}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: size),
        iconSize: size,
        onPressed: onPressed,
      ),
    );
  }
}

// Custom track shape to remove extra padding
class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight!;
    final double trackLeft = offset.dx;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}