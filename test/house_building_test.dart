import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safequest/models/models.dart';
import 'package:safequest/providers/app_provider.dart';
import 'package:safequest/services/data_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final ds = DataService();
    await ds.init();

    final now = DateTime.now();
    final customer = Account(
      id: 3001,
      username: 'kid_builder',
      password: '123',
      role: Role.CUSTOMER,
      coinBalance: 0,
      membershipType: MembershipType.FREE,
      createdAt: now,
    );
    final profile = ChildProfile(
      id: 'cp_3001',
      accountId: 3001,
      name: 'Bé Khôi',
      age: 7,
      avatar: '👦',
      points: 100, // 100 Điểm học tập ban đầu
      streak: 1,
      longestStreak: 1,
      studyDates: ['2026-10-29'],
      unlockedBadges: [],
      completedLevels: [],
      wrongQuestions: [],
      lastCheckInDate: null,
    );

    await ds.saveAccount(customer);
    await ds.saveChildProfile(profile);
  });

  group('House Building Minigame Logic Tests', () {
    test('Catalog contains 15 items across 4 rooms matching specifications', () {
      expect(HouseCatalog.totalItemsCount, 15);
      expect(HouseCatalog.getItemsByRoom(HouseRoomType.livingRoom).length, 4);
      expect(HouseCatalog.getItemsByRoom(HouseRoomType.kitchen).length, 3);
      expect(HouseCatalog.getItemsByRoom(HouseRoomType.bathroom).length, 4);
      expect(HouseCatalog.getItemsByRoom(HouseRoomType.bedroom).length, 4);

      // Verify every item has exactly 3 levels
      for (final item in HouseCatalog.allItems) {
        expect(item.levels.length, 3);
        expect(item.levels[0].tierBadge, 'Cổ Điển');
        expect(item.levels[1].tierBadge, 'Tiện Nghi');
        expect(item.levels[2].tierBadge, 'Smart 4.0');
      }
    });

    test('Upgrade item deducts points, sets level, and enforces point limits', () async {
      final provider = AppProvider();
      await provider.login('kid_builder', '123');

      expect(provider.profile?.points, 100);
      expect(provider.houseData.getItemLevel('living_door'), 0);
      expect(provider.houseData.overallProgress, 0.0);

      // 1. Upgrade living_door to Level 1 (Cost: 25 ⭐)
      final result1 = await provider.upgradeHouseItem('living_door');
      expect(result1['success'], true);
      expect(provider.profile?.points, 75); // 100 - 25 = 75
      expect(provider.houseData.getItemLevel('living_door'), 1);
      expect(provider.houseData.ownedCount, 1);
      expect(provider.houseData.overallProgress, greaterThan(0.0));
      expect(provider.houseData.getItemPointsSpent('living_door'), 25);
      expect(provider.houseData.totalPointsSpent, 25);

      // 2. Upgrade living_door to Level 2 (Cost: 65 ⭐)
      final result2 = await provider.upgradeHouseItem('living_door');
      expect(result2['success'], true);
      expect(provider.profile?.points, 10); // 75 - 65 = 10
      expect(provider.houseData.getItemLevel('living_door'), 2);
      expect(provider.houseData.getItemPointsSpent('living_door'), 90); // 25 + 65 = 90
      expect(provider.houseData.getRoomPointsSpent(HouseRoomType.livingRoom), 90);
      expect(provider.houseData.totalPointsSpent, 90);

      // 3. Try to upgrade living_door to Level 3 (Cost: 180 ⭐, but user only has 10 ⭐)
      final result3 = await provider.upgradeHouseItem('living_door');
      expect(result3['success'], false);
      expect(result3['message'].toString().contains('Chưa đủ Điểm Học Tập'), true);
      expect(provider.houseData.getItemLevel('living_door'), 2);
      expect(provider.profile?.points, 10);

      // 4. Give user 500 points (simulate learning or VIP bonus)
      await provider.updateProfile(addPoints: 500);
      expect(provider.profile?.points, 510);

      // 5. Upgrade living_door to Level 3 Smart 4.0 (Cost: 180 ⭐)
      final result4 = await provider.upgradeHouseItem('living_door');
      expect(result4['success'], true);
      expect(provider.profile?.points, 330); // 510 - 180 = 330
      expect(provider.houseData.getItemLevel('living_door'), 3);
      expect(provider.houseData.isItemMax('living_door'), true);
      expect(provider.houseData.maxCount, 1);
      expect(provider.houseData.getItemPointsSpent('living_door'), 270); // 25 + 65 + 180
      expect(provider.houseData.getRoomPointsSpent(HouseRoomType.livingRoom), 270);
      expect(provider.houseData.totalPointsSpent, 270);

      // 6. Try to upgrade past Level 3
      final result5 = await provider.upgradeHouseItem('living_door');
      expect(result5['success'], false);
      expect(result5['message'].toString().contains('tối đa'), true);

      // 7. Verify persistence across fresh provider login
      final provider2 = AppProvider();
      await provider2.login('kid_builder', '123');
      expect(provider2.houseData.getItemLevel('living_door'), 3);
      expect(provider2.houseData.hasOpenedGame, true);
      expect(provider2.profile?.points, 330);
    });

    test('Leaderboard only shows accounts with hasOpenedGame == true and orders by points spent', () async {
      final ds = DataService();

      // Account 1: Kid A - opened game, spent 250 pts
      const houseA = UserHouseData(
        accountId: 101,
        childName: 'Bé An',
        childAvatar: '👧',
        itemLevels: {'living_door': 2}, // spent 25 + 65 = 90
        hasOpenedGame: true,
      );
      await ds.saveHouseData(101, houseA);

      // Account 2: Kid B - opened game, spent more points
      const houseB = UserHouseData(
        accountId: 102,
        childName: 'Bé Bình',
        childAvatar: '👦',
        itemLevels: {'living_door': 3}, // spent 25 + 65 + 180 = 270
        hasOpenedGame: true,
      );
      await ds.saveHouseData(102, houseB);

      // Account 3: Kid C - registered, BUT NEVER opened house game! (hasOpenedGame == false)
      const houseC = UserHouseData(
        accountId: 103,
        childName: 'Bé Chi',
        childAvatar: '🧒',
        itemLevels: {},
        hasOpenedGame: false, // Never used
      );
      await ds.saveHouseData(103, houseC);

      // Fetch leaderboard
      final leaderboard = await ds.getHouseLeaderboard();

      // Kid C must NOT appear!
      expect(leaderboard.any((e) => e.accountId == 103), false);

      // Only 2 kids appear (Kid A and Kid B)
      final activeEntries = leaderboard.where((e) => e.accountId == 101 || e.accountId == 102).toList();
      expect(activeEntries.length, 2);

      // Kid B (270 pts) is Rank 1, Kid A (90 pts) is Rank 2
      expect(activeEntries[0].accountId, 102);
      expect(activeEntries[0].childName, 'Bé Bình');
      expect(activeEntries[0].totalPointsSpent, 270);

      expect(activeEntries[1].accountId, 101);
      expect(activeEntries[1].childName, 'Bé An');
      expect(activeEntries[1].totalPointsSpent, 90);
    });
  });
}
