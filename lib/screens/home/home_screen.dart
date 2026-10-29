import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_widgets.dart';
import '../../data/mock_data.dart';
import '../../providers/app_provider.dart';
import '../../services/celebration_sound_manager.dart';
import '../topics/topic_detail_screen.dart';
import '../lessons/video_lessons_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final profile = provider.profile;
    final topics = provider.topics.isNotEmpty ? provider.topics : MockContentRepository.topics;

    if (profile == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFEEF6FF),
        body: Center(
          child: Text(
            'Đang tải...',
            style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
          ),
        ),
      );
    }

    final continueLearningContext = provider.getContinueLearningContext();
    final continueTopic = continueLearningContext['topic'];
    final continueLevel = continueLearningContext['level'];

    return Scaffold(
      backgroundColor: const Color(0xFFEEF6FF),
      body: SafeArea(
        child: Stack(
          children: [
            // Background cloud decor
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 180,
              left: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            RefreshIndicator(
              onRefresh: () async {
                await provider.reloadContent();
              },
              color: AppColors.primary,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Kid Profile Island Header
                    _buildProfileHeader(context, provider, profile),

                    const SizedBox(height: 20),

                    // Weekly Stepping Stones
                    _buildWeeklySteppingStones(profile),

                    const SizedBox(height: 20),

                    // Continue Learning Card
                    if (continueTopic != null && continueLevel != null) ...[
                      _buildContinueLearningCard(context, provider, continueTopic, continueLevel),
                      const SizedBox(height: 20),
                    ],


                    // Video Lessons Banner (Vị trí 1: Banner hoạt hình nổi bật)
                    _buildVideoLessonsBanner(context),

                    const SizedBox(height: 24),

                    // Topic Section Header
                    const Text(
                      'Thế Giới An Toàn',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 2-Column Creative Cartoon Topic Cards
                    _buildTopicGrid(context, provider, topics),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, AppProvider provider, dynamic profile) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFD6E4FF), width: 2.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFD0E1FD),
            offset: Offset(0, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              children: [
                // Avatar circle
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2.2),
                  ),
                  child: Center(
                    child: Text(profile.avatar, style: const TextStyle(fontSize: 32)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chào ${profile.name}!',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Cùng khám phá bài học mới nào!',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Nút Điểm Danh ngay dưới chỗ: Chào ... Cùng khám phá bài học mới nào!
                      _buildCheckInButton(context, provider),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Streak flame badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cartoonBorder, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFFD84315),
                  offset: Offset(0, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  '${profile.streak}',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInButton(BuildContext context, AppProvider provider) {
    final isCheckedIn = provider.isTodayCheckedIn;

    return GestureDetector(
      onTap: () async {
        if (isCheckedIn) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hôm nay con đã điểm danh và nhận 30 điểm rồi! Cùng làm bài để tăng chuỗi streak nhé! 🎉'),
              backgroundColor: Color(0xFF00B0FF),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }

        final success = await provider.checkInDaily();
        if (success && context.mounted) {
          CelebrationSoundManager().playBadgeUnlock();
          _showCheckInSuccessDialog(context);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isCheckedIn ? const Color(0xFFE8F5E9) : const Color(0xFFFF9800),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCheckedIn ? const Color(0xFF81C784) : const Color(0xFFF57C00),
            width: 1.6,
          ),
          boxShadow: [
            BoxShadow(
              color: isCheckedIn ? const Color(0xFFC8E6C9) : const Color(0xFFE65100),
              offset: const Offset(0, 2.5),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isCheckedIn ? '✅' : '🎁',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(width: 5),
            Text(
              isCheckedIn ? 'Đã điểm danh' : 'Điểm Danh',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: isCheckedIn ? const Color(0xFF2E7D32) : Colors.white,
              ),
            ),
            if (!isCheckedIn) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '+30 ⭐',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFE65100),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCheckInSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.cartoonBorder, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cartoonBorder,
                offset: Offset(0, 6),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Celebratory Icon Bubble
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9C4),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFD54F), width: 2.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFFFFE082),
                      offset: Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🎉', style: TextStyle(fontSize: 38)),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Điểm Danh Thành Công!',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Points Reward Pod
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFFFB74D), width: 1.8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('⭐', style: TextStyle(fontSize: 22)),
                    SizedBox(width: 8),
                    Text(
                      '+30 Điểm Học Tập',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFE65100),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Tài khoản của con đã được cộng 30 điểm học tập và tính thêm 1 ngày sử dụng app!',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF475569),
                  height: 1.35,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Text('🔥', style: TextStyle(fontSize: 15)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Chuỗi streak chỉ tăng khi con hoàn thành bài học nhé!',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                text: 'NHẬN ĐIỂM NGAY',
                color: AppColors.success,
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklySteppingStones(dynamic profile) {
    final today = DateTime.now();
    final todayStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    final isTodayStudied = profile.studyDates.contains(todayStr);

    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Hành Trình Chăm Chỉ',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: isTodayStudied ? AppColors.successLight : const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isTodayStudied ? AppColors.success.withOpacity(0.4) : const Color(0xFFFDE68A),
                  ),
                ),
                child: Text(
                  isTodayStudied ? 'ĐÃ HỌC HÔM NAY' : 'CHƯA HỌC HÔM NAY',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: isTodayStudied ? AppColors.successDark : AppColors.accentDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final dayDate = startOfWeek.add(Duration(days: index));
              final dayStr = "${dayDate.year}-${dayDate.month.toString().padLeft(2, '0')}-${dayDate.day.toString().padLeft(2, '0')}";
              final isStudied = profile.studyDates.contains(dayStr);
              final isCurrent = dayDate.day == today.day && dayDate.month == today.month && dayDate.year == today.year;

              return Column(
                children: [
                  Text(
                    days[index],
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w700,
                      color: isCurrent ? AppColors.primary : const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isStudied
                          ? AppColors.accent
                          : (isCurrent ? AppColors.secondary : const Color(0xFFF1F5F9)),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isStudied
                            ? AppColors.cartoonBorder
                            : (isCurrent ? AppColors.cartoonBorder : const Color(0xFFCBD5E1)),
                        width: 1.8,
                      ),
                      boxShadow: (isStudied || isCurrent)
                          ? [
                              BoxShadow(
                                color: isStudied ? const Color(0xFFD84315) : const Color(0xFFC68400),
                                offset: const Offset(0, 2.5),
                                blurRadius: 0,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: isStudied
                          ? const Text('🔥', style: TextStyle(fontSize: 16))
                          : (isCurrent
                              ? const Text('⭐', style: TextStyle(fontSize: 15))
                              : const SizedBox.shrink()),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueLearningCard(
    BuildContext context,
    AppProvider provider,
    dynamic continueTopic,
    dynamic continueLevel,
  ) {
    final progress = provider.getTopicProgress(continueTopic.id);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF2980B9),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.cartoonBorder, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF1B4F72),
            offset: Offset(0, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'BÀI HỌC TIẾP THEO',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}% Hoàn thành',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  color: Color(0xFFFFD54F),
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.cartoonBorder, width: 2),
                ),
                child: Center(
                  child: Text(continueTopic.icon, style: const TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      continueTopic.title,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      continueLevel.title,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tube Progress Bar
          ProgressBar(
            progress: progress,
            color: const Color(0xFFFFB300),
            height: 12,
            backgroundColor: Colors.white.withOpacity(0.25),
          ),
          const SizedBox(height: 18),

          // 3D Push Button - NO ICONS
          PrimaryButton(
            text: 'TIẾP TỤC',
            color: const Color(0xFFFFB300),
            height: 50,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TopicDetailScreen(topic: continueTopic)),
              );
            },
          ),
        ],
      ),
    );
  }



  Widget _buildVideoLessonsBanner(BuildContext context) {
    return GestureDetector(
      key: const Key('video_lessons_banner_button'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const VideoLessonsScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7E57C2), Color(0xFF5C6BC0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF3949AB), width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF283593),
              offset: Offset(0, 5),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Title and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Video Bài Giảng',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '4 chủ đề kĩ năng sinh động',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Action Button Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB300),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.cartoonBorder, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFFC68400),
                    offset: Offset(0, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Text(
                'XEM',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicGrid(BuildContext context, AppProvider provider, List<dynamic> topics) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.82,
      ),
      itemCount: topics.length,
      itemBuilder: (context, index) {
        final topic = topics[index];
        final isUnlocked = provider.isLevelUnlocked('${topic.id}_l1');
        final progress = provider.getTopicProgress(topic.id);
        final topicColor = Color(topic.colorValue);

        final hsl = HSLColor.fromColor(topicColor);
        final shadowColor = hsl.withLightness((hsl.lightness - 0.22).clamp(0.0, 1.0)).toColor();

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TopicDetailScreen(topic: topic)),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: isUnlocked ? topicColor : const Color(0xFFCBD5E1), width: 2.2),
              boxShadow: [
                BoxShadow(
                  color: isUnlocked ? shadowColor.withOpacity(0.35) : const Color(0xFFE2E8F0),
                  offset: const Offset(0, 5),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Emoji circle
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: isUnlocked ? topicColor.withOpacity(0.18) : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isUnlocked ? topicColor.withOpacity(0.5) : const Color(0xFFCBD5E1),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(topic.icon, style: const TextStyle(fontSize: 28)),
                    ),
                  ),

                  Column(
                    children: [
                      Text(
                        topic.title,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: isUnlocked ? AppColors.textPrimary : const Color(0xFF94A3B8),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      ProgressBar(
                        progress: progress,
                        color: topicColor,
                        height: 8,
                        backgroundColor: const Color(0xFFF1F5F9),
                      ),
                    ],
                  ),

                  // Status pill - NO ICONS!
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isUnlocked ? topicColor : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isUnlocked
                          ? [
                              BoxShadow(
                                color: shadowColor,
                                offset: const Offset(0, 2.5),
                                blurRadius: 0,
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      isUnlocked
                          ? (progress > 0 ? '${(progress * 100).toInt()}%' : 'BẮT ĐẦU')
                          : 'CHƯA MỞ',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: isUnlocked ? Colors.white : const Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
