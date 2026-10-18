import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safequest/providers/app_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SafeQuest 2-Attempt Scoring & Level Summary Rules Test', () {
    late AppProvider provider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      provider = AppProvider();
      await Future.delayed(const Duration(milliseconds: 200));

      await provider.register('player1', '123456');
      await provider.login('player1', '123456');
      await provider.saveProfile('Bé An', 7, '👦');
    });

    test('Đúng luôn lần 1 cả 3 câu: (10+10+10) = 30đ + 15đ tổng kết = 45 điểm', () async {
      expect(provider.profile?.points, 0);

      // Q1: 10, Q2: 10, Q3: 10 => 30 điểm câu hỏi + 15 điểm tổng kết (đúng cả 3) = 45 điểm
      const score = (10 + 10 + 10) + 15;
      await provider.completeLevel('t1_l1', score);

      expect(provider.isLevelCompleted('t1_l1'), true);
      expect(provider.profile?.points, 45);
    });

    test('Đúng lần 1 ở 2 câu, đúng lần 2 ở 1 câu (3 câu đúng): (10+10+5) = 25đ + 15đ tổng kết = 40 điểm', () async {
      expect(provider.profile?.points, 0);

      // Q1: 10, Q2: 10, Q3: 5 => 25 điểm câu hỏi + 15 điểm tổng kết (đúng cả 3) = 40 điểm
      const score = (10 + 10 + 5) + 15;
      await provider.completeLevel('t1_l2', score);

      expect(provider.isLevelCompleted('t1_l2'), true);
      expect(provider.profile?.points, 40);
    });

    test('Đúng lần 1 ở 1 câu, đúng lần 2 ở 1 câu, sai lần 2 ở 1 câu: (10+5+0) = 15đ + 10đ tổng kết = 25 điểm', () async {
      expect(provider.profile?.points, 0);

      // Q1: 10, Q2: 5, Q3: 0 => 15 điểm câu hỏi + 10 điểm tổng kết (đúng 2 câu, sai 1 câu) = 25 điểm
      const score = (10 + 5 + 0) + 10;
      await provider.completeLevel('t1_l3', score);

      expect(provider.isLevelCompleted('t1_l3'), true);
      expect(provider.profile?.points, 25);
    });

    test('Đúng lần 1 ở 1 câu, 2 câu còn lại sai cả 2 lần: (10+0+0) = 10đ + 5đ tổng kết = 15 điểm', () async {
      expect(provider.profile?.points, 0);

      // Q1: 10, Q2: 0, Q3: 0 => 10 điểm câu hỏi + 5 điểm tổng kết (đúng 1 câu, sai 2 câu) = 15 điểm
      const score = (10 + 0 + 0) + 5;
      await provider.completeLevel('t1_l4', score);

      expect(provider.isLevelCompleted('t1_l4'), true);
      expect(provider.profile?.points, 15);
    });

    test('Đúng lần 2 ở 1 câu (5đ), 2 câu còn lại sai cả 2 lần: (5+0+0) = 5đ + 5đ tổng kết = 10 điểm', () async {
      expect(provider.profile?.points, 0);

      // Q1: 5, Q2: 0, Q3: 0 => 5 điểm câu hỏi + 5 điểm tổng kết (đúng 1 câu, sai 2 câu) = 10 điểm
      const score = (5 + 0 + 0) + 5;
      await provider.completeLevel('t1_l5', score);

      expect(provider.isLevelCompleted('t1_l5'), true);
      expect(provider.profile?.points, 10);
    });

    test('Cả 3 câu đều sai cả 2 lần: không tính là hoàn thành, không mở khóa level tiếp theo, không cộng điểm', () async {
      expect(provider.profile?.points, 0);

      // Q1: 0, Q2: 0, Q3: 0 => 0 điểm câu hỏi + 0 điểm tổng kết = 0 điểm
      const score = 0;
      await provider.completeLevel('t1_l6', score, isCompleted: false);

      expect(provider.isLevelCompleted('t1_l6'), false);
      expect(provider.isLevelUnlocked('t1_l7'), false);
      expect(provider.profile?.points, 0);
    });

    test('Level cũ đã vượt qua rồi mà khi làm lại (trả lời đúng hoặc sai) thì KHÔNG cộng điểm', () async {
      // 1. Vượt qua level t1_l1 lần đầu (được 45 điểm)
      await provider.completeLevel('t1_l1', 45);
      expect(provider.profile?.points, 45);
      expect(provider.isLevelCompleted('t1_l1'), true);

      // 2. Làm lại level t1_l1 và đạt 45 điểm (đúng hết lần 1) -> KHÔNG cộng điểm
      await provider.completeLevel('t1_l1', 45);
      expect(provider.profile?.points, 45, reason: 'Làm lại trả lời đúng lần 1 không được cộng thêm điểm');

      // 3. Làm lại level t1_l1 với 25 điểm -> KHÔNG cộng điểm
      await provider.completeLevel('t1_l1', 25);
      expect(provider.profile?.points, 45, reason: 'Làm lại trả lời đúng lần 2 không được cộng thêm điểm');

      // 4. Làm lại level t1_l1 với 0 điểm (sai hết) -> KHÔNG cộng điểm
      await provider.completeLevel('t1_l1', 0);
      expect(provider.profile?.points, 45, reason: 'Làm lại sai hết không thay đổi điểm');
    });
  });
}
