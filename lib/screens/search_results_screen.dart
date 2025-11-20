import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/bible_verse.dart';
import '../services/database_service.dart';

class SearchResultsScreen extends StatefulWidget {
  final List<BibleVerse> searchResults;
  final String searchQuery;

  const SearchResultsScreen({
    Key? key,
    required this.searchResults,
    required this.searchQuery,
  }) : super(key: key);

  @override
  _SearchResultsScreenState createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final DatabaseService _databaseService = DatabaseService();

  // Function to handle bookmarking a verse
  Future<void> _bookmarkVerse(BuildContext context, BibleVerse verse) async {
    try {
      await _databaseService.toggleBookmark(verse);

      // Check the new state
      final isBookmarked = await _databaseService.isBookmarked(verse);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isBookmarked
                ? '${verse.bookName} ${verse.chapterNumber}:${verse.verseNumber} ወደ የተውሰጦች ዝርዝር ታክሏል'
                : '${verse.bookName} ${verse.chapterNumber}:${verse.verseNumber} ከየተውሰጦች ዝርዝር ተሰርዟል',
            style: TextStyle(fontFamily: 'NotoSansEthiopic'),
          ),
          backgroundColor: isBookmarked ? Colors.green[700] : Colors.grey[700],
          duration: Duration(seconds: 2),
        ),
      );

      // Update the local state
      setState(() {
        verse.isBookmarked = isBookmarked;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ስህተት: $e',
            style: TextStyle(fontFamily: 'NotoSansEthiopic'),
          ),
          backgroundColor: Colors.red[700],
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Function to handle highlighting a verse
  Future<void> _highlightVerse(BuildContext context, BibleVerse verse) async {
    try {
      // Check if already highlighted
      final existingHighlight = await _databaseService.getHighlight(verse);

      if (existingHighlight != null) {
        // Remove highlight
        await _databaseService.removeHighlight(verse);
        setState(() {
          verse.isHighlighted = false;
          verse.highlightColor = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${verse.bookName} ${verse.chapterNumber}:${verse.verseNumber} ጎልማሳ ተሰርዟል',
              style: TextStyle(fontFamily: 'NotoSansEthiopic'),
            ),
            backgroundColor: Colors.grey[700],
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Add highlight with default yellow color
        await _databaseService.updateHighlight(verse, 'yellow');
        setState(() {
          verse.isHighlighted = true;
          verse.highlightColor = 'yellow';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${verse.bookName} ${verse.chapterNumber}:${verse.verseNumber} ተጎልሟል',
              style: TextStyle(fontFamily: 'NotoSansEthiopic'),
            ),
            backgroundColor: Colors.amber[700],
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ስህተት: $e',
            style: TextStyle(fontFamily: 'NotoSansEthiopic'),
          ),
          backgroundColor: Colors.red[700],
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Function to handle sharing a verse
  void _shareVerse(BuildContext context, BibleVerse verse) {
    final String verseText =
        '${verse.bookName} ${verse.chapterNumber}:${verse.verseNumber}\n${verse.amharicText}';

    Share.share(
      verseText,
      subject: 'መጽሐፍ ቅዱስ ጥቅስ',
    );
  }

  // Function to handle copying a verse to clipboard
  void _copyVerse(BuildContext context, BibleVerse verse) {
    final String verseText =
        '${verse.bookName} ${verse.chapterNumber}:${verse.verseNumber} - ${verse.amharicText}';
    Clipboard.setData(ClipboardData(text: verseText)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ጥቅሱ ወደ መልጠሻ ሰሌዳ ተገልብጧል',
            style: TextStyle(fontFamily: 'NotoSansEthiopic'),
          ),
          backgroundColor: Colors.purple[700],
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;
    final Color backgroundColor =
        isDarkMode ? Colors.grey[900]! : Colors.grey[100]!;
    final Color appBarColor = isDarkMode
        ? Colors.grey[800]!
        : const Color.fromARGB(255, 65, 105, 225);
    final Color primaryColor =
        isDarkMode ? Colors.blue[200]! : const Color.fromARGB(255, 25, 75, 200);
    final Color secondaryColor = isDarkMode
        ? Colors.grey[700]!
        : const Color.fromARGB(255, 240, 240, 245);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'የፍለጋ ውጤቶች',
          style: TextStyle(
            fontFamily: 'NotoSansEthiopic',
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: appBarColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(12),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 28),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
      ),
      body: Container(
        color: backgroundColor,
        child: Column(
          children: [
            // Search summary
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'NotoSansEthiopic',
                    color: textColor,
                  ),
                  children: [
                    TextSpan(
                      text: '"${widget.searchQuery}" ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    TextSpan(
                      text: 'የሚለውን ቃል የያዙ ',
                    ),
                    TextSpan(
                      text: '${widget.searchResults.length}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    TextSpan(
                      text: ' ጥቅሶች ተገኝተዋል',
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Results list
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: widget.searchResults.length,
                itemBuilder: (context, index) {
                  final verse = widget.searchResults[index];
                  return _buildVerseCard(
                      context, verse, primaryColor, secondaryColor, textColor);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerseCard(BuildContext context, BibleVerse verse,
      Color primaryColor, Color secondaryColor, Color textColor) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Verse reference
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primaryColor.withOpacity(0.3)),
              ),
              child: Text(
                '${verse.bookName} ${verse.chapterNumber}:${verse.verseNumber}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  fontFamily: 'NotoSansEthiopic',
                ),
              ),
            ),
            SizedBox(height: 12),
            // Verse text
            Text(
              verse.amharicText,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'NotoSansEthiopic',
                height: 1.5,
                color: textColor,
              ),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 16),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: verse.isBookmarked
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                  color: verse.isBookmarked
                      ? Colors.green[700]
                      : Colors.green[700],
                  tooltip:
                      verse.isBookmarked ? 'መጽሐፍ ምልክት አስወግድ' : 'መጽሐፍ ምልክት አድርግ',
                  onPressed: () => _bookmarkVerse(context, verse),
                ),
                _buildActionButton(
                  icon: verse.isHighlighted
                      ? Icons.highlight
                      : Icons.highlight_outlined,
                  color: verse.isHighlighted
                      ? Colors.amber[700]
                      : Colors.amber[700],
                  tooltip: verse.isHighlighted ? 'ጎልማሳ አስወግድ' : 'ጎልማሳ',
                  onPressed: () => _highlightVerse(context, verse),
                ),
                _buildActionButton(
                  icon: Icons.share,
                  color: Colors.blue[700],
                  tooltip: 'አጋራ',
                  onPressed: () => _shareVerse(context, verse),
                ),
                _buildActionButton(
                  icon: Icons.copy,
                  color: Colors.purple[700],
                  tooltip: 'ቅዳ',
                  onPressed: () => _copyVerse(context, verse),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color? color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color?.withOpacity(0.1),
        ),
        child: IconButton(
          icon: Icon(icon, size: 20, color: color),
          onPressed: onPressed,
          padding: EdgeInsets.all(8),
        ),
      ),
    );
  }
}
