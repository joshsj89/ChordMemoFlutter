import 'package:flutter_test/flutter_test.dart';

import 'package:chordmemoflutter/model/types.dart';

void main() {
  group('Song serialization', () {
    test('round-trips through toJson / fromJson', () {
      final song = Song(
        id: '123',
        title: 'Blue Bossa',
        artist: 'Kenny Dorham',
        genres: const ['Jazz', 'Latin'],
        sections: [
          Section(
            sectionTitle: 'Whole',
            key: Key(tonic: 'C', symbol: '', mode: 'Minor'),
            chords: 'i-iv7-ii7-V7',
          ),
        ],
        createdAt: DateTime.parse('2026-01-02T03:04:05.000'),
        updatedAt: DateTime.parse('2026-01-02T03:04:05.000'),
      );

      final restored = Song.fromJson(song.toJson());

      expect(restored.id, song.id);
      expect(restored.title, song.title);
      expect(restored.artist, song.artist);
      expect(restored.genres, song.genres);
      expect(restored.sections.single.chords, 'i-iv7-ii7-V7');
      expect(restored.sections.single.key, song.sections.single.key);
      expect(restored.createdAt, song.createdAt);
      expect(restored.updatedAt, song.updatedAt);
    });

    test('omits null timestamps from JSON', () {
      final json = Song(
        id: '1',
        title: 'x',
        artist: '',
        genres: const [],
        sections: const [],
      ).toJson();

      expect(json.containsKey('createdAt'), isFalse);
      expect(json.containsKey('updatedAt'), isFalse);
    });

    test('loads legacy JSON that predates the optional fields', () {
      final legacy = {
        'id': '42',
        'title': 'Autumn Leaves',
        'artist': 'Joseph Kosma',
        'genres': ['Jazz'],
        'sections': [
          {
            'sectionTitle': 'Whole',
            'key': {'tonic': 'G', 'symbol': '', 'mode': 'Minor'},
            'chords': 'ii-V-i',
          },
        ],
      };

      final song = Song.fromJson(legacy);

      expect(song.title, 'Autumn Leaves');
      expect(song.createdAt, isNull);
      expect(song.updatedAt, isNull);
      expect(song.sections.single.chords, 'ii-V-i');
    });

    test('tolerates missing / malformed fields with sensible defaults', () {
      final song = Song.fromJson({'title': 'Untitled'});

      expect(song.id, isNotEmpty);
      expect(song.title, 'Untitled');
      expect(song.artist, '');
      expect(song.genres, isEmpty);
      expect(song.sections, isEmpty);
    });

    test('Section falls back to a default key when the key is absent', () {
      final section = Section.fromJson({'sectionTitle': 'Verse', 'chords': ''});

      expect(section.key, Key(tonic: 'C', symbol: '', mode: 'Major'));
    });

    test('copyWith replaces only the given fields', () {
      final original = Song(
        id: '1',
        title: 'A',
        artist: 'B',
        genres: const ['Jazz'],
        sections: const [],
      );

      final updated = original.copyWith(title: 'C');

      expect(updated.title, 'C');
      expect(updated.artist, 'B');
      expect(updated.id, '1');
      expect(updated.genres, const ['Jazz']);
    });
  });
}
