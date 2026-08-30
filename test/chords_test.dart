import 'package:flutter_test/flutter_test.dart';

import 'package:chordmemoflutter/view_model/chords.dart';

void main() {
  group('splitChordsIntoArray', () {
    test('returns an empty list for an empty string', () {
      expect(splitChordsIntoArray(''), isEmpty);
    });

    test('drops dashes but keeps chords', () {
      expect(splitChordsIntoArray('I-vi-IV-V'), ['I', 'vi', 'IV', 'V']);
    });

    test('keeps spaces and parentheses as their own tokens', () {
      expect(
        splitChordsIntoArray('I-(V/5-I)-IV-V'),
        ['I', '(', 'V/5', 'I', ')', 'IV', 'V'],
      );
      expect(
        splitChordsIntoArray('i-III-iv :2 i'),
        ['i', 'III', 'iv', ' ', ':2', ' ', 'i'],
      );
    });
  });

  group('transformChords / splitChordsIntoArray round-trip', () {
    const cases = [
      'I-vi-IV-V',
      'i-III-iv :2 i-III-iv-V',
      'I-(V/5-I)-IV-V',
      'i K+M2 i',
      'i-VI-VII(add9)-♯vi-III-♭I',
      'ii-V-ii-V I-IV7-iii-♯ii° ii-V-ii-V-I',
    ];

    for (final progression in cases) {
      test('"$progression" survives a split + transform', () {
        expect(
          transformChords(splitChordsIntoArray(progression)),
          progression,
        );
      });
    }
  });
}
