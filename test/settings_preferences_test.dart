import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chordmemoflutter/model/settings_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final prefs = SettingsPreferences();

  test('defaults to system when nothing is stored', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await prefs.loadThemeMode(), ThemeMode.system);
  });

  test('round-trips an explicit choice', () async {
    SharedPreferences.setMockInitialValues({});
    await prefs.saveThemeMode(ThemeMode.dark);
    expect(await prefs.loadThemeMode(), ThemeMode.dark);
  });

  test('migrates the legacy darkMode=true flag to ThemeMode.dark', () async {
    SharedPreferences.setMockInitialValues({'darkMode': true});
    expect(await prefs.loadThemeMode(), ThemeMode.dark);

    // The migrated value is persisted under the new key.
    final store = await SharedPreferences.getInstance();
    expect(store.getString('themeMode'), 'dark');
  });

  test('migrates the legacy darkMode=false flag to ThemeMode.light', () async {
    SharedPreferences.setMockInitialValues({'darkMode': false});
    expect(await prefs.loadThemeMode(), ThemeMode.light);
  });
}
