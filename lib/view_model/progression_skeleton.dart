import 'package:chordmemoflutter/model/keyboard_options.dart';
import 'package:chordmemoflutter/model/parser.dart';
import 'package:chordmemoflutter/model/token.dart';
import 'package:chordmemoflutter/view_model/progression_validator.dart';

/// Turns a stored Roman-numeral progression into a canonical "skeleton" that
/// keeps the harmonic movement but drops added-note chord extensions, so the
/// "Ignore chord extensions" search mode can group progressions that differ
/// only by 7ths / 9ths / 11ths / 13ths / added tones.
///
/// The skeleton preserves structure (dashes, phrase gaps, parentheses, `:N`
/// repeats, `K±interval` key changes), Roman-numeral case (major vs minor),
/// accidentals (normalised `#` → `♯`), the triad-quality tokens that actually
/// change the chord (`° + sus2 sus4 5 no5`), and inversions / slash chords.

// ---------------------------------------------------------------------------
// Chord-type reduction
// ---------------------------------------------------------------------------

/// Base triad token for each triad `alt`. `M`/`m` carry no token because
/// major vs minor is expressed by Roman-numeral case.
Map<String, String> _buildAltToBaseTriad() {
  final map = <String, String>{};
  for (final t in triadTypes) {
    map[t.alt] = (t.alt == 'M' || t.alt == 'm') ? '' : t.value;
  }
  return map;
}

/// `chordType` value string → base triad token. Built once from the same
/// hand-authored tables the tokenizer is generated from.
Map<String, String> _buildValueToBaseTriad() {
  final altToBase = _buildAltToBaseTriad();
  final valueToBase = <String, String>{};

  // Triad quality tokens map to themselves ('' values are skipped).
  for (final t in triadTypes) {
    if (t.value.isNotEmpty) valueToBase.putIfAbsent(t.value, () => t.value);
  }

  // Walk the extended tables outward. Each map is keyed by its parent entry's
  // `alt`; processing them in this order guarantees every parent key is already
  // resolved in `altToBase` by the time we need it.
  for (final table in [
    seventhTypes,
    ninthTypes,
    eleventhTypes,
    thirteenthTypes,
  ]) {
    table.forEach((parentAlt, entries) {
      final base = altToBase[parentAlt];
      if (base == null) return; // unreachable for the shipped tables
      for (final entry in entries) {
        // Chain resolution for deeper tables that key off this entry's `alt`.
        altToBase.putIfAbsent(entry.alt, () => base);
        // Reduction must come from the PARENT key, not `entry.alt`: the
        // `(addN)` rows reuse `alt: 'add9'` across the M/m/°/+/sus4/sus2/5
        // parents while keeping distinct `value`s.
        valueToBase.putIfAbsent(entry.value, () => base);
      }
    });
  }

  return valueToBase;
}

final Map<String, String> _valueToBaseTriad = _buildValueToBaseTriad();

/// Reduce a parser `chordType` value (e.g. `7`, `M7`, `ø7`, `sus4(add9)`, `5`)
/// to its base triad token: `''` (plain major/minor) or one of
/// `° + sus2 sus4 5 no5`.
///
/// A `null` or empty value yields `''`. A value that appears in none of the
/// chord-type tables is returned unchanged, so an unrecognised quality stays
/// visible in the skeleton rather than silently widening the match.
///
/// Note: the tables classify `dom7♭5` (value `7♭5`) as major-derived, so
/// `7♭5 → ''`, while `M7♭5 → °` and `M7♯5 → +`.
String reduceChordTypeToTriad(String? value) {
  if (value == null || value.isEmpty) return '';
  return _valueToBaseTriad[value] ?? value;
}

// ---------------------------------------------------------------------------
// Skeletonisation
// ---------------------------------------------------------------------------

/// Canonical skeleton of [progression], or `null` if it does not parse cleanly.
/// Empty / whitespace-only input yields `''`.
String? skeletonizeProgression(String progression) {
  final trimmed = progression.trim();
  if (trimmed.isEmpty) return '';
  if (validateProgression(trimmed) != null) return null;

  final buf = StringBuffer();

  void visit(ASTNode node) {
    if (node is ProgressionNode) {
      for (var i = 0; i < node.children.length; i++) {
        final child = node.children[i];
        visit(child);
        if (i < node.children.length - 1 &&
            child is SequenceNode &&
            node.children[i + 1] is SequenceNode) {
          buf.write(' '); // phrase gap
        }
      }
    } else if (node is SequenceNode) {
      for (final child in node.children) {
        visit(child);
      }
    } else if (node is ParenthesizedNode) {
      buf.write('(');
      visit(node.sequence);
      buf.write(')');
    } else if (node is DashNode) {
      buf.write('-');
    } else if (node is RepeatNode) {
      buf.write(' :${node.count} ');
    } else if (node is KeyChangeNode) {
      buf.write(' K${node.direction}${node.interval} ');
    } else if (node is ChordNode) {
      buf.write(_skeletonChord(node));
    }
    // ErrorNode is unreachable — validateProgression rejected it above.
  }

  visit(Parser.parse(trimmed));
  return buf.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
}

String _skeletonChord(ChordNode node) {
  final accidental = (node.accidental?.accidental ?? '').replaceAll('#', '♯');
  final roman = node.romanNumeral.numeral;
  final quality = reduceChordTypeToTriad(node.chordType?.chordType);

  final String tail;
  if (node.inversion != null) {
    tail = '/${node.inversion!.degree}';
  } else if (node.slashChord != null) {
    tail = '/${_skeletonSlashChord(node.slashChord!.chord)}';
  } else {
    tail = '';
  }

  return '$accidental$roman$quality$tail';
}

/// A slash chord's `/Y` target (`VI`, `VI7`, `♭III`, `iiø7`, …) reduced the same
/// way as a normal chord, so `/VI7 → /VI`.
String _skeletonSlashChord(String chord) {
  final chordNode = _firstChordNode(Parser.parse(chord));
  if (chordNode == null) return chord.replaceAll('#', '♯');
  return _skeletonChord(chordNode);
}

ChordNode? _firstChordNode(ASTNode node) {
  if (node is ChordNode) return node;
  if (node is ProgressionNode) {
    for (final child in node.children) {
      final found = _firstChordNode(child);
      if (found != null) return found;
    }
  } else if (node is SequenceNode) {
    for (final child in node.children) {
      final found = _firstChordNode(child);
      if (found != null) return found;
    }
  } else if (node is ParenthesizedNode) {
    return _firstChordNode(node.sequence);
  }
  return null;
}

// ---------------------------------------------------------------------------
// Matching
// ---------------------------------------------------------------------------

/// True if [querySkeleton] occurs as a consecutive dash-run inside
/// [sectionSkeleton]. Both arguments must already be skeletonised. Mirrors the
/// whole-word technique of the literal Chords search so behaviour matches.
bool skeletonContainsRun(String sectionSkeleton, String querySkeleton) {
  final words = querySkeleton.split(RegExp(r'-+'));
  final pattern = r'(?<!\w)' +
      words.map((word) => '(${_escapeRegExp(word.trim())})').join(r'-') +
      r'(?!\w)';
  return RegExp(pattern).hasMatch(sectionSkeleton);
}

String _escapeRegExp(String string) => string.replaceAllMapped(
      RegExp(r'[.*+?^${}()|[\]\\]'),
      (match) => '\\${match[0]}',
    );
