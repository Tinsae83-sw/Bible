import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../models/bible_book.dart';
import '../models/bible_chapter.dart';
import '../models/bible_verse.dart';

class BibleService {
  static final BibleService _instance = BibleService._internal();
  factory BibleService() => _instance;
  BibleService._internal();

  List<BibleBook>? _books;
  Map<int, List<BibleVerse>>? _allVersesCache; // Cache for all verses

  // Map book IDs to English file names
  final Map<int, String> _bookIdFileMap = {
    1: 'genesis',
    2: 'exodus',
    3: 'leviticus',
    4: 'numbers',
    5: 'deuteronomy',
    6: 'joshua',
    7: 'judges',
    8: 'ruth',
    9: '1samuel',
    10: '2samuel',
    11: '1kings',
    12: '2kings',
    13: '1chronicles',
    14: '2chronicles',
    15: 'ezra',
    16: 'nehemiah',
    17: 'esther',
    18: 'job',
    19: 'psalms',
    20: 'proverbs',
    21: 'ecclesiastes',
    22: 'songofsolomon',
    23: 'isaiah',
    24: 'jeremiah',
    25: 'lamentations',
    26: 'ezekiel',
    27: 'daniel',
    28: 'hosea',
    29: 'joel',
    30: 'amos',
    31: 'obadiah',
    32: 'jonah',
    33: 'micah',
    34: 'nahum',
    35: 'habakkuk',
    36: 'zephaniah',
    37: 'haggai',
    38: 'zechariah',
    39: 'malachi',
    40: 'matthew',
    41: 'mark',
    42: 'luke',
    43: 'john',
    44: 'acts',
    45: 'romans',
    46: '1corinthians',
    47: '2corinthians',
    48: 'galatians',
    49: 'ephesians',
    50: 'philippians',
    51: 'colossians',
    52: '1thessalonians',
    53: '2thessalonians',
    54: '1timothy',
    55: '2timothy',
    56: 'titus',
    57: 'philemon',
    58: 'hebrews',
    59: 'james',
    60: '1peter',
    61: '2peter',
    62: '1john',
    63: '2john',
    64: '3john',
    65: 'jude',
    66: 'revelation',
  };

  Future<List<BibleBook>> getBooks() async {
    if (_books != null) return _books!;

    try {
      String jsonString;

      if (kIsWeb) {
        // For web, use HTTP to load the asset with proper UTF-8 decoding
        final response =
            await http.get(Uri.parse('assets/books/bible_books.json'));
        if (response.statusCode == 200) {
          jsonString = utf8.decode(response.bodyBytes); // Ensure UTF-8 decoding
        } else {
          print('Failed to load books from web: ${response.statusCode}');
          throw Exception('Failed to load books JSON: ${response.statusCode}');
        }
      } else {
        // For mobile, use rootBundle
        jsonString =
            await rootBundle.loadString('assets/books/bible_books.json');
      }

      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> booksJson = jsonData['books'];

      _books =
          booksJson.map((bookJson) => BibleBook.fromJson(bookJson)).toList();
      return _books!;
    } catch (e) {
      print('Error loading books: $e');
      // Fallback to sample data if JSON loading fails
      _books = [
        BibleBook(
          id: 1,
          name: "ኦሪት ዘፍጥረት",
          amharicName: "ዘፍጥረት",
          testament: "Old",
          chapters: 50,
          abbreviation: "Gen",
        ),
        BibleBook(
          id: 2,
          name: "ኦሪት ዘጸአት",
          amharicName: "ዘጸአት",
          testament: "Old",
          chapters: 40,
          abbreviation: "Exo",
        ),
        BibleBook(
          id: 40,
          name: "የማቴዎስ ወንጌል",
          amharicName: "ማቴዎስ",
          testament: "New",
          chapters: 28,
          abbreviation: "Mat",
        ),
        BibleBook(
          id: 44,
          name: "የየራ ሐዋርያት",
          amharicName: "ሥራ ሐዋርያት",
          testament: "New",
          chapters: 28,
          abbreviation: "Act",
        ),
      ];
      return _books!;
    }
  }

  Future<BibleBook> getBookById(int id) async {
    final books = await getBooks();
    return books.firstWhere((book) => book.id == id);
  }

