import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chordmemoflutter/model/types.dart';
import 'package:chordmemoflutter/view_model/dark_mode_provider.dart';

class ChordTypeButton extends StatefulWidget {
  final ChordType chordType;
  final bool selected;
  final void Function(ChordType) onPressed;

  const ChordTypeButton({
    super.key,
    required this.chordType,
    required this.selected,
    required this.onPressed,
  });

  @override
  State<ChordTypeButton> createState() => ChordTypeButtonState();
}

class ChordTypeButtonState extends State<ChordTypeButton> {
  late ChordType _chordType;
  late bool _selected;
  late void Function(ChordType) _onPressed;

  @override
  void initState() {
    super.initState();

    _chordType = widget.chordType;
    _selected = widget.selected;
    _onPressed = widget.onPressed;
  }

  @override
  void didUpdateWidget(covariant ChordTypeButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.chordType != widget.chordType) {
      setState(() {
        _chordType = widget.chordType;
      });
    }

    if (oldWidget.selected != widget.selected) {
      setState(() {
        _selected = widget.selected;
      });
    }

    if (oldWidget.onPressed != widget.onPressed) {
      setState(() {
        _onPressed = widget.onPressed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;
    final backgroundColor = isDarkMode ? Color(0xff2d2d2d) : Color(0xfffdfdfd);
    final textColor = isDarkMode ? Color(0xfffafafa) : Color(0xff2d2d2d);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _selected ? Color(0xff009788) : backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      onPressed: () {
        _onPressed(_chordType);
      },
      child: Text(
        _chordType.label,
        style: TextStyle(color: textColor, fontSize: 12),
        maxLines: 1,
      ),
    );
  }
}