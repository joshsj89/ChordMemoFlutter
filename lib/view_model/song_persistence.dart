import 'package:chordmemoflutter/model/types.dart';
import 'package:chordmemoflutter/view_model/song_repository.dart';

// Thin free-function wrappers kept for the screens that already import them.
// All real work (JSON encoding, schema migration, de-duplication) lives in
// [SongRepository]; prefer using that class directly in new code.

Future<void> saveSongs(List<Song> songs) =>
    SongRepository.instance.saveSongs(songs);

Future<List<Song>> loadSongs() => SongRepository.instance.loadSongs();
