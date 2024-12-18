import 'package:flutter/material.dart';

class ExportImportScreen extends StatelessWidget {
  final bool isDarkMode;

  const ExportImportScreen({super.key, this.isDarkMode = false});

  final String exportDescription =
    "This feature allows you to export all your saved songs into a JSON file. Once exported, you can easily share this file with yourself or others by various means, such as email or messaging apps. To access your exported songs, simply download the JSON file outside of the app.";
  final String importDescription =
    "With this option, you can import songs from a JSON file stored anywhere on your device. Whether the file is in your downloads folder or a specific directory, you can select and import it here. This makes it convenient to add new songs or restore your previously exported songs.";

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff009788),
        title: Text('Export/Import', style: TextStyle(color: backgroundColor, fontWeight: FontWeight.w500)),
        iconTheme: IconThemeData(color: backgroundColor), // Change the color of the back button
      ),
      backgroundColor: backgroundColor,
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Text(
                'Export/Import Songs',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            SizedBox(height: 10),

            // Export Description
            FeatureDescription(
              heading: 'Export Your Songs as JSON: ', 
              description: exportDescription, 
              textColor: textColor
            ),
            SizedBox(height: 10),
            CustomButton(
              label: 'EXPORT',
              onPressed: () {
                // Add export functionality here
              },
            ),
            SizedBox(height: 20),

            // Import Description
            FeatureDescription(
              heading: 'Import Songs from JSON File: ', 
              description: importDescription, 
              textColor: textColor
            ),
            SizedBox(height: 10),
            CustomButton(
              label: 'IMPORT',
              onPressed: () {
                // Add import functionality here
              },
            ),
            SizedBox(height: 20),
          ],
        )
      )
    );
  }
}

class FeatureDescription extends StatelessWidget {
  final String heading;
  final String description;
  final Color textColor;

  const FeatureDescription({
    super.key,
    required this.heading,
    required this.description,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Import Songs from JSON File: ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
          ),
          TextSpan(
            text: description,
            style: TextStyle(fontSize: 16, color: textColor),
          )
        ]
      )
    );
  }
}

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll<Color>(Color(0xff009788)),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))
          ),
        ),
        child: Text(
          label, 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}