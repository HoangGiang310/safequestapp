import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/app_provider.dart';
import '../../services/data_service.dart';
import '../welcome/welcome_screen.dart';
import 'admin_topics_screen.dart';
import 'admin_users_screen.dart';
import 'admin_user_list_screen.dart';
import 'admin_feedback_screen.dart';
import 'admin_transactions_screen.dart';
import '../../models/models.dart';
import '../../core/widgets/change_password_dialog.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int totalUsers = 0;
  int pendingTopupRequests = 0;
  int totalFeedbacks = 0;
  int totalRevenue = 0;
  int vipUsers = 0;
  int premiumUsers = 0;
  AppProvider? _appProvider;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newProvider = Provider.of<AppProvider>(context, listen: false);
    if (_appProvider != newProvider) {
      _appProvider?.removeListener(_onProviderUpdate);
      _appProvider = newProvider;
      _appProvider?.addListener(_onProviderUpdate);
    }
  }

  void _onProviderUpdate() {
    if (mounted) {
      _loadStats();
    }
  }

  @override
  void dispose() {
    _appProvider?.removeListener(_onProviderUpdate);
    super.dispose();
  }

  void _loadStats() async {
    final users = await DataService().getAccounts();
    final txs = await DataService().getTransactions();
    final fbs = await DataService().getFeedbacks();
    if (mounted) {
      final customerUsers = users.where((u) => u.role == Role.CUSTOMER).toList();
      final confirmedTxs = txs.where((tx) => tx.status == TransactionStatus.CONFIRMED).toList();
      final calculatedRevenue = confirmedTxs.fold<int>(0, (sum, tx) => sum + tx.amount);

      setState(() {
        totalUsers = customerUsers.length;
        pendingTopupRequests = txs.where((tx) => tx.status == TransactionStatus.PENDING).length;
        totalFeedbacks = fbs.length;
        totalRevenue = calculatedRevenue;
        vipUsers = customerUsers.where((u) => u.membershipType == MembershipType.VIP).length;
        premiumUsers = customerUsers.where((u) => u.membershipType == MembershipType.PREMIUM).length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar with Cartoon Admin Badge & Sign Out Button (NO ICONS)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.cartoonBorder, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.cartoonBorder,
                          offset: Offset(0, 3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Text(
                      'TRUNG TÂM QUẢN TRỊ',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await provider.logout();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                          (route) => false,
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFD32F2F), width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFFC62828),
                            offset: Offset(0, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: const Text(
                        'ĐĂNG XUẤT',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFC62828),
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Title Pod
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: AppColors.cartoonBorder, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.cartoonBorder,
                      offset: Offset(0, 5),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'TỔNG QUAN HỆ THỐNG',
                      style: AppTextStyles.h2.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: 1.0,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Hàng 1: Người Dùng, Chủ Đề, Câu Hỏi
                    Row(
                      children: [
                        Expanded(
                          child: _buildKidStatPod(
                            title: 'NGƯỜI DÙNG',
                            value: '$totalUsers',
                            bgColor: const Color(0xFFE1F5FE),
                            shadowColor: const Color(0xFF0288D1),
                            textColor: const Color(0xFF0277BD),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildKidStatPod(
                            title: 'CHỦ ĐỀ',
                            value: '${provider.adminTopics.length}',
                            bgColor: const Color(0xFFE8F5E9),
                            shadowColor: const Color(0xFF388E3C),
                            textColor: const Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildKidStatPod(
                            title: 'CÂU HỎI',
                            value: '${provider.questions.length}',
                            bgColor: const Color(0xFFFFF3E0),
                            shadowColor: const Color(0xFFF57F17),
                            textColor: const Color(0xFFE65100),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Hàng 2: Tổng Doanh Thu, Người Dùng Vip, Người Dùng Premium
                    Row(
                      children: [
                        Expanded(
                          child: _buildKidStatPod(
                            title: 'TỔNG DOANH THU',
                            value: '$totalRevenue VND',
                            bgColor: const Color(0xFFE8F8F5),
                            shadowColor: const Color(0xFF27AE60),
                            textColor: const Color(0xFF1E824C),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildKidStatPod(
                            title: 'NGƯỜI DÙNG VIP',
                            value: '$vipUsers',
                            bgColor: const Color(0xFFFFF8E1),
                            shadowColor: const Color(0xFFFFA000),
                            textColor: const Color(0xFFFF8F00),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildKidStatPod(
                            title: 'NGƯỜI DÙNG PREMIUM',
                            value: '$premiumUsers',
                            bgColor: const Color(0xFFF3E5F5),
                            shadowColor: const Color(0xFF7B1FA2),
                            textColor: const Color(0xFF6A1B9A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Menu title
              Text(
                'DANH MỤC ĐIỀU HÀNH',
                style: AppTextStyles.h2.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 14),

              _buildCartoonMenuCard(
                title: 'Danh sách Người dùng',
                subtitle: 'Xem toàn bộ thông tin: Tên, Gmail, ID, Coin, Rank và số ngày học',
                badgeText: 'XEM TOÀN BỘ',
                cardColor: const Color(0xFFF3E5F5),
                badgeColor: const Color(0xFFAB47BC),
                badgeShadow: const Color(0xFF7B1FA2),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUserListScreen()))
                      .then((_) => _loadStats());
                },
              ),
              const SizedBox(height: 14),

              _buildCartoonMenuCard(
                title: 'Xem Feedback Người dùng',
                subtitle: 'Xem toàn bộ đánh giá, ý kiến từ mới đến cũ của học viên',
                badgeText: 'FEEDBACK',
                badgeCount: totalFeedbacks,
                badgeCountText: '$totalFeedbacks',
                cardColor: const Color(0xFFFFF3E0),
                badgeColor: const Color(0xFFFF9800),
                badgeShadow: const Color(0xFFE65100),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminFeedbackScreen()))
                      .then((_) => _loadStats());
                },
              ),
              const SizedBox(height: 14),

              _buildCartoonMenuCard(
                title: 'Quản lý Người dùng',
                subtitle: 'Tra cứu tài khoản, điều chỉnh số dư Coin và Hạng thành viên',
                badgeText: 'CHỈNH SỬA',
                cardColor: const Color(0xFFE3F2FD),
                badgeColor: const Color(0xFF2196F3),
                badgeShadow: const Color(0xFF1976D2),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUsersScreen()))
                      .then((_) => _loadStats());
                },
              ),
              const SizedBox(height: 14),

              _buildCartoonMenuCard(
                title: 'Nội dung Bài học',
                subtitle: 'Thêm, sửa, xóa các chủ đề và tình huống câu hỏi',
                badgeText: 'BÀI HỌC',
                cardColor: const Color(0xFFE8F8F5),
                badgeColor: const Color(0xFF2ECC71),
                badgeShadow: const Color(0xFF27AE60),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminTopicsScreen()))
                      .then((_) => _loadStats());
                },
              ),
              const SizedBox(height: 14),

              _buildCartoonMenuCard(
                title: 'Quản lý Nạp Coin',
                subtitle: 'Phê duyệt hoặc từ chối đơn nạp chuyển khoản',
                badgeText: 'DUYỆT ĐƠN',
                badgeCount: pendingTopupRequests,
                cardColor: const Color(0xFFFFF8E1),
                badgeColor: const Color(0xFFFF9800),
                badgeShadow: const Color(0xFFE65100),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminTransactionsScreen()))
                      .then((_) => _loadStats());
                },
              ),
              const SizedBox(height: 14),

              _buildCartoonMenuCard(
                title: 'Đổi Mật khẩu Admin',
                subtitle: 'Cập nhật mật khẩu đăng nhập của tài khoản Quản trị',
                badgeText: 'BẢO MẬT',
                cardColor: const Color(0xFFEDE7F6),
                badgeColor: const Color(0xFF5C6BC0),
                badgeShadow: const Color(0xFF3949AB),
                onTap: () {
                  showChangePasswordDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKidStatPod({
    required String title,
    required String value,
    required Color bgColor,
    required Color shadowColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cartoonBorder, width: 2),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            offset: const Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 28,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 28,
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartoonMenuCard({
    required String title,
    required String subtitle,
    required String badgeText,
    required Color cardColor,
    required Color badgeColor,
    required Color badgeShadow,
    required VoidCallback onTap,
    int badgeCount = 0,
    String? badgeCountText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cartoonBorder, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cartoonBorder,
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.h3.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (badgeCount > 0)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      badgeCountText ?? '$badgeCount ĐANG CHỜ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cartoonBorder, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: badgeShadow,
                        offset: const Offset(0, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Text(
                    badgeText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
