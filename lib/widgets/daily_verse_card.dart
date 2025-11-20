import 'package:flutter/material.dart';
import '../models/bible_verse.dart';
import '../widgets/settings_text.dart';

class DailyVerseCard extends StatelessWidget {
  final BibleVerse verse;
  final bool isMorning;
  final VoidCallback? onTap;

  const DailyVerseCard({
    Key? key,
    required this.verse,
    required this.isMorning,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isMorning
                ? Color(0xFFFFF9C4).withOpacity(isDarkMode ? 0.1 : 1)
                : Color(0xFFE3F2FD).withOpacity(isDarkMode ? 0.1 : 1),
            border: Border.all(
              color: isMorning
                  ? Colors.amber.withOpacity(0.3)
                  : Colors.blue.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isMorning ? Colors.amber : Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isMorning ? 'ጠዋት' : 'ማታ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NotoSansEthiopic',
                      ),
                    ),
                  ),
                  Text(
                    '${verse.bookName} ${verse.chapterNumber}:${verse.verseNumber}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              SettingsText(
                verse.amharicText,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontFamily: 'NotoSansEthiopic',
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'ከመጽሐፍ ቅዱስ',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white60 : Colors.black45,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'NotoSansEthiopic',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
