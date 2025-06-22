import '../model/parser.dart';
import '../model/token.dart';

String? validateProgression(String input) {
  final tokens = tokenize(input);

  if (tokens.isEmpty) { // Empty input is allowed
    return null;
  }

  final parser = Parser(tokens);
  final ast = parser.parseProgression();

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