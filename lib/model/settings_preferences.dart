import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists app-wide settings. Currently just the theme mode; this is the place
/// to add future preferences (default display key, instrument transposition,
/// swing feel, ...) rather than scattering more `SharedPreferences` keys.
class SettingsPreferences {
  static const String _themeModeKey = 'themeMode';

  // Legacy boolean key written by older builds ("Dark Mode: On/Off"). Read once
  // so users who had dark mode on keep it after upgrading.
  static const String _legacyDarkModeKey = 'darkMode';

  Future<void> saveThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, mode.name);
    } catch (error) {
      log('Error saving theme mode: $error');
    }
  }

  Future<ThemeMode> loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final stored = prefs.getString(_themeModeKey);
      if (stored != null) {
        return ThemeMode.values.firstWhere(
          (mode) => mode.name == stored,
          orElse: () => ThemeMode.system,
        );
      }

      // Migrate the old boolean flag, if present.
      final legacy = prefs.getBool(_legacyDarkModeKey);
      if (legacy != null) {
        final migrated = legacy ? ThemeMode.dark : ThemeMode.light;
        await prefs.setString(_themeModeKey, migrated.name);
        return migrated;
      }

      return ThemeMode.system;
    } catch (error) {
      log('Error loading theme mode: $error');
      return ThemeMode.system;
    }
  }
}
