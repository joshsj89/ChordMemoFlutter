import 'package:chordmemoflutter/model/token.dart';

class Parser {
  final List<Token> tokens;
  int position = 0;

  Parser(this.tokens);

  Token get current =>
      position < tokens.length ? tokens[position] : Token(TokenType.error, '');

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

  // Grammar: Progression → Sequence ProgressionTail*
  ASTNode parseProgression() {
    final children = <ASTNode>[];

    children.add(parseSequence());

    while (!isAtEnd()) {
      if (match(TokenType.space)) {
        advance(); // consume space
        
        if (match(TokenType.keyChange)) { // KeyChange space Sequence
          final keyChange = KeyChangeNode(advance());

          if (match(TokenType.space)) advance();

          // If next token is not a key change or repeat, we parse the next sequence
          if (!isAtEnd() && !matchAny([TokenType.keyChange, TokenType.repeat])) {
            children.add(keyChange);
            children.add(parseSequence());
          } else { // CHECK THIS LATER
            children.add(keyChange);
          }
        } else if (match(TokenType.repeat)) { // Repeat space (Sequence)?
          final repeat = RepeatNode(advance());

          if (match(TokenType.space)) advance();

          // If next token is not a repeat, we parse the next sequence
          if (!isAtEnd() && !matchAny([TokenType.repeat])) {
            children.add(repeat);
            children.add(parseSequence());
          } else { // CHECK THIS LATER
            children.add(repeat);
          }
        } else {
          children.add(parseSequence());
        }
      } else { // If not a space, we assume it's the end of the progression
        break;
      }
    }

    return ProgressionNode(Token(TokenType.progression, ''), children);
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
    final seq = parseSequence();

    if (match(TokenType.rightParenthesis)) { // rightParenthesis
      final right = advance(); // consume ')'
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
      accidental = AccidentalNode(advance());
    } else {
      accidental = null;
    }

    if (match(TokenType.romanNumeral)) { // RomanNumeral
      romanNumeral = RomanNumeralNode(advance());
    } else {
      return ErrorNode(Token(TokenType.error, 'Expected Roman numeral'));
    }

    if (match(TokenType.chordType)) { // (ChordType)?
      chordType = ChordTypeNode(advance());
    } else {
      chordType = null;
    }
    
    // (InversionOrSlash)?
    if (match(TokenType.inversion)) {
      inversion = InversionNode(advance());
      slashChord = null;
    } else if (match(TokenType.slashChord)) {
      slashChord = SlashChordNode(advance());
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

  // Entry point for parsing
  List<ASTNode> parseAll() {
    final List<ASTNode> ast = [];

    if (!isAtEnd()) {
      ast.add(parseProgression());
    }

    return ast;
  }
}

void main() {
  for (final testCase in testCases) {
    print('Parsing: $testCase');
    final tokens = tokenize(testCase);
    final parser = Parser(tokens);
    final ast = parser.parseAll();
    for (final node in ast) {
      print(node);
    }
    print('---');
  }
}