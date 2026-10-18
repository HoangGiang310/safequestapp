import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/custom_widgets.dart';
import '../../navigation/main_navigation.dart';
import '../../providers/app_provider.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  String selectedAvatar = '🐱';
  final _nameController = TextEditingController();
  int _selectedAge = 6;

  void _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên của bé nhé!')),
      );
      return;
    }

    final provider = Provider.of<AppProvider>(context, listen: false);
    await provider.saveProfile(_nameController.text.trim(), _selectedAge, selectedAvatar);

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigation()),
      (route) => false,
    );
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final avatars = [
          '🐱', // 1. Mèo
          '🐭', // 2. Chuột
          '🐃', // 3. Trâu
          '🐸', // 4. Ếch
          '🐯', // 5. Hổ
          '🐬', // 6. Cá heo
          '🐰', // 7. Thỏ
          '🐢', // 8. Rùa
          '🐲', // 9. Rồng
          '🦄', // 10. Kì lân
          '🐍', // 11. Rắn
          '🦦', // 12. Cầy mang
          '🐴', // 13. Ngựa
          '🦁', // 14. Sư tử
          '🐑', // 15. Cừu
          '🐺', // 16. Sói
          '🐵', // 17. Khỉ
          '🦀', // 18. Cua
          '🐔', // 19. Gà
          '🦡', // 20. Chồn
          '🐶', // 21. Chó
          '🦅', // 22. Đại bàng
          '🐷', // 23. Heo
          '🦋', // 24. Bướm
        ];
        return Container(
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
            mainAxisSize: MainAxisSize.min,
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
                'CHỌN LINH VẬT CỦA BÉ',
                style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w900, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.55,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: avatars.map((avatar) {
                      final isSelected = selectedAvatar == avatar;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedAvatar = avatar;
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.cartoonYellow.withOpacity(0.35) : AppColors.cardBackground,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.cartoonBorder,
                              width: isSelected ? 3 : 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected ? AppColors.primaryDark : AppColors.cartoonBorder.withOpacity(0.3),
                                offset: const Offset(0, 3),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(avatar, style: const TextStyle(fontSize: 34)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top navigation pill
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
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
              ),
              const SizedBox(height: 24),

              // Title bubble
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.cartoonYellow.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cartoonBorder, width: 2),
                  ),
                  child: const Text(
                    'CHÀO MỪNG HIỆP SĨ MỚI',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFE65100),
                      fontSize: 12,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Bé tên là gì nhỉ?',
                style: AppTextStyles.h1.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  fontSize: 28,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Hãy tạo hồ sơ để nhận huy hiệu và điểm thưởng!',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Cartoon Avatar Pod
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _showAvatarPicker,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF9C4),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.cartoonBorder, width: 3.5),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.cartoonBorder,
                              offset: Offset(0, 5),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          selectedAvatar,
                          style: const TextStyle(fontSize: 64),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _showAvatarPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          'ĐỔI HÌNH ĐẠI DIỆN',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Form card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: AppColors.cartoonBorder, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.cartoonBorder,
                      offset: Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TÊN GỌI CỦA BÉ',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cartoonBorder, width: 2),
                      ),
                      child: TextField(
                        controller: _nameController,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: 'Ví dụ: Bé Bo, Bắp, An Nhiên...',
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    const Text(
                      'ĐỘ TUỔI CỦA BÉ',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cartoonBorder, width: 2),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: _selectedAge,
                          icon: const SizedBox.shrink(), // No icon!
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            fontSize: 16,
                          ),
                          items: [4, 5, 6, 7, 8, 9, 10].map((age) {
                            return DropdownMenuItem<int>(
                              value: age,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('$age TUỔI'),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.cartoonYellow.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'PHÙ HỢP',
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedAge = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action button
              PrimaryButton(
                text: 'BẮT ĐẦU PHIÊU LƯU',
                onPressed: _saveProfile,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
