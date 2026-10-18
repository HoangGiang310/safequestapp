import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safequest/providers/app_provider.dart';

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
}
