import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    required this.selectedIndex,
    required this.onItemTapped,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
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
            ),
            _buildNavItem(
              context,
              icon: CupertinoIcons.book,
              label: 'Bible',
            ),
            _buildNavItem(
              context,
              icon: CupertinoIcons.music_note,
              label: 'Listen',
            ),
            _buildNavItem(
              context,
              icon: CupertinoIcons.chat_bubble,
              label: 'Chat',
            ),
            _buildNavItem(
              context,
              icon: CupertinoIcons.person,
              label: 'Profile', // Add Profile navigation item here
            ),
          ],
          currentIndex: selectedIndex,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).iconTheme.color?.withOpacity(0.5),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          onTap: (index) {
            HapticFeedback.lightImpact();
            onItemTapped(index);
          },
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
      BuildContext context, {
        required IconData icon,
        required String label,
      }) {
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selectedIndex == label ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          color: selectedIndex == label ? Theme.of(context).colorScheme.primary : Theme.of(context).iconTheme.color?.withOpacity(0.5),
        ),
      ),
      activeIcon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
      ),
      label: label,
    );
  }
}