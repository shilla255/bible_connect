import 'package:flutter/material.dart';
import 'package:bible/presentation/view/pages/audio_page/audio_book_page.dart';
import 'package:bible/presentation/view/pages/book_page.dart';
import 'package:bible/presentation/view/pages/home_page.dart';
import 'package:bible/presentation/view/user_auth/auth_wrappe.dart';
import '../../../../routes/session_manager.dart';
import '../../../../widgets/drawer_widget.dart';
import '../../community/profile_screens/profile.dart';
import 'bottom_nav_bar.dart';
import '../../../../widgets/rate_myapp.dart'; // Import the SessionService

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int _selectedIndex = 0;
  late PageController _pageController;
  String _bibleId = 'de4e12af7f28f599-02'; // Default Bible ID
  final SessionService _sessionService = SessionService(); // Initialize SessionService

  @override
  void initState() {
    super.initState();
    _sessionService.incrementSessionCount(); // Increment session count on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sessionService.showRateDialog(context); // Show rate dialog if conditions are met
    });
    WidgetsBinding.instance.addObserver(this);
    _loadLastSession();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadLastSession() async {
    final lastIndex = await SessionManager.getLastTabIndex();
    final lastBibleId = await SessionManager.getLastBibleId();

    setState(() {
      _selectedIndex = lastIndex;
      if (lastBibleId != null) {
        _bibleId = lastBibleId;
      }
    });

    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      SessionManager.saveLastSession(
        tabIndex: _selectedIndex,
        bibleId: _bibleId,
      );
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
    SessionManager.saveLastSession(
      tabIndex: index,
      bibleId: _bibleId,
    );
  }

  void _onItemTapped(int index) {
    _pageController.jumpToPage(index);
  }

  void _onDrawerItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
    Navigator.pop(context); // Close the drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                physics: const ClampingScrollPhysics(),
                children: [
                  const HomePage(),
                  BooksPage(bibleId: _bibleId),
                  const AudioBookPage(),
                  const AuthWrapper(),
                  const ProfileScreen(),
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
      drawer: ModernDrawerWidget(onItemTapped: _onDrawerItemTapped),
    );
  }
}