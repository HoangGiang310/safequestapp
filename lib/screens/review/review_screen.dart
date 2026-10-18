import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/custom_widgets.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../game/game_screen.dart';

class _TopicReviewGroup {
  final Topic topic;
  final Map<String, List<Question>> levelQuestions = {}; // levelTitle -> questions
  final List<Question> allQuestions = [];

  _TopicReviewGroup({required this.topic});

  void addQuestion({required String levelTitle, required Question question}) {
    allQuestions.add(question);
    levelQuestions.putIfAbsent(levelTitle, () => []).add(question);
  }
}

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final wrongQuestionIds = provider.wrongQuestions;

    final allQuestions = provider.questions.isNotEmpty
        ? provider.questions
        : MockContentRepository.questions;
    final allLevels = provider.levels.isNotEmpty
        ? provider.levels
        : MockContentRepository.levels;
    final allTopics = provider.adminTopics.isNotEmpty
        ? provider.adminTopics
        : (provider.topics.isNotEmpty ? provider.topics : MockContentRepository.topics);

    final Map<String, _TopicReviewGroup> topicGroupsMap = {};

    for (final qId in wrongQuestionIds) {
      final q = allQuestions.where((item) => item.id == qId).firstOrNull ??
          MockContentRepository.questions.where((item) => item.id == qId).firstOrNull;
      if (q == null) continue;

      final lvl = allLevels.where((l) => l.id == q.levelId).firstOrNull ??
          MockContentRepository.levels.where((l) => l.id == q.levelId).firstOrNull;

      final topicId = lvl?.topicId ?? (q.levelId.contains('_l') ? q.levelId.split('_l').first : q.levelId);
      final topic = allTopics.where((t) => t.id == topicId).firstOrNull ??
          MockContentRepository.topics.where((t) => t.id == topicId).firstOrNull ??
          Topic(id: topicId, title: 'Chủ đề khác', description: '', icon: '📚', colorValue: 0xFF2196F3, totalLevels: 10);

      final levelNumber = lvl?.order ??
          int.tryParse(RegExp(r'_l(\d+)$').firstMatch(q.levelId)?.group(1) ?? '');
      final levelTitle = levelNumber != null ? 'Level $levelNumber' : (lvl?.title ?? q.levelId);

      final group = topicGroupsMap.putIfAbsent(
        topic.id,
        () => _TopicReviewGroup(topic: topic),
      );

      group.addQuestion(levelTitle: levelTitle, question: q);
    }

    final topicGroups = topicGroupsMap.values.toList();
    final hasItemsToReview = topicGroups.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
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
                    'PHÒNG LUYỆN TẬP',
                    style: AppTextStyles.h2.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: hasItemsToReview
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            topicGroups.length >= 2
                                ? 'Bé có câu sai ở ${topicGroups.length} chủ đề. Hãy chọn từng chủ đề bên dưới để sửa lỗi nhé!'
                                : 'Cùng luyện tập để nắm vững kiến thức nhé!',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),

                          Expanded(
                            child: ListView.separated(
                              physics: const BouncingScrollPhysics(),
                              itemCount: topicGroups.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final group = topicGroups[index];
                                return _buildTopicCard(context, group);
                              },
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.cartoonBorder, width: 3.5),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xFF81C784),
                                  offset: Offset(0, 5),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Text('🎉', style: TextStyle(fontSize: 76)),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            'XUẤT SẮC QUÁ!',
                            style: AppTextStyles.h1.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w900,
                              fontSize: 26,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.0),
                            child: Text(
                              'Con đã nắm vững tất cả các kỹ năng và không có tình huống nào cần ôn tập lúc này.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.cartoonSky.withOpacity(0.35),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.cartoonBorder, width: 2),
                            ),
                            child: const Text(
                              'SẴN SÀNG CHO BÀI HỌC MỚI',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                                fontSize: 12,
                                letterSpacing: 0.8,
                              ),
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

  Widget _buildTopicCard(BuildContext context, _TopicReviewGroup group) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cartoonBorder, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFD0E1FD),
            offset: Offset(0, 5),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9C4),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.cartoonBorder, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(group.topic.icon, style: const TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chủ đề: ${group.topic.title}',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFFB74D), width: 1.2),
                      ),
                      child: Text(
                        '${group.allQuestions.length} câu cần sửa lỗi',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFE65100),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 1.2, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 12),
          
          const Text(
            'Các Level có câu trả lời sai:',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: group.levelQuestions.entries.map((entry) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.2),
                ),
                child: Text(
                  '${entry.key} (${entry.value.length} câu sai)',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          PrimaryButton(
            text: 'LÀM LẠI',
            color: const Color(0xFFFF9800),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GameScreen(
                    isReviewMode: true,
                    reviewTopicId: group.topic.id,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
