import 'dart:math';

import 'package:bible/presentation/view/pages/homepage/verse_of_the_day.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';
import 'dart:ui';



class VerseOfTheDayWidget extends StatefulWidget {
  const VerseOfTheDayWidget({super.key});

  @override
  _VerseOfTheDayWidgetState createState() => _VerseOfTheDayWidgetState();
}

class _VerseOfTheDayWidgetState extends State<VerseOfTheDayWidget>
    with SingleTickerProviderStateMixin {
  String verse = "loading".tr();
  String reference = "";
  String _errorMessage = "";
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _verseBackgroundImageUrl = "";

  // Screenshot Controller
  final ScreenshotController _screenshotController = ScreenshotController();

  // Free Image APIs for background
  final List<String> _imageApis = [
    "https://picsum.photos/800/600",
    "https://picsum.photos/800/600?grayscale",
  ];

  Future<String> _fetchRandomBackgroundImage() async {
    final random = Random();
    final seed = random.nextInt(1000); // Just to ensure we get different images
    return "${_imageApis[random.nextInt(_imageApis.length)]}?random=$seed";
  }

  late double screenWidth;
  late double screenHeight;
  late ThemeData theme;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _errorMessage = "";
    });

    try {
      var verseData = await VerseOfTheDayService.fetchVerse();
      String imageUrl = await _fetchRandomBackgroundImage();

      setState(() {
        verse = verseData["text"];
        reference = "${verseData["bookname"]} ${verseData["chapter"]}:${verseData["verse"]}";
        _verseBackgroundImageUrl = imageUrl;
      });
    } catch (e) {
      setState(() {
        verse = "unable_to_load_verse".tr();
        reference = "";
        _errorMessage = "failed_to_fetch_verse".tr();
      });
    }
  }

  Future<void> _downloadImage() async {
    if (await Permission.storage.request().isGranted) {
      final Uint8List image = await _screenshotController.captureFromWidget(
        _buildVerseContainer(excludeButtons: true),
      );
      if (image != null) {
        final result = await ImageGallerySaver.saveImage(image);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Image saved to gallery'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: theme.colorScheme.primary,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission required')),
      );
    }
  }

  Widget _buildVerseContainer({bool excludeButtons = false}) {
    return Container(
      width: screenWidth * 0.95,
      height: screenHeight * 0.4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        image: DecorationImage(
          image: CachedNetworkImageProvider(_verseBackgroundImageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(24.0),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!excludeButtons)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary.withOpacity(0.2),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.auto_awesome,
                            color: theme.colorScheme.primary,
                          ),
                          onPressed: () {},
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary.withOpacity(0.2),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.download,
                            color: theme.colorScheme.primary,
                          ),
                          onPressed: _downloadImage,
                        ),
                      ),
                    ],
                  ),
                Expanded(
                  child: Center(
                    child: Text(
                      verse,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white, // High contrast white color
                        fontWeight: FontWeight.w900, // Extra bold
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                        fontSize: 18, // Slightly larger font size
                        shadows: [
                          Shadow(
                            blurRadius: 15.0, // Increased blur for more prominence
                            color: Colors.black.withOpacity(0.6), // Stronger shadow
                            offset: const Offset(2.0, 2.0),
                          ),
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black.withOpacity(0.4),
                            offset: const Offset(-1.0, -1.0),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: null,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    reference,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900, // Extra bold
                      fontSize: 16, // Slightly larger font size
                      color: Colors.white, // High contrast white color
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black.withOpacity(0.5), // Stronger shadow
                          offset: const Offset(2.0, 2.0),
                        ),
                        Shadow(
                          blurRadius: 7.0,
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(-1.0, -1.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Screenshot(
      controller: _screenshotController,
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildVerseContainer(),
              if (_errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}