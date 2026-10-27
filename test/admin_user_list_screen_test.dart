import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safequest/models/models.dart';
import 'package:safequest/providers/app_provider.dart';
import 'package:safequest/screens/admin/admin_user_list_screen.dart';
import 'package:safequest/services/data_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final ds = DataService();
    await ds.init();

    final now = DateTime.now();

    // 1. User 1: Free, has 2 study dates
    final u1 = Account(
      id: 101,
      username: 'user_active@gmail.com',
      password: '123',
      role: Role.CUSTOMER,
      membershipType: MembershipType.FREE,
      createdAt: now,
    );
    final p1 = ChildProfile(
      id: 'cp_101',
      accountId: 101,
      name: 'Bé Lan',
      age: 7,
      avatar: '👧',
      points: 120,
      streak: 2,
      longestStreak: 2,
      studyDates: ['2026-10-25', '2026-10-26'],
      unlockedBadges: [],
      completedLevels: ['t1_l1'],
      wrongQuestions: [],
      lastCheckInDate: null,
    );

    // 2. User 2: VIP, has 0 study dates (Chưa dùng)
    final u2 = Account(
      id: 102,
      username: 'user_vip_new@gmail.com',
      password: '123',
      role: Role.CUSTOMER,
      membershipType: MembershipType.VIP,
      createdAt: now,
    );
    final p2 = ChildProfile(
      id: 'cp_102',
      accountId: 102,
      name: 'Bé Minh',
      age: 8,
      avatar: '👦',
      points: 500,
      streak: 0,
      longestStreak: 0,
      studyDates: [], // 0 ngày
      unlockedBadges: ['b19'],
      completedLevels: [],
      wrongQuestions: [],
      lastCheckInDate: null,
    );

    // 3. User 3: Premium, has 5 study dates
    final u3 = Account(
      id: 103,
      username: 'user_premium@gmail.com',
      password: '123',
      role: Role.CUSTOMER,
      membershipType: MembershipType.PREMIUM,
      createdAt: now,
    );
    final p3 = ChildProfile(
      id: 'cp_103',
      accountId: 103,
      name: 'Bé Hoàng',
      age: 9,
      avatar: '🤴',
      points: 1200,
      streak: 5,
      longestStreak: 5,
      studyDates: ['2026-10-22', '2026-10-23', '2026-10-24', '2026-10-25', '2026-10-26'],
      unlockedBadges: ['b19', 'b20'],
      completedLevels: ['t1_l1', 't1_l2'],
      wrongQuestions: [],
      lastCheckInDate: null,
    );

    // 4. User 4: Free, has NO profile yet (0 ngày)
    final u4 = Account(
      id: 104,
      username: 'user_fresh@gmail.com',
      password: '123',
      role: Role.CUSTOMER,
      membershipType: MembershipType.FREE,
      createdAt: now,
    );

    await ds.saveAccount(u1);
    await ds.saveAccount(u2);
    await ds.saveAccount(u3);
    await ds.saveAccount(u4);

    await ds.saveChildProfile(p1);
    await ds.saveChildProfile(p2);
    await ds.saveChildProfile(p3);
  });

  testWidgets('AdminUserListScreen displays 4 categories and filters properly', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final provider = AppProvider();

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AppProvider>.value(
          value: provider,
          child: const AdminUserListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify 4 category filter cards exist
    expect(find.text('TỔNG NGƯỜI DÙNG'), findsOneWidget);
    expect(find.text('ĐÃ NÂNG VIP'), findsOneWidget);
    expect(find.text('ĐÃ NÂNG PREMIUM'), findsOneWidget);
    expect(find.text('CHƯA DÙNG APP'), findsOneWidget);

    // Total: 4 users
    // VIP: 1 user (u2)
    // Premium: 1 user (u3)
    // Not used (0 days): 2 users (u2 and u4)
    expect(find.text('4'), findsWidgets); // Total count
    expect(find.text('Bé Lan'), findsOneWidget);
    expect(find.text('Bé Minh'), findsOneWidget);
    expect(find.text('Bé Hoàng'), findsOneWidget);
    expect(find.text('user_fresh@gmail.com'), findsOneWidget);

    // 2. Filter by VIP: tap on 'ĐÃ NÂNG VIP'
    await tester.tap(find.text('ĐÃ NÂNG VIP'));
    await tester.pumpAndSettle();

    expect(find.text('Bé Minh'), findsOneWidget);
    expect(find.text('Bé Lan'), findsNothing);
    expect(find.text('Bé Hoàng'), findsNothing);
    expect(find.text('user_fresh@gmail.com'), findsNothing);

    // 3. Filter by Premium: tap on 'ĐÃ NÂNG PREMIUM'
    await tester.tap(find.text('ĐÃ NÂNG PREMIUM'));
    await tester.pumpAndSettle();

    expect(find.text('Bé Hoàng'), findsOneWidget);
    expect(find.text('Bé Minh'), findsNothing);
    expect(find.text('Bé Lan'), findsNothing);

    // 4. Filter by Not Used: tap on 'CHƯA DÙNG APP'
    await tester.tap(find.text('CHƯA DÙNG APP'));
    await tester.pumpAndSettle();

    // u2 (Bé Minh) has 0 days, u4 (user_fresh) has 0 days
    expect(find.text('Bé Minh'), findsOneWidget);
    expect(find.text('user_fresh@gmail.com'), findsOneWidget);
    expect(find.text('Bé Lan'), findsNothing);
    expect(find.text('Bé Hoàng'), findsNothing);

    // Verify "0 ngày (Chưa dùng)" label shows
    expect(find.text('0 ngày (Chưa dùng)'), findsWidgets);

    // 5. Filter by All: tap on 'TỔNG NGƯỜI DÙNG'
    await tester.tap(find.text('TỔNG NGƯỜI DÙNG'));
    await tester.pumpAndSettle();

    expect(find.text('Bé Lan'), findsOneWidget);
    expect(find.text('Bé Minh'), findsOneWidget);
    expect(find.text('Bé Hoàng'), findsOneWidget);
    expect(find.text('user_fresh@gmail.com'), findsOneWidget);

    // 6. Test search within current filter
    await tester.enterText(find.byType(TextField), 'Lan');
    await tester.pumpAndSettle();

    expect(find.text('Bé Lan'), findsOneWidget);
    expect(find.text('Bé Minh'), findsNothing);
    expect(find.text('Bé Hoàng'), findsNothing);
  });
}
