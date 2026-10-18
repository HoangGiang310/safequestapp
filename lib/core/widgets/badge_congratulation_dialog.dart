import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../data/mock_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'custom_widgets.dart';

Future<void> showBadgeCongratulationDialog(BuildContext context, List<String> badgeIds) {
  if (badgeIds.isEmpty) return Future.value();

  final badges = badgeIds
      .map((id) => MockContentRepository.getBadgeById(id))
      .whereType<BadgeModel>()
      .toList();

  if (badges.isEmpty) return Future.value();

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return BadgeCongratulationDialog(badges: badges);
    },
  );
}

class BadgeCongratulationDialog extends StatefulWidget {
  final List<BadgeModel> badges;

  const BadgeCongratulationDialog({
    super.key,
    required this.badges,
  });

  @override
  State<BadgeCongratulationDialog> createState() => _BadgeCongratulationDialogState();
}

class _BadgeCongratulationDialogState extends State<BadgeCongratulationDialog> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMultiple = widget.badges.length > 1;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
              BoxShadow(
                color: AppColors.secondary.withOpacity(0.25),
                blurRadius: 40,
                spreadRadius: 2,
              ),
            ],
            border: Border.all(
              color: AppColors.secondary.withOpacity(0.35),
              width: 2.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header badge icon & celebratory title
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🏆', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Text(
                          isMultiple
                              ? 'NHẬN ĐƯỢC ${widget.badges.length} HUY HIỆU MỚI!'
                              : 'NHẬN ĐƯỢC HUY HIỆU MỚI!',
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '🎉 Chúc Mừng Bạn! 🎉',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isMultiple
                        ? 'Bạn đã hoàn thành xuất sắc các nhiệm vụ:'
                        : 'Bạn đã hoàn thành xuất sắc nhiệm vụ nhận huy hiệu:',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Content area (single badge or PageView)
                  if (!isMultiple)
                    _buildBadgeCard(widget.badges.first)
                  else ...[
                    SizedBox(
                      height: 250,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: widget.badges.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return _buildBadgeCard(widget.badges[index]);
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Page Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.badges.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 20 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index ? AppColors.primary : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Saved to account indicator
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Đã lưu vào bộ sưu tập huy hiệu của bạn',
                            style: TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Dismiss button
                  PrimaryButton(
                    text: 'TUYỆT VỜI! ✨',
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeCard(BadgeModel badge) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Glowing Badge Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.secondary.withOpacity(0.3),
                AppColors.secondary.withOpacity(0.08),
              ],
            ),
            border: Border.all(
              color: AppColors.secondary.withOpacity(0.6),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withOpacity(0.2),
                blurRadius: 16,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Center(
            child: Text(
              badge.icon,
              style: const TextStyle(fontSize: 44),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Badge Name
        Text(
          badge.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Requirement fulfilled container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9E6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFFE082), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text('🎯', style: TextStyle(fontSize: 13)),
                  SizedBox(width: 6),
                  Text(
                    'Điều kiện đã hoàn thành:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB78103),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                badge.description,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
