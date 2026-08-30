import 'package:flutter/material.dart';

import 'package:chordmemoflutter/model/types.dart' as custom_types;
import 'package:chordmemoflutter/view/song_form.dart';

/// Thin wrapper around [SongForm] in "edit" mode. Pops with `[true, song]`
/// when the song is saved.
class EditSongScreen extends StatelessWidget {
  final custom_types.Song song;

  const EditSongScreen({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return SongForm(initialSong: song);
  }
}
