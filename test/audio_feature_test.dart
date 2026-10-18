import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:safequest/providers/app_provider.dart';
import 'package:safequest/screens/game/game_screen.dart';
import 'package:safequest/core/widgets/custom_widgets.dart';
import 'package:safequest/services/audio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('AudioService child speed and pitch configuration is optimal for children', () {
    expect(AudioService.defaultSpeechRate, 0.48);
    expect(AudioService.defaultPitch, 1.0);
    expect(AudioService.defaultVolume, 1.0);
  });

  testWidgets('AudioButton renders in Question Card, "Tuyệt vời", and "Thử lại nhé" sheets', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    final provider = AppProvider();
    await tester.pump(const Duration(milliseconds: 200));
    await provider.register('kid_user', '123456');
    await provider.login('kid_user', '123456');
    await provider.saveProfile('Bé Bắp', 6, '👦');

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

    // 1. Question card has AudioButton with 'NGHE'
    expect(find.byType(AudioButton), findsOneWidget);
    expect(find.text('NGHE'), findsOneWidget);

    // 2. Test tapping wrong answer on attempt 1 -> "Thử lại nhé!" bottom sheet appears
    // Wrong answer for question 1: 'Đi tiếp' (correct is 'Dừng lại')
    await tester.tap(find.text('Đi tiếp'));
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Thử lại nhé!'), findsOneWidget);
    // Should display 'NGHE GỢI Ý' button in bottom sheet
    expect(find.text('NGHE GỢI Ý'), findsOneWidget);
    expect(find.text('Bé có thể nghe gợi ý để thử lại nhé'), findsOneWidget);

    // Close bottom sheet by tapping 'THỬ LẠI'
    await tester.tap(find.text('THỬ LẠI'));
    await tester.pumpAndSettle();

    // 3. Test tapping correct answer -> "Tuyệt vời!" bottom sheet appears
    await tester.tap(find.text('Dừng lại'));
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Tuyệt vời!'), findsOneWidget);
    expect(find.text('Bé có thể nghe lại lời giải thích'), findsOneWidget);
    expect(find.byType(AudioButton), findsNWidgets(2)); // Question card + Tuyệt vời sheet
  });
}
