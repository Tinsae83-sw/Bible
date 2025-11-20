import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/bible_service.dart';
import '../services/database_service.dart';
import '../models/bible_book.dart';
import '../models/bible_chapter.dart';
import '../models/bible_verse.dart';
import '../services/settings_service.dart';
import '../widgets/settings_text.dart';
import 'home_screen.dart';
import 'search_results_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final BibleService _bibleService = BibleService();
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  List<BibleBook> _bibleBooks = [];
  int _currentBookIndex = 0;
  int _currentChapter = 1;
  BibleChapter? _currentChapterContent;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadLastReadPosition().then((_) {
      _loadBooks();
    });
  }

  Future<void> _loadLastReadPosition() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentBookIndex = prefs.getInt('lastBookIndex') ?? 0;
      _currentChapter = prefs.getInt('lastChapter') ?? 1;
    });
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
      _isLoading = true;
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
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading chapter: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _selectBook(int bookIndex, int chapter) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(),
      ),
    );
  }

  void _searchVerses(String query) async {
    if (query.isEmpty) return;

    try {
      final results = await _bibleService.searchVerses(query);
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
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('የፍለጋ ስህተት: $e')),
      );
    }
  }

  Widget _buildDashboardHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF0038B8),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'መጽሐፍ ቅዱስ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'NotoSansEthiopic',
                    ),
                  ),
                  Text(
                    'የእግዚአብሔር ቃል',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontFamily: 'NotoSansEthiopic',
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.book,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'መጽሐፍ ቅዱስ ፍለጋ...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        fontFamily: 'NotoSansEthiopic',
                      ),
                    ),
                    onSubmitted: _searchVerses,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => _searchVerses(_searchController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ፈጣን መዳረሻ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoSansEthiopic',
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.auto_stories,
                  title: 'ያነበብኩት',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.bookmark,
                  title: 'የተደለጡ',
                  color: Colors.green,
                  onTap: () {
                    // This will be handled by bottom navigation
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.highlight,
                  title: 'የተጎለበቱ',
                  color: Colors.orange,
                  onTap: () {
                    // This will be handled by bottom navigation
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'NotoSansEthiopic',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentReading() {
    if (_bibleBooks.isEmpty || _currentChapterContent == null) {
      return SizedBox();
    }

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'የአሁን ንባብ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NotoSansEthiopic',
                ),
              ),
              Text(
                '${_bibleBooks[_currentBookIndex].amharicName} ምዕራፍ $_currentChapter',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'NotoSansEthiopic',
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Card(
            elevation: 2,
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_currentChapterContent!.verses.isNotEmpty)
                    Text(
                      _currentChapterContent!.verses.first.amharicText,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'NotoSansEthiopic',
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_currentChapterContent!.verses.length} ጥቅሶች',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0038B8),
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          'መንቀል',
                          style: TextStyle(
                            fontFamily: 'NotoSansEthiopic',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBooksGrid() {
    if (_bibleBooks.isEmpty) return SizedBox();

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'መጽሐፍ ቅዱስ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoSansEthiopic',
            ),
          ),
          SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.5,
            ),
            itemCount: _bibleBooks.length > 6 ? 6 : _bibleBooks.length,
            itemBuilder: (context, index) {
              final book = _bibleBooks[index];
              return Card(
                elevation: 1,
                child: InkWell(
                  onTap: () => _selectBook(index, 1),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          book.amharicName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'NotoSansEthiopic',
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${book.chapters} ምዕ',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          if (_bibleBooks.length > 6)
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(),
                    ),
                  );
                },
                child: Text(
                  'ሁሉንም ይመልከቱ',
                  style: TextStyle(
                    fontFamily: 'NotoSansEthiopic',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);
    final bool isDarkMode = settings.darkMode;
    final Color backgroundColor =
        isDarkMode ? Colors.grey[900]! : Colors.grey[100]!;

    return Scaffold(
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  SettingsText(
                    'በመጫን ላይ...',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            )
          : _bibleBooks.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red[300],
                        ),
                        SizedBox(height: 16),
                        SettingsText(
                          _errorMessage.isNotEmpty
                              ? _errorMessage
                              : 'የመጽሐፍ ቅዱስ ዝርዝር ሊጫን አልተቻለም',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _loadBooks,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0038B8),
                            foregroundColor: Colors.white,
                          ),
                          child: SettingsText('እንደገና ይሞክሩ'),
                        ),
                      ],
                    ),
                  ),
                )
              : Container(
                  color: backgroundColor,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: _buildDashboardHeader()),
                      SliverToBoxAdapter(child: _buildQuickActions()),
                      SliverToBoxAdapter(child: _buildCurrentReading()),
                      SliverToBoxAdapter(child: _buildBooksGrid()),
                    ],
                  ),
                ),
    );
  }
}
