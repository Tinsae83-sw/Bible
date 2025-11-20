// services/theme_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService with ChangeNotifier {
  bool _isDarkModeEnabled = false;

  bool get isDarkModeEnabled => _isDarkModeEnabled;

  ThemeService() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkModeEnabled = prefs.getBool('isDarkModeEnabled') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkModeEnabled = !_isDarkModeEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkModeEnabled', _isDarkModeEnabled);
    notifyListeners();
  }
}
