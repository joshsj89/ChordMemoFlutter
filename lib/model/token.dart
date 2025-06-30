enum TokenType {
  // The token represents a Roman numeral
  romanNumeral,

  // The token represents a chord type
  chordType,

  // The token represents a dash between Roman numerals
  dash,

  // The token represents a space in the input
  space,

  // The token represents a flat or sharp symbol
  accidental,

  // The token represents a left parenthesis
  leftParenthesis,

  // The token represents a right parenthesis
  rightParenthesis,

  // The token represents a key change
  keyChange,

  // The token represents a number repeat sign
  repeat,

  // The token represents a chord inversion slash
  inversion,

  // The token represents a chord with a slash
  slashChord,

  // The token represents an unknown token
  error,

  // The token represents a chord
  chord,

  // The token represents a sequence of chords
  sequence,

  // The token represents a full chord progression
  progression,
}

abstract class ASTNode {
  final Token token;
  ASTNode(this.token);
}

class RomanNumeralNode extends ASTNode {
  // final String numeral;
  // RomanNumeralNode(
  //   super.token, 
  //   this.numeral,
  // );

  RomanNumeralNode(super.token);
  String get numeral => token.value;

  @override
  String toString() {
    return 'RomanNumeralNode($numeral)';
  }
}

class ChordTypeNode extends ASTNode {
  ChordTypeNode(super.token);
  String get chordType => token.value;

  @override
  String toString() {
    return 'ChordTypeNode($chordType)';
  }
}

class RepeatNode extends ASTNode {
  final int count;

  RepeatNode(super.token)
    : count = int.parse(token.value.split(':')[1]);

  @override
  String toString() {
    return 'RepeatNode($count)';
  }
}

class InversionNode extends ASTNode {
  final String degree;

  InversionNode(super.token)
    : degree = token.value.substring(1); // Remove the leading slash

  @override
  String toString() {
    return 'InversionNode($degree)';
  }
}

class SlashChordNode extends ASTNode {
  final String chord;

  SlashChordNode(super.token)
    : chord = token.value.substring(1); // Remove the leading slash

  @override
  String toString() {
    return 'SlashChordNode($chord)';
  }
}

class KeyChangeNode extends ASTNode {
  final String direction;
  final String interval;

  KeyChangeNode(super.token)
    : direction = token.value.substring(1, 2), // Extract the direction (e.g., + or –)
      interval = token.value.substring(2); // Extract the interval (e.g., m2, M2, P4, TT)

  @override
  String toString() {
    return 'KeyChangeNode($direction$interval)';
  }
}

class DashNode extends ASTNode {
  DashNode(super.token);

  @override
  String toString() {
    return 'DashNode(token: ${token.value})';
  }
}

class AccidentalNode extends ASTNode {
  AccidentalNode(super.token);
  String get accidental => token.value;

  @override
  String toString() {
    return 'AccidentalNode($accidental)';
  }
}

class ParenthesizedNode extends ASTNode {
  final ASTNode sequence;
  final Token rightParenthesis;

  ParenthesizedNode(super.leftParenthesis, this.sequence, this.rightParenthesis);

  bool get isLeft => token.type == TokenType.leftParenthesis && token.value == '(';
  bool get isRight => token.type == TokenType.rightParenthesis && token.value == ')';

  @override
  String toString() {
    return 'ParenthesizedNode($sequence)';
  }
}

class SpaceNode extends ASTNode {
  SpaceNode(super.token);
}

class ErrorNode extends ASTNode {
  ErrorNode(super.token);
  String get error => token.value;

  @override
  String toString() {
    return 'ErrorNode(error: $error)';
  }
}

class ChordNode extends ASTNode {
  final AccidentalNode? accidental;
  final RomanNumeralNode romanNumeral;
  final ChordTypeNode? chordType;
  final InversionNode? inversion;
  final SlashChordNode? slashChord;

  ChordNode(
    super.token, {
    this.accidental,
    required this.romanNumeral,
    this.chordType,
    this.inversion,
    this.slashChord,
  });

  @override
  String toString() {
    if (inversion != null) {
      return 'ChordNode($accidental$romanNumeral$chordType$inversion)';
    } else if (slashChord != null) {
      return 'ChordNode($accidental$romanNumeral$chordType$slashChord)';
    }

    return 'ChordNode($accidental$romanNumeral$chordType)';
  }
}

class ChordGroupNode extends ASTNode {
  final List<ASTNode> children;

  ChordGroupNode(super.token, this.children);

  @override
  String toString() {
    return 'ChordGroupNode(children: $children)';
  }
}

class SequenceNode extends ASTNode {
  final List<ASTNode> children;

  SequenceNode(super.token, this.children);
  
  @override
  String toString() {
    return 'SequenceNode($children)';
  }
}

