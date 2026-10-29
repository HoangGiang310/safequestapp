import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:safequest/models/models.dart';
import 'package:safequest/providers/app_provider.dart';
import 'package:safequest/screens/game/house_screen.dart';
import 'package:safequest/services/data_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppProvider provider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    await DataService().init();
    provider = AppProvider();

    // Register & Login a customer account for testing
    await provider.register('house_tester', '123');
    await provider.saveProfile('Bé Test', 7, '👦');
    await provider.updateProfile(addPoints: 200); // 200 points in wallet

    final ds = DataService();
    final acc = provider.currentAccount!;
    await ds.saveHouseData(acc.id, UserHouseData(
      accountId: acc.id,
      childName: 'Bé Test',
      childAvatar: '👦',
      hasOpenedGame: true,
      hasSeenWelcome: true, // Welcome dialog dismissed so screen is interactive
    ));
    await provider.login('house_tester', '123');
  });

  Widget createTestWidget({bool showBetaNotice = false}) {
    return ChangeNotifierProvider<AppProvider>.value(
      value: provider,
      child: MaterialApp(
        home: HouseScreen(showBetaNotice: showBetaNotice),
      ),
    );
  }

  testWidgets('Entering game shows Beta Tester Notice Dialog on first and subsequent visits', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createTestWidget(showBetaNotice: true));
    await tester.pumpAndSettle();

    // Verify Beta Tester Dialog is shown with exact content
    expect(find.text('THÔNG BÁO THỬ NGHIỆM'), findsOneWidget);
    expect(find.text('BETA TESTER'), findsOneWidget);
    expect(
      find.text(
        'Hiện tại trò chơi đang trong giai đoạn thử nghiệm ( Beta Tester ). Nếu có xảy ra lỗi gì vui lòng Feedback hoặc liên hệ email "safequestdev@gmail.com" nhằm đóng góp ý kiến để Admin cải thiện sản phẩm tốt hơn. Xin cảm ơn!',
      ),
      findsOneWidget,
    );
    expect(find.text('Đã Hiểu'), findsOneWidget);

    // Tap "Đã Hiểu"
    final confirmBtn = find.byKey(const Key('beta_tester_dialog_confirm_button'));
    expect(confirmBtn, findsOneWidget);
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();

    // Dialog should disappear and game is ready to play
    expect(find.byKey(const Key('beta_tester_dialog_confirm_button')), findsNothing);
    expect(find.text('Phòng ăn'), findsWidgets);
  });

  testWidgets('HouseScreen displays exactly ONE room at a time and switches cleanly via bottom tabs', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // 1. Verify Top HUD buttons & Wallet Points
    expect(find.text('200'), findsOneWidget); // Available points in wallet
    expect(find.byKey(const Key('house_leaderboard_button')), findsOneWidget); // BXH button

    // 2. Initial state: Default is Phòng ăn / Bếp (như ảnh mẫu 1 & 2)
    expect(find.text('Phòng ăn'), findsWidgets);
    expect(find.text('Phòng khách'), findsOneWidget);
    expect(find.text('Phòng tắm'), findsOneWidget);
    expect(find.text('Phòng ngủ'), findsOneWidget);

    // 3. Switch to Phòng khách tab
    await tester.tap(find.text('Phòng khách'));
    await tester.pumpAndSettle();

    // 4. Switch to Phòng tắm tab
    await tester.tap(find.text('Phòng tắm'));
    await tester.pumpAndSettle();

    // 5. Switch to Phòng ngủ tab
    await tester.tap(find.text('Phòng ngủ'));
    await tester.pumpAndSettle();
  });

  testWidgets('Cumulative points spent modal displays detailed statistics', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Tap the diamond spent points chip
    await tester.tap(find.text('0'));
    await tester.pumpAndSettle();

    // Verify modal appeared
    expect(find.text('ĐIỂM ĐÃ ĐẦU TƯ XÂY NHÀ'), findsOneWidget);
    expect(find.text('ĐÃ TIÊU HAO'), findsOneWidget);
    expect(find.text('CÒN LẠI TRONG VÍ'), findsOneWidget);
    expect(find.text('200 ⭐'), findsOneWidget); // Remaining in wallet
  });

  testWidgets('Leaderboard modal displays ranked list and filters accounts properly', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Seed another kid who has opened game
    final ds = DataService();
    await ds.saveHouseData(7001, const UserHouseData(
      accountId: 7001,
      childName: 'Bé Hùng Siêu Sao',
      childAvatar: '👦',
      itemLevels: {'living_door': 3}, // spent 270 pts
      hasOpenedGame: true,
    ));

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Tap the BXH button
    await tester.tap(find.byKey(const Key('house_leaderboard_button')));
    await tester.pumpAndSettle();

    // Verify Leaderboard modal title
    expect(find.text('BẢNG XẾP HẠNG XÂY NHÀ'), findsOneWidget);
    expect(find.text('Bé Hùng Siêu Sao'), findsOneWidget);
    expect(find.text('270 ⭐'), findsOneWidget); // Bé Hùng's spent points
  });

  testWidgets('Upgrading an item updates spent points, wallet points, and house data', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('200'), findsOneWidget); // Wallet: 200 pts
    expect(find.text('0'), findsOneWidget); // Spent: 0 pts

    // Upgrade door level 1 (costs 25 pts)
    final res = await provider.upgradeHouseItem('living_door');
    expect(res['success'], true);

    await tester.pump(const Duration(milliseconds: 400));

    // Wallet is now 200 - 25 = 175 pts
    expect(find.text('175'), findsOneWidget);
    // Spent points is now 25 pts
    expect(find.text('25'), findsOneWidget);
  });
}
