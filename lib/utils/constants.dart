// utils/constants.dart
class AppConstants {
  static const String appName = 'Holy Bible';
  static const String appVersion = '1.0.0';

  // Bible translations
  static const String defaultTranslation = 'KJV';

  // Preferences keys
  static const String prefFontSize = 'fontSize';
  static const String prefFontFamily = 'fontFamily';
  static const String prefDarkMode = 'darkMode';
  static const String prefLastReadBook = 'lastReadBook';
  static const String prefLastReadChapter = 'lastReadChapter';
  static const String prefLastReadVerse = 'lastReadVerse';

  // Highlight colors
  static const List<String> highlightColors = [
    'yellow',
    'green',
    'blue',
    'pink'
  ];
}
