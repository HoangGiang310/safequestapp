import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import 'admin_questions_screen.dart';

class AdminTopicsScreen extends StatelessWidget {
  const AdminTopicsScreen({super.key});

  void _showTopicDialog(BuildContext context, [Topic? topic]) {
    final titleCtrl = TextEditingController(text: topic?.title ?? '');
    final descCtrl = TextEditingController(text: topic?.description ?? '');
    final iconCtrl = TextEditingController(text: topic?.icon ?? '🚦');
    bool isActive = topic?.isActive ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
            side: const BorderSide(color: AppColors.cartoonBorder, width: 3),
          ),
          title: Text(
            topic == null ? 'THÊM CHỦ ĐỀ MỚI' : 'CHỈNH SỬA CHỦ ĐỀ',
            style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TÊN CHỦ ĐỀ',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: AppColors.textSecondary),
                ),
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
                      hintText: 'Nhập tên chủ đề...',
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'MÔ TẢ NGẮN',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: AppColors.textSecondary),
                ),
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
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Mô tả nội dung bài học...',
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'BIỂU TƯỢNG EMOJI',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cartoonBorder, width: 2),
                  ),
                  child: TextField(
                    controller: iconCtrl,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    decoration: const InputDecoration(
                      hintText: 'Ví dụ: 🚦, 🏠, 🌳, 🌊',
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFFE8F5E9) : const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cartoonBorder, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isActive ? 'ĐANG HIỂN THỊ' : 'TẠM ẨN',
                        style: TextStyle(
                          color: isActive ? AppColors.success : const Color(0xFF757575),
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                      Switch(
                        value: isActive,
                        activeColor: AppColors.success,
                        onChanged: (val) => setState(() => isActive = val),
                      ),
                    ],
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
                      if (title.isEmpty) return;

                      final provider = Provider.of<AppProvider>(context, listen: false);
                      final updatedTopic = topic != null
                          ? topic.copyWith(
                              title: title,
                              description: descCtrl.text.trim(),
                              icon: iconCtrl.text.trim().isEmpty ? '🚦' : iconCtrl.text.trim(),
                              isActive: isActive,
                            )
                          : Topic(
                              id: 't_${DateTime.now().millisecondsSinceEpoch}',
                              title: title,
                              description: descCtrl.text.trim(),
                              icon: iconCtrl.text.trim().isEmpty ? '🚦' : iconCtrl.text.trim(),
                              colorValue: 0xFFFF7043,
                              totalLevels: 10,
                              isActive: isActive,
                            );

                      await provider.saveTopic(updatedTopic);
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã cập nhật chủ đề trên app!'),
                            backgroundColor: AppColors.success,
                          ),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final topics = provider.adminTopics;

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
                    child: const Text(
                      'QUẢN LÝ CHỦ ĐỀ',
                      style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            // Topic List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
                itemCount: topics.length,
                itemBuilder: (context, index) {
                  final topic = topics[index];
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
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Color(topic.colorValue).withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.cartoonBorder, width: 2),
                                ),
                                alignment: Alignment.center,
                                child: Text(topic.icon, style: const TextStyle(fontSize: 28)),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      topic.title,
                                      style: AppTextStyles.h3.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: topic.isActive ? const Color(0xFFE8F5E9) : const Color(0xFFEEEEEE),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: topic.isActive ? AppColors.success : const Color(0xFF9E9E9E),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Text(
                                        topic.isActive ? 'HOẠT ĐỘNG' : 'TẠM ẨN',
                                        style: TextStyle(
                                          color: topic.isActive ? AppColors.success : const Color(0xFF757575),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            topic.description,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Divider(height: 1, thickness: 1.5),
                          const SizedBox(height: 12),

                          // Action Buttons (NO ICONS)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () => _showTopicDialog(context, topic),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF9C4),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppColors.cartoonBorder, width: 2),
                                    boxShadow: const [
                                      BoxShadow(color: Color(0xFFFBC02D), offset: Offset(0, 2), blurRadius: 0),
                                    ],
                                  ),
                                  child: const Text(
                                    'CHỈNH SỬA',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 11,
                                      color: Color(0xFFE65100),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => AdminQuestionsScreen(topic: topic)),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppColors.cartoonBorder, width: 2),
                                    boxShadow: const [
                                      BoxShadow(color: AppColors.primaryDark, offset: Offset(0, 2), blurRadius: 0),
                                    ],
                                  ),
                                  child: const Text(
                                    'VÀO CÂU HỎI',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 11,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
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
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () => _showTopicDialog(context),
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
            'THÊM CHỦ ĐỀ MỚI',
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
