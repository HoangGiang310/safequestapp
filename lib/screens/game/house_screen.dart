import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../services/celebration_sound_manager.dart';
import 'widgets/furniture_shop_drawer.dart';
import 'widgets/room_scene_view.dart';

/// Màn hình Game Xây Nhà Thông Minh 4.0 ("Ngôi Nhà Của Bé")
/// Phong cách Game Mô phỏng Trang trí Căn phòng 2D hoạt hình (như Cat Cafe / Adorable Home)
/// Trực quan, đáng yêu, hoàn toàn như ảnh mẫu của người dùng!
class HouseScreen extends StatefulWidget {
  final bool showBetaNotice;
  const HouseScreen({super.key, this.showBetaNotice = true});

  @override
  State<HouseScreen> createState() => _HouseScreenState();
}

class _HouseScreenState extends State<HouseScreen> with SingleTickerProviderStateMixin {
  HouseRoomType _selectedRoom = HouseRoomType.kitchen; // Mặc định mở Phòng Bếp/Phòng Ăn như ảnh mẫu 1 & 2
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = Provider.of<AppProvider>(context, listen: false);
      provider.openHouseGame();
      if (widget.showBetaNotice) {
        _showBetaTesterDialog(context);
      } else if (!provider.houseData.hasSeenWelcome) {
        _showWelcomeDialog(context, provider);
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  // Mở ngăn kéo Shop / Nâng cấp đồ đạc
  void _openShopDrawer({String? initialItemId}) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final houseData = provider.houseData;
    final currentPoints = provider.profile?.points ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return FurnitureShopDrawer(
          roomType: _selectedRoom,
          houseData: houseData,
          currentWalletPoints: currentPoints,
          initialSelectedItemId: initialItemId,
          onUpgradeRequested: (item, targetLevel) {
            Navigator.pop(ctx);
            _handleUpgradeItem(
              provider: provider,
              item: item,
              targetLevel: targetLevel,
              currentPoints: currentPoints,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final profile = provider.profile;
    final houseData = provider.houseData;

    final currentPoints = profile?.points ?? 0;
    final totalSpent = houseData.totalPointsSpent;

    return Scaffold(
      backgroundColor: const Color(0xFF81D4FA),
      body: Stack(
        children: [
          // 1. SÂN KHẤU CĂN PHÒNG 2D TOÀN MÀN HÌNH (Hiển thị 1 phòng duy nhất tại 1 thời điểm)
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.96, end: 1.0).animate(animation),
                    child: child,
                  ),
                );
              },
              child: RoomSceneView(
                key: ValueKey<HouseRoomType>(_selectedRoom),
                roomType: _selectedRoom,
                houseData: houseData,
                onSelectFurniture: (item) {
                  _openShopDrawer(initialItemId: item.id);
                },
                onOpenShopDrawer: () {
                  _openShopDrawer();
                },
              ),
            ),
          ),

          // 2. THANH HUD ĐẦU TRANG (Ví Sao ⭐, Điểm tiêu 💎, BXH 🏆, Nút Thoát ✕)
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: _buildTopGameHud(context, provider, currentPoints, totalSpent),
            ),
          ),

          // 3. THANH ĐIỀU HƯỚNG CHỌN PHÒNG Ở ĐÁY MÀN HÌNH (Y HỆT ẢNH MẪU 1, 2, 3, 4!)
          Positioned(
            left: 16,
            right: 16,
            bottom: 22,
            child: SafeArea(
              child: _buildBottomRoomNavigationBar(),
            ),
          ),

          // 4. HIỆU ỨNG PHÁO HOA ĂN MỪNG KHI SẮM / NÂNG CẤP THÀNH CÔNG
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.amber,
                Colors.blue,
                Colors.pink,
                Colors.purple,
                Colors.green,
                Colors.orange,
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 1. TOP GAME HUD (Thanh trạng thái phong cách game di động)
  // ===========================================================================
  Widget _buildTopGameHud(
    BuildContext context,
    AppProvider provider,
    int currentPoints,
    int totalSpent,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nút BXH & Huy hiệu thi đua
          Row(
            children: [
              GestureDetector(
                key: const Key('house_leaderboard_button'),
                onTap: () => _showLeaderboardModal(context, provider),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE65100), width: 2),
                    boxShadow: const [
                      BoxShadow(color: Color(0xFFE65100), offset: Offset(0, 3)),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🏆', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 4),
                      Text(
                        'BXH',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          color: Color(0xFFE65100),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Chip Đã tiêu hao điểm (Click để xem chi tiết)
              GestureDetector(
                onTap: () => _showPointsSpentDetailsModal(context, provider.houseData, currentPoints),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E5F5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF7B1FA2), width: 2),
                    boxShadow: const [
                      BoxShadow(color: Color(0xFF7B1FA2), offset: Offset(0, 3)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('💎', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        '$totalSpent',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          color: Color(0xFF6A1B9A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bên phải: Ví Sao ⭐ của bé & Nút Thoát ✕ (Y hệt ảnh mẫu 2 & 4!)
          Row(
            children: [
              // Ví Sao ⭐
              GestureDetector(
                onTap: () => _showPointsHelpDialog(context, currentPoints),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFDE7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFFB300), width: 2),
                    boxShadow: const [
                      BoxShadow(color: Color(0xFFF57F17), offset: Offset(0, 3)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 15)),
                      const SizedBox(width: 4),
                      Text(
                        '$currentPoints',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: Color(0xFFE65100),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFB300),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.add, color: Colors.white, size: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Nút Đóng / Thoát ✕ hình tròn viền đậm (Y hệt ảnh 2 & 4!)
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF546E7A), width: 2.5),
                    boxShadow: const [
                      BoxShadow(color: Color(0xFF37474F), offset: Offset(0, 3)),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.close_rounded, color: Color(0xFF37474F), size: 22),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. BOTTOM ROOM NAVIGATION BAR (Y hệt thanh dưới cùng trong 4 ảnh mẫu!)
  // ===========================================================================
  Widget _buildBottomRoomNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4), // Nền vàng kem ấm áp như ảnh mẫu
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFE65100), width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0xFFBF360C), offset: Offset(0, 5), blurRadius: 0),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildRoomTabButton(
            room: HouseRoomType.livingRoom,
            emoji: '🛋️',
            label: 'Phòng khách',
          ),
          _buildRoomTabButton(
            room: HouseRoomType.kitchen,
            emoji: '🍽️',
            label: 'Phòng ăn',
          ),
          _buildRoomTabButton(
            room: HouseRoomType.bathroom,
            emoji: '🛁',
            label: 'Phòng tắm',
          ),
          _buildRoomTabButton(
            room: HouseRoomType.bedroom,
            emoji: '🛏️',
            label: 'Phòng ngủ',
          ),
        ],
      ),
    );
  }

  Widget _buildRoomTabButton({
    required HouseRoomType room,
    required String emoji,
    required String label,
  }) {
    final isSelected = _selectedRoom == room;

    return GestureDetector(
      onTap: () {
        if (_selectedRoom != room) {
          setState(() => _selectedRoom = room);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 12 : 8,
          vertical: isSelected ? 6 : 4,
        ),
        decoration: isSelected
            ? BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE65100), width: 2.2),
                boxShadow: const [
                  BoxShadow(color: Color(0xFFE65100), offset: Offset(0, 3)),
                ],
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: TextStyle(fontSize: isSelected ? 24 : 20)),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                fontSize: isSelected ? 11 : 10,
                color: isSelected ? const Color(0xFFE65100) : const Color(0xFF5D4037),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 3. XỬ LÝ NÂNG CẤP VẬT PHẨM
  // ===========================================================================
  Future<void> _handleUpgradeItem({
    required AppProvider provider,
    required HouseItem item,
    required int targetLevel,
    required int currentPoints,
  }) async {
    final levelInfo = item.getLevel(targetLevel);
    if (levelInfo == null) return;
    final cost = levelInfo.pointsCost;

    if (currentPoints < cost) {
      final deficit = cost - currentPoints;
      _showInsufficientPointsDialog(cost, currentPoints, deficit);
      return;
    }

    // Hộp thoại xác nhận sắm đồ
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppColors.cartoonBorder, width: 2.5),
          ),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Text(levelInfo.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Sắm ${levelInfo.title}?',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                levelInfo.description,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.secondaryDark, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Chi phí sắm sửa:',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '$cost ⭐',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: AppColors.secondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Để sau', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.successDark, width: 2),
                ),
                elevation: 0,
              ),
              child: const Text('ĐỒNG Ý SẮM ⭐', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final result = await provider.upgradeHouseItem(item.id);
    if (!mounted) return;

    if (result['success'] == true) {
      _confettiController.play();
      CelebrationSoundManager().playBadgeUnlock();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.successDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Row(
            children: [
              const Text('🎉', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result['message'] as String,
                  style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showInsufficientPointsDialog(int cost, int current, int deficit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.cartoonBorder, width: 2.5),
        ),
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Text('⭐', style: TextStyle(fontSize: 26)),
            SizedBox(width: 8),
            Text(
              'Chưa đủ Điểm Học Tập!',
              style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, fontSize: 17),
            ),
          ],
        ),
        content: Text(
          'Món này cần $cost ⭐ nhưng bé đang có $current ⭐ (thiếu $deficit ⭐).\nHọc thêm bài hoặc điểm danh để tích lũy nhé!',
          style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 13),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('ĐÃ HIỂU', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPointsHelpDialog(BuildContext context, int currentPoints) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.cartoonBorder, width: 2.5),
        ),
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Text('⭐', style: TextStyle(fontSize: 26)),
            SizedBox(width: 8),
            Text('Kho Sao Của Bé', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, fontSize: 17)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bé đang có $currentPoints Điểm Học Tập ⭐',
              style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFFE65100)),
            ),
            const SizedBox(height: 10),
            const Text(
              'Cách tích lũy thêm sao để xây nhà 4.0:\n• Giải đúng các câu hỏi an toàn (+45 ⭐/level)\n• Điểm danh mỗi ngày (+30 ⭐)\n• Nâng cấp gói Hiệp Sĩ (+500 ⭐ đến +1.000 ⭐)',
              style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 12.5, height: 1.4),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('ĐÃ BIẾT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 4. MODAL CHI TIẾT ĐIỂM TIÊU HAO
  // ===========================================================================
  void _showPointsSpentDetailsModal(BuildContext context, UserHouseData houseData, int currentPoints) {
    final totalSpent = houseData.totalPointsSpent;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.72,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(top: 10, bottom: 12),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text('💎', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 8),
                    Text(
                      'ĐIỂM ĐÃ ĐẦU TƯ XÂY NHÀ',
                      style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Thống kê tổng quan
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E5F5),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF7B1FA2), width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('ĐÃ TIÊU HAO', style: TextStyle(fontFamily: 'Nunito', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6A1B9A))),
                        Text('$totalSpent ⭐', style: const TextStyle(fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF4A148C))),
                      ],
                    ),
                    Container(width: 1.5, height: 32, color: const Color(0xFFBA68C8)),
                    Column(
                      children: [
                        const Text('CÒN LẠI TRONG VÍ', style: TextStyle(fontFamily: 'Nunito', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFE65100))),
                        Text('$currentPoints ⭐', style: const TextStyle(fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFFBF360C))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: HouseRoomType.values.map((room) {
                    final roomSpent = houseData.getRoomPointsSpent(room);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: room.cardBgColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: room.accentColor, width: 1.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(room.emoji, style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Text(room.displayName, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, fontSize: 13.5)),
                            ],
                          ),
                          Text('$roomSpent ⭐', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, fontSize: 14, color: room.accentColor)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // 5. BẢNG XẾP HẠNG (BXH)
  // ===========================================================================
  void _showLeaderboardModal(BuildContext context, AppProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(top: 10, bottom: 12),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text('🏆', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 8),
                    Text(
                      'BẢNG XẾP HẠNG XÂY NHÀ',
                      style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: FutureBuilder<List<HouseLeaderboardEntry>>(
                  future: provider.getHouseLeaderboard(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final list = snapshot.data ?? [];
                    if (list.isEmpty) {
                      return const Center(child: Text('Chưa có bé nào tham gia xây nhà!'));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final entry = list[index];
                        final isMe = entry.accountId == provider.currentAccount?.id;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isMe ? const Color(0xFFE8F5E9) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isMe ? AppColors.successDark : const Color(0xFFE2E8F0),
                              width: isMe ? 2.2 : 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 32,
                                child: Text(
                                  index == 0 ? '🥇' : (index == 1 ? '🥈' : (index == 2 ? '🥉' : '#${index + 1}')),
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(entry.childAvatar, style: const TextStyle(fontSize: 24)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(entry.childName, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, fontSize: 13.5)),
                                        if (isMe) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                            decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(6)),
                                            child: const Text('BÉ', style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ],
                                    ),
                                    Text('${entry.ownedCount}/15 món • ${(entry.overallProgress * 100).toInt()}% hoàn thành', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  ],
                                ),
                              ),
                              Text('${entry.totalPointsSpent} ⭐', style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF6A1B9A))),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // 6. GIAO DIỆN THÔNG BÁO THỬ NGHIỆM (BETA TESTER)
  // ===========================================================================
  void _showBetaTesterDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
          side: const BorderSide(color: AppColors.cartoonBorder, width: 2.5),
        ),
        backgroundColor: Colors.white,
        title: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE65100), width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFFBF360C),
                      offset: Offset(0, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text('⚠️', style: TextStyle(fontSize: 28)),
              ),
              const SizedBox(height: 12),
              const Text(
                'THÔNG BÁO THỬ NGHIỆM',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: Color(0xFFBF360C),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE0B2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE65100), width: 1),
                ),
                child: const Text(
                  'BETA TESTER',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    color: Color(0xFFE65100),
                  ),
                ),
              ),
            ],
          ),
        ),
        content: const Text(
          'Hiện tại trò chơi đang trong giai đoạn thử nghiệm ( Beta Tester ). Nếu có xảy ra lỗi gì vui lòng Feedback hoặc liên hệ email "safequestdev@gmail.com" nhằm đóng góp ý kiến để Admin cải thiện sản phẩm tốt hơn. Xin cảm ơn!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: AppColors.textPrimary,
            height: 1.45,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              key: const Key('beta_tester_dialog_confirm_button'),
              onPressed: () {
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.cartoonBorder, width: 2),
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: const Text(
                'Đã Hiểu',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 7. GIAO DIỆN CHÀO MỪNG LẦN ĐẦU (TUTORIAL)
  // ===========================================================================
  void _showWelcomeDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
          side: const BorderSide(color: AppColors.cartoonBorder, width: 2.5),
        ),
        backgroundColor: Colors.white,
        title: const Center(
          child: Text('🏡 CHÀO MỪNG ĐẾN VỚI\nNGÔI NHÀ CỦA BÉ! 🎉', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, fontSize: 17, height: 1.3)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Tự tay thiết kế và trang trí 4 căn phòng an toàn chuẩn Smart Home 4.0 từ chính sự chăm chỉ học tập!',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 12.5),
            ),
            const SizedBox(height: 14),
            _welcomeStep('1', '⭐', 'Học bài & Điểm danh nhận Sao'),
            _welcomeStep('2', '🛋️', 'Chạm vào đồ vật để sắm sửa 4.0'),
            _welcomeStep('3', '🏆', 'Thi đua xây nhà đẹp trên BXH'),
          ],
        ),
        actions: [
          ElevatedButton(
            key: const Key('welcome_start_button'),
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.markHouseWelcomeSeen();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Center(
              child: Text('BẮT ĐẦU XÂY NHÀ NGAY 🚀', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _welcomeStep(String num, String icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, fontSize: 12))),
        ],
      ),
    );
  }
}
