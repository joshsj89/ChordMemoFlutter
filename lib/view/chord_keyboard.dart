import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'chord_type_button.dart';
import '../view_model/dark_mode_provider.dart';
import '../model/keyboard_options.dart';
import 'roman_numeral_button.dart';
import '../model/types.dart';

class ChordKeyboard extends StatefulWidget {
  final List<String> originalChords;
  final Function(String) onChordComplete;

  const ChordKeyboard({
    super.key,
    required this.originalChords,
    required this.onChordComplete,
  });

  @override
  State<ChordKeyboard> createState() => _ChordKeyboardState();
}

class _ChordKeyboardState extends State<ChordKeyboard> {
  late List<String> chords;

  bool flat = false;
  bool sharp = false;

  String? selectedRomanNumeral;
  ChordType? selectedTriad;
  ChordType? selectedSeventh;
  ChordType? selectedNinth;
  ChordType? selectedEleventh;
  ChordType? selectedThirteenth;
  List<ChordType>? allInversions;
  ChordType? selectedInversion;

  @override
  void initState() {
    super.initState();

    chords = List.from(widget.originalChords);
  }

  void _handleRomanNumeralPress(String numeral) {
    setState(() {
      selectedRomanNumeral = numeral;
      selectedTriad = null;
      selectedSeventh = null;
      selectedNinth = null;
      selectedEleventh = null;
      selectedThirteenth = null;
      allInversions = null;
      selectedInversion = null;
    });
  }

  void _handleTriadPress(ChordType triad) {
    setState(() {
      selectedTriad = triad;
      selectedSeventh = triad;
      selectedNinth = triad;
      selectedEleventh = triad;
      selectedThirteenth = triad;
      allInversions = null;
      selectedInversion = null;
    });
  }

  void _handleSeventhPress(ChordType seventh) {
    setState(() {
      selectedSeventh = seventh;
      selectedNinth = seventh;
      selectedEleventh = seventh;
      selectedThirteenth = seventh;
      allInversions = null;
      selectedInversion = null;
    });
  }

  void _handleNinthPress(ChordType ninth) {
    setState(() {
      selectedNinth = ninth;
      selectedEleventh = ninth;
      selectedThirteenth = ninth;
      allInversions = null;
      selectedInversion = null;
    });
  }

  void _handleEleventhPress(ChordType eleventh) {
    setState(() {
      selectedEleventh = eleventh;
      selectedThirteenth = eleventh;
      allInversions = null;
      selectedInversion = null;
    });
  }

  void _handleThirteenthPress(ChordType thirteenth) {
    setState(() {
      selectedThirteenth = thirteenth;
      allInversions = null;
      selectedInversion = null;
    });
  }

  void _handleFlatPress() {
    setState(() {
      flat = !flat;
      sharp = false;
    });
  }

  void _handleSharpPress() {
    setState(() {
      sharp = !sharp;
      flat = false;
    });
  }

  void _handleInversionSelect(ChordType inversion) {
    setState(() {
      selectedInversion = inversion;
    });
  }

