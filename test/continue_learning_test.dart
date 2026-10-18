import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safequest/providers/app_provider.dart';
import 'package:safequest/models/models.dart';
import 'package:safequest/screens/home/home_screen.dart';
import 'package:safequest/screens/topics/topic_detail_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Continue learning reflects the topic with the highest level reached for the account', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = AppProvider();
    await Future.delayed(const Duration(milliseconds: 300));

    // Register and login user 1
    await provider.register('user_test_1', '123456');
    await provider.login('user_test_1', '123456');
    await provider.saveProfile('Bé Hoa', 6, '👧');

    // Initially with 0 completed levels, it should show topic 1 at level 1
    var context1 = provider.getContinueLearningContext();
    expect((context1['topic'] as Topic).id, 't1');
    expect((context1['level'] as Level).id, 't1_l1');

    // User 1 completes level 1 of topic 4 (An toàn với người lạ)
    await provider.completeLevel('t4_l1', 30);

    // Now topic 4 has reached level 2 (higher than topic 1, 2, 3 which are at level 1)
    var contextAfterT4 = provider.getContinueLearningContext();
    expect((contextAfterT4['topic'] as Topic).id, 't4');
    expect((contextAfterT4['topic'] as Topic).title, 'An toàn với người lạ');
    expect((contextAfterT4['level'] as Level).id, 't4_l2');
    expect((contextAfterT4['level'] as Level).title, 'Cấp độ 2');

    // User 1 now progresses topic 2 to level 4 (completes t2_l1, t2_l2, t2_l3)
    await provider.completeLevel('t2_l1', 30);
    await provider.completeLevel('t2_l2', 30);
    await provider.completeLevel('t2_l3', 30);

    // Now topic 2 is at level 4 (higher than topic 4 which is at level 2)
    var contextAfterT2 = provider.getContinueLearningContext();
    expect((contextAfterT2['topic'] as Topic).id, 't2');
    expect((contextAfterT2['topic'] as Topic).title, 'An toàn trong nhà');
    expect((contextAfterT2['level'] as Level).id, 't2_l4');
    expect((contextAfterT2['level'] as Level).title, 'Cấp độ 4');
  });

  testWidgets('Tapping Continue Learning button on HomeScreen navigates to TopicDetailScreen of that topic', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = AppProvider();
    await tester.pump(const Duration(milliseconds: 300));

    await provider.register('user_test_nav', '123456');
    await provider.login('user_test_nav', '123456');
    await provider.saveProfile('Bé Minh', 7, '👦');

    // Complete level 1 of topic 4 so topic 4 has the highest level
    await provider.completeLevel('t4_l1', 30);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    debugPrint('=== PUMP 1 DONE ===');

    // Verify card shows Topic 4: An toàn với người lạ and Cấp độ 2
    expect(find.text('An toàn với người lạ'), findsWidgets);
    expect(find.text('Cấp độ 2'), findsOneWidget);

    // Tap "TIẾP TỤC" button
    final continueButton = find.text('TIẾP TỤC');
    expect(continueButton, findsOneWidget);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    // Verify it navigated into TopicDetailScreen of "An toàn với người lạ"
    expect(find.byType(TopicDetailScreen), findsOneWidget);
    expect(find.text('An toàn với người lạ'), findsWidgets);
  });
}