class ProgressionNode extends ASTNode {
  final List<ASTNode> children;

  ProgressionNode(super.token, this.children);

  @override
  String toString() {
    return 'ProgressionNode($children)';
  }
}

// A list of test cases to validate the tokenizer
final testCases = [
  "I-vi-IV-V",
  "I-(I-III-I-VII)-VI-V I-(I-III-I-VII)-VI-(VII-VI)-V",
  "i-III-iv :2 i-III-iv-V",
  "III-VIM7 III-(VIM7-V7)",
  "i-VII-VI-♯VII III",
  "I-I+-I6-I7-IV-iv6-I-V9",
  "VI7-i :2 II7-V7",
  "i-III-viø7-IV",
  "i i-iv-VII i VI-III",
  "i-VI-IV7-VI-VII-I-VI-IV7-Vsus4-V",
  "v-(v-♯iv)-iv",
  "I-iii-I-iii-vi-(V)-IV-V-vi-V",
  "i-VI-VII(add9)-♯vi-III-♭I",
  "I-♯iv7-IVM7-(ii7-V11)",
  "i7-ii7-III6-IV i7/5-IV/3-i7/5-IV/5",
  "I-v(add11)-v(add11)-ii7",
  "IV7sus2-I-V6 :2 IV-IVM7 :1 ",
  "i-VII-IV/3-V :1 i-VII-VI-V i",
  "i-i/5-iv i-V-i",
  "i K+M2 i",
  "I5-VII5-I5 VI5-V5 ♯VII5-V5 :3 i-♭II",
  "i-VII-VI-ivsus2-V7-V7/3",
  "I5-♭II5-I5",
  "V7♭9",
  "I-I I5-VIno5-♭VIIno5-vii I-V",
  "i-v7 :1 K–M2 III-VII i-VI IV-V (V-VII)",
  "I6-♭III6-♭VII-vi-♭VI-Vsus4-(I6-♭vii°)-♭II",
  "I-vi-IV-V :2 IV-V/3-vi-II I-V/3-vi-II",
  "I-(V/5-I)-IV-V",
  "I(add9)-III-vi-ii-V",
  "VI-V-i ii/VI-V/VI-VI-V-i",
  "ii-V-ii-V I-IV7-iii-♯ii° ii-V-ii-V-I",
  "i-IIIM7♯5-III-IV-VIM7-(VII)-i :1 III-IV-VIM7-i-(VII)-III-VII-IV",
  "VI-III-V7-(i-VII/3-III-IV-V) VI-III-iv7-V7",
  "i/3-Vsus4/5-v/5"
];

