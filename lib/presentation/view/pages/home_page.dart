import 'package:bible/presentation/view/pages/quotes/quote_page.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'homepage/verse_of_day_widget.dart';
import '../../../widgets/appbar_widget.dart';
import '../../../widgets/drawer_widget.dart';
import 'package:bible/presentation/view/pages/video/channel_selection.dart';
import 'package:flutter/cupertino.dart';




class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        drawer: ModernDrawerWidget(onItemTapped: (int index) {}),
        appBar: const AppBarWidget(),
        body: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 2));
          },
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Container(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: const VerseOfTheDayWidget(),
                    ),
                    const SizedBox(height: 16),
                    _buildLiveWorshipCard(context, theme),
                    const SizedBox(height: 16),
                    _buildQuotesCard(context, theme), // Uncommented and added
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveWorshipCard(BuildContext context, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const ChannelSelectionPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: animation.drive(Tween(begin: const Offset(0.0, 1.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeInOut))),
                child: child,
              );
            },
          ),
        );
      },
      child: Hero(
        tag: 'worshipCard',
        child: _buildCard(
            theme,
            'Live Worship Channels',
            'Explore and watch live worship services from around the world',
            "https://picsum.photos/800/600?grayscale&blur=1",
            CupertinoIcons.play_fill,
            theme.colorScheme.primary
        ),
      ),
    );
  }

  Widget _buildQuotesCard(BuildContext context, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const QuotePage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: animation.drive(Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeInOut))),
                child: child,
              );
            },
          ),
        );
      },
      child: Hero(
        tag: 'quotesCard',
        child: _buildCard(
            theme,
            'Daily Inspirations',
            'Discover uplifting quotes to brighten your day and nourish your spirit',
            "https://picsum.photos/800/600?random=3",
            CupertinoIcons.quote_bubble,
            theme.colorScheme.tertiary
        ),
      ),
    );
  }

  Widget _buildCard(
      ThemeData theme,
      String title,
      String description,
      String imageUrl,
      IconData icon,
      Color cardColor
      ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cardColor.withOpacity(0.1),
              cardColor.withOpacity(0.01),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cardColor,
                      ),
                    ),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(cardColor.withOpacity(0.7)),
                      ),
                    ),
                    errorWidget: (context, url, error) => Icon(
                        Icons.error,
                        color: theme.colorScheme.error
                    ),
                  ),
                ),
                Positioned(
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: cardColor.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 3
                        )
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(icon, color: Colors.white, size: 24),
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}