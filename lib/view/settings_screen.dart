import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chordmemoflutter/theme/app_theme.dart';
import 'package:chordmemoflutter/view_model/settings_provider.dart';

/// App settings. Currently just the theme mode; future lead-sheet / gig-book
/// preferences (default display key, instrument transposition, swing feel) will
/// be added here.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final colors = context.appColors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              'Appearance',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: colors.subtitleText,
              ),
            ),
          ),
          RadioGroup<ThemeMode>(
            groupValue: settings.themeMode,
            onChanged: (mode) {
              if (mode != null) settings.setThemeMode(mode);
            },
            child: Column(
              children: const [
                _ThemeModeTile(
                  mode: ThemeMode.system,
                  title: 'System',
                  subtitle: 'Match the device theme',
                ),
                _ThemeModeTile(
                  mode: ThemeMode.light,
                  title: 'Light',
                  subtitle: null,
                ),
                _ThemeModeTile(
                  mode: ThemeMode.dark,
                  title: 'Dark',
                  subtitle: null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeModeTile extends StatelessWidget {
  const _ThemeModeTile({
    required this.mode,
    required this.title,
    required this.subtitle,
  });

  final ThemeMode mode;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<ThemeMode>(
      value: mode,
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      activeColor: kBrandTeal,
    );
  }
}
