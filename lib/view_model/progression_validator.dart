import 'package:chordmemoflutter/model/parser.dart';
import 'package:chordmemoflutter/model/token.dart';

String? validateProgression(String input) {
  final ast = Parser.parse(input);

  if (ast is ErrorNode) {
    return ast.error;
  }

  String? findError(ASTNode node) {
    if (node is ErrorNode) return node.error;

    if (node is ProgressionNode || node is SequenceNode) {
      final children = (node as dynamic).children ?? [];
      for (final child in children) {
        final err = findError(child);
        if (err != null) return err;
      }
    } else if (node is ParenthesizedNode) {
      return findError(node.sequence);
    }

    return null;
  }

  final error = findError(ast);
  if (error != null) {
    return error;
  }

  return null; // No errors found
}

/// Decide what to do with [clipboardText] pasted into a chords field.
///
/// On success `chords` is the trimmed text and `error` is null. Otherwise
/// `chords` is null and `error` explains why — an empty clipboard, or the
/// message from [validateProgression] when the text isn't a syntactically
/// valid progression (e.g. pasted from outside the app).
({String? chords, String? error}) resolvePastedProgression(String? clipboardText) {
  final text = (clipboardText ?? '').trim();
  if (text.isEmpty) {
    return (chords: null, error: 'Clipboard has no text to paste.');
  }

  final error = validateProgression(text);
  if (error != null) {
    return (chords: null, error: 'Not a valid chord progression: $error');
  }

  return (chords: text, error: null);
}