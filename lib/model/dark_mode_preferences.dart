import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

class DarkModePreferences {
  static const String _key = 'darkMode';

  Future<void> saveDarkModePreference(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, enabled);
    } catch (error) {
      log('Error saving dark mode preference: $error');
    }
  }

  Future<bool> loadDarkModePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_key) ?? false;
    } catch (error) {
      log('Error loading dark mode preference: $error');
      return false;
    }
  }
}