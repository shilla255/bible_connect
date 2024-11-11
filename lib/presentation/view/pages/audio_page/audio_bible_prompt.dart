import 'package:flutter/material.dart';

class AudioBiblePrompt extends StatelessWidget {
  final VoidCallback onSelectBible;

  const AudioBiblePrompt({
    super.key,
    required this.onSelectBible,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.library_music,
          size: 48,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 16),
        const Text(
          'Welcome to Audio Bible',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Please select your preferred audio Bible version to get started',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: onSelectBible,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Select Audio Bible'),
        ),
      ],
    );
  }
}//