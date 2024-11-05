import 'package:flutter/material.dart';
import 'package:bible/services/api_services.dart';

import '../../../data/models/chapter.dart';
import 'chapter_detail.dart';



class ChaptersPage extends StatelessWidget {
  final String bibleId;
  final String bookId;
  final BibleApiService apiService = BibleApiService();

  ChaptersPage({
    required this.bibleId,
    required this.bookId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Chapter"),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: theme.appBarTheme.elevation,
        iconTheme: theme.appBarTheme.iconTheme,
      ),
      body: FutureBuilder<List<Chapter>>(
        future: apiService.fetchChapters(bibleId: bibleId, bookId: bookId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Failed to load chapters'));
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChapterDetailsPage(
                            bibleId: bibleId,
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
        },
      ),
    );
  }
}
