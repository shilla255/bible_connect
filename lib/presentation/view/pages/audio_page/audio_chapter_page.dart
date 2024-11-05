import 'package:flutter/material.dart';
import 'package:bible/services/audio_service.dart';

import '../../../../data/models/audio_chapter.dart';
import 'audio_player_page.dart';

class ChapterListPage extends StatefulWidget {
  final String bibleId;
  final String bookId;
  final String bookName;

  const ChapterListPage({
    super.key,
    required this.bibleId,
    required this.bookId,
    required this.bookName,
  });

  @override
  _ChapterListPageState createState() => _ChapterListPageState();
}

class _ChapterListPageState extends State<ChapterListPage> {
  late Future<List<AudioChapter>> futureChapters;
  bool isPlaying = false;
  String? playingChapterId;

  @override
  void initState() {
    super.initState();
    futureChapters = MyAudioService().fetchChapters(widget.bibleId, widget.bookId);
  }

  @override
  Widget build(BuildContext context) {
  final theme = Theme.of(context);

  return Scaffold(
    appBar: AppBar(
      title: Text('${widget.bookName} Chapters'),
      backgroundColor: theme.appBarTheme.backgroundColor,
      foregroundColor: theme.appBarTheme.foregroundColor,
      elevation: theme.appBarTheme.elevation,
      iconTheme: theme.appBarTheme.iconTheme,
    ),
    body: FutureBuilder<List<AudioChapter>>(
      future: futureChapters,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          try {
            if (snapshot.hasError) {
              throw snapshot.error!;
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No chapters available'));
            } else {
              final chapters = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: chapters.length,
                  itemBuilder: (context, index) {
                    final chapter = chapters[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          playingChapterId = chapter.id;
                          isPlaying = true;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AudioPlayerPage(
                              audioBibleId: widget.bibleId,
                              chapterId: chapter.id,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        color: theme.cardTheme.color,
                        elevation: theme.cardTheme.elevation,
                        shape: theme.cardTheme.shape,
                        child: Center(
                          child: Text(
                            chapter.number,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          } catch (error) {
            return Center(child: Text('Failed to load chapters: $error'));
          }
        }
      },
    ),
    bottomNavigationBar: isPlaying
        ? Container(
            padding: const EdgeInsets.all(8.0),
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Playing Chapter $playingChapterId',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      isPlaying = !isPlaying;
                    });
                  },
                ),
              ],
            ),
          )
        : null,
  );
}

}
