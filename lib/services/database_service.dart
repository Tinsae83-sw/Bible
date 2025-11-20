import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_preferences.dart';
import '../models/bible_verse.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal() {
    _initBookmarksStream();
  }

  final StreamController<List<BibleVerse>> _bookmarksController =
      StreamController<List<BibleVerse>>.broadcast();

  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  void _initBookmarksStream() async {
    final bookmarks = await getBookmarks();
    _bookmarksController.add(bookmarks);
  }

  Stream<List<BibleVerse>> bookmarksStream() {
    return _bookmarksController.stream;
  }

  Future<void> _emitBookmarksUpdate() async {
    final bookmarks = await getBookmarks();
    _bookmarksController.add(bookmarks);
  }

  Future<void> saveUserPreferences(UserPreferences preferences) async {
    final prefs = await _prefs;
    await prefs.setString('userPreferences', json.encode(preferences.toJson()));
  }

  Future<UserPreferences> getUserPreferences() async {
    final prefs = await _prefs;
    final String? preferencesString = prefs.getString('userPreferences');

    if (preferencesString != null) {
      final Map<String, dynamic> preferencesMap =
          json.decode(preferencesString);
      return UserPreferences.fromJson(preferencesMap);
    }

    return UserPreferences();
  }

  // Bookmark methods
  Future<void> saveBookmark(BibleVerse verse) async {
    final prefs = await _prefs;
    final String key =
        'bookmark_${verse.bookId}_${verse.chapterNumber}_${verse.verseNumber}';
    await prefs.setString(key, json.encode(verse.toJson()));
    _emitBookmarksUpdate();
  }

  Future<void> removeBookmark(BibleVerse verse) async {
    final prefs = await _prefs;
    final String key =
        'bookmark_${verse.bookId}_${verse.chapterNumber}_${verse.verseNumber}';
    await prefs.remove(key);
    _emitBookmarksUpdate();
  }

  Future<List<BibleVerse>> getBookmarks() async {
    final prefs = await _prefs;
    final keys =
        prefs.getKeys().where((key) => key.startsWith('bookmark_')).toList();
    List<BibleVerse> bookmarks = [];

    for (String key in keys) {
      final String? verseString = prefs.getString(key);
      if (verseString != null) {
        final Map<String, dynamic> verseMap = json.decode(verseString);
        bookmarks.add(BibleVerse.fromJson(verseMap));
      }
    }

    return bookmarks;
  }

  Future<bool> isBookmarked(BibleVerse verse) async {
    final prefs = await _prefs;
    final String key =
        'bookmark_${verse.bookId}_${verse.chapterNumber}_${verse.verseNumber}';
    return prefs.containsKey(key);
  }

  Future<void> toggleBookmark(BibleVerse verse) async {
    final isCurrentlyBookmarked = await isBookmarked(verse);
    if (isCurrentlyBookmarked) {
      await removeBookmark(verse);
    } else {
      await saveBookmark(verse);
    }
  }

  // Highlight methods
  Future<void> updateHighlight(BibleVerse verse, String color) async {
    final prefs = await _prefs;
    final String key =
        'highlight_${verse.bookId}_${verse.chapterNumber}_${verse.verseNumber}';
    await prefs.setString(
        key,
        json.encode({
          'verse': verse.toJson(),
          'color': color,
          'timestamp': DateTime.now().toIso8601String()
        }));
  }

  Future<void> removeHighlight(BibleVerse verse) async {
    final prefs = await _prefs;
    final String key =
        'highlight_${verse.bookId}_${verse.chapterNumber}_${verse.verseNumber}';
    await prefs.remove(key);
  }

  Future<Map<String, dynamic>?> getHighlight(BibleVerse verse) async {
    final prefs = await _prefs;
    final String key =
        'highlight_${verse.bookId}_${verse.chapterNumber}_${verse.verseNumber}';
    final String? highlightString = prefs.getString(key);

    if (highlightString != null) {
      return json.decode(highlightString);
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getHighlights() async {
    final prefs = await _prefs;
    final keys =
        prefs.getKeys().where((key) => key.startsWith('highlight_')).toList();
    List<Map<String, dynamic>> highlights = [];

    for (String key in keys) {
      final String? highlightString = prefs.getString(key);
      if (highlightString != null) {
        highlights.add(json.decode(highlightString));
      }
    }

    return highlights;
  }

  void dispose() {
    _bookmarksController.close();
  }
}
