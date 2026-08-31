import 'package:flutter_test/flutter_test.dart';

import 'package:chordmemoflutter/view_model/progression_validator.dart';

import '_fixtures.dart';

void main() {
  group('validateProgression', () {
    test('returns null for every known-good progression', () {
      for (final progression in validProgressions) {
        expect(
          validateProgression(progression),
          isNull,
          reason: 'expected "$progression" to be valid',
        );
      }
    });

    test('returns null for an empty string', () {
      expect(validateProgression(''), isNull);
    });

    test('returns a message for malformed progressions', () {
      for (final bad in const ['Z-I', 'I-', 'I--V', '(I', 'gibberish']) {
        expect(
          validateProgression(bad),
          isNotNull,
          reason: 'expected "$bad" to be reported as invalid',
        );
      }
    });
  });

  group('resolvePastedProgression', () {
    test('accepts a valid progression and trims surrounding whitespace', () {
      final result = resolvePastedProgression('  I-vi-IV-V \n');
      expect(result.chords, 'I-vi-IV-V');
      expect(result.error, isNull);
    });

    test('rejects an empty or whitespace-only clipboard', () {
      for (final value in const [null, '', '   ', '\n\t']) {
        final result = resolvePastedProgression(value);
        expect(result.chords, isNull);
        expect(result.error, contains('Clipboard has no text'));
      }
    });

    test('rejects text that is not a valid progression, keeping the reason', () {
      for (final bad in const ['Cmaj7 Dm7', 'gibberish', 'I - vi']) {
        final result = resolvePastedProgression(bad);
        expect(result.chords, isNull, reason: bad);
        expect(result.error, startsWith('Not a valid chord progression:'));
      }
    });
  });
}
