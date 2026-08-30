import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:chordmemoflutter/model/types.dart';

/// Current on-device schema version for the persisted song list. Bump this when
/// a change to [Song]/[Section]/[Key] serialization needs a one-time migration
/// of already-stored data, then add a branch to [_migrateIfNeeded].
const int kSongsSchemaVersion = 1;

/// Single owner of the persisted song list.
///
/// Every read and write of the `songs` value in [SharedPreferences] goes
/// through here so that JSON encoding, de-duplication on import, and schema
/// migration all live in one place instead of being duplicated across screens.
/// The stored value stays a bare JSON array (indented) so that files exported
/// from one build still import into another.
class SongRepository {
  SongRepository._();

  static final SongRepository instance = SongRepository._();

  static const String _songsKey = 'songs';
  static const String _schemaVersionKey = 'songsSchemaVersion';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  /// Reads every saved song, running any pending schema migration first.
  Future<List<Song>> loadSongs() async {
    final prefs = await _prefs;
    await _migrateIfNeeded(prefs);
    return _decode(prefs.getString(_songsKey));
  }

  /// Overwrites the saved song list with [songs].
  Future<void> saveSongs(List<Song> songs) async {
    final prefs = await _prefs;
    await prefs.setString(_songsKey, _encode(songs));
    await prefs.setInt(_schemaVersionKey, kSongsSchemaVersion);
  }

  /// Appends [song] and returns the updated list.
  Future<List<Song>> addSong(Song song) async {
    final songs = await loadSongs();
    songs.add(song);
    await saveSongs(songs);
    return songs;
  }

  /// Replaces the stored song with the same id as [song] (or appends it if not
  /// found) and returns the updated list.
  Future<List<Song>> updateSong(Song song) async {
    final songs = await loadSongs();
    final index = songs.indexWhere((s) => s.id == song.id);
    if (index >= 0) {
      songs[index] = song;
    } else {
      songs.add(song);
    }
    await saveSongs(songs);
    return songs;
  }

  /// Removes the song with [id] and returns the updated list.
  Future<List<Song>> deleteSong(String id) async {
    final songs = await loadSongs();
    songs.removeWhere((s) => s.id == id);
    await saveSongs(songs);
    return songs;
  }

  /// The indented JSON string used for export, or null when there is nothing
  /// to export.
  Future<String?> exportJson() async {
    final songs = await loadSongs();
    if (songs.isEmpty) return null;
    return _encode(songs);
  }

  /// Merges songs from a decoded export payload (a `List` of song maps, or a
  /// raw JSON string), skipping any whose id already exists. Returns the number
  /// of songs actually added.
  Future<int> importSongs(dynamic payload) async {
    final incoming =
        payload is String ? _decode(payload) : _decodeDynamic(payload);
    final songs = await loadSongs();
    final ids = songs.map((s) => s.id).toSet();
    var added = 0;
    for (final song in incoming) {
      if (ids.add(song.id)) {
        songs.add(song);
        added++;
      }
    }
    if (added > 0) await saveSongs(songs);
    return added;
  }

  // --- internal ---

  String _encode(List<Song> songs) =>
      const JsonEncoder.withIndent('    ').convert(songs);

  List<Song> _decode(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      return _decodeDynamic(jsonDecode(raw));
    } on FormatException {
      return [];
    }
  }

  List<Song> _decodeDynamic(dynamic decoded) {
    if (decoded is! List) return [];
    return decoded.whereType<Map<String, dynamic>>().map(Song.fromJson).toList();
  }

  Future<void> _migrateIfNeeded(SharedPreferences prefs) async {
    if (!prefs.containsKey(_songsKey)) {
      await prefs.setInt(_schemaVersionKey, kSongsSchemaVersion);
      return;
    }

    final stored = prefs.getInt(_schemaVersionKey) ?? 0;
    if (stored >= kSongsSchemaVersion) return;

    // No data-shape migrations needed yet: every field added since v1 is
    // optional and handled by Song.fromJson. Future migrations go here, e.g.
    //   if (stored < 2) { ...rewrite the stored list... }

    await prefs.setInt(_schemaVersionKey, kSongsSchemaVersion);
  }
}
