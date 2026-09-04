import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chordmemoflutter/model/types.dart' as m;
import 'package:chordmemoflutter/view/search_dialog.dart';
import 'package:chordmemoflutter/view_model/settings_provider.dart';

m.Song _song(String id, String title, String chords) => m.Song(
      id: id,
      title: title,
      artist: '',
      genres: const [],
      sections: [
        m.Section(
          sectionTitle: 'Whole',
          key: m.Key(tonic: 'A', symbol: '', mode: 'Minor'),
          chords: chords,
        ),
      ],
    );

final _songs = [
  _song('1', 'Warum warum', 'i-VI7-V7'),
  _song('2', 'Something Else', 'I-IV-V'),
];

/// Pumps a button that opens [SearchDialog] and records the popped result.
Future<List<m.Song>?> _openAndRun(
  WidgetTester tester,
  Future<void> Function(WidgetTester tester) drive,
) async {
  List<m.Song>? result;
  var popped = false;

  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await showDialog<List<m.Song>>(
                    context: context,
                    builder: (_) => SearchDialog(songs: _songs),
                  );
                  popped = true;
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();

  await drive(tester);

  await tester.tap(find.text('SEARCH'));
  await tester.pumpAndSettle();

  expect(popped, isTrue);
  return result;
}

Finder _chordsRadio() => find.byWidgetPredicate(
      (w) => w is Radio<String> && w.value == 'Chords',
    );

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('the toggle only appears once Chords is selected', (tester) async {
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _openAndRun(tester, (tester) async {
      expect(find.text('Ignore chord extensions'), findsNothing);

      await tester.tap(_chordsRadio());
      await tester.pump();

      expect(find.text('Ignore chord extensions'), findsOneWidget);
    });
  });

  testWidgets('toggle on: i-VI-V finds a song stored as i-VI7-V7',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final result = await _openAndRun(tester, (tester) async {
      await tester.tap(_chordsRadio());
      await tester.pump();
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'i-VI-V');
    });

    expect(result, isNotNull);
    expect(result!.map((s) => s.id), ['1']);
  });

  testWidgets('toggle off: i-VI-V does not match i-VI7-V7 literally',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final result = await _openAndRun(tester, (tester) async {
      await tester.tap(_chordsRadio());
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'i-VI-V');
    });

    expect(result, isNotNull);
    expect(result, isEmpty);
  });
}
