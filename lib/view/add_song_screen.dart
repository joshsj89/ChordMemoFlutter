import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

import 'autocomplete_dropdown.dart';
import 'flexible_width_button.dart';
import '../view_model/dark_mode_provider.dart';
import '../view_model/song_persistence.dart';
import '../model/options.dart';
import '../model/types.dart' as custom_types;

class AddSongScreen extends StatefulWidget {
  const AddSongScreen({super.key});

  @override
  State<AddSongScreen> createState() => _AddSongScreenState();
}

class _AddSongScreenState extends State<AddSongScreen> {
  // class-level variables: persist across build calls
  String title = '';
  String artist = '';
  final TextEditingController artistController = TextEditingController();
  List<ListTileOption> genres = [];
  List<ListTileOption> availableGenres = List.from(genreOptions);
  List<custom_types.Section> sections = [];
  List<ListTileOption> sectionTitles = [];
  List<ListTileOption> availableSectionTitles = List.from(sectionTypeOptions);
  List<String> songArtists = [];
  Map<int, String> chordsInputs = {}; // hold the chords text temporarily using the section index as key
  Map<int, custom_types.Key> keysInputs = {}; // hold the key object temporarily using the section index as key
  bool isSameKeyForAllSections = false;

  @override
  void initState() {
    super.initState();

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

  void _onAddSong() async {
    setState(() {
      for (int i = 0; i < sections.length; i++) {
        sections[i] = custom_types.Section(
          sectionTitle: sections[i].sectionTitle,
          key: keysInputs[i] ?? sections[i].key,
          chords: chordsInputs[i] ?? '',
        );
      }
    });

    final newSong = custom_types.Song(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
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

        songs.add(newSong);
        saveSongs(songs);
      });
    } else {
      saveSongs([newSong]);
    }

    Navigator.pop(context, true);
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

                        sections.add(custom_types.Section(
                          sectionTitle: sectionTitle.label,
                          key: custom_types.Key(tonic: 'C', symbol: '', mode: 'Major'), // Change later to use last selected key
                          chords: '',
                        ));
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff009788),
        title: Text(
          'Add Song',
            style: TextStyle(
              color: altTextColor,
              fontWeight: FontWeight.w500,
            ),
        ),
        iconTheme: IconThemeData(color: altTextColor), // Change the color of the back button
      ),
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 10),
                child: Text(
                  'Add Song',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              // Title
              TextField(
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
                ),
                onChanged: (value) {
                  setState(() {
                    title = value;
                  });
                },
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
                          keysInputs[i] = keysInputs[0] ?? custom_types.Key(tonic: 'C', symbol: '', mode: 'Major');
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
              Column(
                children: sections.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final custom_types.Section section = entry.value;

                  final custom_types.Key currentKey = keysInputs[index] ?? section.key;
                  // final TextEditingController chordsController = TextEditingController(
                  //   text: chordsInputs[index] ?? section.chords,
                  // );

                  return ExpansionTile(
                    title: Text(section.sectionTitle, style: TextStyle(color: textColor)),
                    initiallyExpanded: true,
                    children: [
                      Row(
                        children: [
                          DropdownButton<String>(
                            value: isSameKeyForAllSections && index > 0 ? null : currentKey.tonic,
                            dropdownColor: backgroundColor,
                            disabledHint: Text(
                              keysInputs[0]?.tonic ?? 'C', // Show the first key when all keys are the same
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

                                if (isSameKeyForAllSections) {
                                  for (int i = 1; i < sections.length; i++) {
                                    keysInputs[i] = keysInputs[0] ?? custom_types.Key(tonic: 'C', symbol: '', mode: 'Major');
                                  }
                                }
                              });
                            },
                          ),
                          DropdownButton<String>(
                            value: isSameKeyForAllSections && index > 0 ? null : currentKey.symbol,
                            dropdownColor: backgroundColor,
                            disabledHint: Text(
                              keysInputs[0]?.symbol ?? '',
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

                                if (isSameKeyForAllSections) {
                                  for (int i = 1; i < sections.length; i++) {
                                    keysInputs[i] = keysInputs[0] ?? custom_types.Key(tonic: 'C', symbol: '', mode: 'Major');
                                  }
                                }
                              });
                            },
                          ),
                          DropdownButton<String>(
                            value: isSameKeyForAllSections && index > 0 ? null : currentKey.mode,
                            dropdownColor: backgroundColor,
                            disabledHint: Text(
                              keysInputs[0]?.mode ?? 'Major',
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

                                if (isSameKeyForAllSections) {
                                  for (int i = 1; i < sections.length; i++) {
                                    keysInputs[i] = keysInputs[0] ?? custom_types.Key(tonic: 'C', symbol: '', mode: 'Major');
                                  }
                                }
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                sections.removeAt(index);
                                keysInputs.remove(index);
                                chordsInputs.remove(index);
                              });
                            },
                          ),
                        ],
                      ),
                      TextField(
                        // controller: chordsController,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: 'Chords',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: isDarkMode ? Colors.white : Color(0xcccccccc)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: isDarkMode ? Colors.white : Color(0xcccccccc)),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            chordsInputs[index] = value;
                          });
                        }
                      ),
                    ],
                  );
                }).toList(),
              ),
        
              // Add Song Button
              Container(
                margin: EdgeInsets.symmetric(vertical: 20),
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: FlexibleWidthButton(
                  label: 'Add Song',
                  disabled: title.isEmpty || sections.isEmpty,
                  width: double.infinity,
                  onPressed: _onAddSong,
                ),
              )
            ],
          )
        ),
      )
    );
  }
}