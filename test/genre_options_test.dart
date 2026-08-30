import 'package:flutter_test/flutter_test.dart';

import 'package:chordmemoflutter/model/options.dart';

void main() {
  group('buildGenreOptions', () {
    test('returns the built-ins unchanged when nothing has been used', () {
      expect(buildGenreOptions(const []), defaultGenres);
    });

    test('appends unknown used genres after the built-ins, sorted', () {
      final result = buildGenreOptions(const ['Bebop', 'Ambient']);
      expect(result.take(defaultGenres.length), defaultGenres);
      expect(result.sublist(defaultGenres.length), ['Ambient', 'Bebop']);
    });

    test('does not duplicate a built-in genre regardless of case', () {
      final result = buildGenreOptions(const ['jazz', 'JAZZ', 'Jazz']);
      expect(result, defaultGenres);
    });

    test('trims whitespace and ignores blank entries', () {
      final result = buildGenreOptions(const ['  Fusion  ', '   ', '']);
      expect(result.sublist(defaultGenres.length), ['Fusion']);
    });
  });
}
