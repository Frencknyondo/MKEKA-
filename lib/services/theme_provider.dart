import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.dark;
  late SharedPreferences _prefs;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final savedTheme = _prefs.getString(_themeKey) ?? 'dark';
    _themeMode = savedTheme == 'light' ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _prefs.setString(
        _themeKey, _themeMode == ThemeMode.light ? 'light' : 'dark');
    notifyListeners();
  }

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    _prefs.setString(_themeKey, mode == ThemeMode.light ? 'light' : 'dark');
    notifyListeners();
  }
}
