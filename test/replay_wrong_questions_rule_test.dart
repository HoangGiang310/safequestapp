import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:safequest/providers/app_provider.dart';
import 'package:safequest/navigation/main_navigation.dart';
import 'package:safequest/screens/review/review_screen.dart';
import 'package:safequest/screens/game/game_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Bottom navigation tab displays LUYỆN TẬP instead of BÍ KÍP', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    final provider = AppProvider();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.pumpWidget(
      ChangeNotifierProvider<AppProvider>.value(
        value: provider,
        child: const MaterialApp(
          home: MainNavigation(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('LUYỆN TẬP'), findsOneWidget);
    expect(find.text('BÍ KÍP'), findsNothing);
  });

  testWidgets('ReviewScreen displays PHÒNG LUYỆN TẬP and LÀM LẠI button', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    final provider = AppProvider();
    await tester.pump(const Duration(milliseconds: 200));
    await provider.register('test_user', '123456');
    await provider.login('test_user', '123456');
    await provider.saveProfile('Bé Mai', 6, '👧');

    await provider.recordWrongQuestion('t1_l1_q1');

    await tester.pumpWidget(
      ChangeNotifierProvider<AppProvider>.value(
        value: provider,
        child: const MaterialApp(
          home: Scaffold(
            body: ReviewScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('PHÒNG LUYỆN TẬP'), findsOneWidget);
    expect(find.text('LÀM LẠI'), findsOneWidget);
    expect(find.text('PHÒNG LUYỆN BÍ KÍP'), findsNothing);
    expect(find.text('SỬA LỖI CHỦ ĐỀ NÀY'), findsNothing);
  });

  Future<void> answerAll3QuestionsWrong(WidgetTester tester) async {
    // Q1: 'Đèn đỏ có ý nghĩa gì?' -> Wrong: 'Đi tiếp'
    await tester.tap(find.text('Đi tiếp'));
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('THỬ LẠI'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Đi tiếp'));
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('TIẾP TỤC'));
    await tester.pumpAndSettle();

    // Q2: 'Đi bộ qua đường ở đâu là an toàn?' -> Wrong: 'Bất cứ đâu'
    await tester.tap(find.text('Bất cứ đâu'));
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('THỬ LẠI'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bất cứ đâu'));
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('TIẾP TỤC'));
    await tester.pumpAndSettle();

    // Q3: 'Những việc cần làm khi ngồi trên xe máy?' -> Wrong: 'Đứng lên yên xe'
    await tester.tap(find.text('Đứng lên yên xe'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('KIỂM TRA ĐÁP ÁN'));
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('THỬ LẠI'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Đứng lên yên xe'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('KIỂM TRA ĐÁP ÁN'));
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('TIẾP TỤC'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 3));
  }

  testWidgets('New level: failing all 3 questions records them into wrong questions', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    final provider = AppProvider();
    await tester.pump(const Duration(milliseconds: 200));
    await provider.register('test_user_fail_new', '123456');
    await provider.login('test_user_fail_new', '123456');
    await provider.saveProfile('Bé Tí', 6, '👦');

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

    // Answer all 3 questions wrong
    await answerAll3QuestionsWrong(tester);

    // Now provider should have recorded the wrong questions
    expect(provider.wrongQuestions.length, 3, reason: 'Failing all 3 questions on a new level MUST transfer them to wrongQuestions');
    expect(provider.wrongQuestions.contains('t1_l1_q1'), true);
    expect(provider.wrongQuestions.contains('t1_l1_q2'), true);
    expect(provider.wrongQuestions.contains('t1_l1_q3'), true);
  });

  testWidgets('Completed level replay: failing all 3 questions does NOT record into wrong questions', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    final provider = AppProvider();
    await tester.pump(const Duration(milliseconds: 200));
    await provider.register('test_user_replay', '123456');
    await provider.login('test_user_replay', '123456');
    await provider.saveProfile('Bé Tèo', 6, '👦');

    // Complete level t1_l1 first
    await provider.completeLevel('t1_l1', 45);
    expect(provider.isLevelCompleted('t1_l1'), true);
    expect(provider.wrongQuestions.isEmpty, true);

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

    // Answer all 3 questions wrong on replay
    await answerAll3QuestionsWrong(tester);

    // Wrong questions MUST still be empty because this level was already completed!
    expect(provider.wrongQuestions.isEmpty, true, reason: 'Replaying completed level and failing all 3 questions must NOT transfer to wrongQuestions');
  });
}
