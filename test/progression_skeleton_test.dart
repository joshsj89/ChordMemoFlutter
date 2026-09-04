import 'package:flutter_test/flutter_test.dart';

import 'package:chordmemoflutter/view_model/progression_skeleton.dart';

import '_fixtures.dart';

void main() {
  group('reduceChordTypeToTriad', () {
    test('empty / null yield the plain-triad token', () {
      expect(reduceChordTypeToTriad(null), '');
      expect(reduceChordTypeToTriad(''), '');
    });

    test('added-note extensions are dropped', () {
      for (final v in ['7', 'M7', '6', '9', '11', '13', '(add9)', '(add13)']) {
        expect(reduceChordTypeToTriad(v), '', reason: v);
      }
    });

    test('diminished family reduces to °', () {
      for (final v in ['ø7', '°7', '°(add9)', '°9♭5', 'M7♭5']) {
        expect(reduceChordTypeToTriad(v), '°', reason: v);
      }
    });

    test('augmented family reduces to +', () {
      for (final v in ['M7♯5', '7♯5', '+(add9)']) {
        expect(reduceChordTypeToTriad(v), '+', reason: v);
      }
    });

    test('suspended and power-chord qualities are kept', () {
      expect(reduceChordTypeToTriad('sus4(add9)'), 'sus4');
      expect(reduceChordTypeToTriad('7sus4'), 'sus4');
      expect(reduceChordTypeToTriad('sus2(add11)'), 'sus2');
      expect(reduceChordTypeToTriad('7sus2'), 'sus2');
      expect(reduceChordTypeToTriad('5(add9)'), '5');
      expect(reduceChordTypeToTriad('no5'), 'no5');
    });

    test('the tables classify dom7♭5 as major-derived', () {
      expect(reduceChordTypeToTriad('7♭5'), '');
    });

    test('an unrecognised value is returned unchanged', () {
      expect(reduceChordTypeToTriad('totally-made-up'), 'totally-made-up');
    });
  });

  group('skeletonizeProgression', () {
    const cases = {
      'i9-VI7-V7': 'i-VI-V',
      'viø7-III-Vsus4': 'vi°-III-Vsus4',
      'I5-♭VII5-I5': 'I5-♭VII5-I5',
      'V7♭9': 'V',
      'I(add9)-III-vi-ii-V': 'I-III-vi-ii-V',
      'i-III-viø7-IV': 'i-III-vi°-IV',
      'I-I+-I6-I7-IV-iv6-I-V9': 'I-I+-I-I-IV-iv-I-V',
      'i7/5-IV/3': 'i/5-IV/3',
      'i K+M2 i': 'i K+M2 i',
      'i-III-iv :2 i-III-iv-V': 'i-III-iv :2 i-III-iv-V',
      '#VII': '♯VII',
      'VI-III-V7-(i-VII/3-III-IV-V) VI-III-iv7-V7':
          'VI-III-V-(i-VII/3-III-IV-V) VI-III-iv-V',
    };

    cases.forEach((input, expected) {
      test('"$input" -> "$expected"', () {
        expect(skeletonizeProgression(input), expected);
      });
    });

    test('empty / whitespace-only input yields an empty string', () {
      expect(skeletonizeProgression(''), '');
      expect(skeletonizeProgression('   '), '');
    });

    test('a slash-chord target loses its own extension', () {
      expect(skeletonizeProgression('ii/VI-V/VI7'), 'ii/VI-V/VI');
    });

    test('malformed progressions return null', () {
      for (final bad in const ['Z-I', 'gibberish', 'I--V', '(I']) {
        expect(skeletonizeProgression(bad), isNull, reason: bad);
      }
    });

    test('every valid fixture skeletonizes and is idempotent', () {
      for (final progression in validProgressions) {
        final skeleton = skeletonizeProgression(progression);
        expect(skeleton, isNotNull, reason: progression);
        expect(
          skeletonizeProgression(skeleton!),
          skeleton,
          reason: 'not idempotent: $progression',
        );
      }
    });
  });

  group('skeletonContainsRun', () {
    test('matches a consecutive run', () {
      expect(skeletonContainsRun('i-VI-V-i', 'i-VI-V'), isTrue);
      expect(skeletonContainsRun('III-i-VI-V', 'i-VI-V'), isTrue);
    });

    test('does not match out-of-order or partial-token runs', () {
      expect(skeletonContainsRun('i-VI-V', 'VI-i'), isFalse);
      expect(skeletonContainsRun('I5-♭VII5-I5', 'I-♭VII-I'), isFalse);
    });
  });
}
