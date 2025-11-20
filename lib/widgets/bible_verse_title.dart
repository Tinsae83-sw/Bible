import 'package:flutter/material.dart';
import '../models/bible_verse.dart';

class BibleVerseTile extends StatelessWidget {
  final BibleVerse verse;
  final Color textColor;
  final VoidCallback onMenuPressed;
  final double fontSize;

  const BibleVerseTile({
    super.key,
    required this.verse,
    required this.textColor,
    required this.onMenuPressed,
    required this.fontSize,
  });

  Color _getHighlightColor(String? colorName) {
    switch (colorName) {
      case 'yellow':
        return Colors.yellow.withOpacity(0.3);
      case 'green':
        return Colors.green.withOpacity(0.3);
      case 'blue':
        return Colors.blue.withOpacity(0.3);
      case 'pink':
        return Colors.pink.withOpacity(0.3);
      case 'purple':
        return Colors.purple.withOpacity(0.3);
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double verseNumberSize = fontSize - 1;
    final double iconSize = fontSize - 2;

    final bool isHighlighted =
        verse.isHighlighted && verse.highlightColor != null;
    final Color highlightColor = isHighlighted
        ? _getHighlightColor(verse.highlightColor)
        : Colors.transparent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      decoration: BoxDecoration(
        color: highlightColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Verse number - compact
          Container(
            padding: const EdgeInsets.only(top: 1, right: 3),
            child: Text(
              '${verse.verseNumber}.',
              style: TextStyle(
                fontSize: verseNumberSize.clamp(10, 16),
                fontWeight: FontWeight.w600,
                color: textColor.withOpacity(0.8),
                fontFamily: 'NotoSansEthiopic',
                height: 1.1,
              ),
            ),
          ),
          // Verse text - uses the dynamic fontSize
          Expanded(
            child: Text(
              verse.amharicText,
              style: TextStyle(
                fontSize: fontSize.clamp(12, 24),
                color: textColor,
                fontFamily: 'NotoSansEthiopic',
                height: 1.15,
                letterSpacing: -0.1,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          // Compact menu button
          GestureDetector(
            onTap: onMenuPressed,
            child: Container(
              padding: const EdgeInsets.all(2),
              margin: const EdgeInsets.only(left: 4),
              child: Icon(
                Icons.more_vert,
                size: iconSize.clamp(10, 16),
                color: textColor.withOpacity(0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
