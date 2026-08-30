import 'package:flutter/material.dart';
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

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

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
}
