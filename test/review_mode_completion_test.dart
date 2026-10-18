import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:safequest/providers/app_provider.dart';
import 'package:safequest/screens/game/game_screen.dart';
import 'package:safequest/screens/result/result_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ResultScreen in review mode displays "Hoàn thành ôn tập!" and encouragement message', (WidgetTester tester) async {
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
          home: ResultScreen(
            score: 0,
            correctCount: 2,
            totalQuestions: 3,
            isReviewMode: true,
          ),
        ),
      ),
    );

    // Fast-forward animation & celebration delay
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Hoàn thành ôn tập!'), findsOneWidget);
    expect(find.text('Con đã cố gắng làm rất tốt. Hãy cố gắng ôn luyện nhiều hơn nhé.'), findsOneWidget);
    expect(find.text('Số câu đúng: 2/3 câu'), findsOneWidget);
    expect(find.text('Con chưa trả lời đúng câu nào!'), findsNothing);
    expect(find.text('QUAY LẠI LUYỆN TẬP'), findsOneWidget);
    expect(find.text('VỀ TRANG CHỦ'), findsOneWidget);

    // Let the 2-second confetti timer complete
    await tester.pump(const Duration(seconds: 3));
  });

  Future<void> answerQ1Correct(WidgetTester tester) async {
    // Q1: 'Đèn đỏ có ý nghĩa gì?' -> Correct: 'Dừng lại'
    await tester.tap(find.text('Dừng lại'));
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('TIẾP TỤC'));
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> answerQ2Correct(WidgetTester tester) async {
    // Q2: 'Đi bộ qua đường ở đâu là an toàn?' -> Correct: 'Vạch kẻ đường'
    await tester.tap(find.text('Vạch kẻ đường'));
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('TIẾP TỤC'));
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> answerQ2WrongTwice(WidgetTester tester) async {
    // Q2: 'Đi bộ qua đường ở đâu là an toàn?' -> Wrong: 'Bất cứ đâu'
    await tester.tap(find.text('Bất cứ đâu'));
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('THỬ LẠI'));
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('Bất cứ đâu'));
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('TIẾP TỤC'));
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> answerQ3Correct(WidgetTester tester) async {
    // Q3: 'Những việc cần làm khi ngồi trên xe máy?' -> Correct: 'Đội mũ bảo hiểm', 'Bám chặt người lái'
    await tester.tap(find.text('Đội mũ bảo hiểm'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('Bám chặt người lái'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('KIỂM TRA ĐÁP ÁN'));
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('TIẾP TỤC'));
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 1000));
  }

  testWidgets('Practice mode with 2/3 correct does NOT remove wrong questions and awards no points/level unlock', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    final provider = AppProvider();
    await tester.pump(const Duration(milliseconds: 200));
    await provider.register('user_test_review_partial', '123456');
    await provider.login('user_test_review_partial', '123456');
    await provider.saveProfile('Bé An', 6, '👧');

    // Add 3 wrong questions to practice
    await provider.recordWrongQuestion('t1_l1_q1');
    await provider.recordWrongQuestion('t1_l1_q2');
    await provider.recordWrongQuestion('t1_l1_q3');

    expect(provider.wrongQuestions.length, 3);
    final initialScore = provider.profile?.points ?? 0;
    expect(provider.isLevelCompleted('t1_l1'), false);

    await tester.pumpWidget(
      ChangeNotifierProvider<AppProvider>.value(
        value: provider,
        child: const MaterialApp(
          home: GameScreen(
            isReviewMode: true,
            reviewTopicId: 't1',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Q1: correct
    await answerQ1Correct(tester);
    // Q2: wrong
    await answerQ2WrongTwice(tester);
    // Q3: correct
    await answerQ3Correct(tester);

    // Fast-forward delay on ResultScreen
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 1000));

    // Verify ResultScreen content
    expect(find.text('Hoàn thành ôn tập!'), findsOneWidget);
    expect(find.text('Con đã cố gắng làm rất tốt. Hãy cố gắng ôn luyện nhiều hơn nhé.'), findsOneWidget);
    expect(find.text('Số câu đúng: 2/3 câu'), findsOneWidget);
    expect(find.text('Con chưa trả lời đúng câu nào!'), findsNothing);

    // Verify wrong questions STILL REMAIN because not 3/3
    expect(provider.wrongQuestions.length, 3, reason: 'Questions must remain in Luyện Tập because child did not get 3/3');

    // Verify no points added and no level completed
    expect(provider.profile?.points ?? 0, initialScore, reason: 'Review mode must not award points');
    expect(provider.isLevelCompleted('t1_l1'), false, reason: 'Review mode must not complete levels');
    expect(provider.isLevelUnlocked('t1_l2'), false, reason: 'Review mode must not unlock new levels');
  });

  testWidgets('Practice mode with 3/3 correct removes wrong questions from Luyện Tập', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    final provider = AppProvider();
    await tester.pump(const Duration(milliseconds: 200));
    await provider.register('user_test_review_full', '123456');
    await provider.login('user_test_review_full', '123456');
    await provider.saveProfile('Bé Bình', 6, '👦');

    // Add 3 wrong questions to practice
    await provider.recordWrongQuestion('t1_l1_q1');
    await provider.recordWrongQuestion('t1_l1_q2');
    await provider.recordWrongQuestion('t1_l1_q3');

    expect(provider.wrongQuestions.length, 3);
    final initialScore = provider.profile?.points ?? 0;
    expect(provider.isLevelCompleted('t1_l1'), false);

    await tester.pumpWidget(
      ChangeNotifierProvider<AppProvider>.value(
        value: provider,
        child: const MaterialApp(
          home: GameScreen(
            isReviewMode: true,
            reviewTopicId: 't1',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Q1: correct
    await answerQ1Correct(tester);
    // Q2: correct
    await answerQ2Correct(tester);
    // Q3: correct
    await answerQ3Correct(tester);

    // Fast-forward delay on ResultScreen
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 1000));

    // Verify ResultScreen content
    expect(find.text('Hoàn thành ôn tập!'), findsOneWidget);
    expect(find.text('Con đã cố gắng làm rất tốt. Hãy cố gắng ôn luyện nhiều hơn nhé.'), findsOneWidget);
    expect(find.text('Số câu đúng: 3/3 câu'), findsOneWidget);

    // Verify all 3 questions disappeared because 3/3 correct
    expect(provider.wrongQuestions.isEmpty, true, reason: 'All 3 questions must disappear when child scores 3/3 in review');

    // Verify no points added and no level completed
    expect(provider.profile?.points ?? 0, initialScore, reason: 'Review mode must not award points');
    expect(provider.isLevelCompleted('t1_l1'), false, reason: 'Review mode must not complete levels');
    expect(provider.isLevelUnlocked('t1_l2'), false, reason: 'Review mode must not unlock new levels');
  });
}
