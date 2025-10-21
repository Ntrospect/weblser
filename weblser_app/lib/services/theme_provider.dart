import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  final SharedPreferences _prefs;

  static const String _themeKey = 'is_dark_mode';

  late bool _isDarkMode;

  ThemeProvider(this._prefs) {
    _isDarkMode = _prefs.getBool(_themeKey) ?? true; // Default to dark mode
  }

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }

  void setDarkMode(bool isDark) {
    _isDarkMode = isDark;
    _prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }
}
