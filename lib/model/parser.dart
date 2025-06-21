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

  ASTNode parseNext() {
    final token = current;

    switch (token.type) {
      case TokenType.romanNumeral:
        return RomanNumeralNode(advance());
      case TokenType.chordType:
        return ChordTypeNode(advance());
      case TokenType.repeat:
        return RepeatNode(advance());
      case TokenType.inversion:
        return InversionNode(advance());
      case TokenType.slashChord:
        return SlashChordNode(advance());
      case TokenType.keyChange:
        return KeyChangeNode(advance());
      case TokenType.accidental:
        return AccidentalNode(advance());
      case TokenType.leftParenthesis:
      case TokenType.rightParenthesis:
        return ParenthesisNode(advance());
      case TokenType.space:
        return SpaceNode(advance());
      case TokenType.dash:
        return DashNode(advance());
      case TokenType.error:
        // Handle unexpected tokens or errors
        return ErrorNode(advance());
    }
  }

  List<ASTNode> parseAll() {
    final List<ASTNode> ast = [];

    while (!isAtEnd()) {
      ast.add(parseNext());
    }

    return ast;
  }
}

/* // Test parser
void main() {
  for (final testCase in testCases) {
    print('Parsing: $testCase');
    final tokens = tokenize(testCase);
    final parser = Parser(tokens);
    final ast = parser.parseAll();
    for (final node in ast) {
      print('${node.runtimeType}: ${node.token.value}');
    }
    print('---');
  }
}
*/