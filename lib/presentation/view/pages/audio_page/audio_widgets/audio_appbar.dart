
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

AppBar buildModernAppBar(
  BuildContext context,
  String? currentBibleName,
  VoidCallback onSelectBible,
) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final appBarColor = isDarkMode ? Colors.black : Colors.white;
  const buttonColor = Colors.blue;

  return AppBar(
    elevation: 0,
    backgroundColor: appBarColor,
    automaticallyImplyLeading: false,
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              CupertinoIcons.book_fill,
              size: 20,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Audio Bible',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
          child: Text(
            currentBibleName ?? 'Select Bible',
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
    actions: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Hero(
          tag: 'select-bible-button',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onSelectBible,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: buttonColor.withOpacity(0.3),
                    width: 1,
                  ),
                  color: buttonColor.withOpacity(0.1),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.music_note,
                      size: 18,
                      color: buttonColor,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Select Audio Bible',
                      style: TextStyle(
                        color: buttonColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}