  void _handleSlashPress() {
    setState(() {
      if (chords.isNotEmpty) {
        final lastChord = chords[chords.length - 1];

        if (lastChord != ' ' && lastChord != '(' && lastChord != ')' && !lastChord.contains('/')) {
          chords[chords.length - 1] = '$lastChord/';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;

    final backgroundColor = isDarkMode ? Color(0xff0a0a0a) : Color(0xffe6e6e6);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final altTextColor = isDarkMode ? Colors.black : Colors.white;
    final toolbarButtonStyle = ButtonStyle(
      backgroundColor: WidgetStatePropertyAll<Color>(isDarkMode ? Color(0xff505050) : Color(0xffeaeaea)),
      shape: WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))
      ),
    );

    return Container(
      height: 300,
      color: backgroundColor,
      child: Column(
        children: [
          Container(
            color: isDarkMode ? Color(0xff262626) : Color(0xfff6f6f6),
            child: LayoutBuilder(
              builder:(context, constraints) {
                final buttonWidth = constraints.maxWidth / 9; // 9 buttons in the row

                return Row(
                  spacing: 7,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      spacing: 3,
                      children: [
                        SizedBox(
                          width: 33,
                          child: TextButton(
                            style: toolbarButtonStyle,
                            onPressed: _handleFlatPress,
                            child: Text('♭'),
                          ),
                        ),
                        SizedBox(
                          width: 33,
                          child: TextButton(
                            style: toolbarButtonStyle,
                            onPressed: _handleSharpPress,
                            child: Text('♯'),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      spacing: 3,
                      children: [
                        SizedBox(
                          width: 33,
                          child: TextButton(
                            style: toolbarButtonStyle,
                            onPressed: () {},
                            child: Text('('),
                          ),
                        ),
                        SizedBox(
                          width: 33,
                          child: TextButton(
                            style: toolbarButtonStyle,
                            onPressed: () {},
                            child: Text(')'),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      spacing: 3,
                      children: [
                        SizedBox(
                          width: 33,
                          child: TextButton(
                            style: toolbarButtonStyle,
                            onPressed: () {},
                            child: Icon(Icons.arrow_downward),
                          ),
                        ),
                        SizedBox(
                          width: 33,
                          child: TextButton(
                            style: toolbarButtonStyle,
                            onPressed: () {},
                            child: Icon(Icons.arrow_upward),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 33,
                      child: TextButton(
                        style: toolbarButtonStyle,
                        onPressed: () {},
                        child: Text(':|'),
                      ),
                    ),
                    SizedBox(
                      width: 48,
                      child: TextButton(
                        style: toolbarButtonStyle,
                        onPressed: () {},
                        child: Text('INV'),
                      ),
                    ),
                    SizedBox(
                      width: 33,
                      child: TextButton(
                        style: toolbarButtonStyle,
                        onPressed: _handleSlashPress,
                        child: Text('/'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: romanNumerals.length,
                    itemBuilder: (context, index) {
                      String numeral = romanNumerals[index];
                      return RomanNumeralButton(
                        numeral: numeral,
                        selected: selectedRomanNumeral == numeral,
                        onPressed:_handleRomanNumeralPress,
                      );
                    },
                    padding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
                // Triad types
                if (selectedRomanNumeral != null)
                  Expanded(
                    child: ListView.builder(
                      itemCount: triadTypes.length,
                      itemBuilder: (context, index) {
                        ChordType triad = triadTypes[index];
                        return ChordTypeButton(
                          chordType: triad,
                          selected: selectedTriad == triad,
                          onPressed: _handleTriadPress,
                        );
                      },
                      padding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
      
                // Seventh types
                if (selectedTriad != null && seventhTypes[selectedTriad!.alt] != null)
                  Expanded(
                    child: ListView.builder(
                      itemCount: seventhTypes[selectedTriad!.alt]!.length,
                      itemBuilder: (context, index) {
                        ChordType seventh = seventhTypes[selectedTriad!.alt]![index];
                        return ChordTypeButton(
                          chordType: seventh,
                          selected: selectedSeventh == seventh,
                          onPressed: _handleSeventhPress,
                        );
                      },
                      padding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                
                // Ninth types
                if (selectedSeventh != null && ninthTypes[selectedSeventh!.alt] != null)
                  Expanded(
                    child: ListView.builder(
                      itemCount: ninthTypes[selectedSeventh!.alt]!.length,
                      itemBuilder: (context, index) {
                        ChordType ninth = ninthTypes[selectedSeventh!.alt]![index];
                        return ChordTypeButton(
                          chordType: ninth,
                          selected: selectedNinth == ninth,
                          onPressed: _handleNinthPress,
                        );
                      },
                      padding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
      
                // Eleventh types
                if (selectedNinth != null && eleventhTypes[selectedNinth!.alt] != null)
                  Expanded(
                    child: ListView.builder(
                      itemCount: eleventhTypes[selectedNinth!.alt]!.length,
                      itemBuilder: (context, index) {
                        ChordType eleventh = eleventhTypes[selectedNinth!.alt]![index];
                        return ChordTypeButton(
                          chordType: eleventh,
                          selected: selectedEleventh == eleventh,
                          onPressed: _handleEleventhPress,
                        );
                      },
                      padding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
      
                // Thirteenth types
                if (selectedEleventh != null && thirteenthTypes[selectedEleventh!.alt] != null)
                  Expanded(
                    child: ListView.builder(
                      itemCount: thirteenthTypes[selectedEleventh!.alt]!.length,
                      itemBuilder: (context, index) {
                        ChordType thirteenth = thirteenthTypes[selectedEleventh!.alt]![index];
                        return ChordTypeButton(
                          chordType: thirteenth,
                          selected: selectedThirteenth == thirteenth,
                          onPressed: _handleThirteenthPress,
                        );
                      },
                      padding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
      
                // Inversions
                if (allInversions != null)
                  Expanded(
                    child: ListView.builder(
                      itemCount: allInversions!.length,
                      itemBuilder: (context, index) {
                        ChordType inversion = allInversions![index];
                        return ChordTypeButton(
                          chordType: inversion,
                          selected: selectedInversion == inversion,
                          onPressed: _handleInversionSelect,
                        );
                      },
                      padding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}