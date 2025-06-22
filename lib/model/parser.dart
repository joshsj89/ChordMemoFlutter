import 'package:chordmemoflutter/model/token.dart';

class Parser {
  final List<Token> tokens;
  int position = 0;

  Parser(this.tokens);

  Token get current =>
      position < tokens.length ? tokens[position] : Token(TokenType.error, '');

  Token get nextToken =>
      position + 1 < tokens.length ? tokens[position + 1] : Token(TokenType.error, '');

  Token advance() {
    return tokens[position++];
  }

  bool isAtEnd() {
    return position >= tokens.length;
  }

  bool match(TokenType type) {
    if (!isAtEnd() && current.type == type) {
      return true;
    }
    return false;
  }

  bool matchAny(List<TokenType> types) {
    if (!isAtEnd() && types.contains(current.type)) {
      return true;
    }
    return false;
  }

  bool peek(TokenType type) {
    if (nextToken.type == TokenType.error) {
      return false; // No next token
    }

    return nextToken.type == type;
  }

  List<ASTNode> parseRepeatTail() { // space KeyChange space Sequence
    final children = <ASTNode>[];

    if (match(TokenType.space)) { 
      advance(); // consume space

      if (match(TokenType.keyChange)) {
        final keyChange = KeyChangeNode(advance());

        if (keyChange.token.type == TokenType.error) {
          children.add(ErrorNode(keyChange.token));

          return children;
        }

        if (match(TokenType.space)) advance();

        children.add(keyChange);
        children.add(parseSequence());
      }
    }

    // empty (epsilon)
    return children;
  }

  // Grammar: Progression → Sequence ProgressionTail*
  ASTNode parseProgression() {
    final children = <ASTNode>[];

    children.add(parseSequence());

    while (!isAtEnd()) {
      if (match(TokenType.space)) {
        advance(); // consume space

        if (match(TokenType.keyChange)) { // KeyChange space Sequence
          final keyChange = KeyChangeNode(advance());

          if (keyChange.token.type == TokenType.error) {
            return ErrorNode(keyChange.token);
          }

          if (match(TokenType.space)) advance();

          children.add(keyChange);
          children.add(parseSequence());
        } else if (match(TokenType.repeat)) { // Repeat RepeatTail
          final repeat = RepeatNode(advance());

          if (repeat.token.type == TokenType.error) {
            return ErrorNode(repeat.token);
          }

          children.add(repeat);

          if (match(TokenType.space)) {
            if (peek(TokenType.keyChange)) {
              // If there's a space followed by a key change, we parse the repeat tail
              final repeatTail = parseRepeatTail();
              if (repeatTail.isNotEmpty) {
                children.addAll(repeatTail);
              }
            } else if (nextToken.type == TokenType.error) { // Progression ends with a repeat
              advance(); // consume space
              break;
            }
          }
        } else { // Sequence
          children.add(parseSequence());
        }
      } else { // If not a space, we assume it's the end of the progression
        break;
      }
    }

    if (isAtEnd()) {
      // If we reach the end without any further tokens, we can return the progression
      return ProgressionNode(Token(TokenType.progression, ''), children);
    } else {
      // If we encounter an unexpected token, we return an error node
      return ErrorNode(Token(TokenType.error, 'Unexpected token: ${current.value}'));
    }
  }

  // Grammar: Sequence → ChordGroup (dash ChordGroup)*
  ASTNode parseSequence() {
    final children = <ASTNode>[];
    children.add(parseChordGroup());
    while (match(TokenType.dash)) { // (dash ChordGroup)*
      children.add(DashNode(advance()));
      children.add(parseChordGroup());
    }
    return SequenceNode(Token(TokenType.sequence, ''), children);
  }

  // Grammar: ChordGroup → Chord | Parenthesized
  ASTNode parseChordGroup() {
    if (match(TokenType.leftParenthesis)) { // Parenthesized
      return parseParenthesized();
    } else { // Chord
      return parseChord();
    }
  }

  // Grammar: Parenthesized → leftParenthesis Sequence rightParenthesis
  ASTNode parseParenthesized() {
    final left = advance(); // consume '('
    if (left.type == TokenType.error) {
      return ErrorNode(left);
    }
    final seq = parseSequence();
    if (match(TokenType.rightParenthesis)) { // rightParenthesis
      final right = advance(); // consume ')'
      if (right.type == TokenType.error) {
        return ErrorNode(right);
      }

      return ParenthesizedNode(left, seq, right);
    } else {
      return ErrorNode(Token(TokenType.error, 'Expected right parenthesis'));
    }
  }

  // Grammar: Chord → (accidental)? RomanNumeral (ChordType)? (InversionOrSlash)?
  ASTNode parseChord() {
    final AccidentalNode? accidental;
    final RomanNumeralNode romanNumeral;
    final ChordTypeNode? chordType;
    final InversionNode? inversion;
    final SlashChordNode? slashChord;

    if (match(TokenType.accidental)) { // (accidental)?
      final accTok = advance();
      if (accTok.type == TokenType.error) {
        return ErrorNode(accTok);
      }

      accidental = AccidentalNode(accTok);
    } else {
      accidental = null;
    }

    if (match(TokenType.romanNumeral)) { // RomanNumeral
      final romanTok = advance();
      if (romanTok.type == TokenType.error) {
        return ErrorNode(romanTok);
      }
      romanNumeral = RomanNumeralNode(romanTok);
    } else {
      return ErrorNode(Token(TokenType.error, 'Expected Roman numeral'));
    }

    if (match(TokenType.chordType)) { // (ChordType)?
      final chordTypeTok = advance();
      if (chordTypeTok.type == TokenType.error) {
        return ErrorNode(chordTypeTok);
      }
      chordType = ChordTypeNode(chordTypeTok);
    } else {
      chordType = null;
    }

    // (InversionOrSlash)?
    if (match(TokenType.inversion)) {
      final invTok = advance();

      if (invTok.type == TokenType.error) {
        return ErrorNode(invTok);
      }

      inversion = InversionNode(invTok);
      slashChord = null;
    } else if (match(TokenType.slashChord)) {
      final slashTok = advance();

      if (slashTok.type == TokenType.error) {
        return ErrorNode(slashTok);
      }

      slashChord = SlashChordNode(slashTok);
      inversion = null;
    } else {
      inversion = null;
      slashChord = null;
    }

    return ChordNode(
      Token(TokenType.chord, ''),
      accidental: accidental,
      romanNumeral: romanNumeral,
      chordType: chordType,
      inversion: inversion,
      slashChord: slashChord,
    );
  }
}

/* // Test parser
void main() {
  for (final testCase in testCases) {
    print('Parsing: $testCase');
    final tokens = tokenize(testCase);
    final parser = Parser(tokens);
    final ast = parser.parseProgression();
    print(ast);
    print('---');
  }
}
*/