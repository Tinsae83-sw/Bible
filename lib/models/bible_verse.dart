class BibleVerse {
  final int bookId;
  final String bookName;
  final int chapterNumber;
  final int verseNumber;
  final String text;
  final String amharicText;
  bool isHighlighted;
  String? highlightColor;
  bool isBookmarked;

  BibleVerse({
    required this.bookId,
    required this.bookName,
    required this.chapterNumber,
    required this.verseNumber,
    required this.text,
    required this.amharicText,
    this.isHighlighted = false,
    this.highlightColor,
    this.isBookmarked = false,
  });

  factory BibleVerse.fromJson(Map<String, dynamic> json) {
    return BibleVerse(
      bookId: json['bookId'],
      bookName: json['bookName'] ?? '',
      chapterNumber: json['chapterNumber'],
      verseNumber: json['verseNumber'],
      text: json['text'],
      amharicText: json['amharicText'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      'bookName': bookName,
      'chapterNumber': chapterNumber,
      'verseNumber': verseNumber,
      'text': text,
      'amharicText': amharicText,
      'isHighlighted': isHighlighted,
      'highlightColor': highlightColor,
      'isBookmarked': isBookmarked,
    };
  }
}
