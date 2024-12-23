import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dart:convert';

import 'about_screen.dart';
import 'add_song_screen.dart';
import '../view_model/dark_mode_provider.dart';
import 'export_import_screen.dart';
import 'search_dialog.dart';
import 'song_details_screen.dart';
import '../view_model/song_persistence.dart';
import '../model/types.dart' as custom_types;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<custom_types.Song> songs = [];

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
          .map((song) => custom_types.Song.fromJson(song))
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

  void _confirmDelete(custom_types.Song song) {
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

  void _onSearchPressed() {
    showDialog(
      context: context,
      builder: (ctx) => SearchDialog(songs: songs),
    );
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final backgroundColor = darkModeProvider.isDarkMode ? Color(0xff171717) : Colors.white;
    final textColor = darkModeProvider.isDarkMode ? Colors.white : Colors.black;
    final altTextColor = darkModeProvider.isDarkMode ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Color(0xff009788),
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(
          'ChordMemo',
          style: TextStyle(color: altTextColor, fontWeight: FontWeight.w500),
        ),
        iconTheme: IconThemeData(color: altTextColor), // Change the color of the hamburger menu button
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _onSearchPressed,
          ),
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AboutScreen(),
                ),
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
                  color: altTextColor,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text(
                'Export/Import Songs',
                style: TextStyle(color: textColor),
              ),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExportImportScreen(),
                  ),
                );

                // If the user imported songs, reload the list
                if (result == true) {
                  _loadSongs();
                }
              },
            ),
            ListTile(
              title: Text(
                'Dark Mode: ${darkModeProvider.isDarkMode ? 'On' : 'Off'}',
                style: TextStyle(color: textColor),
              ),
              onTap: darkModeProvider.toggleDarkMode,
            ),
            ListTile(
              title: Text('About', style: TextStyle(color: textColor)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AboutScreen(),
                  ),
                );
              },
            ),
            LinkButton(
              text: 'My Website',
              url: 'https://joshsj89.github.io/ChordMemo',
            ),
            LinkButton(
              text: 'GitHub',
              url: 'https://www.github.com/joshsj89',
            ),
            LinkButton(
              text: 'Contact Me',
              url: 'https://joshsj89.github.io/#contact',
            ),
            LinkButton(
              text: 'Donate',
              url: dotenv.env['DONATE_LINK'] ?? '',
            ),
          ],
        )),
      body: ListView.builder(
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];

          return InkWell(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SongDetailsScreen(song: song),
                ),
              );

              if (result == true) {
                _loadSongs();
              }
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
                      color: darkModeProvider.isDarkMode
                        ? Color(0xff99999e)
                        : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddSongScreen(),
            ),
          );

          if (result == true) {
            _loadSongs();
          }
        },
        tooltip: 'Add Song',
        backgroundColor: Color(0xff009788),
        child: Icon(Icons.add, color: altTextColor),
      ),
    );
  }
}

class LinkButton extends StatelessWidget {
  final String text;
  final String url;

  const LinkButton({
    super.key,
    required this.text,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    void openLink() async {
      Uri uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        print('Could not launch $url');
      }
    }

    return ListTile(
      title: Text(text, style: TextStyle(color: textColor)),
      onTap: openLink,
    );
  }
}
