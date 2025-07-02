import 'package:flutter/material.dart';
import 'package:chordmemoflutter/model/parser.dart';
import 'package:chordmemoflutter/model/token.dart';

InlineSpan buildPrettyChordProgression({required String progression, required Color textColor}) {
  final ast = Parser.parse(progression);

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
    } else if (node is SpaceNode) { // won't be used because AST doesn't include SpaceNodes
      return TextSpan(
        text: '',
      );
    } else if (node is RepeatNode) {
      return TextSpan(
        text: '  x${node.count}  ',
        style: TextStyle(color: textColor),
      );
    } else if (node is KeyChangeNode) {
      return TextSpan(
        text: '  K${node.direction}${node.interval}  ',
        style: TextStyle(color: textColor),
      );
    } else if (node is ProgressionNode) {
      final children = <InlineSpan>[];

      for (int i = 0; i < node.children.length; i++) {
        final child = node.children[i];
        children.add(buildSpan(child));

        if ( // Add space between sequences
          i < node.children.length - 1 && 
          child is SequenceNode &&
          node.children[i + 1] is SequenceNode
        ) {
          children.add(const TextSpan(text: '  '));
        }
      }
      
      return TextSpan(children: children);
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
      final accidental = node.accidental?.accidental ?? '';
      final roman = node.romanNumeral.numeral;
      final chordType = node.chordType?.chordType ?? '';

      // Compose the chord as a Row so it never splits
      List<Widget> chordWidgets = [
        Text(
          '$accidental$roman',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ];

      if (chordType.isNotEmpty) {
        chordWidgets.add(
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
        );
      }

      if (node.inversion != null) {
        chordWidgets.add(
          Text(
            '/${node.inversion!.degree}',
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      } else if (node.slashChord != null) {
        chordWidgets.add(
          Text(
            '/${node.slashChord!.chord}',
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }

      return WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: chordWidgets,
        ),
      );
    }

    // Fallback for other or unknown nodes
    return TextSpan(text: node.token.value, style: TextStyle(color: textColor)); 
  }

  return buildSpan(ast);
}