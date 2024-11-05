import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/theme_provider.dart';
import '../../user_auth/auth_wrappe.dart';

class BottomNavBar extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    required this.selectedIndex,
    required this.onItemTapped,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          items: [
            _buildNavItem(
              context,
              icon: CupertinoIcons.home,
              label: 'Home',
              color: theme.colorScheme.primary,
            ),
            _buildNavItem(
              context,
              icon: CupertinoIcons.book,
              label: 'Bible',
              color:  theme.colorScheme.primary,
            ),
            _buildNavItem(
              context,
              icon: CupertinoIcons.music_note,
              label: 'Audio',
              color:  theme.colorScheme.primary,
            ),
            _buildNavItem(
              context,
              icon: CupertinoIcons.chat_bubble,
              label: 'Community',
              color:  theme.colorScheme.primary,
            ),
          ],
          currentIndex: selectedIndex,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: theme.iconTheme.color?.withOpacity(0.5),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: (index) {
            // Add haptic feedback
            HapticFeedback.lightImpact();

            // Navigation logic
            switch (index) {
              case 1: // Bible tab
                _navigateToBiblePage(context);
                break;
              case 3: // Community tab
                _navigateToCommunityPage(context);
                break;
              default:
                onItemTapped(index);
            }
          },
        ),
      ),
    );
  }

  // Custom method to create navigation items with more visual appeal
  BottomNavigationBarItem _buildNavItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color color,
      }) {
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          color: color.withOpacity(0.7),
        ),
      ),
      activeIcon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: 24,
        ),
      ),
      label: label,
    );
  }

  // Extracted Bible page navigation logic
  Future<void> _navigateToBiblePage(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final bibleId = prefs.getString('favoriteBibleId');

    if (bibleId != null) {
      // Navigate to BooksPage with the saved bibleId
      Navigator.pushReplacementNamed(context, 'bookPage', arguments: bibleId);
    } else {
      // Navigate to the main BiblePage if no saved bibleId
      Navigator.pushReplacementNamed(context, 'biblePage');
    }
  }

  // Extracted Community page navigation logic
  void _navigateToCommunityPage(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const AuthWrapper(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                ),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }
}