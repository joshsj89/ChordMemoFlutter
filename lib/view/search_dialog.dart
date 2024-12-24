import 'package:chordmemoflutter/view/autocomplete_dropdown.dart';
import 'package:chordmemoflutter/view/flexible_width_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_model/dark_mode_provider.dart';
import '../model/types.dart' as custom_types;

class SearchDialog extends StatefulWidget {
  final List<custom_types.Song> songs;

  const SearchDialog({
    super.key,
    required this.songs,
  });

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  String _selectedOption = 'Title';
  List<String> suggestions = [];
  List<String> songTitles = [];
  List<String> songArtists = [];
  List<String> songGenres = [];
  List<String> songKeys = [];
  List<String> songChords = [];

  @override
  void initState() {
    super.initState();

    songTitles = widget.songs.map((song) => song.title).toList();
    songArtists = widget.songs.map((song) => song.artist).toList();
    songGenres = widget.songs.expand((song) => song.genres) // flatten the list of genres into a single list
      .toSet() // remove duplicates
      .toList();
    
    songKeys = widget.songs.expand((song) {
      return song.sections.map((section) => '${section.key.tonic}${section.key.symbol} ${section.key.mode}');
    }).toSet().toList();

    songChords = widget.songs.expand((song) {
      return song.sections.map((section) => section.chords);
    }).toSet().toList();

    suggestions = songTitles;
  }

  void _onRadioChanged(String? value) {
    setState(() {
      _selectedOption = value ?? '';
    });

    switch (value) {
      case 'Title':
        suggestions = songTitles;
        break;
      case 'Artist':
        suggestions = songArtists;
        break;
      case 'Genre':
        suggestions = songGenres;
        break;
      case 'Key':
        suggestions = songKeys;
        break;
      case 'Chords':
        suggestions = songChords;
        break;
      default:
        suggestions = [];
    }
  }

  void _onSearch() {

  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;

    final backgroundColor = isDarkMode ? Color(0xff171717) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return AlertDialog(
      title: Text(
        'Search',
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 20),
        textAlign: TextAlign.center,
      ),
      backgroundColor: backgroundColor,
      content: Column(
        mainAxisSize: MainAxisSize.min, // ensures the Column only takes up the space it needs based on its children
        children: [
          // Search field / Autocomplete Dropdown
          Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            child: AutocompleteDropdown(
              dataset: suggestions, 
              caseSensitive: _selectedOption == 'Chords',
              hintText: 'Enter search text',
              hintStyle: TextStyle(color: Colors.grey[500]),
              style: TextStyle(color: textColor),
              borderSide: BorderSide(color: isDarkMode ? Colors.white : Color(0xcccccccc)),
              suggestionListBackgroundColor: backgroundColor,
              onChanged: (value) {},
            ),
          ),

          // Radio buttons
          Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            child: Wrap(
              direction: Axis.horizontal,
              spacing: 50,
              children: [
                RadioButtonOption(
                  label: 'Title',
                  selectedValue: _selectedOption,
                  onChanged: _onRadioChanged,
                  textColor: textColor
                ),
                RadioButtonOption(
                  label: 'Artist',
                  selectedValue: _selectedOption,
                  onChanged: _onRadioChanged,
                  textColor: textColor
                ),
                RadioButtonOption(
                  label: 'Genre',
                  selectedValue: _selectedOption,
                  onChanged: _onRadioChanged,
                  textColor: textColor
                ),
                RadioButtonOption(
                  label: 'Key',
                  selectedValue: _selectedOption,
                  onChanged: _onRadioChanged,
                  textColor: textColor
                ),
                RadioButtonOption(
                  label: 'Chords',
                  selectedValue: _selectedOption,
                  onChanged: _onRadioChanged,
                  textColor: textColor
                ),
              ],
            ),
          ),

          // Buttons
          Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FlexibleWidthButton(
                  label: 'Close',
                  onPressed: () => Navigator.pop(context),
                ),
                FlexibleWidthButton(
                  label: 'Search',
                  onPressed: _onSearch,
                ),
              ],
            ),
          )
        ]
      )
    );
  }
}

class RadioButtonOption extends StatelessWidget {
  final String label;
  final String? selectedValue;
  final Color textColor;
  final void Function(String?) onChanged;


  const RadioButtonOption({
    super.key,
    required this.label,
    this.selectedValue,
    required this.textColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min, // ensures the Row only takes up the space it needs based on its children
      children: [
        Radio(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          activeColor: const Color(0xff009788),
          value: label,
          groupValue: selectedValue,
          onChanged: onChanged,
        ),
        Text(label, style: TextStyle(color: textColor)),
      ],
    );
  }
}