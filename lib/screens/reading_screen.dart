import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../services/bible_service.dart';
import '../services/database_service.dart';
import '../services/settings_service.dart';
import '../models/bible_book.dart';
import '../models/bible_chapter.dart';
import '../models/bible_verse.dart';
import '../widgets/bible_verse_title.dart';

class ReadingScreen extends StatefulWidget {
  final BibleBook book;
  final int chapterNumber;

  const ReadingScreen(
      {super.key, required this.book, required this.chapterNumber});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  final BibleService _bibleService = BibleService();
  final DatabaseService _databaseService = DatabaseService();

  BibleChapter? _chapter;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChapter();
    _saveReadingProgress();
  }

  Future<void> _loadChapter() async {
    try {
      final chapter =
          await _bibleService.getChapter(widget.book.id, widget.chapterNumber);
      setState(() {
        _chapter = chapter;
        _isLoading = false;
      });
      _loadVerseStates();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('ክፍሉ መጫን አልተቻለም')));
    }
  }

  Future<void> _loadVerseStates() async {
    if (_chapter == null) return;
    for (final verse in _chapter!.verses) {
      final isBookmarked = await _databaseService.isBookmarked(verse);
      final highlightData = await _databaseService.getHighlight(verse);
      setState(() {
        verse.isBookmarked = isBookmarked;
        if (highlightData != null) {
          verse.isHighlighted = true;
          verse.highlightColor = highlightData['color'];
        }
      });
    }
  }

  Future<void> _saveReadingProgress() async {
    final preferences = await _databaseService.getUserPreferences();
    await _databaseService.saveUserPreferences(preferences.copyWith(
        lastReadBook: widget.book.id.toString(),
        lastReadChapter: widget.chapterNumber,
        lastReadVerse: 1));
  }

  void _navigateToChapter(int chapterNumber) {
    if (chapterNumber < 1 || chapterNumber > widget.book.chapters) return;
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ReadingScreen(
                book: widget.book, chapterNumber: chapterNumber)));
  }

  void _showHighlightColorDialog(BibleVerse verse) {
    showDialog(
        context: context,
        builder: (BuildContext context) => _buildHighlightColorDialog(verse));
  }

  Widget _buildHighlightColorDialog(BibleVerse verse) {
    return AlertDialog(
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      title: const Text('የምልክት ቀለም ምረጥ'),
      content: SingleChildScrollView(
          child: Column(children: [
        _buildColorOption(verse, Colors.yellow, 'ቢጫ'),
        _buildColorOption(verse, Colors.green, 'አረንጓዴ'),
        _buildColorOption(verse, Colors.blue, 'ሰማያዊ'),
        _buildColorOption(verse, Colors.pink, 'ሮዝ'),
        _buildColorOption(verse, Colors.purple, 'ሐምራዊ'),
        if (verse.isHighlighted)
          ListTile(
              leading: const Icon(Icons.highlight_off, color: Colors.red),
              title: const Text('ምልክት አስወግድ'),
              onTap: () => _removeHighlight(verse)),
      ])),
    );
  }

  ListTile _buildColorOption(BibleVerse verse, Color color, String label) {
    return ListTile(
        leading: Icon(Icons.color_lens, color: color),
        title: Text(label),
        onTap: () => _applyHighlight(verse, _getColorName(color)));
  }

  String _getColorName(Color color) {
    if (color == Colors.yellow) return 'yellow';
    if (color == Colors.green) return 'green';
    if (color == Colors.blue) return 'blue';
    if (color == Colors.pink) return 'pink';
    if (color == Colors.purple) return 'purple';
    return 'yellow';
  }

  void _applyHighlight(BibleVerse verse, String color) {
    setState(() {
      verse.isHighlighted = true;
      verse.highlightColor = color;
    });
    _databaseService.updateHighlight(verse, color);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Verse highlighted in ${_getColorDisplayName(color)}'),
        behavior: SnackBarBehavior.floating));
  }

  String _getColorDisplayName(String colorName) {
    switch (colorName) {
      case 'yellow':
        return 'yellow';
      case 'green':
        return 'green';
      case 'blue':
        return 'blue';
      case 'pink':
        return 'pink';
      case 'purple':
        return 'purple';
      default:
        return 'yellow';
    }
  }

  void _removeHighlight(BibleVerse verse) {
    setState(() {
      verse.isHighlighted = false;
      verse.highlightColor = null;
    });
    _databaseService.removeHighlight(verse);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Highlight removed'),
        behavior: SnackBarBehavior.floating));
  }

  void _shareVerse(BibleVerse verse) {
    final String shareText =
        '${verse.bookName} ${verse.chapterNumber}:${verse.verseNumber}\n${verse.amharicText}';
    Share.share(shareText,
        subject:
            '${verse.bookName} ${verse.chapterNumber}:${verse.verseNumber}');
  }

  void _copyToClipboard(BibleVerse verse) {
    final String shareText =
        '${verse.bookName} ${verse.chapterNumber}:${verse.verseNumber}\n${verse.amharicText}';
    Clipboard.setData(ClipboardData(text: shareText));
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('copied')));
  }

  void _showVerseOptionsMenu(BibleVerse verse, BuildContext context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
        builder: (BuildContext context) => _buildVerseOptionsMenu(verse));
  }

  Widget _buildVerseOptionsMenu(BibleVerse verse) {
    return SafeArea(
        child: Wrap(children: [
      _buildBookmarkOption(verse),
      _buildHighlightOption(verse),
      _buildShareOption(verse),
      _buildCopyOption(verse)
    ]));
  }

  ListTile _buildBookmarkOption(BibleVerse verse) {
    return ListTile(
      leading: Icon(verse.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          color: verse.isBookmarked
              ? Theme.of(context).colorScheme.primary
              : null),
      title: Text(verse.isBookmarked ? 'መጽሐፍ ምልክት አስወግድ' : 'መጽሐፍ ምልክት አድርግ'),
      onTap: () {
        Navigator.pop(context);
        _toggleBookmark(verse);
      },
    );
  }

  ListTile _buildHighlightOption(BibleVerse verse) {
    return ListTile(
      leading: Icon(
          verse.isHighlighted ? Icons.highlight : Icons.highlight_outlined,
          color: verse.isHighlighted
              ? _getColorFromString(verse.highlightColor)
              : null),
      title: Text(verse.isHighlighted ? 'ምልክት አስተካክል' : 'ምልክት ያድርጉ'),
      onTap: () {
        Navigator.pop(context);
        _showHighlightColorDialog(verse);
      },
    );
  }

  ListTile _buildShareOption(BibleVerse verse) {
    return ListTile(
        leading: const Icon(Icons.share),
        title: const Text('አጋራ (share)'),
        onTap: () {
          Navigator.pop(context);
          _shareVerse(verse);
        });
  }

  ListTile _buildCopyOption(BibleVerse verse) {
    return ListTile(
        leading: const Icon(Icons.copy),
        title: const Text('copy'),
        onTap: () {
          Navigator.pop(context);
          _copyToClipboard(verse);
        });
  }

  void _toggleBookmark(BibleVerse verse) {
    setState(() => verse.isBookmarked = !verse.isBookmarked);
    _databaseService.toggleBookmark(verse);
  }

  Color _getColorFromString(String? colorName) {
    switch (colorName) {
      case 'yellow':
        return Colors.yellow;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'pink':
        return Colors.pink;
      case 'purple':
        return Colors.purple;
      default:
        return Colors.yellow;
    }
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text('${widget.book.amharicName} ምዕራፍ ${widget.chapterNumber}',
          style: const TextStyle(fontSize: 16, color: Colors.white)),
      backgroundColor: const Color.fromARGB(255, 25, 75, 200),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      actions: [
        IconButton(
            icon: const Icon(Icons.navigate_before, size: 20),
            onPressed: widget.chapterNumber > 1
                ? () => _navigateToChapter(widget.chapterNumber - 1)
                : null),
        Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text('${widget.chapterNumber}/${widget.book.chapters}',
                style: const TextStyle(color: Colors.white, fontSize: 12))),
        IconButton(
            icon: const Icon(Icons.navigate_next, size: 20),
            onPressed: widget.chapterNumber < widget.book.chapters
                ? () => _navigateToChapter(widget.chapterNumber + 1)
                : null),
      ],
    );
  }

  Widget _buildBody() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    if (_isLoading) return _buildChapterSkeleton();
    if (_chapter == null)
      return Center(
          child: Text('ክፍሉ አልተገኘም',
              style: TextStyle(fontSize: 16, color: textColor)));

    return Consumer<SettingsService>(builder: (context, settings, child) {
      final double fontSize = settings.fontSize;
      return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: _chapter!.verses.length,
              itemBuilder: (context, index) {
                final verse = _chapter!.verses[index];
                return BibleVerseTile(
                    verse: verse,
                    textColor: textColor,
                    fontSize: fontSize,
                    onMenuPressed: () => _showVerseOptionsMenu(verse, context));
              }));
    });
  }

  Widget _buildChapterSkeleton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: 20, // Show 20 skeleton verses
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Skeleton verse number
                  Container(
                    padding: const EdgeInsets.only(top: 1, right: 3),
                    child: Container(
                      width: 20,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Skeleton verse text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 12,
                          margin: EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: 12,
                          margin: EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Skeleton menu button
                  Container(
                    padding: const EdgeInsets.all(2),
                    margin: const EdgeInsets.only(left: 4),
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(), body: _buildBody());
  }
}
