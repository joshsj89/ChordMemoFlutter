import 'package:flutter_test/flutter_test.dart';

import 'package:chordmemoflutter/model/music_theory.dart';
import 'package:chordmemoflutter/model/types.dart' as m;
import 'package:chordmemoflutter/view_model/chord_speller.dart';
import 'package:chordmemoflutter/view_model/concrete_chord_builder.dart';

m.Key _key(String tonic, [String symbol = '', String mode = 'Major']) =>
    m.Key(tonic: tonic, symbol: symbol, mode: mode);

List<String> _chords(
  String progression,
  m.Key key, {
  int transpose = 0,
  EnharmonicPreference preference = EnharmonicPreference.sharps,
}) =>
    concreteChordStrings(
      progression: progression,
      key: key,
      transpose: transpose,
      preference: preference,
    );

void main() {
  group('chordQuality', () {
    test('triads follow the numeral case', () {
      expect(chordQuality(false, ''), '');
      expect(chordQuality(true, ''), 'm');
    });

    test('sevenths and extensions', () {
      expect(chordQuality(true, '7'), 'm7');
      expect(chordQuality(false, '7'), '7');
      expect(chordQuality(false, 'M7'), 'maj7');
      expect(chordQuality(true, '6'), 'm6');
      expect(chordQuality(true, 'mM7'), 'm(maj7)');
      expect(chordQuality(true, 'ø7'), 'm7♭5');
      expect(chordQuality(false, '°7'), '°7');
      expect(chordQuality(false, '7♭9'), '7♭9');
    });

    test('suspensions and adds never gain an m', () {
      expect(chordQuality(true, 'sus4'), 'sus4');
      expect(chordQuality(false, '(add9)'), '(add9)');
      expect(chordQuality(true, '(add9)'), 'm(add9)');
    });
  });

  group('concrete chords in C major', () {
    test('plain triads', () {
      expect(_chords('I-vi-IV-V', _key('C')), ['C', 'Am', 'F', 'G']);
      expect(_chords('ii-V-I', _key('C')), ['Dm', 'G', 'C']);
    });

    test('sevenths', () {
      expect(_chords('ii7-V7-IM7', _key('C')), ['Dm7', 'G7', 'Cmaj7']);
      expect(_chords('viiø7', _key('C')), ['Bm7♭5']);
      expect(_chords('vii°', _key('C')), ['B°']);
      expect(_chords('V7♭9', _key('C')), ['G7♭9']);
    });

    test('accidental-prefixed roots keep their letter', () {
      expect(_chords('♭II-I', _key('C')), ['D♭', 'C']);
      expect(_chords('I-♯iv°-IV', _key('C')), ['C', 'F♯°', 'F']);
    });

    test('inversions (digit after the slash) resolve a bass note', () {
      expect(_chords('I/3-IV-V', _key('C')), ['C/E', 'F', 'G']);
      expect(_chords('V7/3', _key('C')), ['G7/B']);
      expect(_chords('i7/5-iv', _key('C', '', 'Minor')), ['Cm7/G', 'Fm']);
    });

    test('applied / secondary chords (Roman numeral after the slash)', () {
      // V9/ii in F = V9 of ii (G minor) = D9, not a slash-bass chord.
      expect(_chords('V9/ii', _key('F')), ['D9']);
      expect(_chords('V7/V-V7-I', _key('C')), ['D7', 'G7', 'C']);
      expect(_chords('V/vi', _key('C')), ['E']);
      // Non-V applied chords: the target's case picks major vs minor.
      expect(_chords('ii/V-V', _key('C')), ['Am', 'G']); // ii of G major
      expect(_chords('ii/VI', _key('C')), ['Bm']); // ii of A major
    });

    test('applied chords track the transpose', () {
      expect(_chords('V9/ii', _key('F'), transpose: 2), ['E9']);
    });
  });

  group('minor keys and modes', () {
    test('A minor', () {
      expect(_chords('i-iv-V', _key('A', '', 'Minor')), ['Am', 'Dm', 'E']);
    });

    test('E minor spells the raised sixth correctly', () {
      expect(_chords('i-VII-VI', _key('E', '', 'Minor')), ['Em', 'D', 'C']);
    });

    test('C Dorian', () {
      expect(_chords('i-IV-VII', _key('C', '', 'Dorian')), ['Cm', 'F', 'B♭']);
    });
  });

  group('transposition', () {
    test('up a whole step', () {
      expect(_chords('I-vi-IV-V', _key('C'), transpose: 2), ['D', 'Bm', 'G', 'A']);
    });

    test('the tritone respects the sharp/flat preference', () {
      expect(
        _chords('I-IV-V', _key('C'), transpose: 6),
        ['F♯', 'B', 'C♯'],
      );
      expect(
        _chords('I-IV-V', _key('C'),
            transpose: 6, preference: EnharmonicPreference.flats),
        ['G♭', 'C♭', 'D♭'],
      );
    });

    test('round-trips: up 5 then down 5 is identity', () {
      const prog = 'ii7-V7-IM7-vi7';
      expect(
        _chords(prog, _key('E', '♭')),
        _chords(prog, _key('E', '♭'), transpose: 0),
      );
    });
  });

  group('mid-progression key change', () {
    test('K+M2 moves the working key on top of any transpose', () {
      expect(_chords('I K+M2 I', _key('C')), ['C', 'D']);
      expect(_chords('I K+M2 I', _key('C'), transpose: 2), ['D', 'E']);
    });
  });

  group('layout', () {
    test('keeps dashes, gaps, parens and repeats', () {
      final pieces = layoutConcreteProgression(
        progression: 'I-(vi-IV) :2 V',
        key: _key('C'),
      );
      final kinds = pieces.map((p) => p.kind).toList();
      expect(kinds, contains(ConcretePieceKind.openParen));
      expect(kinds, contains(ConcretePieceKind.closeParen));
      expect(kinds, contains(ConcretePieceKind.repeat));
      expect(kinds, contains(ConcretePieceKind.dash));
    });
  });
}
