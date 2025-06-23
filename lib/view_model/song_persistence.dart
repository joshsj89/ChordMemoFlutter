import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

import 'package:chordmemoflutter/model/types.dart' as custom_types;

Future<void> saveSongs(List<custom_types.Song> songs) async {
  final prefs = await SharedPreferences.getInstance();
  // final songsJson = jsonEncode(songs);
  final formattedJson = JsonEncoder.withIndent('    ').convert(songs);

  await prefs.setString('songs', formattedJson);
}

Future<List<custom_types.Song>> loadSongs() async {
  final prefs = await SharedPreferences.getInstance();
  final savedSongs = prefs.getString('songs');
  List<custom_types.Song> songs = [];

  if (savedSongs != null) {
    songs = (jsonDecode(savedSongs) as List)
      .map((song) => custom_types.Song.fromJson(song))
      .toList();
  }

  return songs;
}