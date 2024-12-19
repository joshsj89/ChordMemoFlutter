import 'package:flutter/material.dart';
import '../model/dark_mode_preferences.dart';

class DarkModeProvider extends ChangeNotifier {
  final DarkModePreferences _preferences = DarkModePreferences();
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  DarkModeProvider() {
    loadDarkMode();
  }

  Future<void> loadDarkMode() async {
    _isDarkMode = await _preferences.loadDarkModePreference();
    notifyListeners(); // Notify UI of change
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    _preferences.saveDarkModePreference(_isDarkMode);
    notifyListeners(); // Notify UI of change
  }
}