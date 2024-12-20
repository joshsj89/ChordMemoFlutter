import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

import '../model/types.dart' as custom_types;

Future<void> saveSongs(List<custom_types.Song> songs) async {
  final prefs = await SharedPreferences.getInstance();
  // final songsJson = jsonEncode(songs);
  final formattedJson = JsonEncoder.withIndent('    ').convert(songs);

  await prefs.setString('songs', formattedJson);
}
