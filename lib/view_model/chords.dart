List<String> splitChordsIntoArray(String chords) {
  if (chords.isEmpty) { // return empty array if no chords
    return [];
  }

  // split chord string into parts
  final chordArray = chords.splitWithDelim(RegExp(r'(\s|-|\(|\))')).where((part) => part.isNotEmpty).toList();
  final List<String> updatedChordArray = [];

  for(var part in chordArray) {
    if (part.trim().isNotEmpty && part != '-') {
      updatedChordArray.add(part);
    } else if (part == ' ') {
      updatedChordArray.add(part);
    }
  }

  return updatedChordArray;
}

String transformChords(List<String> chords) {
  return chords.join('-').replaceAllMapped(
    RegExp(r'-\s-|- |\(-|-\)'),
    (match) {
      switch (match[0]) {
        case '- -':
        case '- ':
          return ' '; // Replace dash with a space
        case '(-':
          return '('; // Remove dash after '('
        case '-)':
          return ')'; // Remove dash before ')'
        default:
          return ''; // Default fallback
      }
    },
  );
}

// Extensions allow you to add methods to existing classes
// without modifying the class or creating a new class that inherits from it.

// Adding allMatchesWithSep method to RegExp class
extension RegExpExtension on RegExp {
  List<String> allMatchesWithSep(String input, [int start = 0]) {
    var result = <String>[];
    for (var match in allMatches(input, start)) {
      result.add(input.substring(start, match.start));
      result.add(match[0]!);
      start = match.end;
    }
    result.add(input.substring(start));
    return result;
  }
}

// Adding splitWithDelim method to String class
extension StringExtension on String {
  List<String> splitWithDelim(RegExp pattern) =>
      pattern.allMatchesWithSep(this);
}