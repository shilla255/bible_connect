import 'package:flutter/material.dart';
import '../../../data/models/bible.dart';
import '../../../services/api_services.dart';

class BibleSelectionDialog extends StatefulWidget {
  final String? currentBibleId;
  final Function(String bibleId, String bibleName) onBibleSelected;

  const BibleSelectionDialog({
    super.key,
    this.currentBibleId,
    required this.onBibleSelected,
  });

  @override
  _BibleSelectionDialogState createState() => _BibleSelectionDialogState();
}

class _BibleSelectionDialogState extends State<BibleSelectionDialog> {
  final BibleApiService _apiService = BibleApiService();
  List<Bible> _bibles = [];
  List<Bible> _filteredBibles = [];
  bool _isLoading = true;
  String? _selectedBibleId;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedBibleId = widget.currentBibleId;
    _fetchBibles();
  }

  Future<void> _fetchBibles() async {
    try {
      final bibles = await _apiService.fetchBibles();
      setState(() {
        _bibles = bibles;
        _filteredBibles = bibles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load bibles: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  void _filterBibles(String query) {
    setState(() {
      _filteredBibles = _bibles.where((bible) {
        return bible.name.toLowerCase().contains(query.toLowerCase()) ||
            bible.language.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(17),
        constraints: const BoxConstraints(
          maxHeight: 600,
          maxWidth: double.infinity,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Bible',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search bibles...',
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colorScheme.primary,
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
              onChanged: _filterBibles,
              style: TextStyle(color: colorScheme.onSurface),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading
                  ? Center(
                child: CircularProgressIndicator(
                  color: colorScheme.primary,
                ),
              )
                  : _filteredBibles.isEmpty
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 48,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No bibles found',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.separated(
                itemCount: _filteredBibles.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: colorScheme.outlineVariant,
                ),
                itemBuilder: (context, index) {
                  final bible = _filteredBibles[index];
                  return RadioListTile<String>(
                    value: bible.id,
                    groupValue: _selectedBibleId,
                    title: Text(
                      bible.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      bible.language,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    activeColor: colorScheme.primary,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedBibleId = value;
                      });
                      widget.onBibleSelected(bible.id, bible.name);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}