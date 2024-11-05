import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bible/presentation/view/pages/book_page.dart';
import 'package:bible/services/api_services.dart';
import '../../../data/models/bible.dart';

class BiblePage extends StatefulWidget {
  const BiblePage({super.key});

  @override
  _BiblePageState createState() => _BiblePageState();
}

class _BiblePageState extends State<BiblePage> with TickerProviderStateMixin {
  final BibleApiService apiService = BibleApiService();
  List<Bible> _bibles = [];
  List<Bible> _filteredBibles = [];
  bool _isLoading = true;
  bool _hasError = false;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _controller;
  String? _favoriteBible;

  @override
  void initState() {
    super.initState();
    _fetchBibles();
    _loadSharedPreferences();
    _searchController.addListener(_filterBibles);
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchBibles() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      List<Bible> bibles = await apiService.fetchBibles();
      setState(() {
        _bibles = bibles;
        _filteredBibles = bibles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _filterBibles() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBibles = _bibles.where((bible) {
        return bible.name.toLowerCase().contains(query) ||
            bible.language.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _loadSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteBible = prefs.getString("favoriteBible") ?? "No favorite set".tr();
    });
  }

  Future<void> _saveFavoriteBible(String bibleId, String bibleName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("favoriteBibleId", bibleId);
    await prefs.setString("favoriteBible", bibleName);
    setState(() {
      _favoriteBible = bibleName;
    });
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            "Failed to load bibles".tr(),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _fetchBibles,
            icon: const Icon(Icons.refresh),
            label: Text("Retry".tr()),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Material(
        elevation: 8,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(15),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Search for a Bible...".tr(),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _filterBibles();
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(
            Icons.favorite,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Favorite Bible".tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  _favoriteBible ?? "No favorite set".tr(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBibleList() {
    if (_filteredBibles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              "No bibles found".tr(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _filteredBibles.length,
      itemBuilder: (context, index) {
        final bible = _filteredBibles[index];
        return Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 4,
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () {
              _saveFavoriteBible(bible.id, bible.name);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BooksPage(bibleId: bible.id),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bible.language,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bible.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: "bibleTitle",
          child: FadeTransition(
            opacity: _controller.drive(CurveTween(curve: Curves.easeIn)),
            child: Text(
              "Bible".tr(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    "Loading Bibles...".tr(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            )
          : _hasError
              ? _buildErrorState()
              : Column(
                  children: [
                    _buildSearchBar(),
                    _buildFavoriteSection(),
                    Expanded(child: _buildBibleList()),
                  ],
                ),
    );
  }
}