import 'package:flutter_test/flutter_test.dart';

import 'package:chordmemoflutter/model/music_theory.dart';
import 'package:chordmemoflutter/model/types.dart' as m;

String _spell(List<Note> notes) => notes.join(' ');

m.Key _key(String tonic, String symbol, String mode) =>
    m.Key(tonic: tonic, symbol: symbol, mode: mode);

void main() {
  group('Note', () {
    test('renders accidentals', () {
      expect(const Note(0, 0).toString(), 'C');
      expect(const Note(3, 1).toString(), 'F♯');
      expect(const Note(6, -1).toString(), 'B♭');
      expect(const Note(0, -1).toString(), 'C♭');
    });

    test('flags awkward spellings', () {
      expect(const Note(0, -1).isAwkward, isTrue); // C♭
      expect(const Note(2, 1).isAwkward, isTrue); // E♯
      expect(const Note(1, 2).isAwkward, isTrue); // D♯♯
      expect(const Note(3, 1).isAwkward, isFalse); // F♯
    });
  });

  group('scaleNotes', () {
    test('major keys', () {
      expect(_spell(scaleNotes(const Note(0, 0), 'Major')), 'C D E F G A B');
      expect(_spell(scaleNotes(const Note(4, 0), 'Major')), 'G A B C D E F♯');
      expect(_spell(scaleNotes(const Note(3, 0), 'Major')), 'F G A B♭ C D E');
      expect(
        _spell(scaleNotes(const Note(4, -1), 'Major')),
        'G♭ A♭ B♭ C♭ D♭ E♭ F',
      );
    });

    test('minor and modes', () {
      expect(_spell(scaleNotes(const Note(5, 0), 'Minor')), 'A B C D E F G');
      expect(
        _spell(scaleNotes(const Note(0, 0), 'Dorian')),
        'C D E♭ F G A B♭',
      );
      expect(_spell(scaleNotes(const Note(2, 0), 'Phrygian')), 'E F G A B C D');
      expect(
        _spell(scaleNotes(const Note(5, 0), 'Harmonic Minor')),
        'A B C D E F G♯',
      );
    });
  });

  group('transposeTonic', () {
    test('a shift of zero keeps the original spelling', () {
      expect(transposeTonic(const Note(4, -1), 'Major', 0), const Note(4, -1));
    });

    test('picks the spelling with fewer accidentals', () {
      expect(transposeTonic(const Note(0, 0), 'Major', 2), const Note(1, 0)); // D
      expect(transposeTonic(const Note(0, 0), 'Major', 7), const Note(4, 0)); // G
      expect(transposeTonic(const Note(0, 0), 'Major', -2), const Note(6, -1)); // B♭
      expect(transposeTonic(const Note(1, 0), 'Major', 1), const Note(2, -1)); // E♭ not D♯
    });

    test('the tritone is a true tie resolved by preference', () {
      expect(
        transposeTonic(const Note(0, 0), 'Major', 6,
            preference: EnharmonicPreference.sharps),
        const Note(3, 1), // F♯
      );
      expect(
        transposeTonic(const Note(0, 0), 'Major', 6,
            preference: EnharmonicPreference.flats),
        const Note(4, -1), // G♭
      );
    });
  });

  group('transposedKeyIsAmbiguous', () {
    test('true only where the sharp/flat toggle changes the result', () {
      expect(transposedKeyIsAmbiguous(_key('C', '', 'Major'), 6), isTrue);
      expect(transposedKeyIsAmbiguous(_key('C', '', 'Major'), 2), isFalse);
      expect(transposedKeyIsAmbiguous(_key('C', '', 'Major'), 0), isFalse);
    });
  });

  test('keyChangeIntervalSemitones covers every K token interval', () {
    expect(keyChangeIntervalSemitones['TT'], 6);
    expect(keyChangeIntervalSemitones['P5'], 7);
    expect(keyChangeIntervalSemitones.length, 11);
  });
}
