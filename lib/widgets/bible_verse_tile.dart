import 'package:flutter/material.dart';
import 'package:Amharic_bible/models/bible_verse.dart';

class BibleVerseTile extends StatelessWidget {
  final BibleVerse verse;
  final String? fontFamily;
  final double? fontSize;
  final VoidCallback? onBookmark;
  final VoidCallback? onHighlight;
  final VoidCallback? onShare;
  final String? highlightText; // For search highlighting
  final bool showActions;
  final bool showReference;
  final Color? textColor; // Add this parameter for text color
  final VoidCallback? onMenuPressed; // Add this for menu callback

  const BibleVerseTile({
    super.key,
    required this.verse,
    this.fontFamily,
    this.fontSize,
    this.onBookmark,
    this.onHighlight,
    this.onShare,
    this.highlightText,
    this.showActions = true,
    this.showReference = false,
    this.textColor, // Add this parameter
    this.onMenuPressed, // Add this parameter
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

  // Helper method to highlight search text
  TextSpan _buildHighlightedText(
      String text, String query, BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDarkMode ? Colors.white : Colors.black;

    if (query.isEmpty) {
      return TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize,
          color: textColor ??
              defaultColor, // Use textColor if provided, otherwise use default
        ),
      );
    }

    final pattern = RegExp(RegExp.escape(query), caseSensitive: false);
    final matches = pattern.allMatches(text);

    if (matches.isEmpty) {
      return TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize,
          color: textColor ?? defaultColor,
        ),
      );
    }

    final List<TextSpan> spans = [];
    int currentIndex = 0;

    for (final match in matches) {
      // Text before the match
      if (match.start > currentIndex) {
        spans.add(
          TextSpan(
            text: text.substring(currentIndex, match.start),
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: fontSize,
              color: textColor ?? defaultColor,
            ),
          ),
        );
      }

      // The matched text with highlight
      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: fontSize,
            backgroundColor: Colors.yellow,
            color:
                Colors.black, // Keep search highlight text black for contrast
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      currentIndex = match.end;
    }

    // Text after the last match
    if (currentIndex < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(currentIndex),
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: fontSize,
            color: textColor ?? defaultColor,
          ),
        ),
      );
    }

    return TextSpan(children: spans);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDarkMode ? Colors.white : Colors.black;

    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontFamily: fontFamily,
          fontSize: fontSize,
          color: textColor ??
              defaultColor, // Use textColor if provided, otherwise use default
        );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: verse.isHighlighted
            ? _getHighlightColor(verse.highlightColor)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDarkMode
              ? Colors.grey[700]!
              : Colors.grey[300]!, // Adjust border color for dark mode
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Verse reference (optional)
          if (showReference) ...[
            Text(
              '${verse.bookName} ${verse.chapterNumber}:${verse.verseNumber}',
              style: textStyle?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(height: 8),
          ],
          // Verse number and text
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Verse number
              Container(
                width: 30,
                alignment: Alignment.topRight,
                child: Text(
                  '${verse.verseNumber}.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                        fontFamily: fontFamily,
                        fontSize: fontSize != null ? fontSize! * 0.9 : null,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              // Verse text with search highlighting
              Expanded(
                child: highlightText != null
                    ? RichText(
                        text: _buildHighlightedText(
                          verse.amharicText.isNotEmpty
                              ? verse.amharicText
                              : verse.text,
                          highlightText!,
                          context, // Pass context to access theme
                        ),
                        textAlign: TextAlign.justify,
                      )
                    : Text(
                        verse.amharicText.isNotEmpty
                            ? verse.amharicText
                            : verse.text,
                        style: textStyle,
                        textAlign: TextAlign.justify,
                      ),
              ),
              // Menu button for verse options
              if (onMenuPressed != null)
                IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    size: 20,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                  onPressed: onMenuPressed,
                  tooltip: 'Verse options',
                ),
            ],
          ),
          // Action buttons (optional)
          if (showActions &&
              (onBookmark != null ||
                  onHighlight != null ||
                  onShare != null)) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onBookmark != null)
                  IconButton(
                    icon: Icon(
                      verse.isBookmarked
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      size: 20,
                      color: Colors.blue,
                    ),
                    onPressed: onBookmark,
                    tooltip:
                        verse.isBookmarked ? 'Remove bookmark' : 'Bookmark',
                  ),
                if (onHighlight != null)
                  IconButton(
                    icon: Icon(
                      Icons.highlight,
                      size: 20,
                      color: Colors.amber,
                    ),
                    onPressed: onHighlight,
                    tooltip: 'Highlight',
                  ),
                if (onShare != null)
                  IconButton(
                    icon: const Icon(
                      Icons.share,
                      size: 20,
                      color: Colors.green,
                    ),
                    onPressed: onShare,
                    tooltip: 'Share',
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
