import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService with ChangeNotifier {
  String _fontFamily = 'NotoSansEthiopic';
  double _fontSize = 16.0;
  bool _darkMode = false;
  double _brightness = 1.0;
  bool _isInitialized = false;

  // Public getters for the private properties
  String get fontFamily => _fontFamily;
  double get fontSize => _fontSize;
  bool get darkMode => _darkMode;
  double get brightness => _brightness;

  SettingsService() {
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    _fontFamily = prefs.getString('fontFamily') ?? 'NotoSansEthiopic';
    _fontSize = prefs.getDouble('fontSize') ?? 16.0;
    _darkMode = prefs.getBool('darkMode') ?? false;

    // Ensure brightness is at least 10%
    final double savedBrightness = prefs.getDouble('brightness') ?? 1.0;
    _brightness = savedBrightness.clamp(0.1, 1.0);

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> updateFontFamily(String fontFamily) async {
    _fontFamily = fontFamily;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fontFamily', fontFamily);
    notifyListeners();
  }

  Future<void> updateFontSize(double fontSize) async {
    _fontSize = fontSize;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', fontSize);
    notifyListeners();
  }

  Future<void> updateDarkMode(bool isDarkMode) async {
    _darkMode = isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', isDarkMode);
    notifyListeners();
  }

  Future<void> updateBrightness(double brightness) async {
    // Clamp brightness between 10% and 100%
    _brightness = brightness.clamp(0.3, 1.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('brightness', _brightness);
    notifyListeners();
  }

  Future<void> loadSettings() async {
    await _initializeSettings();
  }
}
