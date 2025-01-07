import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

import '../view_model/dark_mode_provider.dart';
import 'edit_song_screen.dart';
import '../model/types.dart' as custom_types;

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
      });
    }
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
      final prefs = await SharedPreferences.getInstance();
      final savedSongsString = prefs.getString('songs');

      if (savedSongsString != null) {
        final List<custom_types.Song> savedSongs = savedSongsString.isNotEmpty
            ? (jsonDecode(savedSongsString) as List)
                .map((song) => custom_types.Song.fromJson(song))
                .toList()
            : [];
        savedSongs.removeWhere((song) => song.id == _song.id);
        await prefs.setString('songs', jsonEncode(savedSongs));

        Navigator.pop(context, true); // Refresh the list of songs
      }
    } catch (error) {
      print('Error deleting song: $error');
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;
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
                padding: const EdgeInsets.only(top: 8.0, bottom: 30),
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
                              Text(
                                "${section.key.tonic}${section.key.symbol} ${section.key.mode} - ${section.chords}",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: textColor,
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
