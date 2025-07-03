import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

import 'package:chordmemoflutter/model/options.dart';
import 'package:chordmemoflutter/model/types.dart' as custom_types;
import 'package:chordmemoflutter/view/autocomplete_dropdown.dart';
import 'package:chordmemoflutter/view/chord_keyboard.dart';
import 'package:chordmemoflutter/view/expandable_tile_wrapper.dart';
import 'package:chordmemoflutter/view/flexible_width_button.dart';
import 'package:chordmemoflutter/view/size_reporting_widget.dart';
import 'package:chordmemoflutter/view_model/chords.dart';
import 'package:chordmemoflutter/view_model/dark_mode_provider.dart';
import 'package:chordmemoflutter/view_model/progression_validator.dart';
import 'package:chordmemoflutter/view_model/song_persistence.dart';

class EditSongScreen extends StatefulWidget {
  final custom_types.Song song;

  const EditSongScreen({super.key, required this.song});

  @override
  State<EditSongScreen> createState() => _EditSongScreenState();
}

class _EditSongScreenState extends State<EditSongScreen> {
  // class-level variables: persist across build calls
  String title = '';
  final TextEditingController titleController = TextEditingController();
  String artist = '';
  final TextEditingController artistController = TextEditingController();
  List<TextEditingController> chordsControllers = []; // hold the controllers for each section (cursor blink state won't be lost)
  List<ListTileOption> genres = [];
  List<ListTileOption> availableGenres = List.from(genreOptions);
  List<custom_types.Section> sections = [];
  List<ListTileOption> sectionTitles = [];
  List<ListTileOption> availableSectionTitles = List.from(sectionTypeOptions);
  List<double> sectionHeights = []; // used to store the heights of each section for the accordion
  List<String> songArtists = [];
  List<String> chordsInputs = []; // hold the chords text temporarily
  List<custom_types.Key> keysInputs = []; // hold the key object temporarily
  List<String?> chordsErrors = []; // hold the chords errors
  custom_types.Key lastSelectedKey = custom_types.Key(tonic: 'C', symbol: '', mode: 'Major');
  late bool isSameKeyForAllSections;
  bool isChordKeyboardVisible = false;
  int? currentKeyboardSectionIndex;

  @override
  void initState() {
    super.initState();

    title = widget.song.title;
    titleController.text = widget.song.title;
    artist = widget.song.artist;
    artistController.text = widget.song.artist;

    genres = widget.song.genres.map((genre) {
      return genreOptions.firstWhere((option) => option.label == genre);
    }).toList();
    availableGenres.removeWhere((genre) => genres.contains(genre));

    sections = widget.song.sections;
    sectionTitles = sections.map((section) {
      return sectionTypeOptions.firstWhere((option) => option.label == section.sectionTitle);
    }).toList();
    availableSectionTitles.removeWhere((section) => sectionTitles.contains(section));

    for (int i = 0; i < sections.length; i++) {
      chordsInputs.add(sections[i].chords);
      keysInputs.add(sections[i].key);

      chordsControllers.add(TextEditingController(text: sections[i].chords));
      
      chordsErrors.add(validateProgression(sections[i].chords));
    }

    isSameKeyForAllSections = keysInputs.length > 1 ? keysInputs.every((key) => key == keysInputs[0]) : false;

    _loadArtists();
  }

  Future<void> _loadArtists() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSongs = prefs.getString('songs');

