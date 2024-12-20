import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'custom_button.dart';
import '../view_model/dark_mode_provider.dart';
import '../model/options.dart';

class AddSongScreen extends StatefulWidget {
  const AddSongScreen({super.key});

  @override
  State<AddSongScreen> createState() => _AddSongScreenState();
}

class _AddSongScreenState extends State<AddSongScreen> {
  // class-level variables: persist across build calls
  List<GenreOption> genres = [];
  List<GenreOption> availableGenres = List.from(genreOptions);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;

    final backgroundColor = isDarkMode ? Color(0xff171717) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final altTextColor = isDarkMode ? Colors.black : Colors.white;

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
              ),
              SizedBox(height: 20),
        
              // Artist
              TextField(
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Artist',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: isDarkMode ? Colors.white : Color(0xcccccccc)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: isDarkMode ? Colors.white : Color(0xcccccccc)),
                  ),
                ),
              ),
              SizedBox(height: 20),
        
              // Genres
              CustomButton(
                label: 'ADD GENRE',
                onPressed:() {
                  // Show a dialog to add a genre from a list of predefined genres
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Add Genre'),
                        content: SingleChildScrollView(
                          child: Column(
                            children: availableGenres.map((genre) {
                              return ListTile(
                                title: Text(genre.label),
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
                },
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: genres.map((genre) {
                    return Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: Chip(
                        label: Text(genre.label),
                        onDeleted: () {
                          setState(() {
                            genres.remove(genre);
                            // availableGenres.insert(genre.id, genre);

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
              CustomButton(
                label: 'ADD SECTION',
                onPressed:() {},
              ),
        
              // // Lyrics
              // TextField(
              //   style: TextStyle(color: textColor),
              //   decoration: InputDecoration(
              //     hintText: 'Enter the lyrics of the song',
              //     hintStyle: TextStyle(color: textColor),
              //     enabledBorder: OutlineInputBorder(
              //       borderSide: BorderSide(color: textColor),
              //     ),
              //     focusedBorder: OutlineInputBorder(
              //       borderSide: BorderSide(color: textColor),
              //     ),
              //   ),
              //   maxLines: 10,
              // ),
              // SizedBox(height: 20),
        
              // Add Song Button
              Container(
                margin: EdgeInsets.symmetric(vertical: 20),
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: CustomButton(
                  label: 'ADD SONG',
                  disabled: true,
                  onPressed: () {},
                ),
              )
            ],
          )
        ),
      )
    );
  }
}