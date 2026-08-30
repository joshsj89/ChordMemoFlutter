import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chordmemoflutter/main.dart';
import 'package:chordmemoflutter/view_model/settings_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    dotenv.testLoad(fileInput: 'DONATE_LINK=https://example.com');
  });

  testWidgets('app boots to the ChordMemo home screen', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SettingsProvider(),
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // The home screen AppBar title.
    expect(find.text('ChordMemo'), findsWidgets);
    // With no saved songs the list is empty and the add button is shown.
    expect(find.byTooltip('Add Song'), findsOneWidget);
  });
}
