import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_model/dark_mode_provider.dart';

class RomanNumeralButton extends StatefulWidget {
  final String numeral;
  final bool selected;
  final void Function(String) onPressed;

  const RomanNumeralButton({
    super.key,
    required this.numeral,
    required this.selected,
    required this.onPressed,
  });

  @override
  State<RomanNumeralButton> createState() => _RomanNumeralButtonState();
}

class _RomanNumeralButtonState extends State<RomanNumeralButton> {
  late String _numeral;
  late bool _selected;
  late void Function(String) _onPressed;

  @override
  void initState() {
    super.initState();

    _numeral = widget.numeral;
    _selected = widget.selected;
    _onPressed = widget.onPressed;
  }

  @override
  void didUpdateWidget(covariant RomanNumeralButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.numeral != widget.numeral) {
      setState(() {
        _numeral = widget.numeral;
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
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      ),
      onPressed: () {
        _onPressed(_numeral);
      },
      child: Text(
        _numeral,
        style: TextStyle(color: textColor, fontSize: 18),
        textAlign: TextAlign.center,
        maxLines: 1,
      ),
    );
  }
}