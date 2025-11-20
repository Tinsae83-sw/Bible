// models/bible_chapter.dart
import 'bible_verse.dart';

class BibleChapter {
  final int bookId;
  final int chapterNumber;
  final List<BibleVerse> verses;

  BibleChapter({
    required this.bookId,
    required this.chapterNumber,
    required this.verses,
  });

  factory BibleChapter.fromJson(Map<String, dynamic> json) {
    var versesList = json['verses'] as List;
    List<BibleVerse> verses =
        versesList.map((v) => BibleVerse.fromJson(v)).toList();

    return BibleChapter(
      bookId: json['bookId'],
      chapterNumber: json['chapterNumber'],
      verses: verses,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      'chapterNumber': chapterNumber,
      'verses': verses.map((v) => v.toJson()).toList(),
    };
  }
}
