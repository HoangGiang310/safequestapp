import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../welcome/welcome_screen.dart';
import 'top_up_screen.dart';
import 'upgrade_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showEditNameDialog(BuildContext context, AppProvider provider) {
    final controller = TextEditingController(text: provider.profile?.name ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.cartoonBorder, width: 3),
        ),
        title: Text(
          'ĐỔI TÊN',
          textAlign: TextAlign.center,
          style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w900),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cartoonBorder, width: 2),
              ),
              child: TextField(
                controller: controller,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'Nhập tên mới của bé...',
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: InputBorder.none,
                ),
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
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cartoonBorder, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF9E9E9E),
                          offset: Offset(0, 3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'HỦY',
                      style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF616161)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (controller.text.trim().isNotEmpty) {
                      provider.updateProfile(name: controller.text.trim());
                    }
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cartoonBorder, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.primaryDark,
                          offset: Offset(0, 3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'LƯU TÊN',
                      style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAvatarPicker(BuildContext context, AppProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final avatars = [
          '🐱', // 1. Mèo
          '🐭', // 2. Chuột
          '🐃', // 3. Trâu
          '🐸', // 4. Ếch
          '🐯', // 5. Hổ
          '🐬', // 6. Cá heo
          '🐰', // 7. Thỏ
          '🐢', // 8. Rùa
          '🐲', // 9. Rồng
          '🦄', // 10. Kì lân
          '🐍', // 11. Rắn
          '🦦', // 12. Cầy mang
          '🐴', // 13. Ngựa
          '🦁', // 14. Sư tử
          '🐑', // 15. Cừu
          '🐺', // 16. Sói
          '🐵', // 17. Khỉ
          '🦀', // 18. Cua
          '🐔', // 19. Gà
          '🦡', // 20. Chồn
          '🐶', // 21. Chó
          '🦅', // 22. Đại bàng
          '🐷', // 23. Heo
          '🦋', // 24. Bướm
        ];
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(
              top: BorderSide(color: AppColors.cartoonBorder, width: 3.5),
              left: BorderSide(color: AppColors.cartoonBorder, width: 3.5),
              right: BorderSide(color: AppColors.cartoonBorder, width: 3.5),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.cartoonBorder.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'CHỌN HÌNH ĐẠI DIỆN',
                style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w900, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.55,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: avatars.map((avatar) {
                      final isSelected = provider.profile?.avatar == avatar;
                      return GestureDetector(
                        onTap: () {
                          provider.updateProfile(avatar: avatar);
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.cartoonYellow.withOpacity(0.35) : AppColors.cardBackground,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.cartoonBorder,
                              width: isSelected ? 3 : 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected ? AppColors.primaryDark : AppColors.cartoonBorder.withOpacity(0.3),
                                offset: const Offset(0, 3),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(avatar, style: const TextStyle(fontSize: 34)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final profile = provider.profile;

    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final membership = provider.currentAccount?.membershipType ?? MembershipType.FREE;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cartoon Header
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.cartoonBorder, width: 2.5),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.cartoonBorder,
                        offset: Offset(0, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Text(
                    'HỒ SƠ',
                    style: AppTextStyles.h2.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Hero Adventure Passport Card
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
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
                    // Avatar pod with 3D bevel
                    GestureDetector(
                      onTap: () => _showAvatarPicker(context, provider),
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF9C4),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.cartoonBorder, width: 3.5),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.cartoonBorder,
                              offset: Offset(0, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(profile.avatar, style: const TextStyle(fontSize: 58)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Name
                    Text(
                      profile.name,
                      style: AppTextStyles.h1.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Badge Pill: ID & Age
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.cartoonSky.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.cartoonBorder, width: 2),
                      ),
                      child: Text(
                        'ID: ${provider.currentAccount?.id ?? "---"} • ${profile.age} TUỔI',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Coin & Membership Treasure Pod
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.cartoonBorder, width: 2.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFFFFB74D),
                            offset: Offset(0, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🪙', style: TextStyle(fontSize: 26)),
                          const SizedBox(width: 8),
                          Text(
                            '${provider.currentAccount?.coinBalance ?? 0} COIN',
                            style: AppTextStyles.h2.copyWith(
                              color: const Color(0xFFE65100),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (membership != MembershipType.FREE) ...[
                            const SizedBox(width: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: membership == MembershipType.PREMIUM
                                    ? const Color(0xFFAB47BC)
                                    : const Color(0xFF29B6F6),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.cartoonBorder, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: membership == MembershipType.PREMIUM
                                        ? const Color(0xFF7B1FA2)
                                        : const Color(0xFF0288D1),
                                    offset: const Offset(0, 2),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: Text(
                                membership.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 3 Pods: Points, Streak, Badges
                    Row(
                      children: [
                        Expanded(
                          child: _buildKidStatPod('⭐', '${profile.points}', 'ĐIỂM SỐ', const Color(0xFFFFF9C4), const Color(0xFFFBC02D)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildKidStatPod('🔥', '${profile.streak}', 'CHUỖI HỌC', const Color(0xFFFFE0B2), const Color(0xFFFB8C00)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildKidStatPod('🏆', '${provider.unlockedBadges.length}', 'HUY HIỆU', const Color(0xFFE1BEE7), const Color(0xFF8E24AA)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section 1: Tài khoản & Nâng cấp
              Text(
                'CHỨC NĂNG COIN',
                style: AppTextStyles.h2.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              _buildCartoonActionCard(
                title: 'Nạp Coin',
                subtitle: 'Tích lũy tiền vàng để nâng cấp tính năng',
                badgeText: 'NẠP COIN',
                cardColor: const Color(0xFFE0F7FA),
                badgeColor: AppColors.primary,
                badgeShadow: AppColors.primaryDark,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const TopUpScreen()));
                },
              ),
              _buildCartoonActionCard(
                title: 'Nâng cấp tài khoản',
                subtitle: 'Mở khóa đặc quyền hiệp sĩ VIP & Premium',
                badgeText: 'NÂNG CẤP',
                cardColor: const Color(0xFFFFF8E1),
                badgeColor: const Color(0xFFFFB300),
                badgeShadow: const Color(0xFFF57F17),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const UpgradeScreen()));
                },
              ),
              const SizedBox(height: 16),

              // Section 2: Thông tin cá nhân
              Text(
                'TÙY CHỈNH HỒ SƠ',
                style: AppTextStyles.h2.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              _buildCartoonActionCard(
                title: 'Đổi tên',
                subtitle: 'Thay đổi tên hiển thị trong các bài học',
                badgeText: 'ĐỔI TÊN',
                cardColor: const Color(0xFFEDE7F6),
                badgeColor: const Color(0xFF7E57C2),
                badgeShadow: const Color(0xFF512DA8),
                onTap: () => _showEditNameDialog(context, provider),
              ),
              _buildCartoonActionCard(
                title: 'Đổi hình đại diện',
                subtitle: 'Chọn linh vật hoặc nhân vật yêu thích',
                badgeText: 'ĐỔI ẢNH',
                cardColor: const Color(0xFFFCE4EC),
                badgeColor: const Color(0xFFEC407A),
                badgeShadow: const Color(0xFFC2185B),
                onTap: () => _showAvatarPicker(context, provider),
              ),
              const SizedBox(height: 16),

              // Section 3: Thống kê học tập
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: AppColors.cartoonBorder, width: 2.5),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.cartoonBorder,
                      offset: Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'NHẬT KÝ HỌC TẬP',
                          style: AppTextStyles.h2.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.cartoonSky.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.cartoonBorder, width: 1.5),
                          ),
                          child: const Text(
                            'CHĂM CHỈ',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDiaryRow('Chuỗi ngày hiện tại', '${profile.streak} ngày', const Color(0xFF00B0FF)),
                    const SizedBox(height: 10),
                    _buildDiaryRow('Kỷ lục chuỗi dài nhất', '${profile.longestStreak} ngày', const Color(0xFFFF9100)),
                    const SizedBox(height: 10),
                    _buildDiaryRow('Tổng số ngày đã học', '${profile.studyDates.length} ngày', const Color(0xFF00E676)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section 4: Sign Out Button (NO ICONS)

              GestureDetector(
                onTap: () async {
                  await provider.logout();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                    (route) => false,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFD32F2F), width: 2.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFFC62828),
                        offset: Offset(0, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'ĐĂNG XUẤT TÀI KHOẢN',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFC62828),
                      fontSize: 16,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKidStatPod(String emoji, String value, String label, Color bgColor, Color shadowColor) {
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
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.h2.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartoonActionCard({
    required String title,
    required String subtitle,
    required String badgeText,
    required Color cardColor,
    required Color badgeColor,
    required Color badgeShadow,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cartoonBorder, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cartoonBorder,
            offset: Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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

  Widget _buildDiaryRow(String title, String value, Color indicatorColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cartoonBorder.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: indicatorColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: indicatorColor, width: 1.5),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: indicatorColor,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
