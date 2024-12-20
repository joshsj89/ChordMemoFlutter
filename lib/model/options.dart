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

const List<ListTileOption> genreOptions = [
  ListTileOption(label: 'Pop', id: 0),
  ListTileOption(label: 'Rock', id: 1),
  ListTileOption(label: 'Metal', id: 2),
  ListTileOption(label: 'Jazz', id: 3),
  ListTileOption(label: 'Jazz Standards', id: 4),
  ListTileOption(label: 'Alternative/Indie', id: 5),
  ListTileOption(label: 'Classical', id: 6),
  ListTileOption(label: 'Country', id: 7),
  ListTileOption(label: 'R&B', id: 8),
  ListTileOption(label: 'Hip Hop', id: 9),
  ListTileOption(label: 'Blues', id: 10),
  ListTileOption(label: 'Funk', id: 11),
  ListTileOption(label: 'Soul', id: 12),
  ListTileOption(label: 'Folk', id: 13),
  ListTileOption(label: 'Electronic', id: 14),
  ListTileOption(label: 'Disco', id: 15),
  ListTileOption(label: 'Reggae', id: 16),
  ListTileOption(label: 'Punk', id: 17),
  ListTileOption(label: 'Game Music', id: 18),
  ListTileOption(label: 'Show Tunes', id: 19),
];