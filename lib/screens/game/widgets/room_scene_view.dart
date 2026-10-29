import 'package:flutter/material.dart';
import '../../../models/house_models.dart';
import 'cartoon_furniture_widgets.dart';

/// Sân khấu căn phòng 2D hoạt hình tương tác phong cách Cat Cafe / Adorable Home
/// Bài trí đồ đạc theo đúng góc nhìn 2.5D như ảnh mẫu của người dùng.
class RoomSceneView extends StatefulWidget {
  final HouseRoomType roomType;
  final UserHouseData houseData;
  final Function(HouseItem item) onSelectFurniture;
  final VoidCallback onOpenShopDrawer;

  const RoomSceneView({
    super.key,
    required this.roomType,
    required this.houseData,
    required this.onSelectFurniture,
    required this.onOpenShopDrawer,
  });

  @override
  State<RoomSceneView> createState() => _RoomSceneViewState();
}

class _RoomSceneViewState extends State<RoomSceneView> {
  String? _bouncingItemId;

  void _triggerBounce(String itemId, HouseItem item) {
    setState(() => _bouncingItemId = itemId);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _bouncingItemId = null);
    });
    widget.onSelectFurniture(item);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // 1. Phông nền tường & sàn căn phòng hoạt hình
              _buildRoomBackground(w, h),

              // 2. Các bong bóng nước / ánh nắng bay lượn
              _buildAmbientParticles(w, h),

              // 3. Đồ đạc nội thất bài trí theo tọa độ 2.5D của từng phòng
              ..._buildRoomFurniture(w, h),

              // 4. Các vật trang trí hoạt hình phụ trợ (vỏ sò, ấm trà, giỏ khăn)
              ..._buildDecorativeAccents(w, h),

              // 5. Nút Giỏ Đồ Shopping 🧺 nổi ở góc dưới bên phải (y như ảnh mẫu 2 & 4!)
              Positioned(
                right: 18,
                bottom: 22,
                child: GestureDetector(
                  onTap: widget.onOpenShopDrawer,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5252),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.8),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFFD32F2F),
                          offset: Offset(0, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Text('🧺', style: TextStyle(fontSize: 26)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // 1. BACKGROUND TƯỜNG & SÀN
  // ===========================================================================
  Widget _buildRoomBackground(double w, double h) {
    switch (widget.roomType) {
      case HouseRoomType.kitchen:
        // Phòng ăn / Bếp: Gạch men xanh nước biển như ảnh mẫu 1 & 2
        return Container(
          width: w,
          height: h,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF81D4FA), Color(0xFFB3E5FC), Color(0xFFE1F5FE)],
            ),
          ),
          child: CustomPaint(
            painter: _TileGridPainter(tileColor: Colors.white.withOpacity(0.25)),
          ),
        );

      case HouseRoomType.bathroom:
        // Phòng tắm: Gạch mosaic xanh ngọc với gợn sóng nước như ảnh mẫu 3 & 4
        return Container(
          width: w,
          height: h,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF4FC3F7), Color(0xFF81D4FA), Color(0xFFE0F7FA)],
            ),
          ),
          child: CustomPaint(
            painter: _TileGridPainter(tileColor: Colors.white.withOpacity(0.3)),
          ),
        );

      case HouseRoomType.livingRoom:
        // Phòng khách: Tường vàng ấm pastel + sàn gỗ
        return Container(
          width: w,
          height: h,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFF9C4), Color(0xFFFFF176), Color(0xFFFFE082)],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                flex: 6,
                child: Container(color: const Color(0xFFFFF8E1).withOpacity(0.6)),
              ),
              Expanded(
                flex: 4,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD54F),
                    border: Border(top: BorderSide(color: Color(0xFFFFB300), width: 3)),
                  ),
                  child: CustomPaint(painter: _TileGridPainter(tileColor: Colors.white.withOpacity(0.2))),
                ),
              ),
            ],
          ),
        );

      case HouseRoomType.bedroom:
        // Phòng ngủ: Tường tím lavender sao đêm thơ mộng
        return Container(
          width: w,
          height: h,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFCE93D8), Color(0xFFE1BEE7), Color(0xFFF3E5F5)],
            ),
          ),
          child: CustomPaint(
            painter: _TileGridPainter(tileColor: Colors.white.withOpacity(0.25)),
          ),
        );
    }
  }

  // ===========================================================================
  // 2. BONG BÓNG LƠ LỬNG
  // ===========================================================================
  Widget _buildAmbientParticles(double w, double h) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(top: h * 0.12, left: w * 0.15, child: _bubble(18)),
          Positioned(top: h * 0.18, right: w * 0.25, child: _bubble(14)),
          Positioned(top: h * 0.35, left: w * 0.08, child: _bubble(22)),
          Positioned(top: h * 0.42, right: w * 0.12, child: _bubble(16)),
          Positioned(top: h * 0.55, left: w * 0.35, child: _bubble(12)),
          Positioned(top: h * 0.68, right: w * 0.35, child: _bubble(20)),
        ],
      ),
    );
  }

  Widget _bubble(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
      ),
    );
  }

  // ===========================================================================
  // 3. ĐỒ ĐẠC BÀI TRÍ THEO PHÒNG
  // ===========================================================================
  List<Widget> _buildRoomFurniture(double w, double h) {
    switch (widget.roomType) {
      case HouseRoomType.kitchen:
        return _buildKitchenLayout(w, h);
      case HouseRoomType.bathroom:
        return _buildBathroomLayout(w, h);
      case HouseRoomType.livingRoom:
        return _buildLivingRoomLayout(w, h);
      case HouseRoomType.bedroom:
        return _buildBedroomLayout(w, h);
    }
  }

  // --- KITCHEN (Ảnh 1 & 2) ---
  List<Widget> _buildKitchenLayout(double w, double h) {
    final fridgeItem = HouseCatalog.getItemById('kitchen_fridge')!;
    final stoveItem = HouseCatalog.getItemById('kitchen_stove')!;
    final tableItem = HouseCatalog.getItemById('kitchen_table')!;

    final fridgeLvl = widget.houseData.getItemLevel('kitchen_fridge');
    final stoveLvl = widget.houseData.getItemLevel('kitchen_stove');
    final tableLvl = widget.houseData.getItemLevel('kitchen_table');

    return [
      // 1. Tủ lạnh ở góc trên bên trái (Y hệt ảnh 1 & 2)
      Positioned(
        top: h * 0.18,
        left: w * 0.06,
        child: _buildInteractiveSlot(
          item: fridgeItem,
          level: fridgeLvl,
          size: w * 0.28,
        ),
      ),

      // 2. Bếp nấu ở góc trên giữa/bên cạnh tủ lạnh
      Positioned(
        top: h * 0.26,
        left: w * 0.38,
        child: _buildInteractiveSlot(
          item: stoveItem,
          level: stoveLvl,
          size: w * 0.32,
        ),
      ),

      // 3. Bàn ăn khăn caro ở chính giữa tiền cảnh (Trung tâm phòng ăn)
      Positioned(
        top: h * 0.46,
        left: (w - (w * 0.68)) / 2,
        child: _buildInteractiveSlot(
          item: tableItem,
          level: tableLvl,
          size: w * 0.45,
        ),
      ),
    ];
  }

  // --- BATHROOM (Ảnh 3 & 4) ---
  List<Widget> _buildBathroomLayout(double w, double h) {
    final toiletItem = HouseCatalog.getItemById('bath_toilet')!;
    final sinkItem = HouseCatalog.getItemById('bath_sink')!;
    final washerItem = HouseCatalog.getItemById('bath_washing')!;
    final tubItem = HouseCatalog.getItemById('bath_tub')!;

    final toiletLvl = widget.houseData.getItemLevel('bath_toilet');
    final sinkLvl = widget.houseData.getItemLevel('bath_sink');
    final washerLvl = widget.houseData.getItemLevel('bath_washing');
    final tubLvl = widget.houseData.getItemLevel('bath_tub');

    return [
      // 1. Bồn cầu ở góc trên bên trái có rèm tắm (Ảnh 3 & 4)
      Positioned(
        top: h * 0.19,
        left: w * 0.08,
        child: _buildInteractiveSlot(
          item: toiletItem,
          level: toiletLvl,
          size: w * 0.27,
        ),
      ),

      // 2. Lavabo & Gương chim cánh cụt ở giữa phía sau
      Positioned(
        top: h * 0.14,
        left: (w - (w * 0.35)) / 2,
        child: _buildInteractiveSlot(
          item: sinkItem,
          level: sinkLvl,
          size: w * 0.31,
        ),
      ),

      // 3. Máy giặt ở góc trên bên phải
      Positioned(
        top: h * 0.20,
        right: w * 0.08,
        child: _buildInteractiveSlot(
          item: washerItem,
          level: washerLvl,
          size: w * 0.28,
        ),
      ),

      // 4. Bồn tắm có chú vịt vàng ở tiền cảnh góc phải dưới (Ảnh 3 & 4)
      Positioned(
        top: h * 0.52,
        right: w * 0.06,
        child: _buildInteractiveSlot(
          item: tubItem,
          level: tubLvl,
          size: w * 0.48,
        ),
      ),
    ];
  }

  // --- LIVING ROOM ---
  List<Widget> _buildLivingRoomLayout(double w, double h) {
    final doorItem = HouseCatalog.getItemById('living_door')!;
    final tvItem = HouseCatalog.getItemById('living_tv')!;
    final sofaItem = HouseCatalog.getItemById('living_sofa')!;
    final rugItem = HouseCatalog.getItemById('living_rug')!;

    final doorLvl = widget.houseData.getItemLevel('living_door');
    final tvLvl = widget.houseData.getItemLevel('living_tv');
    final sofaLvl = widget.houseData.getItemLevel('living_sofa');
    final rugLvl = widget.houseData.getItemLevel('living_rug');

    return [
      // 1. Cửa chính ở góc trái
      Positioned(
        top: h * 0.15,
        left: w * 0.06,
        child: _buildInteractiveSlot(
          item: doorItem,
          level: doorLvl,
          size: w * 0.28,
        ),
      ),

      // 2. Tivi & Giải trí ở tường phía sau bên phải
      Positioned(
        top: h * 0.18,
        right: w * 0.10,
        child: _buildInteractiveSlot(
          item: tvItem,
          level: tvLvl,
          size: w * 0.36,
        ),
      ),

      // 3. Thảm trải sàn ở trung tâm
      Positioned(
        top: h * 0.52,
        left: (w - (w * 0.72)) / 2,
        child: _buildInteractiveSlot(
          item: rugItem,
          level: rugLvl,
          size: w * 0.45,
        ),
      ),

      // 4. Bàn ghế sofa ở giữa phòng (đè lên thảm)
      Positioned(
        top: h * 0.44,
        left: (w - (w * 0.65)) / 2,
        child: _buildInteractiveSlot(
          item: sofaItem,
          level: sofaLvl,
          size: w * 0.44,
        ),
      ),
    ];
  }

  // --- BEDROOM ---
  List<Widget> _buildBedroomLayout(double w, double h) {
    final bedItem = HouseCatalog.getItemById('bed_bed')!;
    final wardrobeItem = HouseCatalog.getItemById('bed_wardrobe')!;
    final deskItem = HouseCatalog.getItemById('bed_desk')!;
    final lampItem = HouseCatalog.getItemById('bed_lamp')!;

    final bedLvl = widget.houseData.getItemLevel('bed_bed');
    final wardrobeLvl = widget.houseData.getItemLevel('bed_wardrobe');
    final deskLvl = widget.houseData.getItemLevel('bed_desk');
    final lampLvl = widget.houseData.getItemLevel('bed_lamp');

    return [
      // 1. Tủ quần áo ở góc trên trái
      Positioned(
        top: h * 0.15,
        left: w * 0.08,
        child: _buildInteractiveSlot(
          item: wardrobeItem,
          level: wardrobeLvl,
          size: w * 0.28,
        ),
      ),

      // 2. Bàn học ở góc trên phải
      Positioned(
        top: h * 0.18,
        right: w * 0.08,
        child: _buildInteractiveSlot(
          item: deskItem,
          level: deskLvl,
          size: w * 0.32,
        ),
      ),

      // 3. Giường ngủ ấm áp ở giữa phòng
      Positioned(
        top: h * 0.45,
        left: (w - (w * 0.62)) / 2,
        child: _buildInteractiveSlot(
          item: bedItem,
          level: bedLvl,
          size: w * 0.45,
        ),
      ),

      // 4. Đèn ngủ cạnh đầu giường
      Positioned(
        top: h * 0.42,
        left: w * 0.10,
        child: _buildInteractiveSlot(
          item: lampItem,
          level: lampLvl,
          size: w * 0.22,
        ),
      ),
    ];
  }

  // ===========================================================================
  // INTERACTIVE SLOT (Nhấn vào đồ vật để nảy lên và mở Shop drawer)
  // ===========================================================================
  Widget _buildInteractiveSlot({
    required HouseItem item,
    required int level,
    required double size,
  }) {
    final isBouncing = _bouncingItemId == item.id;

    return AnimatedScale(
      scale: isBouncing ? 1.15 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.elasticOut,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Vật thể 2D
          CartoonFurnitureArt(
            itemId: item.id,
            level: level,
            size: size,
            isInteractive: true,
            onTap: () => _triggerBounce(item.id, item),
          ),
          // Huy hiệu cấp độ nhỏ gắn trên góc đồ vật (để bé biết đã đạt 4.0 chưa)
          if (level > 0)
            Positioned(
              top: -6,
              right: -6,
              child: GestureDetector(
                onTap: () => _triggerBounce(item.id, item),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: level == 3
                        ? const Color(0xFF7B1FA2)
                        : (level == 2 ? const Color(0xFFFFB300) : const Color(0xFF0288D1)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 3),
                    ],
                  ),
                  child: Text(
                    level == 3 ? '4.0' : 'Lv.$level',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      fontSize: 9,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 4. CÁC VẬT TRANG TRÍ PHỤ TRỢ (Vỏ sò, cây cảnh như ảnh mẫu 1 & 3)
  // ===========================================================================
  List<Widget> _buildDecorativeAccents(double w, double h) {
    if (widget.roomType == HouseRoomType.kitchen || widget.roomType == HouseRoomType.bathroom) {
      return [
        // Vỏ sò ngọc trai ở góc trái dưới (Y hệt ảnh mẫu 1 & 3!)
        Positioned(
          bottom: h * 0.16,
          left: 12,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.35),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🌿', style: TextStyle(fontSize: 22)),
                Text('🐚', style: TextStyle(fontSize: 28)),
              ],
            ),
          ),
        ),
        // Quầy bánh ngọt / kem nhỏ ở góc phải dưới (Ảnh 1 & 2)
        if (widget.roomType == HouseRoomType.kitchen)
          Positioned(
            bottom: h * 0.14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF64B5F6), width: 1.8),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, offset: Offset(0, 2), blurRadius: 4),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🍨', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 4),
                  Text('🧁', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
      ];
    }
    return [];
  }
}

/// Vẽ họa tiết lưới gạch sàn/tường hoạt hình
class _TileGridPainter extends CustomPainter {
  final Color tileColor;
  _TileGridPainter({required this.tileColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = tileColor
      ..strokeWidth = 1.5;

    // Đường lưới ngang
    for (double y = 0; y < size.height; y += 46) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Đường lưới dọc
    for (double x = 0; x < size.width; x += 46) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
