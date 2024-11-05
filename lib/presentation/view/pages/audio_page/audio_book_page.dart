import 'package:bible/presentation/view/pages/audio_page/audio_wrapper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:bible/services/audio_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/models/audio_book.dart';
import '../../user_auth/auth_wrappe.dart';
import '../homepage/bottom_nav_bar.dart';
import 'audio_chapter_page.dart';

class AudioBookPage extends StatefulWidget {
  final String bibleId;
  final String bibleName;

  const AudioBookPage({super.key, required this.bibleId, required this.bibleName});

  @override
  _AudioBookPageState createState() => _AudioBookPageState();
}

class _AudioBookPageState extends State<AudioBookPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Future<List<AudioBook>> _futureAudioBooks;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _futureAudioBooks = MyAudioService().fetchAudioBooks(widget.bibleId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _clearSavedBible() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('favoriteAudioBible');
      await prefs.remove('favoriteAudioBibleName');
    } catch (e) {
      debugPrint('Error clearing saved bible: $e');
    }
  }

  Future<void> _handleNavigateToWrapper() async {
    if (_isNavigating) return; // Prevent multiple navigation attempts

    setState(() {
      _isNavigating = true;
    });

    try {
      await _clearSavedBible();
      if (mounted) {
        await Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const AudioBibleWrapper(),
          ),
          (route) => false, // Clear all routes from the stack
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Navigation error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isNavigating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        await _handleNavigateToWrapper();
        return false;
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          centerTitle: true,
          title: FadeTransition(
            opacity: _controller.drive(CurveTween(curve: Curves.easeIn)),
            child: Text(
              widget.bibleName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontFamily: "Poppins",
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
          ),
          backgroundColor: theme.appBarTheme.backgroundColor,
          elevation: theme.appBarTheme.elevation,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: theme.dividerColor,
              height: 1.0,
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Icon(
                  Icons.library_music_outlined,
                  color: theme.iconTheme.color,
                  size: 26,
                ),
                onPressed: _isNavigating ? null : _handleNavigateToWrapper,
              ),
            ),
          ],
        ),
        body: FutureBuilder<List<AudioBook>>(
          future: _futureAudioBooks,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: theme.primaryColor,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading audio books...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              );
            }

            try {
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Error: ${snapshot.error}".tr(),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _futureAudioBooks = MyAudioService().fetchAudioBooks(widget.bibleId);
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: Text("Retry".tr()),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.library_music_outlined,
                        size: 48,
                        color: theme.hintColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No audio books available",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final audioBooks = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.only(top: 12, bottom: 24),
                itemCount: audioBooks.length,
                itemBuilder: (context, index) {
                  final audioBook = audioBooks[index];
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withOpacity(0.04),
                          blurRadius: 8,
                          spreadRadius: 0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChapterListPage(
                                bibleId: widget.bibleId,
                                bookId: audioBook.id,
                                bookName: audioBook.name,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      audioBook.name,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontFamily: "Poppins",
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      audioBook.nameLong,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontFamily: "Poppins",
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(21),
                                ),
                                child: Icon(
                                  Icons.play_arrow_rounded,
                                  color: theme.primaryColor,
                                  size: 26,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            } catch (error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Failed to load audio books: $error".tr(),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
        bottomNavigationBar: Theme(
          data: theme.copyWith(
          ),
          child: BottomNavBar(
            selectedIndex: 2,
            onItemTapped: (index) {
              switch (index) {
                case 0:
                  Navigator.pushReplacementNamed(context, "homepage");
                  break;
                case 1:
                  Navigator.pushReplacementNamed(context, "biblePage");
                  break;
                case 2:
                  Navigator.pushReplacementNamed(context, "audioPage");
                  break;
                case 3:
                  Navigator.pushReplacementNamed(context, "community");
                  break;
                default:
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthWrapper()),
                  );
              }
            },
          ),
        ),
      ),
    );
  }
}

