// widgets/navigation_drawer.dart
import 'package:flutter/material.dart';
import 'package:Amharic_bible/models/bible_book.dart';

class BibleNavigationDrawer extends StatefulWidget {
  final List<BibleBook> books;
  final Function(int, int) onBookSelected;

  const BibleNavigationDrawer({
    super.key,
    required this.books,
    required this.onBookSelected,
  });

  @override
  State<BibleNavigationDrawer> createState() => _BibleNavigationDrawerState();
}

class _BibleNavigationDrawerState extends State<BibleNavigationDrawer> {
  int? _expandedBookId;
  bool _isOldTestamentExpanded = true;
  bool _isNewTestamentExpanded = false;

  void _toggleBookExpansion(BibleBook book) {
    setState(() {
      if (_expandedBookId == book.id) {
        _expandedBookId = null;
      } else {
        _expandedBookId = book.id;
      }
    });
  }

  void _selectChapter(BibleBook book, int chapter) {
    final bookIndex = widget.books.indexWhere((b) => b.id == book.id);
    if (bookIndex != -1) {
      widget.onBookSelected(bookIndex, chapter);
      Navigator.pop(context);
    }
  }

  void _selectOldTestament() {
    setState(() {
      _isOldTestamentExpanded = true;
      _isNewTestamentExpanded = false;
    });
  }

