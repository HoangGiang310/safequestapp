import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:safequest/providers/app_provider.dart';
import 'package:safequest/screens/home/home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Daily Check-In feature: grants 30 points and adds study date without increasing streak', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    final provider = AppProvider();
    await tester.pump(const Duration(milliseconds: 200));

    // Register & Login child account
    await provider.register('be_an', '123456');
    await provider.login('be_an', '123456');
    await provider.saveProfile('Bé An', 6, '👦');

    expect(provider.profile!.points, 0);
    expect(provider.profile!.streak, 0);
    expect(provider.profile!.studyDates.length, 0);
    expect(provider.isTodayCheckedIn, false);

    // 1. Render HomeScreen
    await tester.pumpWidget(
      ChangeNotifierProvider<AppProvider>.value(
        value: provider,
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Check greeting and "Điểm Danh" button presence
    expect(find.text('Chào Bé An!'), findsOneWidget);
    expect(find.text('Cùng khám phá bài học mới nào!'), findsOneWidget);
    expect(find.text('Điểm Danh'), findsOneWidget);
    expect(find.text('+30 ⭐'), findsOneWidget);

    // 2. Tap "Điểm Danh" button
    await tester.tap(find.text('Điểm Danh'));
    await tester.pumpAndSettle();

    // Verify dialog appears
    expect(find.text('Điểm Danh Thành Công!'), findsOneWidget);
    expect(find.text('+30 Điểm Học Tập'), findsOneWidget);
    expect(find.text('Tài khoản của con đã được cộng 30 điểm học tập và tính thêm 1 ngày sử dụng app!'), findsOneWidget);

    // Verify state updates: +30 points, +1 study date, streak remains 0
    expect(provider.profile!.points, 30);
    expect(provider.profile!.studyDates.length, 1);
    expect(provider.profile!.streak, 0);
    expect(provider.isTodayCheckedIn, true);

    // Close the dialog
    await tester.tap(find.text('NHẬN ĐIỂM NGAY'));
    await tester.pumpAndSettle();

    // Verify button now shows "Đã điểm danh"
    expect(find.text('Đã điểm danh'), findsOneWidget);

    // 3. Tapping "Đã điểm danh" does not give points again
    await tester.tap(find.text('Đã điểm danh'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(provider.profile!.points, 30); // Still 30

    // 4. Completing a level later today correctly increments streak to 1
    await provider.completeLevel('t1_l1', 15, isCompleted: true);
    expect(provider.profile!.streak, 1);
    // Study dates count remains 1 (same day doesn't duplicate)
    expect(provider.profile!.studyDates.length, 1);
  });
}
