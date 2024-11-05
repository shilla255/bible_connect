import 'package:flutter/material.dart';
import 'package:bible/services/audio_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/models/Audio.dart';
import 'audio_book_page.dart';

class AudioBibleWrapper extends StatefulWidget {
  const AudioBibleWrapper({super.key});

  @override
  _AudioBibleWrapperState createState() => _AudioBibleWrapperState();
}

class _AudioBibleWrapperState extends State<AudioBibleWrapper> {
  @override
  void initState() {
    super.initState();
    _checkSavedBible();
  }

  Future<void> _checkSavedBible() async {
    final prefs = await SharedPreferences.getInstance();
    final savedBibleId = prefs.getString('favoriteAudioBible');
    final savedBibleName = prefs.getString('favoriteAudioBibleName');

    if (savedBibleId != null && savedBibleName != null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AudioBookPage(
              bibleId: savedBibleId,
              bibleName: savedBibleName,
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AudioBibleSelectionPage(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class AudioBibleSelectionPage extends StatefulWidget {
  const AudioBibleSelectionPage({super.key});

  @override
  _AudioBibleSelectionPageState createState() => _AudioBibleSelectionPageState();
}

class _AudioBibleSelectionPageState extends State<AudioBibleSelectionPage>
    with TickerProviderStateMixin {
  late Future<List<AudioBible>> futureAudioBibles;
  List<AudioBible> _audioBibles = [];
  List<AudioBible> _filteredAudioBibles = [];
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    futureAudioBibles = MyAudioService().fetchAudioBibles();
    futureAudioBibles.then((audioBibles) {
      if (mounted) {
        setState(() {
          _audioBibles = audioBibles;
          _filteredAudioBibles = audioBibles;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveFavoriteBible(String bibleId, String bibleName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('favoriteAudioBible', bibleId);
    await prefs.setString('favoriteAudioBibleName', bibleName);
  }

  void _filterBibles(String query) {
    final filteredBibles = _audioBibles.where((bible) {
      final bibleLower = bible.name.toLowerCase();
      final queryLower = query.toLowerCase();
      return bibleLower.contains(queryLower);
    }).toList();

    setState(() {
      _filteredAudioBibles = filteredBibles;
    });
  }

  @override
  Widget build(BuildContext context) {
  final theme = Theme.of(context);

  return Scaffold(
    appBar: AppBar(
  leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () {
      Navigator.pop(context);
    },
  ),
  centerTitle: true,
  title: FadeTransition(
    opacity: _controller.drive(CurveTween(curve: Curves.easeIn)),
    child: const Text(
      'Select Audio Bible',
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.blue,
        letterSpacing: -0.5,
      ),
    ),
  ),
  elevation: 0,
  bottom: PreferredSize(
    preferredSize: const Size.fromHeight(1.0),
    child: Container(
      color: Colors.grey[200],
      height: 1.0,
    ),
  ),
),
    body: Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            onChanged: _filterBibles,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'Search Audio Bibles...',
              hintStyle: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey[400],
                fontSize: 16,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey[600],
                size: 22,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<AudioBible>>(
            future: futureAudioBibles,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: theme.primaryColor,
                    strokeWidth: 3,
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading audio Bibles',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: Colors.grey[800],
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
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No audio Bibles available',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                itemCount: _filteredAudioBibles.length,
                itemBuilder: (context, index) {
                  final audioBible = _filteredAudioBibles[index];
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
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
                        onTap: () async {
                          await _saveFavoriteBible(audioBible.id, audioBible.name);
                          if (mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AudioBookPage(
                                  bibleId: audioBible.id,
                                  bibleName: audioBible.name,
                                ),
                              ),
                            );
                          }
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
                                      audioBible.language,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      audioBible.name,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 15,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      audioBible.updatedAt,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 13,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.play_arrow_rounded,
                                  color: theme.primaryColor,
                                  size: 24,
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
            },
          ),
        ),
      ],
    ),
  );
}
}