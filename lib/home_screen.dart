import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'dart:convert';

import 'about_screen.dart';
import 'dark_mode_provider.dart';
import 'export_import_screen.dart';

class Key {
  final String tonic;
  final String symbol;
  final String mode;

  Key({
    required this.tonic,
    required this.symbol,
    required this.mode,
  });

  factory Key.fromJson(Map<String, dynamic> json) {
    return Key(
      tonic: json['tonic'],
      symbol: json['symbol'],
      mode: json['mode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tonic': tonic,
      'symbol': symbol,
      'mode': mode,
    };
  }
}

class Section {
  final String sectionTitle;
  final Key key;
  final String chords;

  Section({
    required this.sectionTitle,
    required this.key,
    required this.chords,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      sectionTitle: json['sectionTitle'],
      key: Key(
        tonic: json['key']['tonic'],
        symbol: json['key']['symbol'],
        mode: json['key']['mode'],
      ),
      chords: json['chords'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sectionTitle': sectionTitle,
      'key': key.toJson(),
      'chords': chords,
    };
  }
}

class Song {
  final String id;
  final String title;
  final String artist;
  final List<String> genres;
  final List<Section> sections;


  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.genres,
    required this.sections,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      genres: List<String>.from(json['genres']),
      sections: (json['sections'] as List)
        .map((section) => Section.fromJson(section))
        .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'genres': genres,
      'sections': sections.map((section) => section.toJson()).toList(),
    };
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Song> songs = [];

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSongs = prefs.getString('songs');

    if (savedSongs != null) {
      setState(() {
        songs = (jsonDecode(savedSongs) as List)
          .map((song) => Song.fromJson(song))
          .toList();
      });
    }
  }

  Future<void> _deleteSong(String songId) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      songs.removeWhere((song) => song.id == songId);
    });

    await prefs.setString('songs', jsonEncode(songs));
  }

  void _confirmDelete(Song song) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confrim Deletion'),
        content: Text('Are you sure you want to delete ${song.title}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteSong(song.id);
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
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final backgroundColor = darkModeProvider.isDarkMode ? Colors.black : Colors.white;
    final textColor = darkModeProvider.isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Color(0xff009788),
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(
          'ChordMemo', 
          style: TextStyle(color: backgroundColor, fontWeight: FontWeight.w500),
        ),
        iconTheme: IconThemeData(color: backgroundColor), // Change the color of the hamburger menu button
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {

            },
          ),
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AboutScreen(),
                )
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: backgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xff009788),
              ),
              child: Text(
                'ChordMemo',
                style: TextStyle(
                  color: backgroundColor,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Export/Import Songs', style: TextStyle(color: textColor)),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExportImportScreen(),
                  )
                );

                // If the user imported songs, reload the list
                if (result == true) {
                  _loadSongs();
                }
              },
            ),
            ListTile(
              title: Text('Dark Mode: ${darkModeProvider.isDarkMode ? 'On' : 'Off'}', style: TextStyle(color: textColor)),
              onTap: darkModeProvider.toggleDarkMode,
            ),
            ListTile(
              title: Text('About', style: TextStyle(color: textColor)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AboutScreen(),
                  )
                );
              },
            ),
            ListTile(
              title: Text('My Website', style: TextStyle(color: textColor)),
              onTap: () {
                // _openLink('https://joshsj89.github.io/ChordMemo');
              },
            ),
            ListTile(
              title: Text('GitHub', style: TextStyle(color: textColor)),
              onTap: () {
                // _openLink('https://www.github.com/joshsj89');
              },
            ),
            ListTile(
              title: Text('Contact Me', style: TextStyle(color: textColor)),
              onTap: () {
                // _openLink('https://joshsj89.github.io/#contact');
              },
            ),
            ListTile(
              title: Text('Donate', style: TextStyle(color: textColor)),
              onTap: () {
                // _openLink(dotenv.env['DONATE_LINK'] ?? '');
              },
            ),
          ],
        )
      ),
      body: ListView.builder(
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];

          return InkWell(
            onTap: () {
              // TODO: Navigate to SongDetails screen
              // Example: Navigator.push(context, MaterialPageRoute(builder: (_) => SongDetailsScreen(song: song)));
            },
            onLongPress: () => _confirmDelete(song),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    song.artist,
                    style: TextStyle(
                      color: darkModeProvider.isDarkMode ? Color(0xff99999e) : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addArbitrarySong,
        tooltip: 'Add Song',
        backgroundColor: Color(0xff009788),
        child: Icon(Icons.add, color: backgroundColor),
      ),
    );
  }
}