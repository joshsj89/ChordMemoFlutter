import 'package:chordmemoflutter/model/types.dart' as custom_types;

/// Which way to spell a key when the choice is a true enharmonic tie
/// (e.g. F♯ vs G♭ major — both need six accidentals).
enum EnharmonicPreference { sharps, flats }

/// Natural pitch class of each letter, indexed C=0 D=1 E=2 F=3 G=4 A=5 B=6.
const List<int> _naturalPitchClasses = [0, 2, 4, 5, 7, 9, 11];
const List<String> _letterNames = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];

/// A spelled note: a letter (0-6 for C..B) plus a chromatic alteration in
/// semitones (negative = flats, positive = sharps). This keeps `F♯` and `G♭`
/// distinct, which is the whole point of a chord speller.
class Note {
  const Note(this.letter, this.alter);

  /// 0-6 for C, D, E, F, G, A, B.
  final int letter;

  /// Semitone alteration: -2 (double flat) .. +2 (double sharp).
  final int alter;

  int get pitchClass => (_naturalPitchClasses[letter] + alter) % 12;

  /// Number of sharps/flats in the name (0 natural, 1 single, 2 double).
  int get accidentalWeight => alter.abs();

  /// True for the enharmonic spellings musicians treat as awkward: C♭, F♭,
  /// E♯, B♯ and anything with a double accidental.
  bool get isAwkward {
    if (alter.abs() >= 2) return true;
    if (alter == -1 && (letter == 0 || letter == 3)) return true; // C♭, F♭
    if (alter == 1 && (letter == 2 || letter == 6)) return true; // E♯, B♯
    return false;
  }

  Note copyWith({int? letter, int? alter}) =>
      Note(letter ?? this.letter, alter ?? this.alter);

  /// Raise or lower the note without changing its letter (♯II keeps the II
  /// letter, it does not become a III).
  Note alteredBy(int semitones) => Note(letter, alter + semitones);

  @override
  String toString() {
    final glyph = switch (alter) {
      <= -2 => '♭♭',
      -1 => '♭',
      0 => '',
      1 => '♯',
      _ => '♯♯',
    };
    return '${_letterNames[letter]}$glyph';
  }

  @override
  bool operator ==(Object other) =>
      other is Note && other.letter == letter && other.alter == alter;

  @override
  int get hashCode => Object.hash(letter, alter);
}

/// Semitone offsets (from the tonic) of the seven scale degrees for each mode
/// offered in the app. Pentatonic modes borrow their parent seven-note scale
/// so that Roman numerals I..VII always have somewhere to land.
const Map<String, List<int>> modeIntervals = {
  'Major': [0, 2, 4, 5, 7, 9, 11],
  'Minor': [0, 2, 3, 5, 7, 8, 10],
  'Harmonic Minor': [0, 2, 3, 5, 7, 8, 11],
  'Melodic Minor': [0, 2, 3, 5, 7, 9, 11],
  'Phrygian': [0, 1, 3, 5, 7, 8, 10],
  'Lydian': [0, 2, 4, 6, 7, 9, 11],
  'Mixolydian': [0, 2, 4, 5, 7, 9, 10],
  'Dorian': [0, 2, 3, 5, 7, 9, 10],
  'Locrian': [0, 1, 3, 5, 6, 8, 10],
  'Minor Pentatonic': [0, 2, 3, 5, 7, 8, 10], // parent: natural minor
  'Major Pentatonic': [0, 2, 4, 5, 7, 9, 11], // parent: major
  'Lydian Dominant': [0, 2, 4, 6, 7, 9, 10],
  'Phrygian Dominant': [0, 1, 4, 5, 7, 8, 10],
};

List<int> _intervalsFor(String mode) => modeIntervals[mode] ?? modeIntervals['Major']!;

/// Semitone size of the intervals used by `K±` key-change tokens.
const Map<String, int> keyChangeIntervalSemitones = {
  'm2': 1,
  'M2': 2,
  'm3': 3,
  'M3': 4,
  'P4': 5,
  'TT': 6,
  'P5': 7,
  'm6': 8,
  'M6': 9,
  'm7': 10,
  'M7': 11,
};

int _normalizeAlter(int diff) {
  var d = diff % 12;
  if (d > 6) d -= 12;
  if (d < -6) d += 12;
  return d;
}

