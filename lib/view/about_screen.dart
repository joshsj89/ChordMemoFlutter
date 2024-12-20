import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_model/dark_mode_provider.dart';

class AboutScreen extends StatelessWidget {
  AboutScreen({super.key});

  final List<String> keyFeatures = [
    'Chord Progression Storage: Easily create and store chord progressions for songs. Organize them by title, artist, genre, and more.',
    'Interactive Visualization: Visualize your chord progressions on an intuitive interface. See the chords, sections, and keys all at a glance.',
    'Key Information: Add key details like key tonic, key symbol, and key mode to each chord progression for accurate representation.',
    'Genre Categorization: Tag your chord progressions with genres, making it simple to find related progressions for your mood or style.',
    'Section Management: Add, remove, and reorder sections within a chord progression to customize the structure of your song.',
    'Easy Editing: Edit and refine your chord progressions as you go. Rearrange sections, change keys, and update chords seamlessly.',
    'Songwriting Companion: Use ChordMemo to jot down chord progressions for your original songs on the fly. Never lose a brilliant idea again!'
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;

    final backgroundColor = isDarkMode ? Color(0xff171717) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final altTextColor = isDarkMode ? Colors.black : Colors.white;

    final boldTextStyle = TextStyle(fontWeight: FontWeight.bold, color: textColor);
    final defaultTextStyle = TextStyle(fontSize: 16, color: textColor);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff009788),
          title: Text(
            'About',
            style: TextStyle(
              color: altTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        iconTheme: IconThemeData(color: altTextColor), // Change the color of the back button
      ),
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Text(
                'About ChordMemo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            SizedBox(height: 10),

            // Description
            Text(
              "Welcome to ChordMemo, your ultimate chord progression companion! ChordMemo is a powerful and user-friendly app designed to help you capture and organize chord progressions for your favorite songs, or even your own original compositions. Whether you're a musician, songwriter, or just someone who loves playing with chord sequences, ChordMemo has got you covered.",
              style: defaultTextStyle,
            ),
            SizedBox(height: 20),

            // Subheader
            Text(
              'Key Features:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: 10),

            // Key Features List
            ...keyFeatures.map((feature) {
              final splitFeature = feature.split(':');
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: RichText(
                  text: TextSpan(
                    style: defaultTextStyle,
                    children: [
                      TextSpan(
                        text: '- ${splitFeature[0]}:',
                        style: boldTextStyle,
                      ),
                      TextSpan(
                        text: splitFeature.length > 1 ? splitFeature[1] : '',
                      ),
                    ],
                  ),
                ),
              );
            }),
            SizedBox(height: 20),

            // Signature
            Text(
              "ChordMemo is designed to be your go-to tool for managing and exploring chord progressions. Whether you're practicing, performing, or creating, ChordMemo is here to help you harmonize your musical journey.\n\nThank you for choosing ChordMemo. I hope you enjoy using the app as much as I enjoyed creating it!\n\nHappy playing!",
              style: defaultTextStyle.copyWith(fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 20),

            // Name Signature
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '- Josh Kindarara',
                style: defaultTextStyle.copyWith(fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      )
    );
  }
}