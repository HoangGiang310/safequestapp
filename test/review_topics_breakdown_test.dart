import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:safequest/providers/app_provider.dart';
import 'package:safequest/screens/review/review_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ReviewScreen splits wrong questions into separate topic cards with topic and level details', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    final provider = AppProvider();
    await tester.pump(const Duration(milliseconds: 300));

    await provider.register('user_rev_1', '123456');
    await provider.login('user_rev_1', '123456');
    await provider.saveProfile('Bé Hoa', 6, '👧');

    // Add wrong questions from 2 different topics: t1 and t2
    // t1_l1_q1 (Topic 1, Level 1)
    // t1_l2_q1 (Topic 1, Level 2)
    // t2_l1_q1 (Topic 2, Level 1)
    await provider.recordWrongQuestion('t1_l1_q1');
    await provider.recordWrongQuestion('t1_l2_q1');
    await provider.recordWrongQuestion('t2_l1_q1');

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

    // Verify header and instruction
    expect(find.text('PHÒNG LUYỆN TẬP'), findsOneWidget);
    expect(find.text('Bé có câu sai ở 2 chủ đề. Hãy chọn từng chủ đề bên dưới để sửa lỗi nhé!'), findsOneWidget);

    // Verify Topic 1 card
    expect(find.text('Chủ đề: An toàn giao thông'), findsOneWidget);
    expect(find.text('2 câu cần sửa lỗi'), findsOneWidget);
    expect(find.text('Level 1 (1 câu sai)'), findsNWidgets(2));
    expect(find.text('Level 2 (1 câu sai)'), findsOneWidget);

    // Verify Topic 2 card
    expect(find.text('Chủ đề: An toàn trong nhà'), findsOneWidget);
    expect(find.text('1 câu cần sửa lỗi'), findsOneWidget);

    // Verify two separate "LÀM LẠI" buttons exist
    expect(find.text('LÀM LẠI'), findsNWidgets(2));
  });

  testWidgets('When all wrong questions are cleared, ReviewScreen shows celebratory empty state', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = AppProvider();
    await tester.pump(const Duration(milliseconds: 300));

    await provider.register('user_rev_2', '123456');
    await provider.login('user_rev_2', '123456');
    await provider.saveProfile('Bé An', 7, '👦');

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

    expect(find.text('XUẤT SẮC QUÁ!'), findsOneWidget);
    expect(find.text('SẴN SÀNG CHO BÀI HỌC MỚI'), findsOneWidget);
  });
}
