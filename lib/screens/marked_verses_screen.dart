import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bible_verse.dart';
import '../services/database_service.dart';
import '../services/settings_service.dart';
import '../widgets/settings_text.dart';

class MarkedVersesScreen extends StatefulWidget {
  const MarkedVersesScreen({super.key});

  @override
  _MarkedVersesScreenState createState() => _MarkedVersesScreenState();
}

class _MarkedVersesScreenState extends State<MarkedVersesScreen> {
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);
    final isDarkMode = settings.darkMode;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.grey[100];
    final cardColor = isDarkMode ? Colors.grey[800] : Colors.white;

    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom:
                Radius.circular(30.0), // Adjust radius for desired curvature
          ),
        ),
        title: Text(
          'የተውሰጦች ጥቅሶች',
          style: TextStyle(
            fontFamily: 'NotoSansEthiopic',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor:
            isDarkMode ? Colors.grey[800] : Color.fromARGB(255, 65, 105, 225),
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: backgroundColor,
        child: StreamBuilder<List<BibleVerse>>(
          stream: _databaseService.bookmarksStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'የተውሰጦች ጥቅሶች ሲጫኑ ስህተት ተከስቷል',
                  style: TextStyle(
                    fontSize: 18,
                    color: textColor.withOpacity(0.7),
                    fontFamily: 'NotoSansEthiopic',
                  ),
                ),
              );
            }

            final bookmarkedVerses = snapshot.data ?? [];

            if (bookmarkedVerses.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bookmark_border,
                      size: 64,
                      color: textColor.withOpacity(0.3),
                    ),
                    SizedBox(height: 16),
                    SettingsText(
                      'እስካሁን የተወሰኑ ጥቅሶች የሉም',
                      style: TextStyle(
                        fontSize: 18,
                        color: textColor.withOpacity(0.7),
                        fontFamily: 'NotoSansEthiopic',
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookmarkedVerses.length,
              itemBuilder: (context, index) {
                final verse = bookmarkedVerses[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Verse reference
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border:
                                Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: Text(
                            '${verse.bookName} ${verse.chapterNumber}:${verse.verseNumber}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              fontFamily: 'NotoSansEthiopic',
                              fontSize: 14,
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        // Verse text
                        Text(
                          verse.amharicText,
                          style: TextStyle(
                            color: textColor,
                            fontFamily: 'NotoSansEthiopic',
                            fontSize: 16,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.bookmark, color: Colors.blue),
                      onPressed: () => _removeBookmark(verse),
                      tooltip: 'መጽሐፍ ምልክት አስወግድ',
                    ),
                    onTap: () {
                      // You could navigate to the specific verse in the reading screen
                      // This would require additional implementation
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _removeBookmark(BibleVerse verse) async {
    try {
      await _databaseService.removeBookmark(verse);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'መጽሐፍ ምልክት ተሰርዟል',
            style: TextStyle(fontFamily: 'NotoSansEthiopic'),
          ),
          backgroundColor: Colors.green[700],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ስህተት: $e',
            style: TextStyle(fontFamily: 'NotoSansEthiopic'),
          ),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }
}
