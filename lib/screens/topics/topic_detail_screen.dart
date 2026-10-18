import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../game/game_screen.dart';

class TopicDetailScreen extends StatelessWidget {
  final Topic topic;

  const TopicDetailScreen({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final currentTopic = provider.adminTopics.firstWhere((t) => t.id == topic.id, orElse: () => topic);
    final levels = provider.levels.where((l) => l.topicId == currentTopic.id).toList();

    levels.sort((a, b) => a.order.compareTo(b.order));
    final topicColor = Color(currentTopic.colorValue);

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
                // Custom Top Bar with QUAY LẠI pill (NO ICONS)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.cartoonBorder, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFFD0E1FD),
                                offset: Offset(0, 3),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: const Text(
                            'QUAY LẠI',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          currentTopic.title,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 70),
                    ],
                  ),
                ),

                // Level Trail List
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // Large Topic Avatar Bubble
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: topicColor, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: topicColor.withOpacity(0.35),
                                offset: const Offset(0, 6),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(currentTopic.icon, style: const TextStyle(fontSize: 48)),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          currentTopic.title,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${levels.length} cấp độ thử thách hấp dẫn',
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Stepping Stones Level List
                        ...List.generate(levels.length, (index) {
                          final level = levels[index];
                          final isUnlocked = provider.isLevelUnlocked(level.id);
                          final isCompleted = provider.isLevelCompleted(level.id);

                          final hsl = HSLColor.fromColor(topicColor);
                          final shadowColor = hsl.withLightness((hsl.lightness - 0.22).clamp(0.0, 1.0)).toColor();

                          return Column(
                            children: [
                              GestureDetector(
                                onTap: !isUnlocked
                                    ? null
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => GameScreen(level: level)),
                                        );
                                      },
                                child: Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(26),
                                    border: Border.all(
                                      color: isCompleted
                                          ? AppColors.success
                                          : (isUnlocked ? topicColor : const Color(0xFFCBD5E1)),
                                      width: 2.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isCompleted
                                            ? AppColors.successDark.withOpacity(0.35)
                                            : (isUnlocked ? shadowColor.withOpacity(0.3) : const Color(0xFFE2E8F0)),
                                        offset: const Offset(0, 4.5),
                                        blurRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      // Level Number Bubble
                                      Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          color: isCompleted
                                              ? AppColors.successLight
                                              : (isUnlocked ? topicColor.withOpacity(0.15) : const Color(0xFFF1F5F9)),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isCompleted
                                                ? AppColors.success
                                                : (isUnlocked ? topicColor : const Color(0xFFCBD5E1)),
                                            width: 2,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${level.order}',
                                            style: TextStyle(
                                              fontFamily: 'Nunito',
                                              fontSize: 20,
                                              fontWeight: FontWeight.w900,
                                              color: isCompleted
                                                  ? AppColors.successDark
                                                  : (isUnlocked ? topicColor : const Color(0xFF94A3B8)),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),

                                      // Level Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'CẤP ĐỘ ${level.order}',
                                              style: TextStyle(
                                                fontFamily: 'Nunito',
                                                fontSize: 11,
                                                fontWeight: FontWeight.w900,
                                                color: isUnlocked ? topicColor : const Color(0xFF94A3B8),
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              level.title,
                                              style: TextStyle(
                                                fontFamily: 'Nunito',
                                                fontSize: 15,
                                                fontWeight: FontWeight.w900,
                                                color: isUnlocked ? AppColors.textPrimary : const Color(0xFF94A3B8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Status / Action Pill - NO ICONS!
                                      if (isCompleted)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                          decoration: BoxDecoration(
                                            color: AppColors.successLight,
                                            borderRadius: BorderRadius.circular(14),
                                            border: Border.all(color: AppColors.success.withOpacity(0.4), width: 1.5),
                                          ),
                                          child: const Text(
                                            'ĐÃ VƯỢT QUA',
                                            style: TextStyle(
                                              fontFamily: 'Nunito',
                                              color: AppColors.successDark,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        )
                                      else if (isUnlocked)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: topicColor,
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(color: AppColors.cartoonBorder, width: 1.5),
                                            boxShadow: [
                                              BoxShadow(
                                                color: shadowColor,
                                                offset: const Offset(0, 3),
                                                blurRadius: 0,
                                              ),
                                            ],
                                          ),
                                          child: const Text(
                                            'CHƠI',
                                            style: TextStyle(
                                              fontFamily: 'Nunito',
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        )
                                      else
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          child: const Text(
                                            'CHƯA MỞ',
                                            style: TextStyle(
                                              fontFamily: 'Nunito',
                                              color: Color(0xFF94A3B8),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),

                              // Connecting candy connector bar
                              if (index < levels.length - 1)
                                Container(
                                  width: 6,
                                  height: 24,
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isCompleted ? AppColors.success : const Color(0xFFCBD5E1),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                            ],
                          );
                        }),
                      ],
                    ),
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
