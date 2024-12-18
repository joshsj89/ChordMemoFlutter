import 'package:flutter/material.dart';

import 'about_screen.dart';
import 'export_import_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isDarkMode = false;

  void _toggleDarkMode() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  void initState() {
    super.initState();
    // _loadSongs();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

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
                  builder: (_) => AboutScreen(isDarkMode: isDarkMode),
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExportImportScreen(isDarkMode: isDarkMode),
                  )
                );
              },
            ),
            ListTile(
              title: Text('Dark Mode: ${isDarkMode ? 'On' : 'Off'}', style: TextStyle(color: textColor)),
              onTap: _toggleDarkMode,
            ),
            ListTile(
              title: Text('About', style: TextStyle(color: textColor)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AboutScreen(isDarkMode: isDarkMode),
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
      body: Center(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Add Song',
        backgroundColor: Color(0xff009788),
        child: Icon(Icons.add, color: backgroundColor),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}