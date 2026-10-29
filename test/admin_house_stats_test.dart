import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safequest/models/models.dart';
import 'package:safequest/providers/app_provider.dart';
import 'package:safequest/screens/admin/admin_house_stats_screen.dart';
import 'package:safequest/services/data_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final ds = DataService();
    await ds.init();

    final now = DateTime.now();

    // 1. User 101: Đã mở game, đã mua Sofa (cấp 2) và Tủ lạnh (cấp 1)
    final u1 = Account(
      id: 101,
      username: 'lan_explorer@gmail.com',
      password: '123',
      role: Role.CUSTOMER,
      membershipType: MembershipType.VIP,
      createdAt: now,
    );
    final p1 = ChildProfile(
      id: 'cp_101',
      accountId: 101,
      name: 'Bé Lan',
      age: 7,
      avatar: '👧',
      points: 400,
      streak: 2,
      longestStreak: 2,
      studyDates: ['2026-10-25'],
      unlockedBadges: [],
      completedLevels: ['t1_l1'],
      wrongQuestions: [],
      lastCheckInDate: null,
    );
    final h1 = UserHouseData(
      accountId: 101,
      childName: 'Bé Lan',
      childAvatar: '👧',
      hasOpenedGame: true,
      itemLevels: {
        'living_sofa': 2, // Sofa cấp 2
        'kitchen_fridge': 1, // Tủ lạnh cấp 1
      },
    );

    // 2. User 102: Đã mở game lần đầu nhưng CHƯA mua món nào (0 điểm)
    final u2 = Account(
      id: 102,
      username: 'minh_safe@gmail.com',
      password: '123',
      role: Role.CUSTOMER,
      membershipType: MembershipType.FREE,
      createdAt: now,
    );
    final p2 = ChildProfile(
      id: 'cp_102',
      accountId: 102,
      name: 'Bé Minh',
      age: 8,
      avatar: '👦',
      points: 100,
      streak: 1,
      longestStreak: 1,
      studyDates: ['2026-10-26'],
      unlockedBadges: [],
      completedLevels: [],
      wrongQuestions: [],
      lastCheckInDate: null,
    );
    final h2 = UserHouseData(
      accountId: 102,
      childName: 'Bé Minh',
      childAvatar: '👦',
      hasOpenedGame: true,
      itemLevels: {},
    );

    // 3. User 103: CHƯA BAO GIỜ mở game (hasOpenedGame == false)
    final u3 = Account(
      id: 103,
      username: 'an_new@gmail.com',
      password: '123',
      role: Role.CUSTOMER,
      membershipType: MembershipType.FREE,
      createdAt: now,
    );
    final p3 = ChildProfile(
      id: 'cp_103',
      accountId: 103,
      name: 'Bé An',
      age: 6,
      avatar: '🧒',
      points: 50,
      streak: 0,
      longestStreak: 0,
      studyDates: [],
      unlockedBadges: [],
      completedLevels: [],
      wrongQuestions: [],
      lastCheckInDate: null,
    );
    final h3 = UserHouseData(
      accountId: 103,
      childName: 'Bé An',
      childAvatar: '🧒',
      hasOpenedGame: false,
    );

    await ds.saveAccount(u1);
    await ds.saveAccount(u2);
    await ds.saveAccount(u3);

    await ds.saveChildProfile(p1);
    await ds.saveChildProfile(p2);
    await ds.saveChildProfile(p3);

    await ds.saveHouseData(101, h1);
    await ds.saveHouseData(102, h2);
    await ds.saveHouseData(103, h3);
  });

  test('DataService.getAllUserHouses returns only accounts that opened game', () async {
    final ds = DataService();
    final houses = await ds.getAllUserHouses();

    expect(houses.length, equals(2));
    final ids = houses.map((h) => h.accountId).toList();
    expect(ids, contains(101));
    expect(ids, contains(102));
    expect(ids, isNot(contains(103))); // 103 chưa mở game -> Không có trong danh sách
  });

  testWidgets('AdminHouseStatsScreen renders players who opened game with full info', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppProvider()),
        ],
        child: const MaterialApp(
          home: AdminHouseStatsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Kiểm tra tiêu đề màn hình
    expect(find.text('THỐNG KÊ GAME NGÔI NHÀ'), findsOneWidget);

    // 2. Kiểm tra chỉ hiển thị 2 người chơi đã mở game
    expect(find.text('Bé Lan'), findsWidgets);
    expect(find.text('Bé Minh'), findsWidgets);
    expect(find.text('Bé An'), findsNothing); // Không hiện vì chưa mở game

    // 3. Kiểm tra hiển thị đầy đủ thông tin: Avatar, Gmail, ID
    expect(find.text('✉️ lan_explorer@gmail.com'), findsOneWidget);
    expect(find.text('🆔 ID: #101'), findsOneWidget);
    expect(find.text('👧'), findsWidgets);

    expect(find.text('✉️ minh_safe@gmail.com'), findsOneWidget);
    expect(find.text('🆔 ID: #102'), findsOneWidget);
    expect(find.text('👦'), findsWidgets);

    // 4. Kiểm tra điểm tiêu hao
    // Bé Lan mua sofa lvl 2 (20 + 55 = 75) + tủ lạnh lvl 1 (30) = 105 điểm
    expect(find.textContaining('105 điểm tiêu hao'), findsOneWidget);
    expect(find.textContaining('0 điểm tiêu hao'), findsOneWidget); // Bé Minh chưa mua gì
  });

  testWidgets('Search filter filters players by name, email or ID', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppProvider()),
        ],
        child: const MaterialApp(
          home: AdminHouseStatsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Nhập tìm kiếm "lan"
    await tester.enterText(find.byType(TextField), 'lan');
    await tester.pumpAndSettle();

    expect(find.text('Bé Lan'), findsWidgets);
    expect(find.text('Bé Minh'), findsNothing);

    // Xóa tìm kiếm và nhập "102"
    await tester.enterText(find.byType(TextField), '102');
    await tester.pumpAndSettle();

    expect(find.text('Bé Minh'), findsWidgets);
    expect(find.text('Bé Lan'), findsNothing);
  });

  testWidgets('Tapping on a player opens house detail modal showing room and item levels', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppProvider()),
        ],
        child: const MaterialApp(
          home: AdminHouseStatsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Chạm vào thẻ Bé Lan
    await tester.tap(find.text('Bé Lan').first);
    await tester.pumpAndSettle();

    // Modal hiện ra
    expect(find.text('CHI TIẾT 4 PHÒNG & CẤP ĐỘ ĐỒ VẬT'), findsOneWidget);
    expect(find.text('Phòng Khách'), findsOneWidget);
    expect(find.text('Level 2: Tiện Nghi'), findsOneWidget);
    expect(find.text('Phòng Bếp'), findsOneWidget);
    expect(find.text('Level 1: Cổ Điển'), findsOneWidget);
    expect(find.text('Chưa mua'), findsWidgets);
  });

  testWidgets('Switching to Leaderboard tab shows ranked players by points spent', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppProvider()),
        ],
        child: const MaterialApp(
          home: AdminHouseStatsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Chuyển sang Tab Bảng Xếp Hạng
    await tester.tap(find.text('BẢNG XẾP HẠNG'));
    await tester.pumpAndSettle();

    // Hạng 1 là Bé Lan (200 điểm)
    expect(find.text('🥇'), findsOneWidget);
    expect(find.text('🥈'), findsOneWidget);
  });
}
