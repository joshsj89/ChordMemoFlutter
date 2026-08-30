class ListTileOption {
  final String label;
  final int id;

  const ListTileOption({
    required this.label,
    required this.id,
  });
}

const List<String> keyTonicOptions = [
  'C',
  'D',
  'E',
  'F',
  'G',
  'A',
  'B',
];

const List<String> keySymbolOptions = [
  '',
  '♯',
  '♭',
];

const List<String> keyModeOptions = [
  'Major',
  'Minor',
  'Harmonic Minor',
  'Melodic Minor',
  'Phrygian',
  'Lydian',
  'Mixolydian',
  'Dorian',
  'Locrian',
  'Minor Pentatonic',
  'Major Pentatonic',
  'Lydian Dominant',
  'Phrygian Dominant',
];

const List<ListTileOption> sectionTypeOptions = [
  ListTileOption(label: 'Verse', id: 0),
  ListTileOption(label: 'Chorus', id: 1),
  ListTileOption(label: 'Bridge', id: 2),
  ListTileOption(label: 'Intro', id: 3),
  ListTileOption(label: 'Outro', id: 4),
  ListTileOption(label: 'Interlude', id: 5),
  ListTileOption(label: 'Solo', id: 6),
  ListTileOption(label: 'Instrumental', id: 7),
  ListTileOption(label: 'Pre-Chorus', id: 8),
  ListTileOption(label: 'Post-Chorus', id: 9),
  ListTileOption(label: 'Whole', id: 10),
  ListTileOption(label: 'Section A', id: 11),
  ListTileOption(label: 'Section B', id: 12),
  ListTileOption(label: 'Section C', id: 13),
  ListTileOption(label: 'Section D', id: 14),
];

// Genres the app ships with. Custom genres created by the user are merged in
// alongside these via [buildGenreOptions].
const List<String> defaultGenres = [
  'Pop',
  'Rock',
  'Metal',
  'Jazz',
  'Alternative/Indie',
  'Classical',
  'Country',
  'R&B',
  'Hip Hop',
  'Blues',
  'Funk',
  'Soul',
  'Folk',
  'Electronic',
  'Disco',
  'Reggae',
  'Punk',
  'Game Music',
  'Show Tunes',
];

/// Builds the full list of genre options: the built-in [defaultGenres] first (in
/// their canonical order), followed by any previously-used genres from saved
/// songs that aren't already covered, sorted alphabetically. Comparison is
/// case-insensitive so a custom genre never duplicates a built-in one.
List<String> buildGenreOptions(Iterable<String> usedGenres) {
  final options = <String>[...defaultGenres];
  final seen = options.map((genre) => genre.toLowerCase()).toSet();

  final extras = <String>[];
  for (final genre in usedGenres) {
    final trimmed = genre.trim();
    if (trimmed.isEmpty) continue;
    if (seen.add(trimmed.toLowerCase())) extras.add(trimmed);
  }
  extras.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

  return options..addAll(extras);
}