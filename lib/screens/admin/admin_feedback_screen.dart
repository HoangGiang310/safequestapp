import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/models.dart';
import '../../services/data_service.dart';

class AdminFeedbackScreen extends StatefulWidget {
  const AdminFeedbackScreen({super.key});

  @override
  State<AdminFeedbackScreen> createState() => _AdminFeedbackScreenState();
}

class _AdminFeedbackScreenState extends State<AdminFeedbackScreen> {
  final _searchCtrl = TextEditingController();
  List<UserFeedback> _feedbacks = [];
  List<UserFeedback> _filteredFeedbacks = [];
  bool _isLoading = true;

  final Map<int, String> _ratingLabels = {
    1: 'Cần cải thiện 😞',
    2: 'Tạm ổn 😐',
    3: 'Khá ổn định 🙂',
    4: 'Rất hài lòng 😊',
    5: 'Tuyệt vời, cực thích! 🌟',
  };

  @override
  void initState() {
    super.initState();
    _loadFeedbacks();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadFeedbacks() async {
    setState(() => _isLoading = true);
    final list = await DataService().getFeedbacks();
    // Sort strictly newest to oldest (từ mới xuống cũ, từ trên xuống dưới)
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (mounted) {
      setState(() {
        _feedbacks = list;
        _isLoading = false;
        _filterFeedbacks(_searchCtrl.text);
      });
    }
  }

  void _filterFeedbacks(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _filteredFeedbacks = _feedbacks;
      });
      return;
    }

    final lower = query.toLowerCase();
    setState(() {
      _filteredFeedbacks = _feedbacks.where((fb) {
        final nameMatch = fb.userName.toLowerCase().contains(lower);
        final emailMatch = fb.userEmail.toLowerCase().contains(lower);
        final idMatch = fb.accountId.toString().contains(query);
        final contentMatch = fb.content.toLowerCase().contains(lower);
        return nameMatch || emailMatch || idMatch || contentMatch;
      }).toList();
    });
  }

  String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year.toString();
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year • $hour:$minute';
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
                    child: const Text(
                      'PHẢN HỒI NGƯỜI DÙNG',
                      style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cartoonBorder, width: 2.5),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.cartoonBorder,
                      offset: Offset(0, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    hintText: 'Tìm theo Tên, Gmail, ID hoặc nội dung góp ý...',
                    hintStyle: TextStyle(fontSize: 13, color: Colors.black38),
                    contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    border: InputBorder.none,
                  ),
                  onChanged: _filterFeedbacks,
                ),
              ),
            ),

            // Summary banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFFB74D), width: 1.5),
                ),
                child: Row(
                  children: [
                    const Text('💬 ', style: TextStyle(fontSize: 14)),
                    Expanded(
                      child: Text(
                        'Tổng số: ${_feedbacks.length} phản hồi • Sắp xếp: Từ mới xuống cũ',
                        style: const TextStyle(
                          color: Color(0xFFE65100),
                          fontWeight: FontWeight.w800,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 6),

            // Feedbacks List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredFeedbacks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('💌', style: TextStyle(fontSize: 48)),
                              const SizedBox(height: 12),
                              Text(
                                'Chưa có phản hồi nào',
                                style: AppTextStyles.h2.copyWith(color: AppColors.textSecondary, fontSize: 16),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Khi người dùng gửi đánh giá, danh sách sẽ hiển thị ở đây.',
                                style: TextStyle(color: Colors.black38, fontSize: 13),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadFeedbacks,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                            itemCount: _filteredFeedbacks.length,
                            itemBuilder: (context, index) {
                              final fb = _filteredFeedbacks[index];
                              final ratingLabel = _ratingLabels[fb.rating] ?? '${fb.rating}/5 sao';

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
                                      // User Info Header
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE0F7FA),
                                              shape: BoxShape.circle,
                                              border: Border.all(color: const Color(0xFF00ACC1), width: 2),
                                            ),
                                            alignment: Alignment.center,
                                            child: const Text('💬', style: TextStyle(fontSize: 24)),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // Tên
                                                Text(
                                                  fb.userName.isNotEmpty ? fb.userName : 'Người dùng',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 16,
                                                    color: AppColors.textPrimary,
                                                  ),
                                                ),
                                                const SizedBox(height: 3),
                                                // Gmail
                                                Text(
                                                  'Gmail: ${fb.userEmail}',
                                                  style: const TextStyle(
                                                    color: AppColors.textSecondary,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                // ID
                                                Text(
                                                  'ID: ${fb.accountId}',
                                                  style: const TextStyle(
                                                    color: Color(0xFF757575),
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Time badge
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF5F5F5),
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
                                            ),
                                            child: Text(
                                              _formatDateTime(fb.createdAt),
                                              style: const TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFF616161),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 12),

                                      // Rating Stars & Label
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFFDE7),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              children: List.generate(
                                                5,
                                                (i) => Icon(
                                                  i < fb.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                                                  color: const Color(0xFFFFB300),
                                                  size: 18,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              ratingLabel,
                                              style: const TextStyle(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFFE65100),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      // Feedback Content Box
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF9FBE7),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: const Color(0xFFC5E1A5), width: 1.5),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'NỘI DUNG FEEDBACK:',
                                              style: TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF558B2F),
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              fb.content,
                                              style: const TextStyle(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textPrimary,
                                                height: 1.4,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
