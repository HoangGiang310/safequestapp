import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/custom_widgets.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import 'top_up_screen.dart';

class UpgradeScreen extends StatefulWidget {
  const UpgradeScreen({super.key});

  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  void _buyMembership(MembershipType type, int cost) async {
    final provider = Provider.of<AppProvider>(context, listen: false);

    if (provider.currentAccount!.coinBalance < cost) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
            side: const BorderSide(color: AppColors.cartoonBorder, width: 3),
          ),
          title: Text(
            'CHƯA ĐỦ TIỀN VÀNG',
            textAlign: TextAlign.center,
            style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w900, color: AppColors.textPrimary),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🪙', style: TextStyle(fontSize: 48)),
              SizedBox(height: 12),
              Text(
                'Bé cần nạp thêm Coin để mở khóa gói hiệp sĩ này nhé!',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary, height: 1.4),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          actions: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cartoonBorder, width: 2),
                        boxShadow: const [
                          BoxShadow(color: Color(0xFF9E9E9E), offset: Offset(0, 3), blurRadius: 0),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Text('ĐỂ SAU', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF616161))),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TopUpScreen()));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cartoonBorder, width: 2),
                        boxShadow: const [
                          BoxShadow(color: AppColors.primaryDark, offset: Offset(0, 3), blurRadius: 0),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Text('NẠP COIN', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
          side: const BorderSide(color: AppColors.cartoonBorder, width: 3),
        ),
        title: Text(
          'XÁC NHẬN NÂNG CẤP',
          textAlign: TextAlign.center,
          style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w900, color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('👑', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'Bé có chắc chắn muốn dùng $cost Coin để sở hữu gói ${type.name} không?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFF9800), width: 1.5),
              ),
              child: Row(
                children: [
                  const Text('🎁', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'TẶNG NGAY: +${type == MembershipType.PREMIUM ? "1.000" : "500"} Điểm Học Tập để tha hồ xây nhà mơ ước!',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFE65100),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cartoonBorder, width: 2),
                      boxShadow: const [
                        BoxShadow(color: Color(0xFF9E9E9E), offset: Offset(0, 3), blurRadius: 0),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text('HỦY', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF616161))),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    Navigator.pop(ctx);
                    final success = await provider.upgradeMembership(type, cost);
                    if (success && mounted) {
                      final bonus = type == MembershipType.PREMIUM ? 1000 : 500;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Nâng cấp ${type.name} thành công! 🎉 Nhận ngay +$bonus Điểm Học Tập 🏡'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB300),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cartoonBorder, width: 2),
                      boxShadow: const [
                        BoxShadow(color: Color(0xFFF57F17), offset: Offset(0, 3), blurRadius: 0),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text('XÁC NHẬN', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final currentMembership = provider.currentAccount?.membershipType ?? MembershipType.FREE;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Navigation Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
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
                        'QUAY LẠI',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.cartoonBorder, width: 2),
                    ),
                    child: Text(
                      'NÂNG CẤP',
                      style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Current Membership & Vault Pod
              Container(
                padding: const EdgeInsets.all(18),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'HẠNG HIỆP SĨ HIỆN TẠI',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: currentMembership == MembershipType.PREMIUM
                                ? const Color(0xFFFFF9C4)
                                : (currentMembership == MembershipType.VIP
                                    ? const Color(0xFFE1F5FE)
                                    : AppColors.cardBackground),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.cartoonBorder, width: 2),
                          ),
                          child: Text(
                            currentMembership.name,
                            style: TextStyle(
                              color: currentMembership == MembershipType.PREMIUM
                                  ? const Color(0xFFF57F17)
                                  : (currentMembership == MembershipType.VIP
                                      ? const Color(0xFF0288D1)
                                      : AppColors.textPrimary),
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Study Points Pod
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF9C4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.cartoonBorder, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFFFBC02D),
                                offset: Offset(0, 3),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('⭐', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 4),
                              Text(
                                '${provider.profile?.points ?? 0}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFF57F17),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Coin Balance Pod
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.cartoonBorder, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFFFFB74D),
                                offset: Offset(0, 3),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🪙', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 4),
                              Text(
                                '${provider.currentAccount?.coinBalance ?? 0}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFE65100),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Membership Packages
              if (currentMembership == MembershipType.FREE)
                _buildCartoonPackageCard(
                  title: 'GÓI VIP',
                  badgeTitle: 'HIỆP SĨ VIP',
                  cost: 500,
                  cardColor: const Color(0xFFE1F5FE),
                  headerColor: const Color(0xFF039BE5),
                  headerShadow: const Color(0xFF0277BD),
                  bonusGiftText: 'TẶNG NGAY +500 ĐIỂM HỌC TẬP',
                  features: [
                    'Tặng ngay +500 Điểm Học Tập',
                    'Mở khóa toàn bộ chủ đề và bài học an toàn',
                    'Mở khóa vật phẩm & đồ trang trí nhà VIP đặc quyền',
                    'Trải nghiệm mượt mà, không quảng cáo làm phiền',
                    'Huy hiệu danh xưng Hiệp Sĩ VIP độc quyền',
                  ],
                  onTap: () => _buyMembership(MembershipType.VIP, 500),
                ),

              if (currentMembership != MembershipType.PREMIUM)
                _buildCartoonPackageCard(
                  title: 'GÓI PREMIUM',
                  badgeTitle: 'VƯƠNG QUỐC PREMIUM',
                  cost: 1000,
                  cardColor: const Color(0xFFFFF8E1),
                  headerColor: const Color(0xFFFFB300),
                  headerShadow: const Color(0xFFF57F17),
                  bonusGiftText: 'TẶNG NGAY +1.000 ĐIỂM HỌC TẬP',
                  features: [
                    'Tặng ngay +1.000 Điểm Học Tập',
                    'Toàn bộ đặc quyền của gói VIP',
                    'Mở khóa bộ sưu tập nội thất Hoàng Gia & sân vườn biệt thự',
                    'Trợ lý AI đồng hành thông minh giải đáp an toàn',
                    'Ưu tiên nhận sớm chủ đề và vật phẩm kiến trúc mới nhất',
                  ],
                  onTap: () => _buyMembership(MembershipType.PREMIUM, 1000),
                ),

              if (currentMembership == MembershipType.PREMIUM)
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.cartoonBorder, width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFFFFB74D),
                        offset: Offset(0, 5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text('👑', style: TextStyle(fontSize: 68)),
                      const SizedBox(height: 12),
                      Text(
                        'ĐẲNG CẤP CAO NHẤT!',
                        style: AppTextStyles.h1.copyWith(
                          color: const Color(0xFFE65100),
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Con đang sở hữu trọn bộ quyền năng cao cấp của SAFEQUEST và đặc quyền Hoàng Gia trong Game Xây Nhà. Chúc hiệp sĩ nhí có những chuyến phiêu lưu thật bổ ích!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartoonPackageCard({
    required String title,
    required String badgeTitle,
    required int cost,
    required Color cardColor,
    required Color headerColor,
    required Color headerShadow,
    required String bonusGiftText,
    required List<String> features,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Pod
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
              border: const Border(bottom: BorderSide(color: AppColors.cartoonBorder, width: 2.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cartoonBorder, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.cartoonBorder,
                        offset: Offset(0, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Text(
                    '$cost COIN',
                    style: TextStyle(
                      color: headerShadow,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Gift Banner Pod (Bonus points hook!)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6D00), Color(0xFFFF9100)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cartoonBorder, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFFBF360C),
                  offset: Offset(0, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                const Text('🎁', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    bonusGiftText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                      shadows: [
                        Shadow(color: Color(0xFFBF360C), offset: Offset(1, 1), blurRadius: 1),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Features List
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 14.0, 20.0, 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...features.asMap().entries.map((entry) {
                  final idx = entry.key + 1;
                  final f = entry.value;
                  final isPointBonus = entry.key == 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isPointBonus ? const Color(0xFFFFE082) : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isPointBonus ? const Color(0xFFF57F17) : AppColors.cartoonBorder,
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            isPointBonus ? '★' : '$idx',
                            style: TextStyle(
                              fontSize: isPointBonus ? 13 : 11,
                              fontWeight: FontWeight.w900,
                              color: isPointBonus ? const Color(0xFFE65100) : headerShadow,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            f,
                            style: TextStyle(
                              fontWeight: isPointBonus ? FontWeight.w900 : FontWeight.w700,
                              fontSize: 14,
                              color: isPointBonus ? const Color(0xFFBF360C) : AppColors.textPrimary,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                PrimaryButton(
                  text: 'NÂNG CẤP $title',
                  color: headerColor,
                  onPressed: onTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
