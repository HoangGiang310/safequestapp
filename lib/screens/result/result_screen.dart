import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_widgets.dart';
import '../../core/widgets/celebration_widgets.dart';
import '../../core/widgets/confetti_effect.dart';
import '../../core/widgets/badge_congratulation_dialog.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../services/celebration_sound_manager.dart';

class ResultScreen extends StatefulWidget {
  final int score;
  final int questionsScore;
  final int levelBonusScore;
  final int correctCount;
  final int totalQuestions;
  final bool isReplay;
  final bool isReviewMode;
  final List<String> newlyUnlockedBadgeIds;
  final dynamic level;
  final bool isAlreadyCompleted;

  const ResultScreen({
    super.key,
    required this.score,
    this.questionsScore = 0,
    this.levelBonusScore = 0,
    this.correctCount = 0,
    this.totalQuestions = 3,
    this.isReplay = false,
    this.isReviewMode = false,
    this.newlyUnlockedBadgeIds = const [],
    this.level,
    this.isAlreadyCompleted = false,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late ConfettiController _confettiController;
  final CelebrationSoundManager _soundManager = CelebrationSoundManager();
  bool _showDetails = false;
  late List<String> _unlockedBadgeIds;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    final provider = Provider.of<AppProvider>(context, listen: false);
    _unlockedBadgeIds = widget.newlyUnlockedBadgeIds.isNotEmpty
        ? List<String>.from(widget.newlyUnlockedBadgeIds)
        : List<String>.from(provider.recentUnlockedBadges);
    _startCelebrationSequence();
  }

  void _startCelebrationSequence() async {
    final bool isPassed = widget.correctCount > 0 || widget.isReviewMode || widget.isReplay || widget.isAlreadyCompleted;
    if (isPassed && (widget.score > 0 || widget.isReviewMode || widget.isReplay || widget.isAlreadyCompleted)) {
      _soundManager.playLevelComplete();
      _confettiController.play();
    }
    
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) {
      setState(() {
        _showDetails = true;
      });
      
      if (!widget.isReviewMode && _unlockedBadgeIds.isNotEmpty) {
        _soundManager.playBadgeUnlock();
        final provider = Provider.of<AppProvider>(context, listen: false);
        provider.clearRecentUnlockedBadges();
        showBadgeCongratulationDialog(context, _unlockedBadgeIds);
      }
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    final bool isPassed = widget.correctCount > 0 || widget.isReviewMode || widget.isReplay || widget.isAlreadyCompleted;

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

            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: CelebrationCharacter(
                      isCorrect: isPassed,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: CelebrationText(
                      text: widget.isReviewMode 
                          ? 'Hoàn thành ôn tập!' 
                          : (widget.isReplay || widget.isAlreadyCompleted) 
                              ? 'Hoàn thành làm lại!' 
                              : (isPassed ? 'Level Hoàn Thành!' : 'Chưa Hoàn Thành!'),
                      onComplete: () {},
                    ),
                  ),
                  const SizedBox(height: 14),
                  
                  if (_showDetails) ...[
                    if (widget.isReviewMode) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: const Color(0xFF86EFAC), width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFFBBF7D0),
                              offset: Offset(0, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Con đã cố gắng làm rất tốt. Hãy cố gắng ôn luyện nhiều hơn nhé.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF166534),
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFF86EFAC)),
                              ),
                              child: Text(
                                'Số câu đúng: ${widget.correctCount}/${widget.totalQuestions} câu',
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF15803D),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (widget.isReplay || widget.isAlreadyCompleted) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.5),
                        ),
                        child: const Text(
                          'Cấp độ này bé đã vượt qua trước đó\n(Không cộng thêm điểm mới)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Đúng: ${widget.correctCount}/${widget.totalQuestions} câu',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ] else if (isPassed && widget.score > 0) ...[
                      Center(
                        child: ScoreAnimation(
                          score: widget.score,
                          onComplete: () {},
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: const Color(0xFFD6E4FF), width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFFD0E1FD),
                              offset: Offset(0, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                const Text('Trả lời đúng', style: TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                                const SizedBox(height: 2),
                                Text('${widget.correctCount}/${widget.totalQuestions}', style: const TextStyle(fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary)),
                              ],
                            ),
                            Container(width: 1.5, height: 32, color: const Color(0xFFE2E8F0)),
                            Column(
                              children: [
                                const Text('Tổng điểm nhận', style: TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                                const SizedBox(height: 2),
                                Text('+${widget.score}', style: const TextStyle(fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.successDark)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: const Color(0xFFFFB74D), width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFFFFCC80),
                              offset: Offset(0, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Con chưa trả lời đúng câu nào!',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFE65100),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Level này chưa hoàn thành và chưa thể mở khóa level tiếp theo.\nCác câu sai đã được lưu vào PHÒNG LUYỆN TẬP để con ôn luyện lại nhé!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF64748B),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFFFB74D)),
                              ),
                              child: Text(
                                'Đúng: 0/${widget.totalQuestions} câu • Điểm nhận: +0',
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFE65100),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Badge preview cards if unlocked
                    if (!widget.isReviewMode)
                      Builder(
                        builder: (context) {
                          final rawIds = _unlockedBadgeIds.isNotEmpty
                              ? _unlockedBadgeIds
                              : widget.newlyUnlockedBadgeIds.isNotEmpty
                                  ? widget.newlyUnlockedBadgeIds
                                  : provider.recentUnlockedBadges;

                          final distinctIds = rawIds.toSet().toList();
                          final earnedBadges = distinctIds
                              .map((id) => MockContentRepository.getBadgeById(id))
                              .whereType<BadgeModel>()
                              .toList();

                          if (earnedBadges.isNotEmpty) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (int i = 0; i < earnedBadges.length; i++) ...[
                                  if (i > 0) const SizedBox(height: 14),
                                  _buildBadgeCard(
                                    earnedBadges[i],
                                    index: i + 1,
                                    total: earnedBadges.length,
                                  ),
                                ],
                              ],
                            );
                          }

                          // Friendly Cheer Card
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
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
                            child: const Column(
                              children: [
                                Text('🏅', style: TextStyle(fontSize: 60)),
                                SizedBox(height: 10),
                                Text(
                                  'Bé Đang Làm Rất Tốt!',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Tiếp tục rèn luyện thêm nhiều kỹ năng bổ ích nhé!',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF64748B),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  
                    const SizedBox(height: 32),

                    // Action Buttons - 3D cartoon style, NO ICONS!
                    if (widget.isReviewMode)
                      PrimaryButton(
                        text: 'QUAY LẠI LUYỆN TẬP',
                        color: AppColors.primary,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    else
                      PrimaryButton(
                        text: isPassed ? 'TIẾP TỤC' : 'THỬ LẠI',
                        color: isPassed ? AppColors.primary : const Color(0xFFFF9800),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    const SizedBox(height: 12),
                    SecondaryButton(
                      text: 'VỀ TRANG CHỦ',
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                    ),
                  ],
                ],
              ),
            ),

            // Confetti celebration
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiEffect(controller: _confettiController, isStrong: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeCard(BadgeModel badge, {required int index, required int total}) {
    final badgeLabel = total > 1
        ? 'HUY HIỆU MỚI MỞ KHÓA ($index/$total)'
        : 'HUY HIỆU MỚI MỞ KHÓA';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.secondary, width: 2.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFFFE082),
            offset: Offset(0, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9E6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFFE082)),
            ),
            child: Text(
              badgeLabel,
              style: const TextStyle(
                fontFamily: 'Nunito',
                color: AppColors.secondaryDark,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(badge.icon, style: const TextStyle(fontSize: 54)),
          const SizedBox(height: 8),
          Text(
            badge.title,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            badge.description,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

