import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import '../widgets/navigation_drawer.dart';
import '../services/bible_service.dart';
import '../models/bible_verse.dart';
import '../screens/search_results_screen.dart';
import '../screens/about.dart';
import '../models/bible_book.dart';
import '../models/bible_chapter.dart';
import '../services/database_service.dart';
import '../services/settings_service.dart';
import '../widgets/bible_verse_title.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BibleService _bibleService = BibleService();
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  bool _showSearch = false;
  String _errorMessage = '';
  List<BibleVerse> _searchResults = [];
  bool _isSearching = false;

  List<BibleBook> _bibleBooks = [];
  int _currentBookIndex = 0;
  int _currentChapter = 1;
  BibleChapter? _currentChapterContent;
  bool _isChapterLoading = false;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
        _loadLastReadPosition().then((_) {
          _loadBooks();
        });
      }
    });
  }

  Future<void> _loadLastReadPosition() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentBookIndex = prefs.getInt('lastBookIndex') ?? 0;
      _currentChapter = prefs.getInt('lastChapter') ?? 1;
    });
  }

  Future<void> _saveLastReadPosition() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastBookIndex', _currentBookIndex);
    await prefs.setInt('lastChapter', _currentChapter);
  }

  Future<void> _loadBooks() async {
    try {
      final books = await _bibleService.getBooks();
      setState(() {
        _bibleBooks = books;
        _isLoading = false;
        _errorMessage = '';
      });
      if (_bibleBooks.isNotEmpty) {
        if (_currentBookIndex >= _bibleBooks.length) {
          _currentBookIndex = 0;
        }
        if (_currentChapter > _bibleBooks[_currentBookIndex].chapters) {
          _currentChapter = 1;
        }
        _loadChapterContent();
      }
    } catch (e) {
      print('Error loading books: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load books: $e';
      });
    }
  }

  Future<void> _loadChapterContent() async {
    if (_bibleBooks.isEmpty) return;

    setState(() {
      _isChapterLoading = true;
    });

    try {
      final chapter = await _bibleService.getChapter(
        _bibleBooks[_currentBookIndex].id,
        _currentChapter,
      );

      for (var verse in chapter.verses) {
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

      setState(() {
        _currentChapterContent = chapter;
        _isChapterLoading = false;
      });

      _saveLastReadPosition();
    } catch (e) {
      print('Error loading chapter: $e');
      setState(() {
        _isChapterLoading = false;
        _errorMessage = 'Failed to load chapter content: $e';
      });
    }
  }

  void _searchVerses(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _showSearch = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await _bibleService.searchVerses(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });

      if (results.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchResultsScreen(
              searchResults: results,
              searchQuery: query,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"$query" የሚለውን ቃል የያዘ ጥቅስ አልተገኘም'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('የፍለጋ ስህተት: $e'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      if (!_showSearch) {
        _searchController.clear();
        _searchResults = [];
      }
    });
  }

  void _navigateToChapter(int chapterDelta) {
    if (_bibleBooks.isEmpty) return;

    setState(() {
      _currentChapter += chapterDelta;

      if (_currentChapter < 1) {
        if (_currentBookIndex > 0) {
          _currentBookIndex--;
          _currentChapter = _bibleBooks[_currentBookIndex].chapters;
        } else {
          _currentChapter = 1;
        }
      } else if (_currentChapter > _bibleBooks[_currentBookIndex].chapters) {
        if (_currentBookIndex < _bibleBooks.length - 1) {
          _currentBookIndex++;
          _currentChapter = 1;
        } else {
          _currentChapter = _bibleBooks[_currentBookIndex].chapters;
        }
      }

      _saveLastReadPosition();
      _loadChapterContent();
    });
  }

  void _selectBook(int bookIndex, int chapter) {
    setState(() {
      _currentBookIndex = bookIndex;
      _currentChapter = chapter;
      _saveLastReadPosition();
      _loadChapterContent();
    });
  }

  void _showVerseOptionsMenu(BibleVerse verse, BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor ??
          Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withOpacity(0.95),
              ],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        Theme.of(context).colorScheme.primary.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.8),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.menu_book_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${verse.bookName} ${verse.chapterNumber}:${verse.verseNumber}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                                fontFamily: 'NotoSansEthiopic',
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Verse Options',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.4,
                    children: [
                      _buildModernOptionButton(
                        context,
                        icon: verse.isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_add_rounded,
                        label: verse.isBookmarked
                            ? 'Remove Bookmark'
                            : 'Add Bookmark',
                        subtitle: verse.isBookmarked ? 'Saved' : 'Save verse',
                        isActive: verse.isBookmarked,
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            verse.isBookmarked = !verse.isBookmarked;
                          });
                          _databaseService.toggleBookmark(verse);
                        },
                      ),
                      _buildModernOptionButton(
                        context,
                        icon: verse.isHighlighted
                            ? Icons.highlight_rounded
                            : Icons.highlight_alt_rounded,
                        label: verse.isHighlighted
                            ? 'Edit Highlight'
                            : 'Highlight',
                        subtitle:
                            verse.isHighlighted ? 'Change color' : 'Mark verse',
                        isActive: verse.isHighlighted,
                        onTap: () {
                          Navigator.pop(context);
                          _showHighlightColorDialog(verse);
                        },
                      ),
                      _buildModernOptionButton(
                        context,
                        icon: Icons.share_rounded,
                        label: 'Share',
                        subtitle: 'Share verse',
                        onTap: () {
                          Navigator.pop(context);
                          _shareVerse(verse);
                        },
                      ),
                      _buildModernOptionButton(
                        context,
                        icon: Icons.copy_rounded,
                        label: 'Copy',
                        subtitle: 'Copy to clipboard',
                        onTap: () {
                          Navigator.pop(context);
                          _copyToClipboard(verse);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernOptionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      color: isActive
          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
          : Theme.of(context).colorScheme.surface,
      elevation: 2,
      shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: isActive
                      ? LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.8),
                          ],
                        )
                      : LinearGradient(
                          colors: [
                            Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.1),
                            Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.05),
                          ],
                        ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isActive
                      ? Colors.white
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 1,
              ),
              SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHighlightColorDialog(BibleVerse verse) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.surface.withOpacity(0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        Theme.of(context).colorScheme.primary.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.palette_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Select Highlight Color',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildModernColorOption(
                      verse,
                      Colors.yellow,
                      'Yellow',
                      Icons.sunny,
                      'yellow',
                    ),
                    _buildModernColorOption(
                      verse,
                      Colors.green,
                      'Green',
                      Icons.nature,
                      'green',
                    ),
                    _buildModernColorOption(
                      verse,
                      Colors.blue,
                      'Blue',
                      Icons.water_drop,
                      'blue',
                    ),
                    _buildModernColorOption(
                      verse,
                      Colors.pink,
                      'Pink',
                      Icons.favorite,
                      'pink',
                    ),
                    _buildModernColorOption(
                      verse,
                      Colors.purple,
                      'Purple',
                      Icons.brush,
                      'purple',
                    ),
                  ],
                ),
                if (verse.isHighlighted) ...[
                  const SizedBox(height: 24),
                  Divider(),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.red.withOpacity(0.1),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.highlight_off_rounded,
                          color: Colors.red,
                        ),
                      ),
                      title: Text(
                        'Remove Highlight',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                      onTap: () => _removeHighlight(verse),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernColorOption(
    BibleVerse verse,
    Color color,
    String label,
    IconData icon,
    String colorName,
  ) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      color: Theme.of(context).colorScheme.surface,
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _applyHighlight(verse, colorName),
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.8), color.withOpacity(0.4)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'NotoSansEthiopic',
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _applyHighlight(BibleVerse verse, String colorName) {
    setState(() {
      verse.isHighlighted = true;
      verse.highlightColor = colorName;
    });
    _databaseService.updateHighlight(verse, colorName);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Verse highlighted in $colorName'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _removeHighlight(BibleVerse verse) {
    setState(() {
      verse.isHighlighted = false;
      verse.highlightColor = null;
    });
    _databaseService.removeHighlight(verse);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Highlight removed'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _shareVerse(BibleVerse verse) {
    final String shareText =
        '${verse.bookName} ${verse.chapterNumber}:${verse.verseNumber}\n${verse.amharicText}';
    Share.share(
      shareText,
      subject: '${verse.bookName} ${verse.chapterNumber}:${verse.verseNumber}',
    );
  }

  void _copyToClipboard(BibleVerse verse) {
    final String shareText =
        '${verse.bookName} ${verse.chapterNumber}:${verse.verseNumber}\n${verse.amharicText}';
    Clipboard.setData(ClipboardData(text: shareText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Copied to clipboard',
          style: TextStyle(fontFamily: 'NotoSansEthiopic'),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return _buildModernSplashScreen();
    }

    final settings = Provider.of<SettingsService>(context);
    final bool isDarkMode = settings.darkMode;
    final Color primaryColor =
        isDarkMode ? Colors.grey[800]! : const Color(0xFF2563EB);
    final Color onSurfaceColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: _buildModernAppBar(context, primaryColor, onSurfaceColor),
      drawer: BibleNavigationDrawer(
        books: _bibleBooks,
        onBookSelected: _selectBook,
      ),
      body: _buildModernBody(context, primaryColor, onSurfaceColor),
    );
  }

  Widget _buildModernSplashScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF2563EB),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2563EB), Color(0xFF3B82F6), Color(0xFF60A5FA)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 25,
                      spreadRadius: 2,
                      offset: Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 1,
                      offset: Offset(0, -5),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.8),
                    width: 4,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/icon.png',
                    width: 160,
                    height: 160,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
              SizedBox(height: 40),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.9),
                      Colors.white.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'መጽሐፍ ቅዱስ',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2563EB),
                        fontFamily: 'NotoSansEthiopic',
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Holy Bible',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF2563EB).withOpacity(0.8),
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50),
              Container(
                width: 50,
                height: 50,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.9),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildModernAppBar(
    BuildContext context,
    Color primaryColor,
    Color onSurfaceColor,
  ) {
    return AppBar(
      title: _showSearch
          ? Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'መጽሐፍ ቅዱስ ፍለጋ...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.white70,
                  ),
                  suffixIcon: _isSearching
                      ? Container(
                          width: 20,
                          height: 20,
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : IconButton(
                          icon: Icon(Icons.close_rounded),
                          onPressed: _toggleSearch,
                          color: Colors.white,
                        ),
                ),
                style: TextStyle(color: Colors.white),
                onSubmitted: _searchVerses,
              ),
            )
          : Text(
              _bibleBooks.isNotEmpty
                  ? _bibleBooks[_currentBookIndex].amharicName
                  : 'መጽሐፍ ቅዱስ',
              style: TextStyle(
                fontFamily: 'NotoSansEthiopic',
                fontWeight: FontWeight.w700,
                fontSize: 20,
                letterSpacing: 0.5,
              ),
            ),
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      leading: Builder(
        builder: (context) => Container(
          margin: EdgeInsets.only(left: 8),
          child: IconButton(
            icon: Icon(Icons.menu_rounded, size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: 'Open navigation menu',
          ),
        ),
      ),
      actions: _buildModernAppBarActions(context, onSurfaceColor),
    );
  }

  List<Widget> _buildModernAppBarActions(
    BuildContext context,
    Color onSurfaceColor,
  ) {
    return [
      if (!_showSearch)
        Container(
          margin: EdgeInsets.only(right: 8),
          child: IconButton(
            icon: Icon(Icons.search_rounded, size: 26),
            onPressed: _toggleSearch,
            tooltip: 'Search verses',
          ),
        ),
      if (_showSearch)
        Container(
          margin: EdgeInsets.only(right: 8),
          child: IconButton(
            icon: Icon(Icons.close_rounded, size: 26),
            onPressed: _toggleSearch,
            tooltip: 'Close search',
          ),
        ),
      Container(
        margin: EdgeInsets.only(right: 16),
        child: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'about')
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutScreen()),
              );
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'about',
              child: Row(
                children: [
                  Icon(
                    Icons.info_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'ስለ አፕሊኬሽኑ',
                    style: TextStyle(
                      fontFamily: 'NotoSansEthiopic',
                      color: onSurfaceColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.more_vert_rounded, color: Colors.white, size: 22),
          ),
        ),
      ),
    ];
  }

  Widget _buildModernBody(
    BuildContext context,
    Color primaryColor,
    Color onSurfaceColor,
  ) {
    final settings = Provider.of<SettingsService>(context);
    final bool isDarkMode = settings.darkMode;

    return _isLoading
        ? _buildModernLoadingState(primaryColor, onSurfaceColor)
        : _bibleBooks.isEmpty
            ? _buildModernErrorState(primaryColor, onSurfaceColor)
            : Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: isDarkMode
                          ? LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.grey[900]!,
                                Colors.grey[850]!,
                                Colors.grey[900]!,
                              ],
                            )
                          : LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                primaryColor.withOpacity(0.03),
                                Theme.of(context)
                                    .colorScheme
                                    .surface
                                    .withOpacity(0.8),
                                Theme.of(context).colorScheme.surface,
                              ],
                            ),
                    ),
                    child: Column(
                      children: [
                        _buildModernChapterTitle(
                          context,
                          primaryColor,
                          onSurfaceColor,
                        ),
                        Expanded(
                          child: _buildModernChapterContent(
                            context,
                            primaryColor,
                            onSurfaceColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: _buildFloatingNavButton(
                      icon: Icons.arrow_back_ios_rounded,
                      onPressed: (_currentBookIndex > 0 || _currentChapter > 1)
                          ? () => _navigateToChapter(-1)
                          : null,
                      primaryColor: primaryColor,
                    ),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: _buildFloatingNavButton(
                      icon: Icons.arrow_forward_ios_rounded,
                      onPressed: (_currentBookIndex < _bibleBooks.length - 1 ||
                              _currentChapter <
                                  _bibleBooks[_currentBookIndex].chapters)
                          ? () => _navigateToChapter(1)
                          : null,
                      primaryColor: primaryColor,
                    ),
                  ),
                ],
              );
  }

  Widget _buildModernLoadingState(Color primaryColor, Color onSurfaceColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withOpacity(0.7)],
              ),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Loading Bible...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: onSurfaceColor.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Preparing your spiritual journey',
            style: TextStyle(
              fontSize: 14,
              color: onSurfaceColor.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernErrorState(Color primaryColor, Color onSurfaceColor) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Unable to Load Bible',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: onSurfaceColor,
              ),
            ),
            SizedBox(height: 12),
            Text(
              _errorMessage.isNotEmpty
                  ? _errorMessage
                  : 'Please check your connection and try again',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: onSurfaceColor.withOpacity(0.6),
                height: 1.4,
              ),
              maxLines: 3,
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loadBooks,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                elevation: 4,
                shadowColor: primaryColor.withOpacity(0.3),
              ),
              child: Text(
                'Try Again',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernChapterTitle(
    BuildContext context,
    Color primaryColor,
    Color onSurfaceColor,
  ) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          SizedBox(height: 2),
          Text(
            'Chapter $_currentChapter',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: primaryColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingNavButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required Color primaryColor,
  }) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: onPressed != null ? primaryColor : Colors.grey.withOpacity(0.4),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: CircleBorder(),
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: onPressed,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildModernChapterContent(
    BuildContext context,
    Color primaryColor,
    Color onSurfaceColor,
  ) {
    final settings = Provider.of<SettingsService>(context);
    final double fontSize = settings.fontSize;

    return _isChapterLoading
        ? _buildChapterSkeleton()
        : _currentChapterContent == null ||
                _currentChapterContent!.verses.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.book_rounded,
                      size: 64,
                      color: onSurfaceColor.withOpacity(0.3),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Chapter content not available',
                      style: TextStyle(
                        fontSize: 16,
                        color: onSurfaceColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              )
            : Container(
                margin: EdgeInsets.fromLTRB(4, 0, 4, 4),
                child: ListView.builder(
                  padding: EdgeInsets.only(bottom: 4),
                  itemCount: _currentChapterContent!.verses.length,
                  itemBuilder: (context, index) {
                    final verse = _currentChapterContent!.verses[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 0),
                      child: BibleVerseTile(
                        verse: verse,
                        textColor: onSurfaceColor,
                        fontSize: fontSize,
                        onMenuPressed: () {
                          _showVerseOptionsMenu(verse, context);
                        },
                      ),
                    );
                  },
                ),
              );
  }

  Widget _buildChapterSkeleton() {
    return Container(
      margin: EdgeInsets.fromLTRB(4, 0, 4, 4),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          padding: EdgeInsets.only(bottom: 4),
          itemCount: 15, // Show 15 skeleton verses
          itemBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.only(bottom: 0),
              padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Skeleton verse number
                  Container(
                    padding: EdgeInsets.only(top: 1, right: 3),
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
                          width: MediaQuery.of(context).size.width * 0.7,
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
                    padding: EdgeInsets.all(2),
                    margin: EdgeInsets.only(left: 4),
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
}
