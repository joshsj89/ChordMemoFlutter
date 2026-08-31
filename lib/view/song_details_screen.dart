import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:developer';

import 'package:chordmemoflutter/model/music_theory.dart';
import 'package:chordmemoflutter/model/types.dart' as custom_types;
import 'package:chordmemoflutter/view/edit_song_screen.dart';
import 'package:chordmemoflutter/view_model/concrete_chord_builder.dart';
import 'package:chordmemoflutter/view_model/settings_provider.dart';
import 'package:chordmemoflutter/view_model/pretty_chord_builder.dart';
import 'package:chordmemoflutter/view_model/song_repository.dart';

/// How the progressions on this screen are shown: functional Roman numerals
/// (the stored form) or concrete chord names spelled for the section key.
enum ChordView { numerals, chords }

class SongDetailsScreen extends StatefulWidget {
  final custom_types.Song song;

  const SongDetailsScreen({super.key, required this.song});

  @override
  State<SongDetailsScreen> createState() => _SongDetailsScreenState();
}

class _SongDetailsScreenState extends State<SongDetailsScreen> {
  bool _showSections = false;
  bool _didEdit = false;
  late custom_types.Song _song;

  // View-only display state — never persisted.
  ChordView _view = ChordView.numerals;
  int _transpose = 0; // semitones, applied to concrete chords only
  bool? _preferSharpsOverride; // null = auto (derived from the song's key)

  static const int _maxTranspose = 11;

  @override
  void initState() {
    super.initState();

    _song = widget.song;
  }