final List<String> chordTypeRegexPatterns = [
  '13♯9♯11sus2',
  '7♯9♯11♭13sus2',
  '13♯9♭11sus2',
  '7♯9♭11♭13sus2',
  '13♯9sus2',
  '11♯9♭13sus2',
  '13♭9♯11sus2',
  '7♭9♯11♭13sus2',
  '13♭9♭11sus2',
  '7♭9♭11♭13sus2',
  '13♭9sus2',
  '11♭9♭13sus2',
  '13♯9♯11sus4',
  '7♯9♯11♭13sus4',
  '13♯9♭11sus4',
  '7♯9♭11♭13sus4',
  '13♭9♯11sus4',
  '7♭9♯11♭13sus4',
  '13♭9♭11sus4',
  '7♭9♭11♭13sus4',
  '13♯11sus4',
  '9♯11♭13sus4',
  '13♭11sus4',
  '9♭11♭13sus4',
  'M13♯5♯9♯11',
  'M7♯5♯9♯11♯13',
  'M13♯5♯9',
  'M11♯5♯9♯13',
  'M13♯5♭9♯11',
  'M7♯5♭9♯11♯13',
  'M13♯5♭9',
  'M11♯5♭9♯13',
  'M13♯5♯11',
  'M♯13♯5♯11',
  'M13♯5',
  'M11♯5♯13',
  '13♯5♯9♯11',
  '13♯5♯9',
  '13♯5♭9♯11',
  '13♯5♭9',
  '13♯5♯11',
  '13♯5',
  '°7♭5♭9♭11♭13',
  '°7♭5♭9♭11♯13',
  '°11♭5♭9♭13',
  '°11♭5♭9♯13',
  '°9♭5♭11♭13',
  '°9♭5♭11♯13',
  '°11♭5♭13',
  '°11♭5♯13',
  '7♭5♭9♭11♭13',
  '7♭5♭9♭11♯13',
  '11♭5♭9♭13',
  '11♭5♭9♯13',
  '9♭5♭11♭13',
  '9♭5♭11♯13',
  '11♭5♭13',
  '11♭5♯13',
  '6/♭9♯11♭13',
  '6/♭9♯11♯13',
  '6/♭9♭11♭13',
  '6/♭9♭11♯13',
  '6/11♭9♭13',
  '6/11♭9♯13',
  '6/9♯11♭13',
  '6/9♯11♯13',
  '6/9♭11♭13',
  '6/9♭11♯13',
  '6/11♭13',
  '6/11♯13',
  '6/♯9♯11♭13',
  '6/♯9♯11♯13',
  '6/11♯9♭13',
  '6/11♯9♯13',
  '6/♭9♯11♭13',
  '6/♭9♯11♯13',
  '6/11♭9♭13',
  '6/11♭9♯13',
  '6/9♯11♭13',
  '6/9♯11♯13',
  '6/11♭13',
  '6/11♯13',
  'mM13♭9♯11',
  'mM♭9♯11♭13',
  'mM♭9♯11♯13',
  'mM13♭9♭11',
  'mM7♭9♭11♭13',
  'mM7♭9♭11♯13',
  'mM13♭9',
  'mM11♭9♭13',
  'mM11♭9♯13',
  'mM13♯11',
  'mM9♯11♭13',
  'mM9♯11♯13',
  'mM13♭11',
  'mM9♭11♭13',
  'mM9♭11♯13',
  'mM13',
  'mM11♭13',
  'mM11♯13',
  '13♭9♯11',
  '7♭9♯11♭13',
  '13♭9♭11',
  '7♭9♭11♭13',
  '13♭9',
  '11♭9♭13',
  '13♯11',
  '9♯11♭13',
  '13♭11',
  '9♭11♭13',
  '13',
  '11♭13',
  '13♯9♯11',
  '7♯9♯11♭13',
  '7♯9♯11♯13',
  '13♯9',
  '11♯9♭13',
  '11♯9♯13',
  '13♭9♯11',
  '7♭9♯11♭13',
  '7♭9♯11♯13',
  '13♭9',
  '11♭9♭13',
  '11♭9♯13',
  '13♯11',
  '9♯11♭13',
  '9♯11♯13',
  '13',
  '11♭13',
  '11♯13',
  'M13♯9♯11',
  'M7♯9♯11♭13',
  'M7♯9♯11♯13',
  'M13♯9',
  'M11♯9♭13',
  'M11♯9♯13',
  'M13♭9♯11',
  'M7♭9♯11♭13',
  'M7♭9♯11♯13',
  'M13♭9',
  'M11♭9♭13',
  'M11♭9♯13',
  'M13♯11',
  'M9♯11♭13',
  'M9♯11♯13',
  'M13',
  'M11♭13',
  'M11♯13',
  '5\(add13\)',
  'sus2\(add13\)',
  '\+\(add13\)',
  '°\(add13\)',
  '\(add13\)',
  '\(add13\)',
  '11♯9sus2',
  '7♯9♭11sus2',
  '7♯9♯11sus2',
  '11♭9sus2',
  '7♭9♭11sus2',
  '7♭9♯11sus2',
  '7♯9♭11sus4',
  '7♯9♯11sus4',
  '7♭9♭11sus4',
  '7♭9♯11sus4',
  '9♭11sus4',
  '9♯11sus4',
  'M11♯5♯9',
  'M7♯5♯9♯11',
  'M11♯5♭9',
  'M7♯5♭9♯11',
  'M11♯5',
  'M9♯5♯11',
  '11♯5♯9',
  '7♯5♯9♯11',
  '11♯5♭9',
  '7♯5♭9♯11',
  '11♯5',
  '9♯5♯11',
  '°11♭5♭9',
  '°7♭5♭9♭11',
  '°11♭5',
  '°9♭5♭11',
  '11♭5♭9',
  '7♭5♭9♭11',
  '11♭5',
  '9♭5♭11',
  '6/11♭9',
  '6/♭9♭11',
  '6/♭9♯11',
  '6/11',
  '6/9♭11',
  '6/9♯11',
  '6/11♯9',
  '6/♯9♯11',
  '6/11♭9',
  '6/♭9♯11',
  '6/11',
  '6/9♯11',
  'mM11♭9',
  'mM7♭9♭11',
  'mM7♭9♯11',
  'mM11',
  'mM9♭11',
  'mM9♯11',
  '11♭9',
  '7♭9♭11',
  '7♭9♯11',
  '11',
  '9♭11',
  '9♯11',
  '11♯9',
  '7♯9♯11',
  '11♭9',
  '7♭9♯11',
  '11',
  '9♯11',
  'M11♯9',
  'M7♯9♯11',
  'M11♭9',
  'M7♭9♯11',
  'M11',
  'M9♯11',
  '5\(add11\)',
  'sus2\(add11\)',
  '\+\(add11\)',
  '°\(add11\)',
  '\(add11\)',
  '\(add11\)',
  '7♭9sus2',
  '7♯9sus2',
  '9sus4',
  '7♭9sus4',
  '7♯9sus4',
  'M9♯5',
  'M7♯5♭9',
  'M7♯5♯9',
  '9♯5',
  '7♯5♭9',
  '7♯5♯9',
  '°9♭5',
  '°7♭5♭9',
  '9♭5',
  '7♭5♭9',
  '6/9',
  '6/♭9',
  '6/9',
  '6/♭9',
  '6/♯9',
  'mM9',
  'mM7♭9',
  '9',
  '7♭9',
  '9',
  '7♭9',
  '7♯9',
  'M9',
  'M7♭9',
  'M7♯9',
  '5\(add9\)',
  'sus4\(add9\)',
  '\+\(add9\)',
  '°\(add9\)',
  '\(add9\)',
  '\(add9\)',
  'M7sus2',
  '7sus2',
  'M7sus4',
  '7sus4',
  'M7♯5',
  '7♯5',
  '°7',
  'ø7',
  '6',
  'mM7',
  '7',
  '6',
  '7',
  'M7',
  'no5',
  '5', 
  'sus2', 
  'sus4', 
  '\+', 
  '°' 
]..sort((a, b) => b.length.compareTo(a.length)); // Sort patterns by length for better matching

