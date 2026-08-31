import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chordmemoflutter/model/types.dart' as m;
import 'package:chordmemoflutter/view/song_form.dart';
import 'package:chordmemoflutter/view_model/settings_provider.dart';
import 'package:chordmemoflutter/view_model/song_repository.dart';

Widget _host(Widget child) => ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: MaterialApp(
        home: Navigator(
          onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => child),
        ),
      ),
    );

/// Adds a section to a freshly-pumped [SongForm] and returns a finder for its
/// (still empty) Chords field.
Future<Finder> _addSection(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(TextButton, 'ADD SECTION'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Verse'));
  await tester.pumpAndSettle();
  return find.widgetWithText(TextField, 'Chords');
}

String _chordsText(WidgetTester tester, Finder chordsField) =>
    tester.widget<TextField>(chordsField).controller!.text;

void main() {
  final clipboard = <String, Object?>{};

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    clipboard.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      switch (call.method) {
        case 'Clipboard.setData':
          clipboard['text'] = (call.arguments as Map)['text'];
          return null;
        case 'Clipboard.getData':
          return {'text': clipboard['text']};
        case 'Clipboard.hasStrings':
          return {'value': (clipboard['text'] as String?)?.isNotEmpty ?? false};
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('create mode: submit is gated until a title and a section exist',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_host(const SongForm()));
    await tester.pumpAndSettle();

    final submit = find.widgetWithText(TextButton, 'ADD SONG');
    expect(tester.widget<TextButton>(submit).onPressed, isNull);

    await tester.enterText(find.byType(TextField).first, 'Blue Bossa');
    await tester.pump();
    expect(tester.widget<TextButton>(submit).onPressed, isNull,
        reason: 'still gated with no sections');

    await tester.tap(find.widgetWithText(TextButton, 'ADD SECTION'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Verse'));
    await tester.pumpAndSettle();

    expect(tester.widget<TextButton>(submit).onPressed, isNotNull);

    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();

    final songs = await SongRepository.instance.loadSongs();
    expect(songs.single.title, 'Blue Bossa');
    expect(songs.single.sections.single.sectionTitle, 'Verse');
    expect(songs.single.createdAt, isNotNull);
  });

  testWidgets('edit mode: fields are pre-populated and update in place',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final original = m.Song(
      id: 'abc',
      title: 'Autumn Leaves',
      artist: 'Kosma',
      genres: const ['Jazz'],
      sections: [
        m.Section(
          sectionTitle: 'Whole',
          key: m.Key(tonic: 'G', symbol: '', mode: 'Minor'),
          chords: 'ii-V-i',
        ),
      ],
      createdAt: DateTime.parse('2020-01-01T00:00:00.000'),
    );
    await SongRepository.instance.addSong(original);

    await tester.pumpWidget(_host(SongForm(initialSong: original)));
    await tester.pumpAndSettle();

    expect(find.text('Autumn Leaves'), findsWidgets);
    expect(find.text('Kosma'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Autumn Leaves (Jazz)');
    await tester.pump();

    final submit = find.widgetWithText(TextButton, 'EDIT SONG');
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();

    final songs = await SongRepository.instance.loadSongs();
    expect(songs.length, 1);
    expect(songs.single.id, 'abc');
    expect(songs.single.title, 'Autumn Leaves (Jazz)');
    expect(songs.single.createdAt, DateTime.parse('2020-01-01T00:00:00.000'));
    expect(songs.single.updatedAt, isNotNull);
  });

  testWidgets('long-press Paste fills a Chords field from a valid clipboard',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_host(const SongForm()));
    await tester.pumpAndSettle();
    final chordsField = await _addSection(tester);

    await Clipboard.setData(const ClipboardData(text: 'I-vi-IV-V'));

    await tester.longPress(chordsField);
    await tester.pumpAndSettle();
    expect(find.text('Paste'), findsOneWidget);

    await tester.tap(find.text('Paste'));
    await tester.pumpAndSettle();

    expect(_chordsText(tester, chordsField), 'I-vi-IV-V');
  });

  testWidgets('long-press Paste rejects clipboard text that is not a progression',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_host(const SongForm()));
    await tester.pumpAndSettle();
    final chordsField = await _addSection(tester);

    await Clipboard.setData(const ClipboardData(text: 'just some prose'));

    await tester.longPress(chordsField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Paste'));
    await tester.pump(); // let the SnackBar appear

    expect(_chordsText(tester, chordsField), isEmpty);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Not a valid chord progression'), findsOneWidget);
  });
}
