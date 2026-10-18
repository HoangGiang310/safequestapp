import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_widgets.dart';
import '../../core/widgets/celebration_widgets.dart';
import '../../core/widgets/confetti_effect.dart';
import '../../models/models.dart';
import '../../data/mock_data.dart';
import '../../providers/app_provider.dart';
import '../../services/celebration_sound_manager.dart';
import '../../services/audio_service.dart';
import '../result/result_screen.dart';

class GameScreen extends StatefulWidget {
  final Level? level;
  final bool isReviewMode;
  final String? reviewTopicId;

  const GameScreen({
    super.key,
    this.level,
    this.isReviewMode = false,
    this.reviewTopicId,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<Question> _questions;
  int _currentIndex = 0;
  Set<int> _selectedAnswers = {};
  
  bool _hasAnswered = false;
  bool _isCorrect = false;
  int _attempts = 0;
  bool _isProcessingAnswer = false;
  bool _isAlreadyCompleted = false;
  final Set<String> _wrongQuestionIdsThisSession = {};
  final Map<String, int> _questionScores = {};
  final Set<String> _reviewCorrectQuestionIds = {};

  late ConfettiController _confettiController;
  final CelebrationSoundManager _soundManager = CelebrationSoundManager();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));

    final provider = Provider.of<AppProvider>(context, listen: false);
    _isAlreadyCompleted = widget.level != null && provider.isLevelCompleted(widget.level!.id);
    if (widget.isReviewMode) {
      final allQ = provider.questions.isNotEmpty
          ? provider.questions
          : MockContentRepository.questions;
      final activeQuestions = allQ.where((q) => q.isActive).toList();
      var wrongQ = activeQuestions
          .where((q) => provider.wrongQuestions.contains(q.id))
          .toList();

      if (widget.reviewTopicId != null) {
        final allL = provider.levels.isNotEmpty ? provider.levels : MockContentRepository.levels;
        final topicLevelIds = allL
            .where((l) => l.topicId == widget.reviewTopicId)
            .map((l) => l.id)
            .toSet();
        wrongQ = wrongQ.where((q) => topicLevelIds.contains(q.levelId)).toList();
      }

      _questions = wrongQ;
    } else {
      final activeQuestions = provider.questions.where((q) => q.isActive).toList();
      _questions = activeQuestions
          .where((q) => q.levelId == widget.level!.id)
          .toList();
      if (_questions.isEmpty && provider.questions.isEmpty) {
        _questions = MockContentRepository.questions
            .where((q) => q.levelId == widget.level!.id)
            .toList();
      }
    }
  }
      
  @override
  void dispose() {
    AudioService().stop();
    _confettiController.dispose();
    super.dispose();
  }
  
  void _onOptionSelected(int index) {
    if (_isProcessingAnswer || (_hasAnswered && _isCorrect)) return;

    final q = _questions[_currentIndex];
    
    setState(() {
      if (q.type == QuestionType.multipleChoice) {
        if (_selectedAnswers.contains(index)) {
          _selectedAnswers.remove(index);
        } else {
          _selectedAnswers.add(index);
        }
      } else {
        _selectedAnswers = {index};
        _checkAnswer();
      }
    });
  }
  
  void _checkAnswer() async {
    if (_selectedAnswers.isEmpty || _isProcessingAnswer) return;
    
    setState(() {
      _isProcessingAnswer = true;
    });

    final q = _questions[_currentIndex];
    
    final selectedList = _selectedAnswers.toList()..sort();
    final correctList = List<int>.from(q.correctAnswers)..sort();
    
    bool correct = selectedList.length == correctList.length;
    if (correct) {
      for (int i = 0; i < selectedList.length; i++) {
        if (selectedList[i] != correctList[i]) {
          correct = false;
          break;
        }
      }
    }
                  
    _attempts++;

    setState(() {
      _hasAnswered = true;
      _isCorrect = correct;
    });

    final provider = Provider.of<AppProvider>(context, listen: false);

    int pointsEarned = 0;
    if (correct && !_isAlreadyCompleted && !widget.isReviewMode) {
      if (_attempts == 1) {
        pointsEarned = 10;
      } else if (_attempts == 2) {
        pointsEarned = 5;
      }
    }

    if (correct) {
      _soundManager.playCorrectAnswer();
      _confettiController.play();
      
      if (!widget.isReviewMode) {
        _questionScores[q.id] = pointsEarned;
        if (_attempts > 1) {
          _wrongQuestionIdsThisSession.add(q.id);
        }
      } else {
        _reviewCorrectQuestionIds.add(q.id);
      }
    } else {
      _soundManager.playWrongAnswer();
      if (!widget.isReviewMode) {
        _wrongQuestionIdsThisSession.add(q.id);
        if (_attempts >= 2) {
          _questionScores[q.id] = 0;
        }
      } else {
        if (_attempts >= 2) {
          _reviewCorrectQuestionIds.remove(q.id);
        }
      }
    }

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        _showResultBottomSheet(correct, pointsEarned);
        setState(() {
          _isProcessingAnswer = false;
        });
      }
    });
  }

  void _showResultBottomSheet(bool correct, int pointsEarned) {
    final q = _questions[_currentIndex];
    final bool showFullExplanation = _attempts >= 2;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  correct ? '🎉' : '💡',
                  style: const TextStyle(fontSize: 40),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            correct ? 'Tuyệt vời!' : 'Thử lại nhé!',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: correct ? AppColors.successDark : AppColors.accentDark,
                            ),
                          ),
                          if (pointsEarned > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.successLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.success.withOpacity(0.4)),
                              ),
                              child: Text(
                                '+$pointsEarned điểm',
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  color: AppColors.successDark,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        correct || showFullExplanation ? q.explanation : q.hint,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (correct) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  AudioButton(
                    textToSpeak: 'Tuyệt vời! ${q.explanation}',
                    label: 'NGHE',
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Bé có thể nghe lại lời giải thích',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              if (!showFullExplanation) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    AudioButton(
                      textToSpeak: 'Thử lại nhé! Gợi ý: ${q.hint}',
                      label: 'NGHE GỢI Ý',
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Bé có thể nghe gợi ý để thử lại nhé',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.error.withOpacity(0.4)),
                  ),
                  child: Text(
                    'Đáp án đúng: ${q.correctAnswers.map((i) => String.fromCharCode(65 + i)).join(", ")}',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      color: AppColors.errorDark,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ),
                Row(
                  children: [
                    AudioButton(
                      textToSpeak: 'Thử lại nhé! Lời giải thích: ${q.explanation}',
                      label: 'NGHE',
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Bé có thể nghe lại lời giải thích',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
            const SizedBox(height: 22),
            PrimaryButton(
              text: correct || showFullExplanation ? 'TIẾP TỤC' : 'THỬ LẠI',
              color: correct ? AppColors.success : AppColors.primary,
              onPressed: () {
                AudioService().stop();
                Navigator.pop(context);
                if (correct || showFullExplanation) {
                  _nextQuestion();
                } else {
                  setState(() {
                    _hasAnswered = false;
                    _selectedAnswers.clear(); 
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _nextQuestion() async {
    AudioService().stop();
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _hasAnswered = false;
        _isCorrect = false;
        _attempts = 0;
        _selectedAnswers.clear();
      });
    } else {
      List<String> newlyUnlocked = [];
      int questionsScore = 0;
      int levelBonusScore = 0;
      int finalLevelScore = 0;

      final int totalQuestions = _questions.length;
      final int correctCount = widget.isReviewMode
          ? _reviewCorrectQuestionIds.length
          : _questionScores.values.where((score) => score > 0).length;
      final bool isLevelPassed = correctCount > 0;

      if (widget.isReviewMode) {
        final provider = Provider.of<AppProvider>(context, listen: false);
        // Khi luyện tập, phải trả lời đúng 3/3 câu thì những câu bị sai chuyển vào mục Luyện Tập mới biến mất,
        // nếu không thì nó vẫn sẽ còn thống kê trong mục Luyện Tập.
        final Map<String, List<Question>> questionsByLevel = {};
        for (final q in _questions) {
          questionsByLevel.putIfAbsent(q.levelId, () => []).add(q);
        }

        for (final entry in questionsByLevel.entries) {
          final levelQuestions = entry.value;
          final int levelCorrect = levelQuestions
              .where((q) => _reviewCorrectQuestionIds.contains(q.id))
              .length;

          // Đúng 3/3 câu của level đó trong phòng luyện tập
          if (levelQuestions.length >= 3 && levelCorrect == levelQuestions.length) {
            for (final q in levelQuestions) {
              await provider.removeWrongQuestion(q.id);
            }
          }
        }

        // Trường hợp cả buổi ôn luyện có 3 câu và làm đúng 3/3 câu (hoặc đúng 100% với từ 3 câu trở lên)
        if (totalQuestions >= 3 && correctCount == totalQuestions) {
          for (final q in _questions) {
            await provider.removeWrongQuestion(q.id);
          }
        }
      } else if (widget.level != null) {
        if (!_isAlreadyCompleted && isLevelPassed) {
          questionsScore = _questionScores.values.fold(0, (sum, score) => sum + score);

          if (correctCount == 3) {
            levelBonusScore = 15;
          } else if (correctCount == 2) {
            levelBonusScore = 10;
          } else if (correctCount == 1) {
            levelBonusScore = 5;
          } else {
            levelBonusScore = 0;
          }

          finalLevelScore = questionsScore + levelBonusScore;
        } else {
          finalLevelScore = 0;
        }

        final provider = Provider.of<AppProvider>(context, listen: false);
        newlyUnlocked = await provider.completeLevel(
          widget.level!.id,
          finalLevelScore,
          isCompleted: isLevelPassed,
        );
        // Level nào đã vượt qua, khi làm lại mà sai cả 3 câu thì KHÔNG chuyển vào mục Luyện Tập
        // Bấm sai cả 3 câu rồi bị chuyển vào mục Luyện Tập chỉ áp dụng cho level mới
        final bool skipRecordingWrong = _isAlreadyCompleted && correctCount == 0;
        if (!skipRecordingWrong) {
          for (String wId in _wrongQuestionIdsThisSession) {
            await provider.recordWrongQuestion(wId);
          }
        }
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            score: finalLevelScore,
            totalQuestions: totalQuestions,
            correctCount: correctCount,
            isReviewMode: widget.isReviewMode,
            newlyUnlockedBadgeIds: newlyUnlocked,
            isAlreadyCompleted: _isAlreadyCompleted,
            level: widget.level,
          ),
        ),
      );
    }
  }

  Future<bool> _onWillPop() async {
    AudioService().stop();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Tạm Dừng Thử Thách',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Bé có chắc chắn muốn thoát khỏi màn chơi hiện tại không? Tiến trình câu hỏi sẽ không được lưu.',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                        ),
                        child: const Text(
                          'Ở LẠI HỌC',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cartoonBorder, width: 1.5),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.errorDark,
                              offset: Offset(0, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: const Text(
                          'THOÁT RA',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFEEF6FF),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Không có câu hỏi nào.', style: TextStyle(fontFamily: 'Nunito', fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              PrimaryButton(
                text: 'QUAY LẠI',
                isFullWidth: false,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      );
    }
    
    final q = _questions[_currentIndex];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final confirm = await _onWillPop();
        if (confirm && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFEEF6FF),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Top Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                    child: Row(
                      children: [
                        // Quit Pill Button - NO ICONS
                        GestureDetector(
                          onTap: () async {
                            final confirm = await _onWillPop();
                            if (confirm && context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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
                              'THOÁT',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Question Tube Progress Bar
                        Expanded(
                          child: ProgressBar(
                            progress: (_currentIndex + 1) / _questions.length,
                            color: AppColors.success,
                            height: 14,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Count Chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFD6E4FF), width: 2),
                          ),
                          child: Text(
                            '${_currentIndex + 1}/${_questions.length}',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          // Question Card
                          Container(
                            padding: const EdgeInsets.all(20),
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
                                // Illustration Frame
                                Container(
                                  height: 180,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: q.image != null && q.image!.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(18),
                                          child: _buildQuestionImage(q.image!),
                                        )
                                      : const Center(child: Text('🧩', style: TextStyle(fontSize: 72))),
                                ),
                                const SizedBox(height: 18),
                                
                                Text(
                                  q.question,
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary,
                                    height: 1.35,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: AudioButton(
                                    textToSpeak: q.type == QuestionType.dialogue && q.characterDialogue != null
                                        ? '${q.question}. ${q.characterDialogue}'
                                        : q.question,
                                    label: 'NGHE',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          if (q.type == QuestionType.dialogue && q.characterDialogue != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF9E6),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: const Color(0xFFFFE082), width: 2),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('🗣️', style: TextStyle(fontSize: 32)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      q.characterDialogue!,
                                      style: const TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        fontStyle: FontStyle.italic,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),
                      
                          // 3D Cartoon Options A, B, C, D - NO ICONS!
                          ...List.generate(q.options.length, (index) {
                            final isSelected = _selectedAnswers.contains(index);
                            final letter = String.fromCharCode(65 + index); // A, B, C, D
                            
                            List<Color> optionColors = [
                              AppColors.optionA,
                              AppColors.optionB,
                              AppColors.optionC,
                              AppColors.optionD
                            ];
                            Color optColor = optionColors[index % 4];
                            final hsl = HSLColor.fromColor(optColor);
                            final shadowColor = hsl.withLightness((hsl.lightness - 0.22).clamp(0.0, 1.0)).toColor();

                            return GestureDetector(
                              onTap: () => _onOptionSelected(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 100),
                                margin: const EdgeInsets.only(bottom: 14),
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                decoration: BoxDecoration(
                                  color: isSelected ? optColor.withOpacity(0.12) : Colors.white,
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: isSelected ? optColor : const Color(0xFFD6E4FF),
                                    width: isSelected ? 2.5 : 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSelected ? shadowColor.withOpacity(0.4) : const Color(0xFFD0E1FD),
                                      offset: const Offset(0, 4),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // Candy Letter Bubble
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: isSelected ? optColor : optColor.withOpacity(0.18),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected ? shadowColor : optColor.withOpacity(0.5),
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          letter,
                                          style: TextStyle(
                                            fontFamily: 'Nunito',
                                            color: isSelected ? Colors.white : optColor,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 17,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        q.options[index],
                                        style: TextStyle(
                                          fontFamily: 'Nunito',
                                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                                          fontSize: 15,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                      
                          if (q.type == QuestionType.multipleChoice) ...[
                            const SizedBox(height: 12),
                            PrimaryButton(
                              text: 'KIỂM TRA ĐÁP ÁN',
                              onPressed: _selectedAnswers.isEmpty || _isProcessingAnswer ? () {} : _checkAnswer,
                              color: _selectedAnswers.isEmpty ? const Color(0xFF94A3B8) : AppColors.primary,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          
              // Confetti celebration
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiEffect(controller: _confettiController, isStrong: false),
              ),
          
              // Mascot encouragement overlay
              if (_hasAnswered && _isCorrect && _isProcessingAnswer)
                Positioned.fill(
                  child: Container(
                    color: Colors.white.withOpacity(0.92),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CelebrationCharacter(isCorrect: true),
                        const SizedBox(height: 20),
                        CelebrationText(
                          text: "ĐÚNG RỒI! 🎉",
                          onComplete: () {},
                        ),
                        const SizedBox(height: 14),
                        ScoreAnimation(
                          score: _attempts == 1 ? 10 : 5,
                          onComplete: () {},
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionImage(String path) {
    if (path.startsWith('assets/')) {
      if (path.endsWith('.svg')) {
        return SvgPicture.asset(
          path,
          fit: BoxFit.cover,
        );
      }
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackImage(),
      );
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      if (path.endsWith('.svg')) {
        return SvgPicture.network(
          path,
          fit: BoxFit.cover,
        );
      }
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackImage(),
      );
    }
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _fallbackImage(),
    );
  }

  Widget _fallbackImage() {
    return const Center(child: Text('🧩', style: TextStyle(fontSize: 72)));
  }
}