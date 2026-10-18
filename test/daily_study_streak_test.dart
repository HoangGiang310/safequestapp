import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safequest/providers/app_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Daily Study & Streak Rules Test', () {
    late AppProvider provider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      provider = AppProvider();
      await Future.delayed(const Duration(milliseconds: 200));

      await provider.register('streak_tester', '123456');
      await provider.login('streak_tester', '123456');
      await provider.saveProfile('Bé Bông', 7, '👧');
    });

    test('Initial profile has streak 0 and 0 study dates', () {
      expect(provider.profile?.streak, 0);
      expect(provider.profile?.longestStreak, 0);
      expect(provider.profile?.studyDates.isEmpty, true);
    });

    test('Hoàn thành 1 level mới trong ngày: tính là ngày hôm đó đã học và cập nhật chuỗi lên 1', () async {
      final today = DateTime(2026, 10, 14);
      final todayStr = "2026-10-14";

      // Complete a new level on today
      await provider.completeLevel('t1_l1', 45, isCompleted: true, completionDate: today);

      expect(provider.isLevelCompleted('t1_l1'), true);
      expect(provider.profile?.studyDates.contains(todayStr), true, reason: 'Ngày hôm nay phải được ghi nhận đã học');
      expect(provider.profile?.streak, 1, reason: 'Chuỗi học tập phải được cập nhật thành 1');
      expect(provider.profile?.longestStreak, 1);
    });

    test('Hoàn thành thêm level mới thứ 2 trong cùng một ngày: không tăng thêm chuỗi trong ngày đó', () async {
      final today = DateTime(2026, 10, 14);
      final todayStr = "2026-10-14";

      // Level 1 on today
      await provider.completeLevel('t1_l1', 45, isCompleted: true, completionDate: today);
      expect(provider.profile?.streak, 1);
      expect(provider.profile?.studyDates.length, 1);

      // Level 2 (cũng là level mới) on the same day
      await provider.completeLevel('t1_l2', 45, isCompleted: true, completionDate: today);
      expect(provider.profile?.streak, 1, reason: 'Chuỗi chỉ tăng 1 lần mỗi ngày dù hoàn thành nhiều level mới');
      expect(provider.profile?.studyDates.length, 1);
      expect(provider.profile?.studyDates.first, todayStr);
    });

    test('Làm lại level cũ đã vượt qua: KHÔNG tính là ngày hôm đó đã học và KHÔNG cập nhật chuỗi', () async {
      final day1 = DateTime(2026, 10, 14);
      final day2 = DateTime(2026, 10, 15);
      final day2Str = "2026-10-15";

      // Ngày 1: Hoàn thành level mới t1_l1
      await provider.completeLevel('t1_l1', 45, isCompleted: true, completionDate: day1);
      expect(provider.profile?.streak, 1);
      expect(provider.profile?.studyDates.contains("2026-10-14"), true);

      // Ngày 2: Người dùng CHỈ làm lại level t1_l1 (đã hoàn thành trước đó)
      await provider.completeLevel('t1_l1', 45, isCompleted: true, completionDate: day2);

      // Level cũ không được tính là ngày hôm đó đã học
      expect(provider.profile?.studyDates.contains(day2Str), false, reason: 'Level cũ đã vượt qua không được tính là ngày học mới');
      expect(provider.profile?.streak, 1, reason: 'Chuỗi không được tăng khi chỉ làm lại level cũ');
    });

    test('Làm level mới nhưng sai cả 3 câu (isCompleted: false): KHÔNG tính là đã học và KHÔNG cập nhật chuỗi', () async {
      final today = DateTime(2026, 10, 14);
      final todayStr = "2026-10-14";

      // Sai cả 3 câu ở level mới t1_l1 -> isCompleted = false
      await provider.completeLevel('t1_l1', 0, isCompleted: false, completionDate: today);

      expect(provider.isLevelCompleted('t1_l1'), false);
      expect(provider.profile?.studyDates.contains(todayStr), false, reason: 'Level chưa hoàn thành không tính là đã học');
      expect(provider.profile?.streak, 0, reason: 'Chuỗi không cập nhật khi chưa hoàn thành level');
    });

    test('Hoàn thành level mới liên tiếp các ngày: chuỗi tăng đều đặn', () async {
      final day1 = DateTime(2026, 10, 10);
      final day2 = DateTime(2026, 10, 11);
      final day3 = DateTime(2026, 10, 12);

      // Ngày 1: Level 1
      await provider.completeLevel('t1_l1', 45, isCompleted: true, completionDate: day1);
      expect(provider.profile?.streak, 1);

      // Ngày 2: Level 2
      await provider.completeLevel('t1_l2', 45, isCompleted: true, completionDate: day2);
      expect(provider.profile?.streak, 2);

      // Ngày 3: Level 3
      await provider.completeLevel('t1_l3', 45, isCompleted: true, completionDate: day3);
      expect(provider.profile?.streak, 3);
      expect(provider.profile?.longestStreak, 3);
    });

    test('Bị ngắt quãng ngày: chuỗi đứt và bắt đầu lại từ 1 khi học level mới tiếp theo', () async {
      final day1 = DateTime(2026, 10, 10);
      final day2 = DateTime(2026, 10, 11);
      // Ngày 12 không học (bị ngắt quãng)
      final day4 = DateTime(2026, 10, 13);

      await provider.completeLevel('t1_l1', 45, isCompleted: true, completionDate: day1);
      await provider.completeLevel('t1_l2', 45, isCompleted: true, completionDate: day2);
      expect(provider.profile?.streak, 2);
      expect(provider.profile?.longestStreak, 2);

      // Ngày 13 (sau khi nghỉ ngày 12) mới học tiếp level mới t1_l3
      await provider.completeLevel('t1_l3', 45, isCompleted: true, completionDate: day4);
      expect(provider.profile?.streak, 1, reason: 'Chuỗi phải bắt đầu lại từ 1 sau khi bỏ lỡ ngày 12');
      expect(provider.profile?.longestStreak, 2, reason: 'Kỷ lục chuỗi dài nhất phải được bảo toàn');
    });
  });
}
