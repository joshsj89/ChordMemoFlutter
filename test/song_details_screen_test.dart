import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chordmemoflutter/model/types.dart' as m;
import 'package:chordmemoflutter/view/song_details_screen.dart';
import 'package:chordmemoflutter/view_model/settings_provider.dart';

m.Song _song() => m.Song(
      id: '1',
      title: 'Test Tune',
      artist: 'Nobody',
      genres: const ['Jazz'],
      sections: [
        m.Section(
          sectionTitle: 'Whole',
          key: m.Key(tonic: 'C', symbol: '', mode: 'Major'),
          chords: 'ii7-V7-IM7',
        ),
      ],
    );

Widget _host(Widget child) => ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: MaterialApp(
        home: Navigator(
          onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => child),
        ),
      ),
    );

Finder _richTextContaining(String text) =>
    find.textContaining(text, findRichText: true);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('numerals by default; toggle to chords and transpose', (tester) async {
    await tester.pumpWidget(_host(SongDetailsScreen(song: _song())));
    await tester.pumpAndSettle();

    // Reveal the sections.
    await tester.tap(find.text('Test Tune').first);
    await tester.pumpAndSettle();

    // Default view: the key label reads the stored key, transpose controls hidden.
    expect(_richTextContaining('C Major -'), findsOneWidget);
    expect(find.text('Numerals'), findsOneWidget);
    expect(find.byTooltip('Up a semitone'), findsNothing);

    // Switch to concrete chords.
    await tester.tap(find.text('Chords'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Up a semitone'), findsOneWidget);
    expect(find.text('Original key'), findsOneWidget);
    // ii7 in C major spells D...m7 (root and quality are separate spans).
    expect(find.text('D'), findsWidgets);

    // Transpose up two semitones -> key label becomes D major.
    await tester.tap(find.byTooltip('Up a semitone'));
    await tester.tap(find.byTooltip('Up a semitone'));
    await tester.pumpAndSettle();

    expect(_richTextContaining('D Major -'), findsOneWidget);
    expect(find.text('+2 semitones'), findsOneWidget);

    // Reset returns to the original key.
    await tester.tap(find.byTooltip('Reset to original key'));
    await tester.pumpAndSettle();
    expect(_richTextContaining('C Major -'), findsOneWidget);
  });

  testWidgets('sharp/flat toggle only appears at an enharmonic tie', (tester) async {
    await tester.pumpWidget(_host(SongDetailsScreen(song: _song())));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Test Tune').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chords'));
    await tester.pumpAndSettle();

    // +2 semitones (D major) is unambiguous -> no preference toggle.
    await tester.tap(find.byTooltip('Up a semitone'));
    await tester.tap(find.byTooltip('Up a semitone'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Prefer'), findsNothing);

    // +6 semitones (F#/Gb) is the tritone tie -> toggle shows.
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.byTooltip('Up a semitone'));
    }
    await tester.pumpAndSettle();
    expect(find.textContaining('Prefer'), findsOneWidget);
    expect(_richTextContaining('F♯ Major -'), findsOneWidget);

    await tester.tap(find.textContaining('Prefer'));
    await tester.pumpAndSettle();
    expect(_richTextContaining('G♭ Major -'), findsOneWidget);
  });
}