  void _selectNewTestament() {
    setState(() {
      _isOldTestamentExpanded = false;
      _isNewTestamentExpanded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    // Updated to match settings page dark mode colors
    final Color primaryColor =
        isDark ? Colors.blue[200]! : const Color(0xFF0038B8);
    final Color backgroundColor = isDark ? Colors.grey[900]! : Colors.white;
    final Color surfaceColor = isDark ? Colors.grey[800]! : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color secondaryTextColor =
        isDark ? Colors.white70 : Colors.grey[600]!;

    final List<BibleBook> oldTestamentBooks =
        widget.books.where((book) => book.testament == "Old").toList();
    final List<BibleBook> newTestamentBooks =
        widget.books.where((book) => book.testament == "New").toList();

    return Drawer(
      backgroundColor: backgroundColor,
      child: Column(
        children: [
          // Modernized header
          SizedBox(
            height: 140,
            child: Stack(
              children: [
                // Background image
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('assets/images/devid.jpg'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                  ),
                ),

                // Enhanced gradient overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          isDark
                              ? Colors.black.withOpacity(0.7)
                              : primaryColor.withOpacity(0.9),
                        ],
                        stops: const [0.4, 1.0],
                      ),
                    ),
                  ),
                ),

                // Refined content layout - FIXED VERSE REFERENCE
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'አይዞህ! በርታ!” ብዬ ያዘዝኩህን አስታውስ፤ ከቶ አትፍራ፤ ተስፋ አትቁረጥ ምክንያቱም በምትሄድበት ስፍራ ሁሉ እኔ ያህቬህ(הוהי) አምላክህ ከአንተ ጋር ነኝ፡፡',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'NotoSansEthiopic',
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6),
                      Text(
                        'ኢያሱ 1:9',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'NotoSansEthiopic',
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Modernized testament selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: surfaceColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _TestamentChip(
                    label: 'ብሉይ ኪዳን',
                    isSelected: _isOldTestamentExpanded,
                    onTap: _selectOldTestament,
                    primaryColor: primaryColor,
                    backgroundColor: surfaceColor,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TestamentChip(
                    label: 'ሃዲስ ኪዳን',
                    isSelected: _isNewTestamentExpanded,
                    onTap: _selectNewTestament,
                    primaryColor: primaryColor,
                    backgroundColor: surfaceColor,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ),

          // Books and chapters list
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
              ),
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  if (_isOldTestamentExpanded) ...[
                    _TestamentHeader(
                      title: 'ብሉይ ኪዳን',
                      bookCount: oldTestamentBooks.length,
                      color: primaryColor,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    ...oldTestamentBooks.map((book) => _ExpandableBookItem(
                          book: book,
                          isExpanded: _expandedBookId == book.id,
                          onBookTap: () => _toggleBookExpansion(book),
                          onChapterTap: (chapter) =>
                              _selectChapter(book, chapter),
                          primaryColor: primaryColor,
                          backgroundColor: surfaceColor,
                          textColor: textColor,
                          secondaryTextColor: secondaryTextColor,
                          isDark: isDark,
                        )),
                    const SizedBox(height: 20),
                  ],
                  if (_isNewTestamentExpanded) ...[
                    _TestamentHeader(
                      title: 'ሃዲስ ኪዳን',
                      bookCount: newTestamentBooks.length,
                      color: primaryColor,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    ...newTestamentBooks.map((book) => _ExpandableBookItem(
                          book: book,
                          isExpanded: _expandedBookId == book.id,
                          onBookTap: () => _toggleBookExpansion(book),
                          onChapterTap: (chapter) =>
                              _selectChapter(book, chapter),
                          primaryColor: primaryColor,
                          backgroundColor: surfaceColor,
                          textColor: textColor,
                          secondaryTextColor: secondaryTextColor,
                          isDark: isDark,
                        )),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandableBookItem extends StatelessWidget {
  final BibleBook book;
  final bool isExpanded;
  final VoidCallback onBookTap;
  final Function(int) onChapterTap;
  final Color primaryColor;
  final Color backgroundColor;
  final Color textColor;
  final Color secondaryTextColor;
  final bool isDark;

  const _ExpandableBookItem({
    required this.book,
    required this.isExpanded,
    required this.onBookTap,
    required this.onChapterTap,
    required this.primaryColor,
    required this.backgroundColor,
    required this.textColor,
    required this.secondaryTextColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          // Modernized book tile
          Material(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            elevation: isExpanded ? 2 : 0,
            shadowColor: isDark
                ? Colors.black.withOpacity(0.5)
                : Colors.grey.withOpacity(0.3),
            child: InkWell(
              onTap: onBookTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isExpanded
                        ? primaryColor.withOpacity(0.3)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                  color: backgroundColor,
                ),
                child: Row(
                  children: [
                    // Refined book icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isExpanded
                            ? primaryColor
                            : primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.book_rounded,
                        color: isExpanded ? Colors.white : primaryColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Improved text layout
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'NotoSansEthiopic',
                              color: textColor,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            book.amharicName,
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'NotoSansEthiopic',
                              color: secondaryTextColor,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Sleeker chapter count badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${book.chapters}',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          fontFamily: 'NotoSansEthiopic',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Modernized chapters grid
          if (isExpanded)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: primaryColor.withOpacity(0.2),
                ),
              ),
              child: _BookChaptersGrid(
                book: book,
                onChapterTap: onChapterTap,
                primaryColor: primaryColor,
                backgroundColor: backgroundColor,
                isDark: isDark,
              ),
            ),
        ],
      ),
    );
  }
}

class _BookChaptersGrid extends StatelessWidget {
  final BibleBook book;
  final Function(int) onChapterTap;
  final Color primaryColor;
  final Color backgroundColor;
  final bool isDark;

  const _BookChaptersGrid({
    required this.book,
    required this.onChapterTap,
    required this.primaryColor,
    required this.backgroundColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Simplified chapters header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            children: [
              Text(
                'ምዕራፎች',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                  fontFamily: 'NotoSansEthiopic',
                ),
              ),
              const Spacer(),
              Text(
                '${book.chapters} ምዕራፎች',
                style: TextStyle(
                  fontSize: 12,
                  color: primaryColor.withOpacity(0.6),
                  fontFamily: 'NotoSansEthiopic',
                ),
              ),
            ],
          ),
        ),

        // Refined chapters grid
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.1,
            ),
            itemCount: book.chapters,
            itemBuilder: (context, index) {
              final chapterNumber = index + 1;
              return _ChapterGridItem(
                chapterNumber: chapterNumber,
                onTap: () => onChapterTap(chapterNumber),
                primaryColor: primaryColor,
                backgroundColor: backgroundColor,
                isDark: isDark,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ChapterGridItem extends StatelessWidget {
  final int chapterNumber;
  final VoidCallback onTap;
  final Color primaryColor;
  final Color backgroundColor;
  final bool isDark;

  const _ChapterGridItem({
    required this.chapterNumber,
    required this.onTap,
    required this.primaryColor,
    required this.backgroundColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: primaryColor.withOpacity(0.3),
              width: 1,
            ),
            color: primaryColor.withOpacity(0.1),
          ),
          child: Center(
            child: Text(
              '$chapterNumber',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: primaryColor,
                fontFamily: 'NotoSansEthiopic',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TestamentChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color primaryColor;
  final Color backgroundColor;
  final bool isDark;

  const _TestamentChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.primaryColor,
    required this.backgroundColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? primaryColor : backgroundColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? primaryColor : primaryColor.withOpacity(0.3),
              width: 1.5,
            ),
            color: isSelected ? primaryColor : backgroundColor,
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                fontFamily: 'NotoSansEthiopic',
                color: isSelected ? Colors.white : primaryColor,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TestamentHeader extends StatelessWidget {
  final String title;
  final int bookCount;
  final Color color;
  final bool isDark;

  const _TestamentHeader({
    required this.title,
    required this.bookCount,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.grey[800],
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'NotoSansEthiopic',
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$bookCount መጻሕፍት',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 11,
                fontFamily: 'NotoSansEthiopic',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
