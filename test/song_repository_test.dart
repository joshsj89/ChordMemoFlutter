import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chordmemoflutter/model/types.dart';
import 'package:chordmemoflutter/view_model/song_repository.dart';

Song _song(String id, {String title = 'Song'}) => Song(
      id: id,
      title: title,
      artist: '',
      genres: const [],
      sections: [
        Section(
          sectionTitle: 'Whole',
          key: Key(tonic: 'C', symbol: '', mode: 'Major'),
          chords: 'I-IV-V',
        ),
      ],
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final repo = SongRepository.instance;

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('loadSongs returns an empty list when nothing is stored', () async {
    expect(await repo.loadSongs(), isEmpty);
  });

  test('add / update / delete round-trip through storage', () async {
    await repo.addSong(_song('1', title: 'First'));
    await repo.addSong(_song('2', title: 'Second'));
    expect((await repo.loadSongs()).map((s) => s.id), ['1', '2']);

    await repo.updateSong(_song('1', title: 'Renamed'));
    expect((await repo.loadSongs()).firstWhere((s) => s.id == '1').title, 'Renamed');

    await repo.deleteSong('2');
    expect((await repo.loadSongs()).map((s) => s.id), ['1']);
  });

  test('reads a legacy bare-array payload with no schema version key', () async {
    SharedPreferences.setMockInitialValues({
      'songs': jsonEncode([_song('legacy').toJson()]),
    });

    final songs = await repo.loadSongs();
    expect(songs.single.id, 'legacy');

    // The migration stamps the current schema version on read.
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('songsSchemaVersion'), kSongsSchemaVersion);
  });

  test('importSongs skips ids that already exist and reports the count', () async {
    await repo.addSong(_song('1'));

    final payload = jsonEncode([
      _song('1', title: 'dupe').toJson(),
      _song('3').toJson(),
    ]);

    final added = await repo.importSongs(payload);
    expect(added, 1);
    expect((await repo.loadSongs()).map((s) => s.id), ['1', '3']);
    // The pre-existing song keeps its original title.
    expect((await repo.loadSongs()).firstWhere((s) => s.id == '1').title, 'Song');
  });

  test('exportJson is null when there is nothing to export', () async {
    expect(await repo.exportJson(), isNull);
    await repo.addSong(_song('1'));
    expect(await repo.exportJson(), contains('"id": "1"'));
  });
}
