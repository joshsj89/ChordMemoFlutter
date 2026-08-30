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
}
