import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_model/dark_mode_provider.dart';
import 'song_details_screen.dart';
import '../view_model/song_persistence.dart';
import '../model/types.dart' as custom_types;

class SearchResultsScreen extends StatefulWidget {
  final List<custom_types.Song> songs;

  const SearchResultsScreen({
    super.key,
    required this.songs,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  List<custom_types.Song> _songs = [];

  @override
  void initState() {
    super.initState();

    _songs = widget.songs;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;
    final backgroundColor = isDarkMode ? Color(0xff171717) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final altTextColor = isDarkMode ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Color(0xff009788),
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(
          'Search Results',
          style: TextStyle(color: altTextColor, fontWeight: FontWeight.w500),
        ),
        iconTheme: IconThemeData(color: altTextColor), // Change the color of the back button
      ),
      body: ListView.builder(
        itemCount: _songs.length,
        itemBuilder: (context, index) {
          final song = _songs[index];

          return InkWell(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SongDetailsScreen(song: song),
                ),
              );

              if (result == true) {
                loadSongs().then((loadedSongs) {
                  setState(() {
                    _songs = loadedSongs;
                  });
                });
              }
            },
            // onLongPress: () => _confirmDelete(song),
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
                      color: isDarkMode
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
    );
  }
}