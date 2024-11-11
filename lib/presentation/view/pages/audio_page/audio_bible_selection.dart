import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bible/services/audio_service.dart';
import '../../../../data/models/Audio.dart';

class ModernAudioBibleSelector extends StatefulWidget {
  final String? currentBibleId;
  final Function(String bibleId, String bibleName) onBibleSelected;

  const ModernAudioBibleSelector({
    super.key,
    this.currentBibleId,
    required this.onBibleSelected,
  });

  @override
  _ModernAudioBibleSelectorState createState() => _ModernAudioBibleSelectorState();
}

class _ModernAudioBibleSelectorState extends State<ModernAudioBibleSelector> {
  final MyAudioService _audioService = MyAudioService();
  List<AudioBible> _audioBibles = [];
  List<AudioBible> _filteredBibles = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAudioBibles();
  }

  Future<void> _fetchAudioBibles() async {
    try {
      final bibles = await _audioService.fetchAudioBibles();
      setState(() {
        _audioBibles = bibles;
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
            content: Text('Error loading audio Bibles: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterBibles(String query) {
    setState(() {
      _filteredBibles = _audioBibles.where((bible) {
        return bible.name.toLowerCase().contains(query.toLowerCase()) ||
            bible.language.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: theme.dialogBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Audio Bible',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search audio Bibles...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.inputDecorationTheme.fillColor,
              ),
              onChanged: _filterBibles,
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredBibles.length,
                    itemBuilder: (context, index) {
                      final bible = _filteredBibles[index];
                      final isSelected = bible.id == widget.currentBibleId;

                      return Card(
                        elevation: isSelected ? 2 : 0,
                        color: isSelected
                            ? theme.colorScheme.primary.withOpacity(0.1)
                            : theme.cardColor,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primary,
                            child: Text(
                              bible.language.substring(0, 2).toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            bible.name,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(bible.language),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle,
                                  color: theme.colorScheme.primary,
                                )
                              : null,
                          onTap: () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString('favoriteAudioBible', bible.id);
                            await prefs.setString('favoriteAudioBibleName', bible.name);
                            widget.onBibleSelected(bible.id, bible.name);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}