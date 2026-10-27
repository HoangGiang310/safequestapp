import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safequest/models/models.dart';
import 'package:safequest/providers/app_provider.dart';
import 'package:safequest/screens/profile/upgrade_screen.dart';
import 'package:safequest/services/data_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final ds = DataService();
    await ds.init();

    final customer = Account(
      id: 2001,
      username: 'student1',
      password: '123',
      role: Role.CUSTOMER,
      coinBalance: 0,
      membershipType: MembershipType.FREE,
      createdAt: DateTime.now(),
    );
    await ds.saveAccount(customer);
  });

  group('Membership Upgrade Bonus Points & UI Tests', () {
    testWidgets('VIP upgrade awards +500 points and updates membership', (tester) async {
      final provider = AppProvider();
      await provider.login('student1', '123');

      // Top up 500 coins
      final account = provider.currentAccount!;
      final updatedAcc = account.copyWith(coinBalance: 500);
      await DataService().saveAccount(updatedAcc);
      await provider.login('student1', '123');

      final initialPoints = provider.profile?.points ?? 0;
      final success = await provider.upgradeMembership(MembershipType.VIP, 500);

      expect(success, true);
      expect(provider.currentAccount?.membershipType, MembershipType.VIP);
      expect(provider.currentAccount?.coinBalance, 0);
      expect(provider.profile?.points, initialPoints + 500);
      // Reaching >= 300 points unlocks b19 badge
      expect(provider.unlockedBadges.contains('b19'), true);
    });

    testWidgets('PREMIUM upgrade awards +1000 points and updates membership', (tester) async {
      final provider = AppProvider();
      await provider.login('student1', '123');

      // Top up 1000 coins
      final account = provider.currentAccount!;
      final updatedAcc = account.copyWith(coinBalance: 1000);
      await DataService().saveAccount(updatedAcc);
      await provider.login('student1', '123');

      final initialPoints = provider.profile?.points ?? 0;
      final success = await provider.upgradeMembership(MembershipType.PREMIUM, 1000);

      expect(success, true);
      expect(provider.currentAccount?.membershipType, MembershipType.PREMIUM);
      expect(provider.currentAccount?.coinBalance, 0);
      expect(provider.profile?.points, initialPoints + 1000);
      // Reaching >= 1000 points unlocks b20 badge
      expect(provider.unlockedBadges.contains('b20'), true);
    });

    testWidgets('UpgradeScreen renders gift banners and features for house building', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final provider = AppProvider();
      await provider.login('student1', '123');

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppProvider>.value(
            value: provider,
            child: const UpgradeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check Header & current status
      expect(find.text('NÂNG CẤP'), findsOneWidget);
      expect(find.text('HẠNG HIỆP SĨ HIỆN TẠI'), findsOneWidget);

      // Check bonus gift badges
      expect(find.text('TẶNG NGAY +500 ĐIỂM HỌC TẬP'), findsOneWidget);
      expect(find.text('TẶNG NGAY +1.000 ĐIỂM HỌC TẬP'), findsOneWidget);

      // Check house building perks in feature list
      expect(find.text('Tặng ngay +500 Điểm Học Tập'), findsOneWidget);
      expect(find.text('Tặng ngay +1.000 Điểm Học Tập'), findsOneWidget);
      expect(find.text('Mở khóa bộ sưu tập nội thất Hoàng Gia & sân vườn biệt thự'), findsOneWidget);
    });
  });
}