/// The note `steps` letter-steps above [from] whose pitch class is
/// [targetPitchClass], spelled by adjusting only the accidental.
Note spellFromLetter(Note from, int steps, int targetPitchClass) {
  final letter = (from.letter + steps) % 7;
  final alter = _normalizeAlter(targetPitchClass - _naturalPitchClasses[letter]);
  return Note(letter, alter);
}

/// The seven diatonic notes of [tonic] [mode], spelled on consecutive letters.
List<Note> scaleNotes(Note tonic, String mode) {
  final intervals = _intervalsFor(mode);
  return [
    for (var degree = 0; degree < 7; degree++)
      spellFromLetter(tonic, degree, (tonic.pitchClass + intervals[degree]) % 12),
  ];
}

/// The tonic of [key] as a spelled [Note].
Note tonicFromKey(custom_types.Key key) {
  final letter = _letterNames.indexOf(key.tonic);
  final alter = switch (key.symbol) {
    '♯' => 1,
    '♭' => -1,
    _ => 0,
  };
  return Note(letter < 0 ? 0 : letter, alter);
}

/// Whether [key]'s written tonic leans on flats (so a tie-break should keep
/// using flats).
EnharmonicPreference preferenceFromKey(custom_types.Key key) =>
    key.symbol == '♭' ? EnharmonicPreference.flats : EnharmonicPreference.sharps;

/// Pick a spelling for the tonic that is [semitones] above [original], keeping
/// [mode], choosing the name that:
///   1. needs the fewest accidentals across the resulting scale, then
///   2. produces the fewest awkward notes (C♭, E♯, double accidentals), then
///   3. matches [preference] (this only bites on true ties such as F♯/G♭).
/// A [semitones] of 0 returns [original] untouched so the user's own spelling
/// is always respected at concert pitch.
Note transposeTonic(
  Note original,
  String mode,
  int semitones, {
  EnharmonicPreference preference = EnharmonicPreference.sharps,
}) {
  final shift = semitones % 12;
  if (shift == 0) return original;

  final targetPc = (original.pitchClass + shift) % 12;

  // Every pitch class has at least one name spelled with a single accidental
  // or none, so a tonic never needs a double accidental.
  final candidates = <Note>[
    for (var letter = 0; letter < 7; letter++)
      Note(letter, _normalizeAlter(targetPc - _naturalPitchClasses[letter])),
  ].where((note) => note.alter.abs() <= 1).toList();

  int accidentalScore(Note tonic) =>
      scaleNotes(tonic, mode).fold(0, (sum, note) => sum + note.accidentalWeight);
  int awkwardScore(Note tonic) =>
      scaleNotes(tonic, mode).where((note) => note.isAwkward).length;

  candidates.sort((a, b) {
    final byAccidentals = accidentalScore(a).compareTo(accidentalScore(b));
    if (byAccidentals != 0) return byAccidentals;
    final byAwkward = awkwardScore(a).compareTo(awkwardScore(b));
    if (byAwkward != 0) return byAwkward;
    // Tie: honour the sharp/flat preference. sharps -> favour a sharp/natural
    // spelling; flats -> favour a flat/natural spelling.
    final aPref = preference == EnharmonicPreference.sharps
        ? (a.alter >= 0 ? 0 : 1)
        : (a.alter <= 0 ? 0 : 1);
    final bPref = preference == EnharmonicPreference.sharps
        ? (b.alter >= 0 ? 0 : 1)
        : (b.alter <= 0 ? 0 : 1);
    if (aPref != bPref) return aPref.compareTo(bPref);
    return a.accidentalWeight.compareTo(b.accidentalWeight);
  });

  return candidates.isEmpty ? original : candidates.first;
}

/// Whether transposing [key] by [semitones] lands on a pitch with two equally
/// good spellings, i.e. a spot where the ♯/♭ toggle actually changes something.
bool transposedKeyIsAmbiguous(custom_types.Key key, int semitones) {
  if (semitones % 12 == 0) return false;
  final tonic = tonicFromKey(key);
  final sharp = transposeTonic(tonic, key.mode, semitones,
      preference: EnharmonicPreference.sharps);
  final flat = transposeTonic(tonic, key.mode, semitones,
      preference: EnharmonicPreference.flats);
  return sharp != flat;
}
