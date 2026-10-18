import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_widgets.dart';
import '../../data/mock_data.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  void _showBadgeDetail(BuildContext context, BadgeModel badge, bool isUnlocked) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.only(top: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: AppColors.cartoonBorder, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cartoonBorder,
                offset: Offset(0, -5),
                blurRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: isUnlocked ? const Color(0xFFFFF9E6) : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isUnlocked ? AppColors.secondary : const Color(0xFFCBD5E1),
                        width: 2.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        badge.icon,
                        style: TextStyle(
                          fontSize: 44,
                          color: isUnlocked ? null : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  badge.title,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: isUnlocked ? AppColors.successLight : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isUnlocked ? AppColors.success.withOpacity(0.4) : const Color(0xFFCBD5E1),
                      ),
                    ),
                    child: Text(
                      isUnlocked ? 'ĐÃ MỞ KHÓA' : 'CHƯA MỞ KHÓA',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        color: isUnlocked ? AppColors.successDark : const Color(0xFF64748B),
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Ý nghĩa huy hiệu',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  badge.description,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nhiệm vụ để nhận',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    _getBadgeRequirementText(badge.id),
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'ĐÓNG',
                  color: AppColors.primary,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getBadgeRequirementText(String badgeId) {
    switch (badgeId) {
      case 'b1':
        return 'Vượt qua Level 3 của chủ đề An toàn giao thông.';
      case 'b2':
        return 'Vượt qua 5 Level liên tiếp của chủ đề An toàn giao thông.';
      case 'b3':
        return 'Vượt qua Level 3 của chủ đề An toàn khi ở nhà.';
      case 'b4':
        return 'Vượt qua 5 Level liên tiếp của chủ đề An toàn khi ở nhà.';
      case 'b5':
        return 'Vượt qua Level 3 của chủ đề An toàn ngoài trời.';
      case 'b6':
        return 'Vượt qua 5 Level liên tiếp của chủ đề An toàn ngoài trời.';
      case 'b7':
        return 'Vượt qua Level 1 của chủ đề An toàn với người lạ.';
      case 'b8':
        return 'Vượt qua 5 Level liên tiếp của chủ đề An toàn với người lạ.';
      case 'b9':
        return 'Đạt 3/3 câu đúng ở bất kỳ Level nào lần đầu tiên.';
      case 'b10':
        return 'Đạt 3/3 câu đúng ở 5 Level liên tiếp ở cùng 1 chủ đề.';
      case 'b11':
        return 'Trả lời đúng toàn bộ câu hỏi của 10 level trong 1 chủ đề bất kỳ.';
      case 'b12':
        return 'Vượt qua ít nhất 1 Level mỗi ngày trong 3 ngày liên tiếp.';
      case 'b13':
        return 'Duy trì chuỗi học tập (Streak) 7 ngày liên tiếp.';
      case 'b15':
        return 'Mở khóa thành công 10 huy hiệu bất kỳ.';
      case 'b16':
        return 'Hoàn thành level 1 của 4 chủ đề.';
      case 'b17':
        return 'Hoàn thành level 5 của 4 chủ đề.';
      case 'b18':
        return 'Hoàn thành level 7 của 1 chủ đề bất kì.';
      case 'b19':
        return 'Đạt 300 điểm học tập (nhận được khi trả lời đúng câu hỏi).';
      case 'b20':
        return 'Đạt 1000 điểm học tập (nhận được khi trả lời đúng câu hỏi).';
      default:
        return MockContentRepository.getBadgeRequirementText(badgeId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final badges = MockContentRepository.badges;
    final unlockedBadges = provider.unlockedBadges;

    return Scaffold(
      backgroundColor: const Color(0xFFEEF6FF),
      body: SafeArea(
        child: Stack(
          children: [
            // Floating cloud scenery
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.55),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Column(
              children: [
                // Custom Cartoon Header
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Text(
                    'Kho Báu Huy Hiệu',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Treasury Tracker Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: const Color(0xFFD6E4FF), width: 2.2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFFD0E1FD),
                          offset: Offset(0, 5),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Bộ Sưu Tập Của Bé',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF9E6),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFFFE082)),
                              ),
                              child: Text(
                                '${unlockedBadges.length}/${badges.length} HUY HIỆU',
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.secondaryDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ProgressBar(
                          progress: badges.isEmpty ? 0 : unlockedBadges.length / badges.length,
                          color: AppColors.secondary,
                          height: 12,
                          backgroundColor: const Color(0xFFF1F5F9),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Grid of Badges
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: badges.length,
                    itemBuilder: (context, index) {
                      final badge = badges[index];
                      final isUnlocked = unlockedBadges.contains(badge.id);

                      return GestureDetector(
                        onTap: () => _showBadgeDetail(context, badge, isUnlocked),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: isUnlocked ? AppColors.secondary : const Color(0xFFCBD5E1),
                              width: 2.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isUnlocked ? const Color(0xFFFFE082) : const Color(0xFFE2E8F0),
                                offset: const Offset(0, 4.5),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Badge Emoji Bubble
                              Container(
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  color: isUnlocked ? const Color(0xFFFFF9E6) : const Color(0xFFF1F5F9),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isUnlocked ? AppColors.secondary : const Color(0xFFCBD5E1),
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    badge.icon,
                                    style: TextStyle(
                                      fontSize: 36,
                                      color: isUnlocked ? null : Colors.grey.withOpacity(0.4),
                                    ),
                                  ),
                                ),
                              ),

                              Column(
                                children: [
                                  Text(
                                    badge.title,
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: isUnlocked ? AppColors.textPrimary : const Color(0xFF94A3B8),
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    badge.description,
                                    style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF94A3B8),
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),

                              // Status Pill - NO ICONS!
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isUnlocked ? AppColors.secondary : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isUnlocked ? 'ĐÃ ĐẠT ĐƯỢC' : 'CHƯA MỞ',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: isUnlocked ? Colors.white : const Color(0xFF94A3B8),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
