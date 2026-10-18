import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safequest/providers/app_provider.dart';
import 'package:safequest/data/mock_data.dart';
import 'package:safequest/core/widgets/badge_congratulation_dialog.dart';
import 'package:safequest/screens/result/result_screen.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Completing level 1 of topic 4 unlocks "Lá Chắn Đầu Tiên" badge (b7)', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = AppProvider();
    
    // Wait for provider initialization
    await Future.delayed(const Duration(milliseconds: 300));

    // Register a test account
    await provider.register('testuser', '123456');
    await provider.login('testuser', '123456');
    await provider.saveProfile('Bé An', 7, '👦');

    expect(provider.unlockedBadges.contains('b7'), false);

    // Complete level 1 of topic An toàn với người lạ (t4_l1)
    final newlyUnlocked = await provider.completeLevel('t4_l1', 30);

    // Verify b7 is newly unlocked
    expect(newlyUnlocked.contains('b7'), true);
    expect(provider.unlockedBadges.contains('b7'), true);

    // Verify badge metadata
    final badge = MockContentRepository.getBadgeById('b7');
    expect(badge, isNotNull);
    expect(badge!.title, 'Lá Chắn Đầu Tiên');
    expect(badge.description, 'Vượt qua Level 1 của chủ đề An toàn với người lạ');
    expect(badge.icon, '🧤');

    // Completing again should not duplicate b7 in newly unlocked
    final secondRun = await provider.completeLevel('t4_l1', 30);
    expect(secondRun.contains('b7'), false);
  });

  testWidgets('BadgeCongratulationDialog renders badge details and completed condition correctly', (WidgetTester tester) async {
    final b7 = MockContentRepository.getBadgeById('b7')!;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => BadgeCongratulationDialog(badges: [b7]),
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      ),
    );

    // Tap button to show dialog
    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    // Verify dialog contents
    expect(find.text('🎉 Chúc Mừng Bạn! 🎉'), findsOneWidget);
    expect(find.text('Lá Chắn Đầu Tiên'), findsOneWidget);
    expect(find.text('🧤'), findsOneWidget);
    expect(find.text('Điều kiện đã hoàn thành:'), findsOneWidget);
    expect(find.text('Vượt qua Level 1 của chủ đề An toàn với người lạ'), findsOneWidget);
    expect(find.text('Đã lưu vào bộ sưu tập huy hiệu của bạn'), findsOneWidget);
    expect(find.text('TUYỆT VỜI! ✨'), findsOneWidget);

    // Tap dismiss button
    await tester.tap(find.text('TUYỆT VỜI! ✨'));
    await tester.pumpAndSettle();

    // Verify dialog dismissed
    expect(find.text('🎉 Chúc Mừng Bạn! 🎉'), findsNothing);
  });

  test('Verify badge list changes: b14 removed, b11 modified, b16-b20 added', () {
    // 1. Thợ Săn Thành Tích (b14) removed
    expect(MockContentRepository.getBadgeById('b14'), isNull);
    expect(MockContentRepository.badges.any((b) => b.id == 'b14'), false);

    // 2. Bộ Óc Siêu Biến (b11) modified
    final b11 = MockContentRepository.getBadgeById('b11');
    expect(b11, isNotNull);
    expect(b11!.title, 'Bộ Óc Siêu Biến');
    expect(b11.description, 'Trả lời đúng toàn bộ câu hỏi của 10 level trong 1 chủ đề bất kỳ');

    // 3. Làm Quen Đa Dạng (b16)
    final b16 = MockContentRepository.getBadgeById('b16');
    expect(b16, isNotNull);
    expect(b16!.title, 'Làm Quen Đa Dạng');
    expect(b16.description, 'Hoàn thành level 1 của 4 chủ đề');

    // 4. Làm Nhiều Quen Cách (b17)
    final b17 = MockContentRepository.getBadgeById('b17');
    expect(b17, isNotNull);
    expect(b17!.title, 'Làm Nhiều Quen Cách');
    expect(b17.description, 'Hoàn thành level 5 của 4 chủ đề');

    // 5. Đi Nhiều Nhớ Đường (b18)
    final b18 = MockContentRepository.getBadgeById('b18');
    expect(b18, isNotNull);
    expect(b18!.title, 'Đi Nhiều Nhớ Đường');
    expect(b18.description, 'Hoàn thành level 7 của 1 chủ đề bất kì');

    // 6. Tập Sự Sơ Cấp (b19)
    final b19 = MockContentRepository.getBadgeById('b19');
    expect(b19, isNotNull);
    expect(b19!.title, 'Tập Sự Sơ Cấp');
    expect(b19.description, 'Đạt 300 điểm học tập');

    // 7. Tập Sự Trung Cấp (b20)
    final b20 = MockContentRepository.getBadgeById('b20');
    expect(b20, isNotNull);
    expect(b20!.title, 'Tập Sự Trung Cấp');
    expect(b20.description, 'Đạt 1000 điểm học tập');
  });

  test('Unlock b16 (Làm Quen Đa Dạng) upon completing level 1 of 4 topics', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = AppProvider();
    await Future.delayed(const Duration(milliseconds: 200));
    await provider.register('user_b16', '123456');
    await provider.login('user_b16', '123456');
    await provider.saveProfile('Bé An', 7, '👦');

    expect(provider.unlockedBadges.contains('b16'), false);

    await provider.completeLevel('t1_l1', 10);
    expect(provider.unlockedBadges.contains('b16'), false);

    await provider.completeLevel('t2_l1', 10);
    expect(provider.unlockedBadges.contains('b16'), false);

    await provider.completeLevel('t3_l1', 10);
    expect(provider.unlockedBadges.contains('b16'), false);

    final newlyUnlocked = await provider.completeLevel('t4_l1', 10);
    expect(newlyUnlocked.contains('b16'), true);
    expect(provider.unlockedBadges.contains('b16'), true);
  });

  test('Unlock b17 (Làm Nhiều Quen Cách) upon completing level 5 of 4 topics', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = AppProvider();
    await Future.delayed(const Duration(milliseconds: 200));
    await provider.register('user_b17', '123456');
    await provider.login('user_b17', '123456');
    await provider.saveProfile('Bé An', 7, '👦');

    expect(provider.unlockedBadges.contains('b17'), false);

    await provider.completeLevel('t1_l5', 10);
    await provider.completeLevel('t2_l5', 10);
    await provider.completeLevel('t3_l5', 10);
    expect(provider.unlockedBadges.contains('b17'), false);

    final newlyUnlocked = await provider.completeLevel('t4_l5', 10);
    expect(newlyUnlocked.contains('b17'), true);
    expect(provider.unlockedBadges.contains('b17'), true);
  });

  test('Unlock b18 (Đi Nhiều Nhớ Đường) upon completing level 7 of any 1 topic', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = AppProvider();
    await Future.delayed(const Duration(milliseconds: 200));
    await provider.register('user_b18', '123456');
    await provider.login('user_b18', '123456');
    await provider.saveProfile('Bé An', 7, '👦');

    expect(provider.unlockedBadges.contains('b18'), false);

    final newlyUnlocked = await provider.completeLevel('t2_l7', 10);
    expect(newlyUnlocked.contains('b18'), true);
    expect(provider.unlockedBadges.contains('b18'), true);
  });

  test('Unlock b19 and b20 based on learning points thresholds (300 and 1000)', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = AppProvider();
    await Future.delayed(const Duration(milliseconds: 200));
    await provider.register('user_points', '123456');
    await provider.login('user_points', '123456');
    await provider.saveProfile('Bé An', 7, '👦');

    expect(provider.unlockedBadges.contains('b19'), false);
    expect(provider.unlockedBadges.contains('b20'), false);

    // Increase points to 290 - not reached yet
    await provider.updateProfile(addPoints: 290);
    expect(provider.unlockedBadges.contains('b19'), false);

    // Reach 300 points
    await provider.updateProfile(addPoints: 10);
    expect(provider.unlockedBadges.contains('b19'), true);
    expect(provider.unlockedBadges.contains('b20'), false);

    // Reach 1000 points
    await provider.updateProfile(addPoints: 700);
    expect(provider.unlockedBadges.contains('b20'), true);
  });

  test('Unlock b11 (Bộ Óc Siêu Biến) when answering perfectly 10 levels of any 1 topic', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = AppProvider();
    await Future.delayed(const Duration(milliseconds: 200));
    await provider.register('user_b11', '123456');
    await provider.login('user_b11', '123456');
    await provider.saveProfile('Bé An', 7, '👦');

    expect(provider.unlockedBadges.contains('b11'), false);

    // Complete 9 levels without wrong answers in topic t1
    for (int i = 1; i <= 9; i++) {
      await provider.completeLevel('t1_l$i', 30);
    }
    expect(provider.unlockedBadges.contains('b11'), false);

    // Complete 10th level
    final newlyUnlocked = await provider.completeLevel('t1_l10', 30);
    expect(newlyUnlocked.contains('b11'), true);
    expect(provider.unlockedBadges.contains('b11'), true);
  });

  testWidgets('ResultScreen displays all unlocked badges when 2 or more badges are unlocked', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = AppProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider<AppProvider>.value(
        value: provider,
        child: const MaterialApp(
          home: ResultScreen(
            score: 30,
            totalQuestions: 3,
            correctCount: 3,
            newlyUnlockedBadgeIds: ['b7', 'b16'],
          ),
        ),
      ),
    );

    // Fast forward past celebration sequence (700ms delay in ResultScreen)
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(milliseconds: 600));

    // Dismiss the popup dialog first if visible
    if (find.byType(BadgeCongratulationDialog).evaluate().isNotEmpty) {
      Navigator.of(tester.element(find.byType(BadgeCongratulationDialog))).pop();
      await tester.pump(const Duration(milliseconds: 500));
    }

    // Verify both badges are rendered on ResultScreen
    expect(find.descendant(of: find.byType(ResultScreen), matching: find.text('HUY HIỆU MỚI MỞ KHÓA (1/2)')), findsOneWidget);
    expect(find.descendant(of: find.byType(ResultScreen), matching: find.text('HUY HIỆU MỚI MỞ KHÓA (2/2)')), findsOneWidget);
    expect(find.descendant(of: find.byType(ResultScreen), matching: find.text('Lá Chắn Đầu Tiên')), findsOneWidget);
    expect(find.descendant(of: find.byType(ResultScreen), matching: find.text('Làm Quen Đa Dạng')), findsOneWidget);
  });
}

