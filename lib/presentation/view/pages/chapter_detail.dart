import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:bible/services/api_services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/chapter.dart';

class ChapterDetailsPage extends StatelessWidget {
  final String bibleId;
  final String chapterId;
  final BibleApiService apiService = BibleApiService();

  ChapterDetailsPage({
    required this.bibleId,
    required this.chapterId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bible Chapter"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: FutureBuilder<ChapterDetail>(
        future: apiService.fetchChapterDetails(bibleId: bibleId, chapterId: chapterId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Failed to load chapter details'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No chapter details available'));
          } else {
            final chapter = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      chapter.reference,
                      style: GoogleFonts.poppins(
                        fontSize: 32.0,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    chapter.title,
                    style: GoogleFonts.poppins(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w500,
                      color: theme.textTheme.titleMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Divider(color: theme.dividerColor),
                  const SizedBox(height: 24),
                  HtmlWidget(
                    chapter.content,
                    textStyle: GoogleFonts.poppins(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w400,
                      color: theme.textTheme.bodyLarge?.color,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (chapter.previous != null)
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChapterDetailsPage(
                                  bibleId: bibleId,
                                  chapterId: chapter.previous!.id,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Previous'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.secondary,
                            foregroundColor: theme.colorScheme.onSecondary,
                            textStyle: GoogleFonts.poppins(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (chapter.next != null)
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChapterDetailsPage(
                                  bibleId: bibleId,
                                  chapterId: chapter.next!.id,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Next'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.secondary,
                            foregroundColor: theme.colorScheme.onSecondary,
                            textStyle: GoogleFonts.poppins(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}