  Future<BibleChapter> getChapter(int bookId, int chapterNumber) async {
    try {
      final book = await getBookById(bookId);

      // Get the English file name from the ID-based mapping
      final String? englishFileName = _bookIdFileMap[bookId];

      if (englishFileName == null) {
        print('No English filename mapping found for book ID: $bookId');
        return _getSampleChapter(bookId, chapterNumber, book.name);
      }

      String jsonString;

      if (kIsWeb) {
        // For web, use the English file name from the map
        final response = await http.get(
          Uri.parse('assets/bible_data/$englishFileName.json'),
        );

        if (response.statusCode == 200) {
          jsonString = utf8.decode(response.bodyBytes);
        } else {
          print('Failed to load chapter from web: ${response.statusCode}');
          print('Requested URL: assets/bible_data/$englishFileName.json');
          return _getSampleChapter(bookId, chapterNumber, book.name);
        }
      } else {
        // For mobile, use rootBundle with English filename
        jsonString = await rootBundle
            .loadString('assets/bible_data/$englishFileName.json');
      }

      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Get the book data from the JSON (use the English file name as key)
      final String bookKey = englishFileName.toLowerCase();
      if (!jsonData.containsKey(bookKey)) {
        print('JSON does not contain key: $bookKey');
        print('Available keys: ${jsonData.keys.join(', ')}');
        return _getSampleChapter(bookId, chapterNumber, book.name);
      }

      final Map<String, dynamic> bookData = jsonData[bookKey];
      final String chapterKey = 'Chapter $chapterNumber';

      if (!bookData.containsKey(chapterKey)) {
        print('Chapter $chapterNumber not found in book $bookKey');
        print('Available chapters: ${bookData.keys.join(', ')}');
        return _getSampleChapter(bookId, chapterNumber, book.name);
      }

      final Map<String, dynamic> versesMap = bookData[chapterKey];

      // Convert the verses map to a list of BibleVerse objects
      List<BibleVerse> verses = [];
      versesMap.forEach((verseNum, verseText) {
        int verseNumber = int.tryParse(verseNum) ?? 0;
        if (verseNumber > 0) {
          verses.add(BibleVerse(
            bookId: bookId,
            bookName: book.name,
            chapterNumber: chapterNumber,
            verseNumber: verseNumber,
            text: verseText.toString(),
            amharicText: verseText.toString(),
            isBookmarked: false,
            isHighlighted: false,
            highlightColor: null,
          ));
        }
      });

      // Sort verses by verse number
      verses.sort((a, b) => a.verseNumber.compareTo(b.verseNumber));

      return BibleChapter(
        bookId: bookId,
        chapterNumber: chapterNumber,
        verses: verses,
      );
    } catch (e) {
      print('Error loading chapter: $e');
      final book = await getBookById(bookId);
      return _getSampleChapter(bookId, chapterNumber, book.name);
    }
  }

  BibleChapter _getSampleChapter(
      int bookId, int chapterNumber, String bookName) {
    List<BibleVerse> verses = [];

    for (int i = 1; i <= 5; i++) {
      verses.add(BibleVerse(
        bookId: bookId,
        bookName: bookName,
        chapterNumber: chapterNumber,
        verseNumber: i,
        text:
            "This is a sample verse $i from $bookName chapter $chapterNumber.",
        amharicText: "ይህ የ$chapterNumber ምዕራፍ $i ነጥብ ነው።",
        isBookmarked: false,
        isHighlighted: false,
        highlightColor: null,
      ));
    }

    return BibleChapter(
      bookId: bookId,
      chapterNumber: chapterNumber,
      verses: verses,
    );
  }

  // NEW: Load all verses from all books for comprehensive search
  Future<void> _loadAllVerses() async {
    if (_allVersesCache != null) return;

    _allVersesCache = {};
    final books = await getBooks();

    for (var book in books) {
      try {
        _allVersesCache![book.id] = [];
        for (int chapter = 1; chapter <= book.chapters; chapter++) {
          final bibleChapter = await getChapter(book.id, chapter);
          _allVersesCache![book.id]!.addAll(bibleChapter.verses);
        }
      } catch (e) {
        print('Error loading verses for ${book.name}: $e');
      }
    }
  }

  // UPDATED: Search across all verses in all books with proper Amharic support
  Future<List<BibleVerse>> searchVerses(String query) async {
    if (query.isEmpty) return [];

    // Load all verses if not already loaded
    if (_allVersesCache == null) {
      await _loadAllVerses();
    }

    List<BibleVerse> results = [];
    final lowercaseQuery = query.toLowerCase();

    _allVersesCache!.forEach((bookId, verses) {
      for (var verse in verses) {
        if (verse.text.toLowerCase().contains(lowercaseQuery) ||
            verse.amharicText.toLowerCase().contains(lowercaseQuery)) {
          results.add(verse);
        }
      }
    });

    return results;
  }
}
