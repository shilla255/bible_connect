import 'package:flutter/material.dart';
import 'homepage/snow_animation.dart';
import 'homepage/verse_of_day_widget.dart';
import '../../../widgets/appbar_widget.dart';
import '../../../widgets/drawer_widget.dart';
import 'package:bible/presentation/view/pages/video/channel_selection.dart';
import 'package:flutter/cupertino.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  bool _isFabExpanded = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildFABs(ThemeData theme) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Positioned(
          bottom: 80,
          right: 16,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 200),
            offset: _isFabExpanded ? Offset.zero : const Offset(1.5, 0),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _isFabExpanded ? 1.0 : 0.0,
              child: FloatingActionButton(
                heroTag: "channelButton",
                onPressed: _isFabExpanded
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChannelSelectionPage(),
                          ),
                        );
                      }
                    : null,
                backgroundColor: theme.colorScheme.secondary,
                child: const Icon(CupertinoIcons.tv, color: Colors.white),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            heroTag: "mainButton",
            onPressed: () {
              setState(() {
                _isFabExpanded = !_isFabExpanded;
                _isFabExpanded
                    ? _animationController.forward()
                    : _animationController.reverse();
              });
            },
            backgroundColor: theme.colorScheme.primary,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _animationController.value * 0.5 * 3.14,
                  child: Icon(
                    _isFabExpanded ? Icons.close : Icons.add,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        drawer: const ModernDrawerWidget(),
        appBar: const AppBarWidget(),
        body: ChristmasSnowAnimation(
          child: RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 2));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: const VerseOfTheDayWidget(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: _buildFABs(theme),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}