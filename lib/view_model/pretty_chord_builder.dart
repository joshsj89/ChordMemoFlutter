import 'package:flutter/material.dart';
import 'package:chordmemoflutter/model/parser.dart';
import 'package:chordmemoflutter/model/token.dart';

InlineSpan buildPrettyChordProgression({required String progression, required Color textColor}) {
  final tokens = tokenize(progression);
  final parser = Parser(tokens);
  final ast = parser.parseProgression();

  InlineSpan buildSpan(ASTNode node) {
    if (node is ErrorNode) {
      return TextSpan(
        text: node.error,
        style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
      );
    } else if (node is DashNode) {
      return TextSpan(
        text: ' - ',
        style: TextStyle(color: textColor),
      );
    } else if (node is SpaceNode) {
      return TextSpan(
        text: '',
      );
    } else if (node is RepeatNode) {
      return TextSpan(
        text: '  :${node.count}  ',
        style: TextStyle(color: textColor),
      );
    } else if (node is ProgressionNode) {
      return TextSpan(
        children: node.children.map(buildSpan).toList(),
      );
    } else if (node is SequenceNode) {
      return TextSpan(
        children: node.children.map(buildSpan).toList(),
      );
    } else if (node is ParenthesizedNode) {
      return TextSpan(
        children: [
          TextSpan(text: '(', style: TextStyle(color: textColor)),
          buildSpan(node.sequence),
          TextSpan(text: ')', style: TextStyle(color: textColor)),
        ],
      );
    } else if (node is ChordNode) {
      final roman = node.romanNumeral.numeral;
      final chordType = node.chordType?.chordType ?? '';

      if (node.inversion != null) {
        return WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                roman,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
          
              if (chordType.isNotEmpty)
                Transform.translate(
                  offset: Offset(0, -6),
                  child: Text(
                    chordType,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                    ),
                  ),
                ),

              Text(
                '/${node.inversion!.degree}',
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        );
      } else if (node.slashChord != null) {
        return WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                roman,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),

              if (chordType.isNotEmpty)
                Transform.translate(
                  offset: Offset(0, -6),
                  child: Text(
                    chordType,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                    ),
                  ),
                ),
              
              Text(
                '/${node.slashChord!.chord}',
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      } else {
        return TextSpan(
          children: [
            TextSpan(
              text: roman,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),

            if (chordType.isNotEmpty)
              WidgetSpan(
                alignment: PlaceholderAlignment.top,
                child: Transform.translate(
                  offset: Offset(0, -6),
                  child: Text(
                    chordType,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        );
      }
    }

    // Fallback for other or unknown nodes
    return TextSpan(text: node.token.value, style: TextStyle(color: textColor)); 
  }

  return buildSpan(ast);
}