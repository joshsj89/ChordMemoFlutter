import 'package:chordmemoflutter/model/music_theory.dart';
import 'package:chordmemoflutter/model/token.dart';

/// A Roman-numeral chord resolved to concrete notes for a particular key:
/// a spelled [root], a display [quality] suffix (`m7`, `maj7`, `°7`, `sus4`…)
/// and an optional [bass] set only for inversions (`X/3`, `X/5`, `X/7`).
/// A `X/Y` slash chord where `Y` is a Roman numeral is an applied chord and is
/// resolved into [root]/[quality], with no [bass].
class ChordSymbol {
  const ChordSymbol({required this.root, required this.quality, this.bass});

  final Note root;
  final String quality;
  final Note? bass;

  int get rootPitchClass => root.pitchClass;

  /// The root and quality without any slash-bass, e.g. `Dm7`.
  String get body => '$root$quality';

  @override
  String toString() =>
      (bass != null && bass != root) ? '$body/$bass' : body;
}

const Map<String, int> _degreeByNumeral = {
  'i': 1,
  'ii': 2,
  'iii': 3,
  'iv': 4,
  'v': 5,
  'vi': 6,
  'vii': 7,
};

final RegExp _slashChordPattern =
    RegExp(r'^([♯#♭]?)(iii|III|ii|II|iv|IV|vii|VII|vi|VI|[iIvV])');

/// Resolve a parsed [ChordNode] against [keyTonic] / [mode].
ChordSymbol spellChord(
  ChordNode node, {
  required Note keyTonic,
  required String mode,
}) {
  final numeral = node.romanNumeral.numeral;
  final degree = _degreeByNumeral[numeral.toLowerCase()] ?? 1;
  final isLower = numeral == numeral.toLowerCase();

  // A slash chord `X/Y` (Y a Roman numeral) is an applied / "secondary" chord:
  // X is spelled in the key that Y tonicizes, not against a bass note.
  var effTonic = keyTonic;
  var effMode = mode;
  final applied = node.slashChord != null
      ? _appliedKey(node.slashChord!.chord, keyTonic, mode)
      : null;
  if (applied != null) {
    effTonic = applied.$1;
    effMode = applied.$2;
  }

  var root = scaleNotes(effTonic, effMode)[degree - 1];
  root = _applyAccidental(root, node.accidental?.accidental);

  final quality = chordQuality(isLower, node.chordType?.chordType ?? '');

  // Only inversions produce a bass note; the grammar makes inversion and
  // slash-chord mutually exclusive, so an applied chord never has one.
  final bass = node.inversion != null
      ? _inversionBass(root, quality, node.inversion!.degree)
      : null;

  return ChordSymbol(root: root, quality: quality, bass: bass);
}

Note _applyAccidental(Note note, String? accidental) {
  switch (accidental) {
    case '♯':
    case '#':
      return note.alteredBy(1);
    case '♭':
      return note.alteredBy(-1);
    default:
      return note;
  }
}

/// Turn the app's chord-type value string into a lead-sheet quality suffix,
/// taking the Roman numeral's case into account for the underlying triad.
String chordQuality(bool isLowerNumeral, String value) {
  if (value.isEmpty) return isLowerNumeral ? 'm' : '';

  var core = value;
  var addPart = '';
  final add = RegExp(r'\((add\d+)\)$').firstMatch(value);
  if (add != null) {
    addPart = '(${add.group(1)})';
    core = value.substring(0, add.start);
  }

  String quality;
  if (core.isEmpty) {
    quality = isLowerNumeral ? 'm' : '';
  } else if (core == '°' || core == '°7') {
    quality = core;
  } else if (core == '+') {
    quality = '+';
  } else if (core == '5' || core == 'no5') {
    quality = core;
  } else if (core.contains('sus')) {
    quality = core; // suspended chords have no third; never add an 'm'
  } else if (core.startsWith('ø')) {
    // ø always implies the 7th (half-diminished 7).
    quality = core.replaceFirst(RegExp(r'^ø7?'), 'm7♭5');
  } else if (core.startsWith('°')) {
    quality = core; // °9♭5 etc.
  } else if (core.startsWith('mM')) {
    quality = 'm(maj${core.substring(2)})';
  } else if (core.startsWith('M')) {
    quality = 'maj${core.substring(1)}';
  } else if (isLowerNumeral && !core.startsWith('m')) {
    quality = 'm$core';
  } else {
    quality = core;
  }

  return quality + addPart;
}

bool _isMinorish(String quality) =>
    quality.startsWith('m') || quality.startsWith('°') || quality.startsWith('ø');

Note _inversionBass(Note root, String quality, String degree) {
  // (letter steps above the root, semitones above the root)
  final ({int steps, int semitones}) target = switch (degree) {
    '3' when quality.contains('sus4') => (steps: 3, semitones: 5),
    '3' when quality.contains('sus2') => (steps: 1, semitones: 2),
    '3' => (steps: 2, semitones: _isMinorish(quality) ? 3 : 4),
    '5' when quality.contains('°') || quality.contains('m7♭5') || quality.contains('7♭5') =>
      (steps: 4, semitones: 6),
    '5' when quality.contains('+') || quality.contains('7♯5') => (steps: 4, semitones: 8),
    '5' => (steps: 4, semitones: 7),
    '7' when quality.contains('maj') => (steps: 6, semitones: 11),
    '7' when quality.contains('°7') => (steps: 6, semitones: 9),
    '7' => (steps: 6, semitones: 10),
    '2' || '9' => (steps: 1, semitones: 2),
    '4' || '11' => (steps: 3, semitones: 5),
    '6' || '13' => (steps: 5, semitones: 9),
    _ => (steps: 0, semitones: 0),
  };

  return spellFromLetter(
    root,
    target.steps,
    (root.pitchClass + target.semitones) % 12,
  );
}

/// The key that a slash chord's `/Y` target tonicizes: the note at Y's scale
/// degree in the current key (with Y's `♯`/`♭` prefix applied), paired with a
/// mode matched to Y's case — uppercase Y → a major key, lowercase → minor.
(Note, String)? _appliedKey(String chord, Note keyTonic, String mode) {
  final match = _slashChordPattern.firstMatch(chord);
  if (match == null) return null;

  final numeral = match.group(2)!;
  final degree = _degreeByNumeral[numeral.toLowerCase()] ?? 1;
  var tonic = scaleNotes(keyTonic, mode)[degree - 1];

  final accidental = match.group(1)!;
  if (accidental.isNotEmpty) tonic = _applyAccidental(tonic, accidental);

  return (tonic, numeral == numeral.toLowerCase() ? 'Minor' : 'Major');
}
