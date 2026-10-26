import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safequest/models/models.dart';
import 'package:safequest/providers/app_provider.dart';
import 'package:safequest/screens/admin/admin_dashboard_screen.dart';
import 'package:safequest/screens/admin/admin_transactions_screen.dart';
import 'package:safequest/services/data_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Admin Dashboard Overview displays total revenue from confirmed orders, VIP and Premium user counts',
      (tester) async {
    // 1. Setup mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final ds = DataService();
    await ds.init();

    // 2. Add test accounts: 1 Admin, 1 Free Customer, 2 VIP Customers, 1 Premium Customer
    final now = DateTime.now();
    final freeUser = Account(
      id: 1,
      username: 'user_free',
      password: '123',
      role: Role.CUSTOMER,
      membershipType: MembershipType.FREE,
      createdAt: now,
    );
    final vipUser1 = Account(
      id: 2,
      username: 'user_vip1',
      password: '123',
      role: Role.CUSTOMER,
      membershipType: MembershipType.VIP,
      createdAt: now,
    );
    final vipUser2 = Account(
      id: 3,
      username: 'user_vip2',
      password: '123',
      role: Role.CUSTOMER,
      membershipType: MembershipType.VIP,
      createdAt: now,
    );
    final premiumUser = Account(
      id: 4,
      username: 'user_premium',
      password: '123',
      role: Role.CUSTOMER,
      membershipType: MembershipType.PREMIUM,
      createdAt: now,
    );

    await ds.saveAccount(freeUser);
    await ds.saveAccount(vipUser1);
    await ds.saveAccount(vipUser2);
    await ds.saveAccount(premiumUser);

    // 3. Add test transactions:
    // - 2 Confirmed orders of 50000 VND (500 coin) -> Total revenue = 100000 VND
    // - 1 Pending order of 20000 VND (should NOT be added to revenue)
    // - 1 Rejected order of 50000 VND (should NOT be added to revenue)
    final tx1 = Transaction(
      id: 'tx_1',
      transactionCode: '10001',
      userId: 1,
      amount: 50000,
      coinAmount: 500,
      status: TransactionStatus.CONFIRMED,
      transferContent: 'SAFEQUEST 1 10001',
      createdAt: now,
    );
    final tx2 = Transaction(
      id: 'tx_2',
      transactionCode: '10002',
      userId: 2,
      amount: 50000,
      coinAmount: 500,
      status: TransactionStatus.CONFIRMED,
      transferContent: 'SAFEQUEST 2 10002',
      createdAt: now,
    );
    final txPending = Transaction(
      id: 'tx_3',
      transactionCode: '10003',
      userId: 3,
      amount: 20000,
      coinAmount: 200,
      status: TransactionStatus.PENDING,
      transferContent: 'SAFEQUEST 3 10003',
      createdAt: now,
    );
    final txRejected = Transaction(
      id: 'tx_4',
      transactionCode: '10004',
      userId: 4,
      amount: 50000,
      coinAmount: 500,
      status: TransactionStatus.REJECTED,
      transferContent: 'SAFEQUEST 4 10004',
      createdAt: now,
    );

    await ds.saveTransaction(tx1);
    await ds.saveTransaction(tx2);
    await ds.saveTransaction(txPending);
    await ds.saveTransaction(txRejected);

    // Add 3 feedbacks
    await ds.saveFeedback(UserFeedback(
      id: 'fb_1',
      accountId: 1,
      userName: 'User 1',
      userEmail: 'user1@test.com',
      content: 'Ứng dụng tuyệt vời',
      rating: 5,
      createdAt: now,
    ));
    await ds.saveFeedback(UserFeedback(
      id: 'fb_2',
      accountId: 2,
      userName: 'User 2',
      userEmail: 'user2@test.com',
      content: 'Rất bổ ích',
      rating: 4,
      createdAt: now,
    ));
    await ds.saveFeedback(UserFeedback(
      id: 'fb_3',
      accountId: 3,
      userName: 'User 3',
      userEmail: 'user3@test.com',
      content: 'Bé rất thích',
      rating: 5,
      createdAt: now,
    ));

    // 4. Pump AdminDashboardScreen
    final provider = AppProvider();
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AppProvider>.value(
          value: provider,
          child: const AdminDashboardScreen(),
        ),
      ),
    );

    // Allow async _loadStats to complete
    await tester.pumpAndSettle();

    // 5. Verify Overview Section
    expect(find.text('TỔNG QUAN HỆ THỐNG'), findsOneWidget);

    // Row 1: NGƯỜI DÙNG, CHỦ ĐỀ, CÂU HỎI
    expect(find.text('NGƯỜI DÙNG'), findsOneWidget);
    final userPod = find.ancestor(
      of: find.text('NGƯỜI DÙNG'),
      matching: find.byType(Column),
    ).first;
    expect(find.descendant(of: userPod, matching: find.text('4')), findsOneWidget);

    expect(find.text('CHỦ ĐỀ'), findsOneWidget);
    expect(find.text('CÂU HỎI'), findsOneWidget);

    // Row 2: TỔNG DOANH THU, NGƯỜI DÙNG VIP, NGƯỜI DÙNG PREMIUM
    expect(find.text('TỔNG DOANH THU'), findsOneWidget);
    expect(find.text('100000 VND'), findsOneWidget);
    expect(find.text('ĐÃ DUYỆT'), findsNothing);

    // Verify VIP Users: 2
    expect(find.text('NGƯỜI DÙNG VIP'), findsOneWidget);
    final vipPod = find.ancestor(
      of: find.text('NGƯỜI DÙNG VIP'),
      matching: find.byType(Column),
    ).first;
    expect(find.descendant(of: vipPod, matching: find.text('2')), findsOneWidget);

    // Verify Premium Users: 1
    expect(find.text('NGƯỜI DÙNG PREMIUM'), findsOneWidget);
    final premiumPod = find.ancestor(
      of: find.text('NGƯỜI DÙNG PREMIUM'),
      matching: find.byType(Column),
    ).first;
    expect(find.descendant(of: premiumPod, matching: find.text('1')), findsOneWidget);

    // Verify Feedback badge shows ONLY the count '3', without 'ĐANG CHỜ'
    expect(find.text('3'), findsOneWidget);
    expect(find.text('3 ĐANG CHỜ'), findsNothing);
  });

  testWidgets('Full User Journey: User requests top-up -> Admin confirms order -> User upgrades to VIP -> Admin Dashboard updates revenue and VIP count',
      (tester) async {
    // 1. Setup mock storage
    SharedPreferences.setMockInitialValues({});
    final ds = DataService();
    await ds.init();

    // 2. Create customer and admin accounts
    final now = DateTime.now();
    final customer = Account(
      id: 2001,
      username: 'student1',
      password: '123',
      role: Role.CUSTOMER,
      coinBalance: 0,
      membershipType: MembershipType.FREE,
      createdAt: now,
    );
    final admin = Account(
      id: 1000,
      username: 'admin',
      password: '123',
      role: Role.ADMIN,
      createdAt: now,
    );
    await ds.saveAccount(customer);
    await ds.saveAccount(admin);

    // 3. User logs in with AppProvider and requests top-up of 50000 VND (500 coin)
    final provider = AppProvider();
    await provider.login('student1', '123');
    expect(provider.currentAccount?.coinBalance, 0);
    expect(provider.currentAccount?.membershipType, MembershipType.FREE);

    // User requests top-up
    await provider.requestTopUp(50000, 500);
    final txsAfterRequest = await ds.getTransactions();
    expect(txsAfterRequest.length, 1);
    expect(txsAfterRequest.first.status, TransactionStatus.PENDING);
    expect(txsAfterRequest.first.amount, 50000);
    expect(txsAfterRequest.first.coinAmount, 500);

    // 4. Admin logs in and opens AdminDashboardScreen
    await provider.login('admin', '123');
    expect(provider.isAdmin, true);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AppProvider>.value(
          value: provider,
          child: const AdminDashboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Before approving:
    // Revenue must still be 0 VND because the order is pending
    expect(find.text('0 VND'), findsOneWidget);
    // 1 order pending notification badge
    expect(find.text('1 ĐANG CHỜ'), findsOneWidget);
    // VIP count is 0
    final vipPodBefore = find.ancestor(
      of: find.text('NGƯỜI DÙNG VIP'),
      matching: find.byType(Column),
    ).first;
    expect(find.descendant(of: vipPodBefore, matching: find.text('0')), findsOneWidget);

    // 5. Admin confirms the top-up order
    final pendingTx = txsAfterRequest.first;
    await provider.confirmTransaction(pendingTx.id);

    // Verify order is now CONFIRMED in DataService
    final txsAfterConfirm = await ds.getTransactions();
    expect(txsAfterConfirm.first.status, TransactionStatus.CONFIRMED);

    // Pump active screen (real-time reactive listener updates stats)
    await tester.pumpAndSettle();

    // Check Admin Dashboard immediately:
    // -> Does Revenue update? YES!
    expect(find.text('50000 VND'), findsOneWidget);
    expect(find.text('0 VND'), findsNothing);

    // 6. User now uses coin to upgrade to VIP rank
    await provider.login('student1', '123');
    expect(provider.currentAccount?.coinBalance, 500);

    final successUpgrade = await provider.upgradeMembership(MembershipType.VIP, 500);
    expect(successUpgrade, true);
    expect(provider.currentAccount?.membershipType, MembershipType.VIP);
    expect(provider.currentAccount?.coinBalance, 0);

    // 7. Admin returns / re-enters Admin Dashboard
    await provider.login('admin', '123');
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AppProvider>.value(
          value: provider,
          child: const AdminDashboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Check Admin Dashboard:
    // -> Does VIP count update?
    final vipPodAfter = find.ancestor(
      of: find.text('NGƯỜI DÙNG VIP'),
      matching: find.byType(Column),
    ).first;
    expect(find.descendant(of: vipPodAfter, matching: find.text('1')), findsOneWidget);
    expect(find.text('50000 VND'), findsOneWidget);
  });

  testWidgets('AdminTransactionsScreen displays statistic for total approved orders', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final ds = DataService();
    await ds.init();

    final now = DateTime.now();
    final admin = Account(id: 1000, username: 'admin', password: '123', role: Role.ADMIN, createdAt: now);
    await ds.saveAccount(admin);

    // 3 transactions: 2 confirmed, 1 pending
    await ds.saveTransaction(Transaction(id: 'tx_1', transactionCode: '101', userId: 1, amount: 50000, coinAmount: 500, status: TransactionStatus.CONFIRMED, transferContent: 'TX1', createdAt: now));
    await ds.saveTransaction(Transaction(id: 'tx_2', transactionCode: '102', userId: 2, amount: 100000, coinAmount: 1000, status: TransactionStatus.CONFIRMED, transferContent: 'TX2', createdAt: now));
    await ds.saveTransaction(Transaction(id: 'tx_3', transactionCode: '103', userId: 3, amount: 20000, coinAmount: 200, status: TransactionStatus.PENDING, transferContent: 'TX3', createdAt: now));

    final provider = AppProvider();
    await provider.login('admin', '123');

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AppProvider>.value(
          value: provider,
          child: const AdminTransactionsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify approved orders statistic
    expect(find.text('TỔNG SỐ ĐƠN ĐÃ DUYỆT'), findsOneWidget);
    expect(find.text('2'), findsWidgets);
    expect(find.text('2 ĐƠN'), findsOneWidget);
    expect(find.text('đơn đã duyệt'), findsOneWidget);
  });
}
