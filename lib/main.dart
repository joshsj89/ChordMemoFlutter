import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'package:chordmemoflutter/theme/app_theme.dart';
import 'package:chordmemoflutter/view/home_screen.dart';
import 'package:chordmemoflutter/view_model/settings_provider.dart';

Future main() async {
  await dotenv.load(fileName: '.env');

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding); // keep showing splash screen until .remove() is called

  // Force portrait mode
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<SettingsProvider>().themeMode;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChordMemo',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    initialization();
  }

  void initialization() async {
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return HomeScreen();
  }
}
