import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safequest/providers/app_provider.dart';
import 'package:safequest/services/data_service.dart';
import 'package:safequest/screens/game/game_screen.dart';
import 'package:safequest/screens/admin/admin_question_edit_screen.dart';
import 'package:safequest/screens/topics/topic_detail_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Admin updates topic, level, and question reflect immediately in AppProvider', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = AppProvider();
    await Future.delayed(const Duration(milliseconds: 200));

    // 1. Admin updates a Topic
    final originalTopic = provider.adminTopics.firstWhere((t) => t.id == 't1');
    final updatedTopic = originalTopic.copyWith(
      title: 'An toàn giao thông nâng cao',
      icon: '🚗',
    );
    await provider.saveTopic(updatedTopic);

    // Verify user topics has updated topic title & icon
    final userTopic = provider.topics.firstWhere((t) => t.id == 't1');
    expect(userTopic.title, 'An toàn giao thông nâng cao');
    expect(userTopic.icon, '🚗');

    // 2. Admin updates a Level
    final originalLevel = provider.levels.firstWhere((l) => l.id == 't1_l1');
    final updatedLevel = originalLevel.copyWith(
      title: 'Cấp độ 1: Khởi đầu siêu an toàn',
      description: 'Bài học đã được cập nhật bởi Admin',
    );
    await provider.saveLevel(updatedLevel);

    // Verify user levels has updated level
    final userLevel = provider.levels.firstWhere((l) => l.id == 't1_l1');
    expect(userLevel.title, 'Cấp độ 1: Khởi đầu siêu an toàn');
    expect(userLevel.description, 'Bài học đã được cập nhật bởi Admin');

    // 3. Admin updates Question text, options, correct answers and image
    final originalQuestion = provider.questions.firstWhere((q) => q.id == 't1_l1_q1');
    final updatedQuestion = originalQuestion.copyWith(
      question: 'Đèn đỏ có ý nghĩa gì đối với người tham gia giao thông?',
      options: ['Đi thẳng nhanh', 'Dừng lại hoàn toàn', 'Bấm còi liên tục'],
      correctAnswers: [1],
      image: '/path/to/custom_gallery_image.jpg',
    );
    await provider.saveQuestion(updatedQuestion);

    // Verify user questions has updated question
    final userQuestion = provider.questions.firstWhere((q) => q.id == 't1_l1_q1');
    expect(userQuestion.question, 'Đèn đỏ có ý nghĩa gì đối với người tham gia giao thông?');
    expect(userQuestion.options, ['Đi thẳng nhanh', 'Dừng lại hoàn toàn', 'Bấm còi liên tục']);
    expect(userQuestion.correctAnswers, [1]);
    expect(userQuestion.image, '/path/to/custom_gallery_image.jpg');

    // 4. Admin deletes a question
    await provider.deleteQuestion('t1_l1_q1');
    expect(provider.questions.any((q) => q.id == 't1_l1_q1'), false);
  });

  testWidgets('End-user sees and plays the updated question edited by Admin in GameScreen', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    final provider = AppProvider();
    await tester.pump(const Duration(milliseconds: 200));

    // Admin edits question t1_l1_q1
    final originalQuestion = provider.questions.firstWhere((q) => q.id == 't1_l1_q1');
    final editedQuestion = originalQuestion.copyWith(
      question: 'CÂU HỎI MỚI TỪ ADMIN: Đèn vàng thì con phải làm gì?',
      options: ['Phóng thật nhanh', 'Đi chậm và dừng trước vạch', 'Nhắm mắt đi tiếp'],
      correctAnswers: [1],
      explanation: 'Đèn vàng báo hiệu con cần giảm tốc độ và dừng lại trước vạch dừng.',
    );
    await provider.saveQuestion(editedQuestion);

    // Child opens GameScreen for level t1_l1
    final level = provider.levels.firstWhere((l) => l.id == 't1_l1');
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AppProvider>.value(
          value: provider,
          child: GameScreen(level: level),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify the child sees the newly edited question and options
    expect(find.text('CÂU HỎI MỚI TỪ ADMIN: Đèn vàng thì con phải làm gì?'), findsOneWidget);
    expect(find.text('Phóng thật nhanh'), findsOneWidget);
    expect(find.text('Đi chậm và dừng trước vạch'), findsOneWidget);
    expect(find.text('Nhắm mắt đi tiếp'), findsOneWidget);

    // Child selects the newly configured correct answer
    await tester.tap(find.text('Đi chậm và dừng trước vạch'));
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump(const Duration(milliseconds: 100));

    // Verify feedback shows the explanation
    expect(find.text('Đèn vàng báo hiệu con cần giảm tốc độ và dừng lại trước vạch dừng.'), findsOneWidget);
  });

  testWidgets('End-to-End Journey: Admin edits question in AdminQuestionEditScreen UI -> Child opens TopicDetailScreen & sees updated question in GameScreen', (tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    final provider = AppProvider();
    await tester.pump(const Duration(milliseconds: 200));

    // Admin login
    await provider.login('admin', '123');
    expect(provider.isAdmin, true);

    final topic = provider.adminTopics.firstWhere((t) => t.id == 't1');
    final questionToEdit = provider.questions.firstWhere((q) => q.id == 't1_l1_q1');

    // 1. Admin opens AdminQuestionEditScreen UI
    await tester.pumpWidget(
      ChangeNotifierProvider<AppProvider>.value(
        value: provider,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminQuestionEditScreen(
                        topic: topic,
                        question: questionToEdit,
                      ),
                    ),
                  );
                },
                child: const Text('Mở Admin Sửa'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mở Admin Sửa'));
    await tester.pumpAndSettle();

    // Verify initial values in Admin screen
    expect(find.text('Sửa câu hỏi'), findsOneWidget);
    expect(find.text('Đèn đỏ có ý nghĩa gì?'), findsOneWidget);

    // 2. Admin edits question text and explanation
    final questionField = find.widgetWithText(TextFormField, 'Câu hỏi');
    await tester.enterText(questionField, 'CÂU HỎI MỚI TỪ ADMIN: Khi thấy người già qua đường, con nên làm gì?');
    await tester.pumpAndSettle();

    final explanationField = find.widgetWithText(TextFormField, 'Giải thích (Khi trả lời đúng)');
    await tester.enterText(explanationField, 'Giúp đỡ người già qua đường là hành động văn minh và an toàn.');
    await tester.pumpAndSettle();

    // Scroll to and tap 'LƯU CÂU HỎI' button
    final saveButton = find.text('LƯU CÂU HỎI');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Verify question is updated in provider & DataService
    final updatedQ = (await DataService().getQuestions()).firstWhere((q) => q.id == 't1_l1_q1');
    expect(updatedQ.question, 'CÂU HỎI MỚI TỪ ADMIN: Khi thấy người già qua đường, con nên làm gì?');
    expect(updatedQ.explanation, 'Giúp đỡ người già qua đường là hành động văn minh và an toàn.');

    // 3. User perspective: User logs in, opens TopicDetailScreen
    await provider.register('kid_user', '123456');
    await provider.login('kid_user', '123456');
    await provider.saveProfile('Bé An', 6, '👦');

    await tester.pumpWidget(
      ChangeNotifierProvider<AppProvider>.value(
        value: provider,
        child: MaterialApp(
          key: UniqueKey(),
          home: TopicDetailScreen(topic: topic),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // User taps Level 1
    final level1Card = find.text('CẤP ĐỘ 1');
    expect(level1Card, findsOneWidget);
    await tester.ensureVisible(level1Card);
    await tester.tap(level1Card);
    await tester.pumpAndSettle();

    // 4. Verify GameScreen displays Admin's newly edited question to the child
    expect(find.text('CÂU HỎI MỚI TỪ ADMIN: Khi thấy người già qua đường, con nên làm gì?'), findsOneWidget);
  });
}