  @override
  void didUpdateWidget(covariant SongDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.song != widget.song) {
      setState(() {
        _song = widget.song;
        _showSections = false;
        _transpose = 0;
        _preferSharpsOverride = null;
      });
    }
  }

  EnharmonicPreference get _preference {
    if (_preferSharpsOverride != null) {
      return _preferSharpsOverride!
          ? EnharmonicPreference.sharps
          : EnharmonicPreference.flats;
    }
    return _song.sections.isEmpty
        ? EnharmonicPreference.sharps
        : preferenceFromKey(_song.sections.first.key);
  }

  bool get _enharmonicToggleMatters =>
      _transpose != 0 &&
      _song.sections.any((s) => transposedKeyIsAmbiguous(s.key, _transpose));

  String _sectionKeyLabel(custom_types.Section section) {
    if (_view == ChordView.numerals || _transpose == 0) {
      return '${section.key.tonic}${section.key.symbol} ${section.key.mode}';
    }
    final tonic = transposeTonic(
      tonicFromKey(section.key),
      section.key.mode,
      _transpose,
      preference: _preference,
    );
    return '$tonic ${section.key.mode}';
  }

  void _toggleSections() {
    setState(() {
      _showSections = !_showSections;
    });
  }

  void _editSong() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditSongScreen(song: _song),
      ),
    );

    if (result == null) return;

    _didEdit = result[0] as bool;
    final updatedSong = result[1] as custom_types.Song;

    setState(() {
      if (_didEdit) {
        // Refresh the song details
          _song = updatedSong;
      }
      
      _showSections = false;
    });
  }

  Future<void> _deleteSong() async {
    try {
      await SongRepository.instance.deleteSong(_song.id);

      if (!mounted) return;
      Navigator.pop(context, [true, _song]); // Refresh the list of songs
    } catch (error) {
      log('Error deleting song: $error');
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete ${_song.title}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteSong();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplayControls(Color textColor) {
    const brand = Color(0xff009788);

    final segmented = SegmentedButton<ChordView>(
      segments: const [
        ButtonSegment(value: ChordView.numerals, label: Text('Numerals')),
        ButtonSegment(value: ChordView.chords, label: Text('Chords')),
      ],
      selected: {_view},
      showSelectedIcon: false,
      onSelectionChanged: (selection) =>
          setState(() => _view = selection.first),
    );

    if (_view == ChordView.numerals) return segmented;

    final magnitude = _transpose.abs();
    final transposeLabel = _transpose == 0
        ? 'Original key'
        : '${_transpose > 0 ? '+' : '−'}$magnitude '
            'semitone${magnitude == 1 ? '' : 's'}';

    return Column(
      children: [
        segmented,
        const SizedBox(height: 4),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              tooltip: 'Down a semitone',
              onPressed: _transpose > -_maxTranspose
                  ? () => setState(() => _transpose--)
                  : null,
            ),
            Text(
              transposeLabel,
              style: TextStyle(color: textColor, fontSize: 13),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Up a semitone',
              onPressed: _transpose < _maxTranspose
                  ? () => setState(() => _transpose++)
                  : null,
            ),
            if (_transpose != 0)
              IconButton(
                icon: const Icon(Icons.restart_alt),
                tooltip: 'Reset to original key',
                onPressed: () => setState(() => _transpose = 0),
              ),
            if (_enharmonicToggleMatters)
              TextButton(
                onPressed: () => setState(() {
                  _preferSharpsOverride =
                      _preference != EnharmonicPreference.sharps;
                }),
                child: Text(
                  _preference == EnharmonicPreference.sharps
                      ? 'Prefer ♯'
                      : 'Prefer ♭',
                  style: const TextStyle(color: brand),
                ),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<SettingsProvider>(context).isDarkMode;
    final backgroundColor = isDarkMode ? Color(0xff171717) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final altTextColor = isDarkMode ? Colors.black : Colors.white;
    final borderColor = isDarkMode ? Color(0xff2a2a2a) : Colors.black;

    return PopScope(
      canPop: false, // Prevent default behavior of back button
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (!_showSections) { // Pop the screen if sections are hidden
            Navigator.pop(context, [_didEdit, _song]);
          } else { // Hide sections if visible when back button is pressed
            setState(() {
              _showSections = false;
            });
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff009788),
          title: Text(
            _song.title,
            style: TextStyle(
              color: altTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          iconTheme: IconThemeData(
              color: altTextColor), // Change the color of the back button
        ),
        backgroundColor: backgroundColor,
        body: Column(
          children: [
            if (_showSections) ...[
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 12),
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        _song.title,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (_song.artist.isNotEmpty)
                      Text(
                        _song.artist,
                        style: TextStyle(
                          fontSize: 15,
                          color: textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 12),
                    _buildDisplayControls(textColor),
                  ],
                ),
              ),
            ],
            
            if (!_showSections) ...[
              GestureDetector(
                onTap: _toggleSections,
                child: SizedBox(
                  width: double.infinity,
                  height: 375,
                  child: Container(
                    margin: const EdgeInsets.only(top: 80, bottom: 10, left: 35, right: 35),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: borderColor, width: 1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        _song.title,
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
              if (_song.artist.isNotEmpty || _song.genres.isNotEmpty)
                Column(
                  children: [
                    if (_song.artist.isNotEmpty)
                      Text(
                        _song.artist,
                        style: TextStyle(fontSize: 20, color: textColor),
                        textAlign: TextAlign.center,
                      ),
                    if (_song.genres.isNotEmpty)
                      Text(
                        _song.genres.join(', '),
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
            ],
      
            if (_showSections)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _song.sections.map((section) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                section.sectionTitle,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(fontSize: 16, color: textColor),
                                    children: [
                                      TextSpan(
                                        text: "${_sectionKeyLabel(section)} - ",
                                        style: TextStyle(fontWeight: FontWeight.normal, color: textColor),
                                      ),
                                      if (_view == ChordView.numerals)
                                        buildPrettyChordProgression(
                                          progression: section.chords,
                                          textColor: textColor,
                                        )
                                      else
                                        buildConcreteChordProgression(
                                          progression: section.chords,
                                          key: section.key,
                                          transpose: _transpose,
                                          preference: _preference,
                                          textColor: textColor,
                                        ),
                                    ],
                                  ),
                                  textAlign: TextAlign.left,
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
          ],
        ),

        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'edit',
              tooltip: 'Edit',
              backgroundColor: const Color(0xff009788),
              onPressed: _editSong,
              child: Icon(Icons.edit, color: altTextColor),
            ),
            const SizedBox(width: 10),
            FloatingActionButton(
              heroTag: 'delete',
              tooltip: 'Delete',
              backgroundColor: const Color(0xff009788),
              onPressed: _confirmDelete,
              child: Icon(Icons.delete, color: altTextColor),
            ),
          ],
        ),
      ),
    );
  }
}
