import 'package:flutter_test/flutter_test.dart';

import 'package:chordmemoflutter/model/parser.dart';
import 'package:chordmemoflutter/model/token.dart';

import '_fixtures.dart';

bool _containsError(ASTNode node) {
  if (node is ErrorNode) return true;
  if (node is ProgressionNode) return node.children.any(_containsError);
  if (node is SequenceNode) return node.children.any(_containsError);
  if (node is ParenthesizedNode) return _containsError(node.sequence);
  if (node is ChordNode) {
    return node.accidental is ErrorNode ||
        node.chordType is ErrorNode ||
        node.inversion is ErrorNode ||
        node.slashChord is ErrorNode;
  }
  return false;
}

void main() {
  group('tokenize', () {
    test('splits a plain progression into roman numerals and dashes', () {
      final tokens = tokenize('I-vi-IV-V');
      expect(tokens.map((t) => t.type).toList(), [
        TokenType.romanNumeral,
        TokenType.dash,
        TokenType.romanNumeral,
        TokenType.dash,
        TokenType.romanNumeral,
        TokenType.dash,
        TokenType.romanNumeral,
      ]);
      expect(tokens.map((t) => t.value).toList(), ['I', '-', 'vi', '-', 'IV', '-', 'V']);
    });

    test('recognizes chord types, accidentals, repeats and key changes', () {
      expect(
        tokenize('♯iv7').map((t) => t.type).toList(),
        [TokenType.accidental, TokenType.romanNumeral, TokenType.chordType],
      );
      expect(tokenize(':3').single.type, TokenType.repeat);
      expect(tokenize('K+M2').single.type, TokenType.keyChange);
      expect(tokenize('/VI').single.type, TokenType.slashChord);
      expect(tokenize('/3').single.type, TokenType.inversion);
    });

    test('emits an error token for an unknown character', () {
      expect(tokenize('Z').single.type, TokenType.error);
    });
  });

  group('Parser.parse', () {
    test('parses every known-good progression without an error node', () {
      for (final progression in validProgressions) {
        final ast = Parser.parse(progression);
        expect(
          _containsError(ast),
          isFalse,
          reason: 'expected "$progression" to parse cleanly',
        );
      }
    });

    test('an empty progression is a valid empty ProgressionNode', () {
      final ast = Parser.parse('');
      expect(ast, isA<ProgressionNode>());
      expect((ast as ProgressionNode).children, isEmpty);
    });

    test('flags malformed progressions', () {
      for (final bad in const ['Z-I', 'I-', 'I--V', '(I', 'I/']) {
        final ast = Parser.parse(bad);
        expect(
          ast is ErrorNode || _containsError(ast),
          isTrue,
          reason: 'expected "$bad" to be rejected',
        );
      }
    });
  });
}
