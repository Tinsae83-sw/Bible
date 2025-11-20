// utils/helpers.dart
import 'package:flutter/material.dart';

class Helpers {
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static String formatVerseReference(int bookId, int chapter, int verse) {
    // This would typically map book IDs to book names
    return 'Book $bookId $chapter:$verse';
  }

  static double calculateFontSize(double baseSize, String fontFamily) {
    // Adjust font size based on font family for better readability
    switch (fontFamily) {
      case 'Serif':
        return baseSize + 1.0;
      case 'Monospace':
        return baseSize - 1.0;
      case 'Handwriting':
        return baseSize + 2.0;
      default:
        return baseSize;
    }
  }
}
