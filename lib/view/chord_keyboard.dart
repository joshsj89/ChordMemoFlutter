import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chordmemoflutter/model/keyboard_options.dart';
import 'package:chordmemoflutter/model/types.dart';
import 'package:chordmemoflutter/view/chord_type_button.dart';
import 'package:chordmemoflutter/view/roman_numeral_button.dart';
import 'package:chordmemoflutter/view_model/chords.dart';
import 'package:chordmemoflutter/view_model/dark_mode_provider.dart';

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
    widget.onChordComplete(transformChords(chords));
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

  void _handleLeftParenthesisPress() {
    final lastChord = chords.isNotEmpty ? chords[chords.length - 1] : '';
    if (lastChord != '(') { // prevent multiple parentheses or parentheses at beginning
      setState(() {
        chords.add('(');
      });

      widget.onChordComplete(transformChords(chords));
    }
  }

  void _handleRightParenthesisPress() {
    if (chords.isNotEmpty && // prevent right parentheses at beginning
      chords[chords.length - 1] != ')' &&  // prevent multiple right parentheses
      chords[chords.length - 1] != ' ' && // prevent right parentheses after space
      chords[chords.length - 1] != '(') { // prevent right parentheses after left parentheses

      setState(() {
        chords.add(')');
      });

      widget.onChordComplete(transformChords(chords));
    }
  }

  void _handleKeyChangeDownPress() {
    if (chords.isNotEmpty) {
      final lastChord = chords[chords.length - 1];

      if (lastChord == ' ' && chords[chords.length - 2].contains('K')) { // cycle through key changes
        final keyChange = chords[chords.length - 2].split('K–');
        final key = keyChange.length > 1 ? keyChange[1] : 'M7'; // allows switching from key change up to key change down
        final keyIndex = keyChangeTypes['–']!.indexOf('K–$key');
        final newKey = keyChangeTypes['–']![(keyIndex + 1) % keyChangeTypes['–']!.length];

        setState(() {
          chords[chords.length - 2] = newKey;
          chords[chords.length - 1] = ' ';
        });
      } else if (chords[chords.length - 1] == ' ') { // add key change after space
        setState(() {
          chords.addAll(['K–m2', ' ']);
        });
      } else if (chords[chords.length - 1] != '(') { // add key change after chord
        setState(() {
          chords.addAll([' ', 'K–m2', ' ']);
        });
      }

      widget.onChordComplete(transformChords(chords));
    }
  }

  void _handleKeyChangeUpPress() {
    if (chords.isNotEmpty) {
      final lastChord = chords[chords.length - 1];

      if (lastChord == ' ' && chords[chords.length - 2].contains('K')) { // cycle through key changes
        final keyChange = chords[chords.length - 2].split('K+');
        final key = keyChange.length > 1 ? keyChange[1] : 'M7'; // allows switching from key change down to key change up
        final keyIndex = keyChangeTypes['+']!.indexOf('K+$key');
        final newKey = keyChangeTypes['+']![(keyIndex + 1) % keyChangeTypes['+']!.length];

        setState(() {
          chords[chords.length - 2] = newKey;
          chords[chords.length - 1] = ' ';
        });
      } else if (chords[chords.length - 1] == ' ') { // add key change after space
        setState(() {
          chords.addAll(['K+m2', ' ']);
        });
      } else if (chords[chords.length - 1] != '(') { // add key change after chord
        setState(() {
          chords.addAll([' ', 'K+m2', ' ']);
        });
      }

      widget.onChordComplete(transformChords(chords));
    }
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

  void _handleRepeatPress() {
    if (chords.isNotEmpty) {
      final lastChord = chords[chords.length - 1];
      final secondLastChord = chords.length > 1 ? chords[chords.length - 2] : null;

      if (lastChord == ' ' && secondLastChord!.contains(':')) { // increment repeat bar
        final repeatBar = secondLastChord.split(':');
        final repeatCount = int.tryParse(repeatBar[1])! + 1;

        setState(() {
          chords[chords.length - 2] = ':$repeatCount';
          chords[chords.length - 1] = ' ';
        });
      } else if (lastChord == ' ') { // add repeat bar after space
        setState(() {
          chords.addAll([':1', ' ']);
        });
      } else if (lastChord != '(') { // add repeat bar after chord
        setState(() {
          chords.addAll([' ', ':1', ' ']);
        });
      }

      widget.onChordComplete(transformChords(chords));
    }
  }

  void _handleInversionPress() {
    final List<ChordType> inversions = [];

    if (chords.isNotEmpty) {
      final lastChord = chords[chords.length - 1];

      if (lastChord.contains('/')) return; // prevent multiple inversions or inversion on a slash chord
    }

    if (selectedRomanNumeral != null && selectedTriad != null) {
      if (selectedTriad!.label == 'M' || 
        selectedTriad!.label == 'm' || 
        selectedTriad!.label == '°' || 
        selectedTriad!.label == '+') { // '/3' and '/5' inversions

        inversions.add(inversionTypes['/3']!);
        inversions.add(inversionTypes['/5']!);
      } else if (selectedTriad!.label == 'sus4') { // '/4' and '/5' inversions
        inversions.add(inversionTypes['/4']!);
        inversions.add(inversionTypes['/5']!);
      } else if (selectedTriad!.label == 'sus2') { // '/2' and '/5' inversions
        inversions.add(inversionTypes['/2']!);
        inversions.add(inversionTypes['/5']!);
      } else if (selectedTriad!.label == '5') { // '/5' inversion
        inversions.add(inversionTypes['/5']!);
      } else if  (selectedTriad!.label == 'no5') { // '/3' inversion
        inversions.add(inversionTypes['/3']!);
      }

      if (selectedTriad != selectedSeventh) { // seventh chords
        if (selectedSeventh?.label == '6') {
          inversions.add(inversionTypes['/6']!);
        } else {
          inversions.add(inversionTypes['/7']!);
        }
      }

      if (selectedSeventh == selectedNinth && 
        selectedNinth == selectedEleventh &&
        selectedEleventh == selectedThirteenth) {
        
        // do nothing
      } else if (selectedNinth == selectedEleventh &&
        selectedEleventh == selectedThirteenth) { // ninth chords
        
        inversions.add(inversionTypes['/9']!);
      } else if (selectedEleventh == selectedThirteenth) { // eleventh chords
          
        if (selectedEleventh?.label == 'add11') {
          inversions.add(inversionTypes['/11']!);
        } else {
          inversions.add(inversionTypes['/9']!);
          inversions.add(inversionTypes['/11']!);
        }
      } else if (selectedThirteenth != null) { // thirteenth chords
          
        if (selectedThirteenth!.label == 'add13') {
          inversions.add(inversionTypes['/13']!);
        } else {
          inversions.add(inversionTypes['/9']!);
          inversions.add(inversionTypes['/11']!);
          inversions.add(inversionTypes['/13']!);
        }
      }
    }

    setState(() {
      allInversions = inversions;
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

        widget.onChordComplete(transformChords(chords));
      }
    });
  }

  void _handleErasePress() {
    if (chords.isEmpty) return;
    
    if (chords[chords.length - 1] == ' ' && chords[chords.length - 2].contains(':')) { // erase repeat bar and spaces around it
      setState(() {
        chords.removeRange(chords.length - 3, chords.length); // remove last 3 elements
      });
    } else if (chords[chords.length - 1] == ' ' && chords[chords.length - 2].contains('K')) { // erase key change and space
      setState(() {
        chords.removeRange(chords.length - 3, chords.length); // remove last 3 elements
      });
    } else { // erase last character
      setState(() {
        chords.removeLast();
      });
    }

    widget.onChordComplete(transformChords(chords));
  }

  void _handleSpacePress() {
    if (chords.isNotEmpty && chords[chords.length - 1] != ' ' && chords[chords.length - 1] != '(') { // prevent multiple spaces or space at beginning
      setState(() {
        chords.add(' ');
      });

      widget.onChordComplete(transformChords(chords));
    }
  }

  void _handleChordComplete() {
    String completeChord = '';

    if (selectedRomanNumeral != null && selectedTriad != null) {
      if (selectedTriad == selectedSeventh && 
        selectedSeventh == selectedNinth && 
        selectedNinth == selectedEleventh && 
        selectedEleventh == selectedThirteenth) { // triads

        if (selectedTriad!.label == 'm' || selectedTriad!.label == '°') {
          completeChord = selectedRomanNumeral!.toLowerCase() + selectedTriad!.value;
        } else {
          completeChord = selectedRomanNumeral! + selectedTriad!.value;
        }
      } else if (selectedSeventh == selectedNinth && 
        selectedNinth == selectedEleventh &&
        selectedEleventh == selectedThirteenth) { // seventh chords
        
        if (selectedTriad!.label == 'm' || selectedTriad!.label == '°') {
          completeChord = selectedRomanNumeral!.toLowerCase() + selectedSeventh!.value;
        } else {
          completeChord = selectedRomanNumeral! + selectedSeventh!.value;
        }
      } else if (selectedNinth == selectedEleventh && 
        selectedEleventh == selectedThirteenth) { // ninth chords
        
        if (selectedTriad!.label == 'm' || selectedTriad!.label == '°') {
          completeChord = selectedRomanNumeral!.toLowerCase() + selectedNinth!.value;
        } else {
          completeChord = selectedRomanNumeral! + selectedNinth!.value;
        }
      } else if (selectedEleventh == selectedThirteenth) { // eleventh chords
              
        if (selectedTriad!.label == 'm' || selectedTriad!.label == '°') {
          completeChord = selectedRomanNumeral!.toLowerCase() + selectedEleventh!.value;
        } else {
          completeChord = selectedRomanNumeral! + selectedEleventh!.value;
        }
      } else if (selectedThirteenth != null) { // thirteenth chords
          
        if (selectedTriad!.label == 'm' || selectedTriad!.label == '°') {
          completeChord = selectedRomanNumeral!.toLowerCase() + selectedThirteenth!.value;
        } else {
          completeChord = selectedRomanNumeral! + selectedThirteenth!.value;
        }
      }

      if (flat) {
        completeChord = '♭$completeChord';
      } else if (sharp) {
        completeChord = '♯$completeChord';
      }

      if (selectedInversion != null) { // add inversion
        completeChord += selectedInversion!.value;
      }

      if (chords.isNotEmpty) { // add chord right after slash
        final lastChord = chords[chords.length - 1];
        if (lastChord[lastChord.length - 1] == '/') {
          completeChord = lastChord + completeChord;
          setState(() {
            chords.removeLast();
          });
        }
      }

      setState(() {
        chords.add(completeChord);

        flat = false;
        sharp = false;

        selectedRomanNumeral = null;
        selectedTriad = null;
        selectedSeventh = null;
        selectedNinth = null;
        selectedEleventh = null;
        selectedThirteenth = null;
        allInversions = null;
        selectedInversion = null;
      });

      widget.onChordComplete(transformChords(chords));
    }
  }

  @override
  void didUpdateWidget(covariant ChordKeyboard oldWidget) {
    super.didUpdateWidget(oldWidget);

    final transformedChords = transformChords(chords);

    widget.onChordComplete(transformedChords);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;

    final backgroundColor = isDarkMode ? Color(0xff0a0a0a) : Color(0xffe6e6e6);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final toolbarButtonStyle = ButtonStyle(
      backgroundColor: WidgetStatePropertyAll<Color>(isDarkMode ? Color(0xff505050) : Color(0xffeaeaea)),
      foregroundColor: WidgetStatePropertyAll<Color>(textColor),
      iconColor: WidgetStatePropertyAll<Color>(textColor),
      overlayColor: WidgetStatePropertyAll<Color>(Color(0xff009788)),
      shape: WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))
      ),
    );
    final toolbarOnButtonStyle = ButtonStyle(
      backgroundColor: WidgetStatePropertyAll<Color>(Color(0xff009788)),
      foregroundColor: WidgetStatePropertyAll<Color>(Colors.white),
      iconColor: WidgetStatePropertyAll<Color>(Colors.white),
      shape: WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))
      ),
    );

    return Stack(
      children: [
        Container(
          height: 300,
          color: backgroundColor,
          child: Column(
            children: [
              Container(
                color: isDarkMode ? Color(0xff262626) : Color(0xfff6f6f6),
                child: LayoutBuilder(
                  builder:(context, constraints) {
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
                                style: flat ? toolbarOnButtonStyle : toolbarButtonStyle,
                                onPressed: _handleFlatPress,
                                child: Text('♭'),
                              ),
                            ),
                            SizedBox(
                              width: 33,
                              child: TextButton(
                                style: sharp ? toolbarOnButtonStyle : toolbarButtonStyle,
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
                                onPressed: _handleLeftParenthesisPress,
                                child: Text('('),
                              ),
                            ),
                            SizedBox(
                              width: 33,
                              child: TextButton(
                                style: toolbarButtonStyle,
                                onPressed: _handleRightParenthesisPress,
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
                                onPressed: _handleKeyChangeDownPress,
                                child: Icon(Icons.arrow_downward),
                              ),
                            ),
                            SizedBox(
                              width: 33,
                              child: TextButton(
                                style: toolbarButtonStyle,
                                onPressed: _handleKeyChangeUpPress,
                                child: Icon(Icons.arrow_upward),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 33,
                          child: TextButton(
                            style: toolbarButtonStyle,
                            onPressed: _handleRepeatPress,
                            child: Text(':|'),
                          ),
                        ),
                        SizedBox(
                          width: 48,
                          child: TextButton(
                            style: toolbarButtonStyle,
                            onPressed: _handleInversionPress,
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
              SizedBox(
                height: 250,
                width: double.infinity, // Fill the width of the parent and start from the left
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 60,
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
                        SizedBox(
                          width: 60,
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
                        SizedBox(
                          width: 60,
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
                        SizedBox(
                          width: 60,
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
                        SizedBox(
                          width: 60,
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
                        SizedBox(
                          width: 70,
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
                        SizedBox(
                          width: 60,
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
              ),
            ],
          ),
        ),

        Positioned(
          bottom: 16,
          right: 16,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 5,
            children: [
              FloatingActionButton(
                onPressed: _handleErasePress,
                backgroundColor: Color(0xff009788),
                child: Text('DEL'),
              ),
              SizedBox(height: 10),
              FloatingActionButton(
                onPressed: _handleSpacePress,
                backgroundColor: Color(0xff009788),
                child: Text('SPACE'),
              ),
              SizedBox(height: 10),
              FloatingActionButton(
                onPressed: _handleChordComplete,
                backgroundColor: Color(0xff009788),
                child: Icon(Icons.arrow_right_alt),
              ),
            ],
          ),
        ),
      ],
    );
  }
}