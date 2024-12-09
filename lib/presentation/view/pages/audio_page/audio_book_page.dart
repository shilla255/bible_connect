
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bible/services/audio_service.dart';
import 'package:bible/presentation/view/pages/audio_page/audio_bible_selection.dart';
import '../../../../data/models/audio_book.dart';
import 'audio_bible_prompt.dart';
import 'audio_widgets/audio_appbar.dart';

class AudioBookPage extends StatefulWidget {
  const AudioBookPage({super.key});

  @override
  _AudioBookPageState createState() => _AudioBookPageState();
}

class _AudioBookPageState extends State<AudioBookPage> with TickerProviderStateMixin {
  final MyAudioService _audioService = MyAudioService();
  late Future<List<AudioBook>> _futureAudioBooks;
  String? _currentBibleId;
  bool _isFirstLaunch = true;

  @override
  void initState() {
    super.initState();
    _loadSavedBible();
  }

  Future<void> _loadSavedBible() async {
    final prefs = await SharedPreferences.getInstance();
    final savedBibleId = prefs.getString('favoriteAudioBible');
    final savedBibleName = prefs.getString('favoriteAudioBibleName');

    setState(() {
      if (savedBibleId != null && savedBibleName != null) {
        _currentBibleId = savedBibleId;
        _isFirstLaunch = false;
        _loadAudioBooks();
      } else {
        _isFirstLaunch = true;
      }
    });
  }

  void _loadAudioBooks() {
    if (_currentBibleId != null) {
      setState(() {
        _futureAudioBooks = _fetchAudioBooksWithHandling(_currentBibleId!);
      });
    }
  }

  Future<List<AudioBook>> _fetchAudioBooksWithHandling(String bibleId) async {
    try {
      return await _audioService.fetchAudioBooks(bibleId);
    } catch (e) {
      if (e is SocketException) {
        throw Exception('Network error. Please check your internet connection.');
      } else {
        throw Exception('An unexpected error occurred. Please try again later.');
      }
    }
  }

  Future<void> _showBibleSelectionDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ModernAudioBibleSelector(
        currentBibleId: _currentBibleId,
        onBibleSelected: (bibleId, bibleName) async {
          setState(() {
            _currentBibleId = bibleId;
            _isFirstLaunch = false;
          });
          _loadAudioBooks();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModernAppBar(
        onSelectBible: _showBibleSelectionDialog,
        title: 'Audio',
      ),
      body: _isFirstLaunch
          ? Center(
        child: AudioBiblePrompt(
          onSelectBible: _showBibleSelectionDialog,
        ),
      )
          : _currentBibleId == null
          ? const Center(
        child: Text('Please select an Audio Bible to begin'),
      )
          : FutureBuilder<List<AudioBook>>(
        future: _futureAudioBooks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading audio books\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadAudioBooks,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final audioBooks = snapshot.data ?? [];

          if (audioBooks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.library_music_outlined, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No audio books available',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: audioBooks.length,
            itemBuilder: (context, index) {
              final book = audioBooks[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Text(
                      book.name.substring(0, 1),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    book.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    book.nameLong,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      'audioChapter',
                      arguments: {
                        'bibleId': _currentBibleId,
                        'bookId': book.id,
                        'bookName': book.name,
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}