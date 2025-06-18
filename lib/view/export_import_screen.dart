import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'flexible_width_button.dart';
import '../view_model/dark_mode_provider.dart';

class ExportImportScreen extends StatefulWidget {
  const ExportImportScreen({super.key});

  @override
  State<ExportImportScreen> createState() => _ExportImportScreenState();
}

class _ExportImportScreenState extends State<ExportImportScreen> {
  bool didImport = false;

  final String exportDescription =
    "This feature allows you to export all your saved songs into a JSON file. Once exported, you can easily share this file with yourself or others by various means, such as email or messaging apps. To access your exported songs, simply download the JSON file outside of the app.";
  final String importDescription =
    "With this option, you can import songs from a JSON file stored anywhere on your device. Whether the file is in your downloads folder or a specific directory, you can select and import it here. This makes it convenient to add new songs or restore your previously exported songs.";

  Future<void> exportSongs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedSongs = prefs.getString('songs');

      if (savedSongs != null && savedSongs != '[]') {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/songs.json';

        final file = File(filePath);
        await file.writeAsString(savedSongs, flush: true);

        // Share the file
        await Share.shareXFiles([XFile(filePath)]);
        _showAlert('Export Successful', 'Songs exported successfully.');
      } else {
        _showAlert('No Songs to Export', 'There are no songs to export.');
      }
    } catch(error) {
      log('Error exporting songs: $error');
      _showAlert('Error', 'Failed to export songs.');
    }
  }

  Future<void> importSongs() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final filePath = result.files.single.path!;
        final file = File(filePath);

        String importedData = await file.readAsString();
        List<dynamic> importedSongs = jsonDecode(importedData);

        final prefs = await SharedPreferences.getInstance();
        String? savedSongs = prefs.getString('songs');
        List<dynamic> updatedSongs = savedSongs != null ? jsonDecode(savedSongs) : [];

        // Check for duplicate songs
        for (var song in importedSongs) {
          if (!updatedSongs.any((s) => s['id'] == song['id'])) {
            updatedSongs.add(song);
          }
        }

        await prefs.setString('songs', JsonEncoder.withIndent('    ').convert(updatedSongs));

        _showAlert('Import Successful', '${result.files.single.name} imported successfully.', true);
      } else {
        _showAlert('Import Cancelled', 'No file was selected.');
      }
    } catch (error) {
      log('Error importing songs: $error');
      _showAlert('Error', 'Failed to import songs.');
    }
  }

  void _showAlert(String title, String message, [bool? didImportResult]) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (ctx) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            Navigator.pop(ctx, didImportResult ?? false);
          }
        },
        child: AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, didImportResult ?? false),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      setState(() {
        didImport = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;

    final backgroundColor = isDarkMode ? Color(0xff171717) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final altTextColor = isDarkMode ? Colors.black : Colors.white;

    return PopScope(
      canPop: false, // Prevent default behavior of back button
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context, didImport);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff009788),
            title: Text(
              'Export/Import',
              style: TextStyle(
                color: altTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          iconTheme: IconThemeData(color: altTextColor), // Change the color of the back button
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, didImport),
          ),
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
              FlexibleWidthButton(
                label: 'Export',
                width: double.infinity,
                onPressed: exportSongs,
              ),
              SizedBox(height: 20),
      
              // Import Description
              FeatureDescription(
                heading: 'Import Songs from JSON File: ', 
                description: importDescription, 
                textColor: textColor
              ),
              SizedBox(height: 10),
              FlexibleWidthButton(
                label: 'Import',
                width: double.infinity,
                onPressed: importSongs,
              ),
              SizedBox(height: 20),
            ],
          )
        )
      ),
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