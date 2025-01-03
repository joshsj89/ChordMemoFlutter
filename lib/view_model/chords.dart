List<String> splitChordsIntoArray(String chords) {
  if (chords.isEmpty) { // return empty array if no chords
    return [];
  }

  // split chord string into parts
  final chordArray = chords.split(RegExp(r'(\s|-|\(|\))')).where((part) => part.isNotEmpty).toList();
  final List<String> updatedChordArray = [];

  chordArray.forEach((part){
    if (part.trim().isNotEmpty && part != '-') {
      updatedChordArray.add(part);
    } else if (part == ' ') {
      updatedChordArray.add(part);
    }
  });

  return updatedChordArray;
}