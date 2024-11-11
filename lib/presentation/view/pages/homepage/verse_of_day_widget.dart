
import 'package:bible/presentation/view/pages/homepage/verse_of_the_day.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../data/models/quote.dart';
import '../../../../services/quote_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class VerseOfTheDayWidget extends StatefulWidget {
  const VerseOfTheDayWidget({super.key});

  @override
  _VerseOfTheDayWidgetState createState() => _VerseOfTheDayWidgetState();
}

class _VerseOfTheDayWidgetState extends State<VerseOfTheDayWidget> with SingleTickerProviderStateMixin {
  String verse = "loading".tr();
  String reference = "";
  late Future<List<Quote>> futureQuotes;
  bool _isVerseLoading = true;
  bool _isQuoteImageLoading = true;
  String _errorMessage = "";
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Custom cache manager
  final CacheManager _customCacheManager = CacheManager(
    Config(
      "customQuoteCache",
      stalePeriod: const Duration(days: 1), // Refresh cache every day
      maxNrOfCacheObjects: 20,
    ),
  );

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
    futureQuotes = fetchQuotes();
    _loadData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _customCacheManager
        .emptyCache(); // Optional, to clear cache on widget disposal
    super.dispose();
  }

  Future<void> _loadData() async {
    await _fetchVerse();
    await _fetchQuotes();
  }

  Future<void> _fetchVerse() async {
    setState(() {
      _isVerseLoading = true;
      _errorMessage = "";
    });

    try {
      var verseData = await VerseOfTheDayService.fetchVerse();
      setState(() {
        verse = verseData["text"];
        reference =
        "${verseData["bookname"]} ${verseData["chapter"]}:${verseData["verse"]}";
        _isVerseLoading = false;
      });
    } catch (e) {
      setState(() {
        verse = "unable_to_load_verse".tr();
        reference = "";
        _isVerseLoading = false;
        _errorMessage = "failed_to_fetch_verse".tr();
      });
    }
  }

  Future<void> _fetchQuotes() async {
    setState(() {
      _isQuoteImageLoading = true;
    });

    try {
      futureQuotes = fetchQuotes();
      setState(() {
        _isQuoteImageLoading = false;
      });
    } catch (e) {
      setState(() {
        _isQuoteImageLoading = false;
        _errorMessage = "failed_to_load_quotes".tr();
      });
    }
  }


  Widget _buildQuoteImage(ThemeData theme) {
    return FutureBuilder<List<Quote>>(
      future: futureQuotes,
      builder: (context, snapshot) {
        if (_isQuoteImageLoading) {
          return _buildLoadingPlaceholder(theme);
        }

        if (snapshot.hasError) {
          return _buildErrorImagePlaceholder(theme);
        }

        return Hero(
          tag: "quote-image",
          child: Container(
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.0),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.3),
                  blurRadius: 20.0,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.0),
              child: CachedNetworkImage(
                cacheManager: _customCacheManager,
                imageUrl: "https://zenquotes.io/api/image",
                height: 220.0,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildLoadingPlaceholder(theme),
                errorWidget: (context, url, error) =>
                    _buildErrorImagePlaceholder(theme),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingPlaceholder(ThemeData theme) {
    return Container(
      height: 230.0,
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 20.0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
          color: theme.colorScheme.primary,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildErrorImagePlaceholder(ThemeData theme) {
    return Container(
      height: 220.0,
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: theme.colorScheme.error,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              "failed_to_load_image".tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchQuotes,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: Text("retry".tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.errorContainer,
                foregroundColor: theme.colorScheme.onErrorContainer,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildQuoteImage(theme),
              Container(
                width: screenWidth * 0.95,
                // Use 95% of screen width
                constraints: const BoxConstraints(
                  minHeight: 200,
                  maxHeight: 270,
                ),
                padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.08),
                      blurRadius: 24.0,
                      offset: const Offset(0, 12),
                    ),
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.04),
                      blurRadius: 4.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Verse of the Day".tr(),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Verse Content
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isVerseLoading)
                              LoadingAnimationWidget.horizontalRotatingDots(
                                color: theme.colorScheme.primary,
                                size: 40,
                              )
                            else
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0),
                                child: Text(
                                  verse,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    height: 1.6,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 14,
                                    letterSpacing: 0.2,
                                    fontFamily: "Poppins",
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondaryContainer
                                    .withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                reference,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.secondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),


                  ],
                ),
              ),

              // Error Message
              if (_errorMessage.isNotEmpty)
                Container(
                  width: screenWidth * 0.95,
                  margin: const EdgeInsets.all(16.0),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.error.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
