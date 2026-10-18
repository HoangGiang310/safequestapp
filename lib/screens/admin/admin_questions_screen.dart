import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import 'admin_question_edit_screen.dart';

class AdminQuestionsScreen extends StatefulWidget {
  final Topic topic;
  const AdminQuestionsScreen({super.key, required this.topic});

  @override
  State<AdminQuestionsScreen> createState() => _AdminQuestionsScreenState();
}

class _AdminQuestionsScreenState extends State<AdminQuestionsScreen> {
  Widget _buildQuestionImage(String path) {
    if (kIsWeb) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(
          child: Text('Không tải được ảnh', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      );
    } else {
      if (path.startsWith('http://') || path.startsWith('https://')) {
        return Image.network(
          path,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Center(
            child: Text('Không tải được ảnh', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        );
      } else {
        return Image.file(
          File(path),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Center(
            child: Text('Không tải được ảnh', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        );
      }
    }
  }

  void _deleteQuestion(Question q) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.cartoonBorder, width: 3),
        ),
        title: const Text(
          'XÓA CÂU HỎI',
          style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'Bạn có chắc chắn muốn xóa câu hỏi này vĩnh viễn khỏi chủ đề không?',
          style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
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
                    final provider = Provider.of<AppProvider>(context, listen: false);
                    await provider.deleteQuestion(q.id);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã xóa câu hỏi thành công!'), backgroundColor: AppColors.success),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cartoonBorder, width: 2),
                      boxShadow: const [
                        BoxShadow(color: AppColors.errorDark, offset: Offset(0, 3), blurRadius: 0),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text('XÓA NGAY', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditLevelDialog(BuildContext context, [Level? level]) {
    final titleCtrl = TextEditingController(text: level?.title ?? '');
    final descCtrl = TextEditingController(text: level?.description ?? '');
    final orderCtrl = TextEditingController(text: level?.order.toString() ?? '1');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.cartoonBorder, width: 3),
        ),
        title: Text(
          level == null ? 'THÊM CẤP ĐỘ' : 'SỬA CẤP ĐỘ',
          style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary, fontSize: 18),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('TÊN CẤP ĐỘ', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cartoonBorder, width: 2),
                ),
                child: TextField(
                  controller: titleCtrl,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    hintText: 'Ví dụ: Màn 1 - Khởi đầu...',
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text('MÔ TẢ MÀN CHƠI', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cartoonBorder, width: 2),
                ),
                child: TextField(
                  controller: descCtrl,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    hintText: 'Mô tả nội dung thử thách...',
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text('THỨ TỰ (SỐ NGUYÊN)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cartoonBorder, width: 2),
                ),
                child: TextField(
                  controller: orderCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    hintText: '1, 2, 3...',
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
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
                    final title = titleCtrl.text.trim();
                    final order = int.tryParse(orderCtrl.text.trim()) ?? 1;
                    if (title.isEmpty) return;

                    final provider = Provider.of<AppProvider>(context, listen: false);
                    final newLvl = level != null
                        ? Level(
                            id: level.id,
                            topicId: level.topicId,
                            title: title,
                            description: descCtrl.text.trim(),
                            order: order,
                          )
                        : Level(
                            id: 'lvl_${DateTime.now().millisecondsSinceEpoch}',
                            topicId: widget.topic.id,
                            title: title,
                            description: descCtrl.text.trim(),
                            order: order,
                          );

                    await provider.saveLevel(newLvl);
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã cập nhật cấp độ thành công!'), backgroundColor: AppColors.success),
                      );
                    }
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
                    child: const Text('LƯU', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showManageLevelsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer<AppProvider>(
          builder: (context, provider, child) {
            final levels = provider.levels.where((l) => l.topicId == widget.topic.id).toList()
              ..sort((a, b) => a.order.compareTo(b.order));

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
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
                    'QUẢN LÝ CẤP ĐỘ',
                    style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: levels.isEmpty
                        ? const Center(child: Text('Chưa có cấp độ nào.'))
                        : ListView.builder(
                            itemCount: levels.length,
                            itemBuilder: (context, i) {
                              final lvl = levels[i];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.cardBackground,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.cartoonBorder, width: 2),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: AppColors.cartoonSky.withOpacity(0.3),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppColors.cartoonBorder, width: 1.5),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${lvl.order}',
                                        style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(lvl.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                                          const SizedBox(height: 2),
                                          Text(lvl.description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _showEditLevelDialog(context, lvl),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFF9C4),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: AppColors.cartoonBorder, width: 1.5),
                                        ),
                                        child: const Text(
                                          'SỬA',
                                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFFE65100)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => _showEditLevelDialog(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.cartoonBorder, width: 2),
                        boxShadow: const [
                          BoxShadow(color: AppColors.primaryDark, offset: Offset(0, 3), blurRadius: 0),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'THÊM CẤP ĐỘ MỚI',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
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
                      widget.topic.title,
                      style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary, fontSize: 13),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showManageLevelsModal(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.cartoonSky.withOpacity(0.35),
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
                      child: const Text(
                        'CẤP ĐỘ',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Questions List
            Expanded(
              child: Consumer<AppProvider>(
                builder: (context, provider, child) {
                  final levels = provider.levels.where((l) => l.topicId == widget.topic.id).toList();
                  final levelIds = levels.map((l) => l.id).toList();
                  final questions = provider.questions.where((q) => levelIds.contains(q.levelId)).toList();

                  if (questions.isEmpty) {
                    return const Center(
                      child: Text(
                        'Chưa có câu hỏi nào trong chủ đề này.',
                        style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
                    itemCount: questions.length,
                    itemBuilder: (context, i) {
                      final q = questions[i];
                      final lvl = levels.firstWhere(
                        (l) => l.id == q.levelId,
                        orElse: () => Level(id: '', topicId: '', title: 'Màn ?', description: '', order: 0),
                      );

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.cartoonSky.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppColors.cartoonBorder, width: 1.5),
                                    ),
                                    child: Text(
                                      'MÀN ${lvl.order}',
                                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: AppColors.textPrimary),
                                    ),
                                  ),
                                  Text(
                                    '${q.options.length} ĐÁP ÁN',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                q.question,
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.textPrimary, height: 1.3),
                              ),
                              if (q.image != null) ...[
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    height: 130,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: AppColors.cardBackground,
                                      border: Border.all(color: AppColors.cartoonBorder.withOpacity(0.3), width: 1.5),
                                    ),
                                    child: _buildQuestionImage(q.image!),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 14),
                              const Divider(height: 1, thickness: 1.5),
                              const SizedBox(height: 12),

                              // Actions (NO ICONS)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => AdminQuestionEditScreen(topic: widget.topic, question: q)),
                                      ).then((_) => setState(() {}));
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF9C4),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.cartoonBorder, width: 1.5),
                                        boxShadow: const [
                                          BoxShadow(color: Color(0xFFFBC02D), offset: Offset(0, 2), blurRadius: 0),
                                        ],
                                      ),
                                      child: const Text(
                                        'CHỈNH SỬA',
                                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFFE65100)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () => _deleteQuestion(q),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFEBEE),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.error, width: 1.5),
                                        boxShadow: const [
                                          BoxShadow(color: AppColors.errorDark, offset: Offset(0, 2), blurRadius: 0),
                                        ],
                                      ),
                                      child: const Text(
                                        'XÓA',
                                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: AppColors.error),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AdminQuestionEditScreen(topic: widget.topic)),
          ).then((_) => setState(() {}));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF2ECC71),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.cartoonBorder, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF27AE60),
                offset: Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: const Text(
            'THÊM CÂU HỎI MỚI',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
