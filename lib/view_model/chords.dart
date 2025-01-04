List<String> splitChordsIntoArray(String chords) {
  if (chords.isEmpty) { // return empty array if no chords
    return [];
  }

  // split chord string into parts
  final chordArray = chords.split(RegExp(r'(\s|-|\(|\))')).where((part) => part.isNotEmpty).toList();
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