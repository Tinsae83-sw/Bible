import 'package:flutter/material.dart';
import '../models/bible_book.dart';
import '../widgets/settings_text.dart';

class ChaptersGrid extends StatelessWidget {
  final BibleBook selectedBook;
  final Function(int) onChapterSelected;
  final Color textColor;
  final Color backgroundColor;
  final Color primaryColor;

  const ChaptersGrid({
    required this.selectedBook,
    required this.onChapterSelected,
    required this.textColor,
    required this.backgroundColor,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final chapters = List.generate(selectedBook.chapters, (index) => index + 1);

    return Container(
      color: backgroundColor,
      child: Column(
        children: [
          _buildHeader(),
          SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                final chapter = chapters[index];
                return _buildChapterCard(chapter, context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.8),
            primaryColor.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.library_books,
            size: 40,
            color: Colors.white,
          ),
          SizedBox(height: 8),
          SettingsText(
            selectedBook.amharicName,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          SettingsText(
            '${selectedBook.chapters} ምዕራፎች',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterCard(int chapter, BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor.withOpacity(0.8),
              primaryColor.withOpacity(0.5),
            ],
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onChapterSelected(chapter),
            child: Center(
              child: SettingsText(
                '$chapter',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
