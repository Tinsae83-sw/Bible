class UserPreferences {
  final String lastReadBook;
  final int lastReadChapter;
  final int lastReadVerse;
  final String fontFamily;
  final double fontSize;

  UserPreferences({
    this.lastReadBook = '1',
    this.lastReadChapter = 1,
    this.lastReadVerse = 1,
    this.fontFamily = 'NotoSansEthiopic',
    this.fontSize = 16.0,
  });

  UserPreferences copyWith({
    String? lastReadBook,
    int? lastReadChapter,
    int? lastReadVerse,
    String? fontFamily,
    double? fontSize,
  }) {
    return UserPreferences(
      lastReadBook: lastReadBook ?? this.lastReadBook,
      lastReadChapter: lastReadChapter ?? this.lastReadChapter,
      lastReadVerse: lastReadVerse ?? this.lastReadVerse,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
    );
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      lastReadBook: json['lastReadBook'] ?? '1',
      lastReadChapter: json['lastReadChapter'] ?? 1,
      lastReadVerse: json['lastReadVerse'] ?? 1,
      fontFamily: json['fontFamily'] ?? 'NotoSansEthiopic',
      fontSize: json['fontSize'] ?? 16.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastReadBook': lastReadBook,
      'lastReadChapter': lastReadChapter,
      'lastReadVerse': lastReadVerse,
      'fontFamily': fontFamily,
      'fontSize': fontSize,
    };
  }
}
