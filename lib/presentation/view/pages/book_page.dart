import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bible/services/api_services.dart';
import '../../../data/models/books.dart';
import '../user_auth/auth_wrappe.dart';
import 'chapters_page.dart';
import 'bible_page.dart';
import 'homepage/bottom_nav_bar.dart';

class BooksPage extends StatefulWidget {
  final String bibleId;

  const BooksPage({super.key, required this.bibleId});

  @override
  _BooksPageState createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> with TickerProviderStateMixin {
  final BibleApiService apiService = BibleApiService();
  List<Book> _books = [];
  List<Book> _filteredBooks = [];
  bool _isLoading = true;
  bool _hasError = false;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _fadeController;
  late AnimationController _slideController;
  String? _selectedBible;

  // Add scroll controller for scroll animations
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchBooks();
    _loadSelectedBible();
    _searchController.addListener(_filterBooks);

    _fadeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchBooks() async {
    try {
      List<Book> books = await apiService.fetchBooks(bibleId: widget.bibleId);
      setState(() {
        _books = books;
        _filteredBooks = books;
        _isLoading = false;
      });
      _slideController.forward();
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSelectedBible() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedBible = prefs.getString('favoriteBible') ?? 'Unknown Bible';
    });
  }

  void _filterBooks() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBooks = _books.where((book) {
        return book.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            FadeTransition(
              opacity: _fadeController.drive(
                CurveTween(curve: Curves.easeInOut),
              ),
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    colors: [
                      theme.primaryColor,
                      theme.colorScheme.primary,
                    ],
                  ).createShader(bounds);
                },
                child: Text(
                  _selectedBible?.split(' ').first ?? 'Books',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
              ),
            ),
            const Spacer(),
            Container(
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(
                  CupertinoIcons.bookmark,
                  color: Colors.blue,
                  size: 28,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                      const BiblePage(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading Books...',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      )
          : _hasError
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load books',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
                fontFamily: 'Poppins',
              ),
            ),
            ElevatedButton(
              onPressed: _fetchBooks,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for a Book...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: theme.primaryColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: theme.cardColor,
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Poppins',
                    color: theme.hintColor,
                  ),
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredBooks.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 48,
                    color: theme.hintColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No books found',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontFamily: 'Poppins',
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            )
                : SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _slideController,
                curve: Curves.easeOut,
              )),
              child: ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                itemCount: _filteredBooks.length,
                itemBuilder: (context, index) {
                  final book = _filteredBooks[index];
                  return TweenAnimationBuilder<double>(
                    duration: Duration(
                      milliseconds: 200 + (index * 50),
                    ),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      margin: const EdgeInsets.symmetric(
                        vertical: 6.0,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16.0),
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation,
                                  secondaryAnimation) =>
                                  ChaptersPage(
                                    bibleId: widget.bibleId,
                                    bookId: book.id,
                                  ),
                              transitionsBuilder: (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                  ) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(1.0, 0.0),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: theme.primaryColor
                                      .withOpacity(0.1),
                                  borderRadius:
                                  BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    book.name[0],
                                    style: theme
                                        .textTheme.titleLarge
                                        ?.copyWith(
                                      color: theme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  book.name,
                                  style: theme
                                      .textTheme.bodyLarge
                                      ?.copyWith(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: theme.primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 1,
        onItemTapped: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, 'homepage');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, 'biblePage');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, 'audioPage');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, 'community');
              break;
            default:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AuthWrapper()),
              );
          }
        },
      ),
    );
  }
}