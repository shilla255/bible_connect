import 'package:flutter/material.dart';
import 'package:bible/presentation/view/pages/audio_page/audio_book_page.dart';
import 'package:bible/presentation/view/pages/book_page.dart';
import 'package:bible/presentation/view/pages/home_page.dart';
import 'package:bible/presentation/view/user_auth/auth_wrappe.dart';
import 'bottom_nav_bar.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onItemTapped(int index) {
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false, // Remove bottom safe area to prevent double padding
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                physics: const ClampingScrollPhysics(),
                children: [
                  const HomePage(),
                  BooksPage(bibleId: 'de4e12af7f28f599-02'),
                  const AudioBookPage(),
                  const AuthWrapper(),
                ],
              ),
            ),
            BottomNavBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
            ),
          ],
        ),
      ),
    );
  }
}