import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chordmemoflutter/view/flexible_width_button.dart';
import'package:chordmemoflutter/view_model/dark_mode_provider.dart';

const List<String> symbols = ['♭', '♯'];

class SymbolPickerModal extends StatefulWidget {
  const SymbolPickerModal({super.key});

  @override
  State<SymbolPickerModal> createState() => _SymbolPickerModalState();
}

class _SymbolPickerModalState extends State<SymbolPickerModal> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;
    final backgroundColor = isDarkMode ? Color(0xff171717) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return AlertDialog(
      title: Text(
        'Select a symbol',
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 20),
        textAlign: TextAlign.center,
      ),
      backgroundColor: backgroundColor,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Add symbol buttons here
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 20,
              children: [
                  ...symbols.map((symbol) => ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, symbol);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode ? Color(0xff333333) : Color(0xffeeeeee),
                    ),
                    child: Text(symbol, style: TextStyle(fontSize: 20, color: isDarkMode ? Colors.white : Colors.black)),
                  )),
              ],
            ),
          ),
          FlexibleWidthButton(
            label: "Close",
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      )
    );
  }
}