    if (savedSongs != null) {
      setState(() {
        final List<custom_types.Song> songs = (jsonDecode(savedSongs) as List)
          .map((song) => custom_types.Song.fromJson(song))
          .toList();

        songArtists = songs.map((song) => song.artist).toSet().toList(); // Remove duplicates
      });
    }
  }

  void _showKeyboard(BuildContext context) {
    final bottomSheetController = Scaffold.of(context).showBottomSheet(
      (context2) {
        return ChordKeyboard(
          originalChords: splitChordsIntoArray(sections[currentKeyboardSectionIndex!].chords),
          onChordComplete: (chord) {
            if (currentKeyboardSectionIndex != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) { // Wait for the keyboard to close
                setState(() {
                  final updatedSections = [...sections];

                  updatedSections[currentKeyboardSectionIndex!] = custom_types.Section(
                    sectionTitle: sections[currentKeyboardSectionIndex!].sectionTitle,
                    key: sections[currentKeyboardSectionIndex!].key, // can it be keysInputs[currentKeyboardSectionIndex!] ?
                    chords: chord,
                  );

                  sections = updatedSections;

                  chordsInputs[currentKeyboardSectionIndex!] = chord;

                  chordsErrors[currentKeyboardSectionIndex!] = validateProgression(chord);

                  chordsControllers[currentKeyboardSectionIndex!].text = chord; // Update the text field
                });
              });
            }
          },
        );
      },
    );

    // listen for when the keyboard is closed
    bottomSheetController.closed.then((_) {
      setState(() {
        isChordKeyboardVisible = false;
      });
    });
  }

  void _removeSection(int index) {
    setState(() {
      chordsControllers[index].dispose();
      chordsControllers.removeAt(index);

      sections.removeAt(index);
      keysInputs.removeAt(index);
      chordsInputs.removeAt(index);
      chordsErrors.removeAt(index);
      sectionHeights.removeAt(index);

      availableSectionTitles.add(sectionTitles[index]);
      availableSectionTitles.sort((a, b) => a.id.compareTo(b.id));

      sectionTitles.removeAt(index);

      if (isChordKeyboardVisible) {
        if (currentKeyboardSectionIndex == index) { // close keyboard if current keyboard section is removed
          _handleKeyboardToggle(context, index);
          currentKeyboardSectionIndex = null;
        } else if (currentKeyboardSectionIndex != null && index < currentKeyboardSectionIndex!) { // close keyboard if keyboard section now has different index
          _handleKeyboardToggle(context, index);
          currentKeyboardSectionIndex = null;
        }
        // do nothing if currentKeyboardSectionIndex > index
      }

    });
  }

  void _onEditSong() async {
    setState(() {
      for (int i = 0; i < sections.length; i++) {
        sections[i] = custom_types.Section(
          sectionTitle: sections[i].sectionTitle,
          key: keysInputs[i],
          chords: chordsInputs[i],
        );
      }
    });

    final updatedSong = custom_types.Song(
      id: widget.song.id,
      title: title.trim(), // Change later to use the input value
      artist: artist.trim(), // Change later to use the input value
      genres: genres.map((genre) => genre.label.trim()).toList(),
      sections: sections,
    );

    final prefs = await SharedPreferences.getInstance();
    final savedSongs = prefs.getString('songs');

    if (savedSongs != null) {
      setState(() {
        final songs = (jsonDecode(savedSongs) as List)
          .map((song) => custom_types.Song.fromJson(song))
          .toList();

        final index = songs.indexWhere((song) => song.id == updatedSong.id);
        songs[index] = updatedSong;

        saveSongs(songs);
      });
    } else {
      saveSongs([updatedSong]);
    }

    Navigator.pop(context, [true, updatedSong]);
  }

  void _handleKeyboardToggle(BuildContext context, int index) {
    if (isChordKeyboardVisible) {
      Navigator.pop(context); // closes keyboard
    } else {
      _showKeyboard(context); // opens keyboard
    }

    setState(() {
      isChordKeyboardVisible = !isChordKeyboardVisible;
      currentKeyboardSectionIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;

    final backgroundColor = isDarkMode ? Color(0xff171717) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final altTextColor = isDarkMode ? Colors.black : Colors.white;

    void onAddGenrePress() {
      // Show a dialog to add a genre from a list of predefined genres
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Add Genre', 
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
            backgroundColor: backgroundColor,
            content: SingleChildScrollView(
              child: Column(
                children: availableGenres.map((genre) {
                  return ListTile(
                    title: Text(
                      genre.label,
                      style: TextStyle(color: textColor),
                    ),
                    onTap: () {
                      setState(() {
                        genres.add(genre);
                        availableGenres.remove(genre);
                      });
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ),
          );
        },
      );
    }

    void onAddSectionPress() {
      // Show a dialog to add a section from a list of predefined section titles
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Add Section',
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
            backgroundColor: backgroundColor,
            content: SingleChildScrollView(
              child: Column(
                children: availableSectionTitles.map((sectionTitle) {
                  return ListTile(
                    title: Text(
                      sectionTitle.label,
                      style: TextStyle(color: textColor),
                    ),
                    onTap: () {
                      setState(() {
                        sectionTitles.add(sectionTitle);
                        availableSectionTitles.remove(sectionTitle);

                        custom_types.Section newSection = custom_types.Section(
                          sectionTitle: sectionTitle.label,
                          key: isSameKeyForAllSections && sections.isNotEmpty ? keysInputs[0] : lastSelectedKey,
                          chords: '',
                        );

                        sections.add(newSection);

                        keysInputs.add(newSection.key);
                        chordsInputs.add(newSection.chords);
                        chordsControllers.add(TextEditingController());
                        chordsErrors.add(null); // initialize with no error
                        sectionHeights.add(0.0); // initialize with height 0
                      });

                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ),
          );
        },
      );
    }

    void onReorder(int oldIndex, int newIndex) {
      setState(() {
        if (newIndex > oldIndex) newIndex -= 1;

        final section = sections.removeAt(oldIndex);
        sections.insert(newIndex, section);

        final key = keysInputs.removeAt(oldIndex);
        keysInputs.insert(newIndex, key);

        final chordsInput = chordsInputs.removeAt(oldIndex);
        chordsInputs.insert(newIndex, chordsInput);

        final chordsController = chordsControllers.removeAt(oldIndex);
        chordsControllers.insert(newIndex, chordsController);

        final chordsError = chordsErrors.removeAt(oldIndex);
        chordsErrors.insert(newIndex, chordsError);

        final sectionHeight = sectionHeights.removeAt(oldIndex);
        sectionHeights.insert(newIndex, sectionHeight);

        final sectionTitle = sectionTitles.removeAt(oldIndex);
        sectionTitles.insert(newIndex, sectionTitle);

        // Update keyboard section index if it was affected
        if (currentKeyboardSectionIndex != null) {
          if (oldIndex == currentKeyboardSectionIndex) {
            currentKeyboardSectionIndex = newIndex;
          } else if (newIndex <= currentKeyboardSectionIndex!) {
            currentKeyboardSectionIndex = currentKeyboardSectionIndex! + 1;
          }
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff009788),
        title: Text(
          'Edit Song',
            style: TextStyle(
              color: altTextColor,
              fontWeight: FontWeight.w500,
            ),
        ),
        iconTheme: IconThemeData(color: altTextColor), // Change the color of the back button
      ),
      backgroundColor: backgroundColor,
      body: Builder(
        builder: (context2) {
          return SingleChildScrollView(
            padding: isChordKeyboardVisible ? EdgeInsets.only(bottom: 300) : EdgeInsets.zero, // Adjust the padding when the keyboard is visible
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Edit Song',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  // Title
                  TextField(
                    controller: titleController,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Title',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: isDarkMode ? Colors.white : Color(0xcccccccc)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: isDarkMode ? Colors.white : Color(0xcccccccc)),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: isDarkMode ? Colors.white : Color(0xcccccccc)),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        title = value;
                      });
                    },
                    enabled: isChordKeyboardVisible ? false : true,
                    textCapitalization: TextCapitalization.words,
                  ),
                  SizedBox(height: 20),
            
                  // Artist
                  AutocompleteDropdown(
                    dataset: songArtists,
                    controller: artistController,
                    hintText: 'Artist',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    style: TextStyle(color: textColor),
                    borderSide: BorderSide(color: isDarkMode ? Colors.white : Color(0xcccccccc)),
                    suggestionListBackgroundColor: backgroundColor,
                    onChanged: (value) {
                      setState(() {
                        artist = value;
                      });
                    },
                    enabled: isChordKeyboardVisible ? false : true,
                    textCapitalization: TextCapitalization.words,
                  ),
                  SizedBox(height: 20),
            
                  // Genres
                  FlexibleWidthButton(
                    label: 'Add Genre',
                    width: double.infinity,
                    onPressed: onAddGenrePress,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: genres.map((genre) {
                        return Container(
                          margin: const EdgeInsets.only(right: 10),
                          child: Chip(
                            label: Text(genre.label),
                            backgroundColor: isDarkMode ? Colors.grey[900]: const Color(0xfff4faf8),
                            labelStyle: TextStyle(color: textColor),
                            deleteIcon: Icon(Icons.cancel, color: Colors.red),
                            onDeleted: () {
                              setState(() {
                                genres.remove(genre);
          
                                // Sort the genres by id
                                availableGenres.add(genre);
                                availableGenres.sort((a, b) {
                                  return a.id.compareTo(b.id);
                                });
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
            
                  // Sections
                  FlexibleWidthButton(
                    label: 'Add Section',
                    width: double.infinity,
                    onPressed: onAddSectionPress,
                  ),
          
                  if (sections.isNotEmpty)
                    CheckboxListTile(
                      title: Text('Same Key For All Sections', style: TextStyle(color: textColor)),
                      value: isSameKeyForAllSections,      
                      onChanged: (value) {
                        setState(() {
                          isSameKeyForAllSections = value!;
          
                          if (value) {
                            for (int i = 1; i < sections.length; i++) {
                              keysInputs[i] = keysInputs[0];
                            }
                          }
                        });
                      },
                      activeColor: const Color(0xff009788),
                      side: const BorderSide(color: 
                        Color(0xff009788),
                        width: 2,
                      ),
                    ),
          
                  // Section Chooser List (Accordion)
                  SizedBox(
                    height: sectionHeights.isEmpty ? 0 : sectionHeights.reduce((a, b) => a + b), // Adjust height based on section heights
                    child: ReorderableListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: sections.length,
                      onReorder: onReorder,
                      itemBuilder: (context, index) {
                        final custom_types.Section section = sections[index];
                    
                        final custom_types.Key currentKey = keysInputs[index];
                        final TextEditingController chordsController = chordsControllers[index];
                              
                        return SizeReportingWidget(
                          key: ValueKey(section.sectionTitle),
                          onSizeChanged: (height) {
                            setState(() {
                              if (sectionHeights.length > index) {
                                sectionHeights[index] = height;
                              } else {
                                sectionHeights.add(height);
                              }
                            });
                          },
                          child: ExpandableTileWrapper(
                            tileKey: ValueKey(section.sectionTitle),
                            onExpansionComplete: () {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                // Rebuild the widget to ensure the heights are updated
                                setState(() {});
                              });
                            },
                            builder: (context, isExpanded, onExpansionChanged) {
                              return ExpansionTile(
                                title: Text(section.sectionTitle, style: TextStyle(color: textColor)),
                                initiallyExpanded: isExpanded,
                                onExpansionChanged: onExpansionChanged,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        DropdownButton<String>(
                                          value: isSameKeyForAllSections && index > 0 ? null : currentKey.tonic,
                                          dropdownColor: backgroundColor,
                                          disabledHint: Text(
                                            keysInputs[0].tonic, // Show the first key when all keys are the same
                                            style: TextStyle(color: Colors.grey[500]),
                                          ),
                                          items: keyTonicOptions.map((tonic) {
                                            return DropdownMenuItem<String>(
                                              value: tonic,
                                              child: Text(tonic, style: TextStyle(color: textColor)),
                                            );
                                          }).toList(),
                                          onChanged: isSameKeyForAllSections && index > 0 ? null : (value) {
                                            setState(() {
                                              keysInputs[index] = custom_types.Key(
                                                tonic: value!,
                                                symbol: currentKey.symbol,
                                                mode: currentKey.mode,
                                              );
                                                  
                                              lastSelectedKey = keysInputs[index]; // Save the last selected key
                                              
                                              if (isSameKeyForAllSections) {
                                                for (int i = 1; i < sections.length; i++) {
                                                  keysInputs[i] = keysInputs[0];
                                                }
                                              }
                                            });
                                          },
                                        ),
                                        DropdownButton<String>(
                                          value: isSameKeyForAllSections && index > 0 ? null : currentKey.symbol,
                                          dropdownColor: backgroundColor,
                                          disabledHint: Text(
                                            keysInputs[0].symbol, // Show the first key when all keys are the same
                                            style: TextStyle(color: Colors.grey[500]),
                                          ),
                                          items: keySymbolOptions.map((symbol) {
                                            return DropdownMenuItem<String>(
                                              value: symbol,
                                              child: Text(symbol, style: TextStyle(color: textColor)),
                                            );
                                          }).toList(),
                                          onChanged: isSameKeyForAllSections && index > 0 ? null : (value) {
                                            setState(() {
                                              keysInputs[index] = custom_types.Key(
                                                tonic: currentKey.tonic,
                                                symbol: value!,
                                                mode: currentKey.mode,
                                              );
                                                  
                                              lastSelectedKey = keysInputs[index]; // Save the last selected key
                                              
                                              if (isSameKeyForAllSections) {
                                                for (int i = 1; i < sections.length; i++) {
                                                  keysInputs[i] = keysInputs[0];
                                                }
                                              }
                                            });
                                          },
                                        ),
                                        DropdownButton<String>(
                                          value: isSameKeyForAllSections && index > 0 ? null : currentKey.mode,
                                          dropdownColor: backgroundColor,
                                          disabledHint: Text(
                                            keysInputs[0].mode, // Show the first key when all keys are the same
                                            style: TextStyle(color: Colors.grey[500]),
                                          ),
                                          items: keyModeOptions.map((mode) {
                                            return DropdownMenuItem<String>(
                                              value: mode,
                                              child: Text(mode, style: TextStyle(color: textColor)),
                                            );
                                          }).toList(),
                                          onChanged: isSameKeyForAllSections && index > 0 ? null : (value) {
                                            setState(() {
                                              keysInputs[index] = custom_types.Key(
                                                tonic: currentKey.tonic,
                                                symbol: currentKey.symbol,
                                                mode: value!,
                                              );
                                                  
                                              lastSelectedKey = keysInputs[index]; // Save the last selected key
                                              
                                              if (isSameKeyForAllSections) {
                                                for (int i = 1; i < sections.length; i++) {
                                                  keysInputs[i] = keysInputs[0];
                                                }
                                              }
                                            });
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete, color: Colors.red),
                                          onPressed: () {
                                            _removeSection(index);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(bottom: 10),
                                    child: TextField(
                                      controller: chordsController,
                                      style: TextStyle(color: textColor),
                                      decoration: InputDecoration(
                                        hintText: 'Chords',
                                        hintStyle: TextStyle(color: Colors.grey[500]),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: chordsErrors[index] != null ? Colors.red : (isChordKeyboardVisible && currentKeyboardSectionIndex == index ? Color(0xff009788) : isDarkMode ? Colors.white : Color(0xcccccccc)),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: chordsErrors[index] != null ? Colors.red : (isChordKeyboardVisible && currentKeyboardSectionIndex == index ? Color(0xff009788) : isDarkMode ? Colors.white : Color(0xcccccccc)),
                                          ),
                                        ),
                                        errorText: chordsErrors[index],
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Color(0xFFB71C1C)),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.red),
                                        ),
                                      ),
                                      onTap: () {
                                        _handleKeyboardToggle(context2, index);
                                      },
                                      readOnly: true,
                                      showCursor: true,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
            
                  // Edit Song Button
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: FlexibleWidthButton(
                      label: 'Edit Song',
                      disabled: title.isEmpty || sections.isEmpty || isChordKeyboardVisible || chordsErrors.any((e) => e != null),
                      width: double.infinity,
                      onPressed: _onEditSong,
                    ),
                  )
                ],
              )
            ),
          );
        }
      )
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    artistController.dispose();
    for (final controller in chordsControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}