final String chordTypeRegexString = chordTypeRegexPatterns.map((alt) => '(${RegExp.escape(alt)})').join('|');

class Token {
  final TokenType type;
  final String value;

  Token(
    this.type, 
    this.value,
  );

  @override
  String toString() {
    return 'Token(type: $type, value: "$value")';
  }
}

List<Token> tokenize(String input) {
  final tokens = <Token>[];
  int index = 0;
  final pattern = RegExp(
    r'(iii|III|ii|II|iv|IV|vii|VII|vi|VI|[iIvV])|'         // Roman numerals
    r'(\/([2-79]|11|13))|' // inversion slash (e.g., /2, /3, /4, /5, /6, /7, /9, /11, /13)
    r'([\-])|'             // dash
    r'([♯#♭])|'             // accidentals
    r'(\/[^\d\s\-\(\)]+)|'     // slash chord
    r'(:(\d+))|'               // repeat (e.g., x2)
    r'(K[+–]([mM][2367]|P[45]|TT))|'     // key change
    '$chordTypeRegexString|' // Chord types
    r'(\()|'                 // left parenthesis
    r'(\))|'                 // right parenthesis
    r'(\s)',                  // space
    caseSensitive: true,
  );

  while (index < input.length) {
    final match = pattern.matchAsPrefix(input, index);
    if (match != null) {
      final value = match.group(0)!;
      if (RegExp(r'^(iii|III|ii|II|iv|IV|vii|VII|vi|VI|[iIvV])$', caseSensitive: true).hasMatch(value)) {
        tokens.add(Token(TokenType.romanNumeral, value));
      } else if (RegExp(r'^(\/[2-79]|11|13)$').hasMatch(value)) {
        tokens.add(Token(TokenType.inversion, value));
      } else if (RegExp(r'^[\-]$').hasMatch(value)) {
        tokens.add(Token(TokenType.dash, value));
      } else if (RegExp(r'^[♯#♭]$').hasMatch(value)) {
        tokens.add(Token(TokenType.accidental, value));
      } else if (RegExp(r'^(\/[^\d\s\-\(\)]+)$', caseSensitive: true).hasMatch(value)) {
        tokens.add(Token(TokenType.slashChord, value));
      } else if (RegExp(r'^(:(\d+))$').hasMatch(value)) {
        tokens.add(Token(TokenType.repeat, value));
      } else if (RegExp(r'^(K[+–]([mM][2367]|P[45]|TT))$', caseSensitive: true).hasMatch(value)) {
        tokens.add(Token(TokenType.keyChange, value));
      } else if (RegExp(r'^\s$').hasMatch(value)) {
        tokens.add(Token(TokenType.space, value));
      } else if (RegExp(chordTypeRegexString, caseSensitive: true).hasMatch(value)) {
        tokens.add(Token(TokenType.chordType, value));
      } else if (value == '(') {
        tokens.add(Token(TokenType.leftParenthesis, value));
      } else if (value == ')') {
        tokens.add(Token(TokenType.rightParenthesis, value));
      } else {
        tokens.add(Token(TokenType.error, value));
      }

      // index += match.end - match.start; // Move the index forward
      index += value.length; // Move the index forward by the length of the matched value
    } else {
      // If no match is found, we can treat it as an error token
      tokens.add(Token(TokenType.error, input[index]));
      index++;
    }
  }

  return tokens;
}

/* // Main function to test the tokenizer with various cases
void main() {
  for (final testCase in testCases) {
    print('Testing: $testCase');
    final tokens = tokenize(testCase);
    for (final token in tokens) {
      print(token);
    }
    print('---');
  }
}
*/