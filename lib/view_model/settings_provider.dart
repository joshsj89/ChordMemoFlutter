import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';

import 'package:chordmemoflutter/model/settings_preferences.dart';

/// App-wide settings. Replaces the old `DarkModeProvider`: it still exposes
/// [isDarkMode] / [toggleDarkMode] so existing screens keep working, and adds a
/// three-way [themeMode] (system / light / dark) that drives `MaterialApp`.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider() {
    _load();
  }

  final SettingsPreferences _preferences = SettingsPreferences();

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  Future<void> _load() async {
    _themeMode = await _preferences.loadThemeMode();
    notifyListeners();
  }

  /// Whether dark colours should currently be used, resolving [ThemeMode.system]
  /// against the platform brightness.
  bool get isDarkMode {
    switch (_themeMode) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        return PlatformDispatcher.instance.platformBrightness == Brightness.dark;
    }
  }

  void setThemeMode(ThemeMode mode) {
    if (mode == _themeMode) return;
    _themeMode = mode;
    _preferences.saveThemeMode(mode);
    notifyListeners();
  }

  /// Kept for the drawer's quick toggle: flips between explicit light and dark.
  void toggleDarkMode() {
    setThemeMode(isDarkMode ? ThemeMode.light : ThemeMode.dark);
  }
}
