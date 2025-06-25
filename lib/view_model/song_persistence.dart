import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
// import 'dart:developer';

import 'package:chordmemoflutter/model/types.dart' as custom_types;

// import 'package:chordmemoflutter/model/parser.dart';
// import 'package:chordmemoflutter/model/token.dart';

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

  /* // FOR TESTING: Validate each song's progression
  for (custom_types.Song song in songs) {
    for (custom_types.Section section in song.sections) {
      final ast = Parser.parse(section.chords);

      // If AST is an ErrorNode, log the error
      if (ast is ErrorNode) {
        log('Error in song "${song.title}" section "${section.sectionTitle}": ${ast.error}');
        // Optionally, you can handle the error further, e.g., set a flag or remove the section
      }
    }
  }
  */

  return songs;
}