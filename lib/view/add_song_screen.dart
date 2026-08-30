import 'package:flutter/material.dart';

import 'package:chordmemoflutter/view/song_form.dart';

/// Thin wrapper around [SongForm] in "create" mode. Pops with `[true, song]`
/// when a song is saved.
class AddSongScreen extends StatelessWidget {
  const AddSongScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SongForm();
  }
}
