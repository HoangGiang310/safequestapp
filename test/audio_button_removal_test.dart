import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:safequest/providers/app_provider.dart';
import 'package:safequest/screens/game/game_screen.dart';
import 'package:safequest/core/widgets/custom_widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AudioButton is present in question card and in "Tuyệt vời" bottom sheet', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    final provider = AppProvider();
    await tester.pump(const Duration(milliseconds: 200));
    await provider.register('audio_test_user', '123456');
    await provider.login('audio_test_user', '123456');
    await provider.saveProfile('Bé Linh', 6, '👧');

    final level = provider.levels.firstWhere((l) => l.id == 't1_l1');

    await tester.pumpWidget(
      ChangeNotifierProvider<AppProvider>.value(
        value: provider,
        child: MaterialApp(
          home: GameScreen(level: level),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify that the question card contains an AudioButton with 'NGHE'
    expect(find.byType(AudioButton), findsOneWidget, reason: 'Question card must display AudioButton');
    expect(find.text('NGHE'), findsOneWidget);

    // 2. Answer question 1 correctly: tap 'Dừng lại'
    await tester.tap(find.text('Dừng lại'));
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 500));

    // Verify "Tuyệt vời!" bottom sheet is visible
    expect(find.text('Tuyệt vời!'), findsOneWidget);

    // Verify AudioButton is present in "Tuyệt vời!" bottom sheet
    // There will now be AudioButton in question card and in bottom sheet
    expect(find.byType(AudioButton), findsNWidgets(2), reason: 'Bottom sheet and question card must display AudioButton');
    expect(find.text('Bé có thể nghe lại lời giải thích'), findsOneWidget);
  });
}

