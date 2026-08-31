import 'package:flutter/material.dart';

import 'package:chordmemoflutter/model/music_theory.dart';
import 'package:chordmemoflutter/model/parser.dart';
import 'package:chordmemoflutter/model/token.dart';
import 'package:chordmemoflutter/model/types.dart' as custom_types;
import 'package:chordmemoflutter/view_model/chord_speller.dart';

/// One rendered piece of a concrete-chord progression.
enum ConcretePieceKind { chord, dash, gap, openParen, closeParen, repeat, keyChange, error }

class ConcretePiece {
  const ConcretePiece(this.kind, {this.chord, this.text});

  final ConcretePieceKind kind;
  final ChordSymbol? chord;
  final String? text;
}

/// Walk the progression AST and resolve every chord to concrete notes for
/// [key], shifted by [transpose] semitones. Mid-progression `K±` tokens move
/// the working key on top of the transpose. Pure; the widget layer turns the
/// result into styled spans.
List<ConcretePiece> layoutConcreteProgression({
  required String progression,
  required custom_types.Key key,
  int transpose = 0,
  EnharmonicPreference preference = EnharmonicPreference.sharps,
}) {
  final baseTonic = tonicFromKey(key);
  final mode = key.mode;
  var offset = transpose;

  Note currentTonic() =>
      transposeTonic(baseTonic, mode, offset, preference: preference);

  final pieces = <ConcretePiece>[];

  void visit(ASTNode node) {
    if (node is ProgressionNode) {
      for (var i = 0; i < node.children.length; i++) {
        final child = node.children[i];
        visit(child);
        if (i < node.children.length - 1 &&
            child is SequenceNode &&
            node.children[i + 1] is SequenceNode) {
          pieces.add(const ConcretePiece(ConcretePieceKind.gap));
        }
      }
    } else if (node is SequenceNode) {
      for (final child in node.children) {
        visit(child);
      }
    } else if (node is ParenthesizedNode) {
      pieces.add(const ConcretePiece(ConcretePieceKind.openParen));
      visit(node.sequence);
      pieces.add(const ConcretePiece(ConcretePieceKind.closeParen));
    } else if (node is DashNode) {
      pieces.add(const ConcretePiece(ConcretePieceKind.dash));
    } else if (node is RepeatNode) {
      pieces.add(ConcretePiece(ConcretePieceKind.repeat, text: 'x${node.count}'));
    } else if (node is KeyChangeNode) {
      final magnitude = keyChangeIntervalSemitones[node.interval] ?? 0;
      offset += node.direction == '+' ? magnitude : -magnitude;
      pieces.add(ConcretePiece(
        ConcretePieceKind.keyChange,
        text: '→ ${currentTonic()} $mode',
      ));
    } else if (node is ChordNode) {
      pieces.add(ConcretePiece(
        ConcretePieceKind.chord,
        chord: spellChord(node, keyTonic: currentTonic(), mode: mode),
      ));
    } else if (node is ErrorNode) {
      pieces.add(ConcretePiece(ConcretePieceKind.error, text: node.error));
    }
  }

  visit(Parser.parse(progression));
  return pieces;
}

/// The concrete chord bodies in order (slash bass included), ignoring layout.
/// Handy for tests and quick inspection.
List<String> concreteChordStrings({
  required String progression,
  required custom_types.Key key,
  int transpose = 0,
  EnharmonicPreference preference = EnharmonicPreference.sharps,
}) {
  return [
    for (final piece in layoutConcreteProgression(
      progression: progression,
      key: key,
      transpose: transpose,
      preference: preference,
    ))
      if (piece.kind == ConcretePieceKind.chord) piece.chord!.toString(),
  ];
}

/// Styled span for the song-details view: bold root, small raised quality,
/// bold slash bass — matching the look of [buildPrettyChordProgression].
InlineSpan buildConcreteChordProgression({
  required String progression,
  required custom_types.Key key,
  required Color textColor,
  int transpose = 0,
  EnharmonicPreference preference = EnharmonicPreference.sharps,
}) {
  final pieces = layoutConcreteProgression(
    progression: progression,
    key: key,
    transpose: transpose,
    preference: preference,
  );

  final spans = <InlineSpan>[];

  for (final piece in pieces) {
    switch (piece.kind) {
      case ConcretePieceKind.chord:
        final chord = piece.chord!;
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                chord.root.toString(),
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (chord.quality.isNotEmpty)
                Transform.translate(
                  offset: const Offset(0, -6),
                  child: Text(
                    chord.quality,
                    style: TextStyle(color: textColor, fontSize: 12),
                  ),
                ),
              if (chord.bass != null && chord.bass != chord.root)
                Text(
                  '/${chord.bass}',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ));
      case ConcretePieceKind.dash:
        spans.add(TextSpan(text: ' - ', style: TextStyle(color: textColor)));
      case ConcretePieceKind.gap:
        spans.add(const TextSpan(text: '  '));
      case ConcretePieceKind.openParen:
        spans.add(TextSpan(text: '(', style: TextStyle(color: textColor)));
      case ConcretePieceKind.closeParen:
        spans.add(TextSpan(text: ')', style: TextStyle(color: textColor)));
      case ConcretePieceKind.repeat:
        spans.add(TextSpan(text: '  ${piece.text}  ', style: TextStyle(color: textColor)));
      case ConcretePieceKind.keyChange:
        spans.add(TextSpan(
          text: '  ${piece.text}  ',
          style: TextStyle(color: textColor, fontStyle: FontStyle.italic),
        ));
      case ConcretePieceKind.error:
        spans.add(TextSpan(
          text: piece.text,
          style: const TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
        ));
    }
  }

  return TextSpan(children: spans);
}
