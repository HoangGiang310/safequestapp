import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Bộ sưu tập đồ nội thất hoạt hình 2D sống động phong cách Cat Cafe / Adorable Home
/// Cung cấp 15 món đồ nội thất cho 4 căn phòng:
/// - 3 Cấp độ rõ rệt:
///   * Level 1: Cổ Điển (Đơn sơ, mộc mạc, màu tự nhiên, ít phụ kiện)
///   * Level 2: Tiện Nghi (Hiện đại, màu sắc tươi sáng, phụ kiện tiện ích y hệt 4 ảnh mẫu)
///   * Level 3: Smart 4.0 MAX (Thiết kế công nghệ cao tương lai, đèn LED neon, màn hình OLED/AI cảm ứng, hào quang phát sáng)
typedef CartoonFurnitureArt = CartoonFurnitureWidget;

class CartoonFurnitureWidget extends StatelessWidget {
  final String itemId;
  final int level; // 0: chưa mua (placeholder), 1: cổ điển, 2: tiện nghi, 3: smart 4.0
  final double size;
  final bool isInteractive;
  final VoidCallback? onTap;

  const CartoonFurnitureWidget({
    super.key,
    required this.itemId,
    required this.level,
    this.size = 110,
    this.isInteractive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget art;

    if (level == 0) {
      art = _buildPlaceholder();
    } else {
      switch (itemId) {
        // --- BẾP & PHÒNG ĂN ---
        case 'kitchen_fridge':
          art = _buildFridge(level);
          break;
      case 'kitchen_stove':
        art = _buildStove(level);
        break;
      case 'kitchen_table':
        art = _buildDiningTable(level);
        break;

      // --- NHÀ TẮM / WC ---
      case 'bath_toilet':
        art = _buildToilet(level);
        break;
      case 'bath_sink':
        art = _buildLavabo(level);
        break;
      case 'bath_washer':
      case 'bath_washing':
        art = _buildWasher(level);
        break;
      case 'bath_tub':
        art = _buildBathtub(level);
        break;

      // --- PHÒNG KHÁCH ---
      case 'living_door':
        art = _buildDoor(level);
        break;
      case 'living_sofa':
        art = _buildSofa(level);
        break;
      case 'living_tv':
        art = _buildTv(level);
        break;
      case 'living_rug':
        art = _buildRug(level);
        break;

      // --- PHÒNG NGỦ ---
      case 'bed_bed':
        art = _buildBed(level);
        break;
      case 'bed_desk':
        art = _buildDesk(level);
        break;
      case 'bed_wardrobe':
        art = _buildWardrobe(level);
        break;
      case 'bed_lamp':
        art = _buildLamp(level);
        break;

      default:
        art = _buildGenericItem(level);
      }
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: art,
      );
    }

    return art;
  }

  // ===========================================================================
  // PLACEHOLDER (Vị trí chưa có đồ - khung nét đứt hoạt hình mời bé sắm)
  // ===========================================================================
  Widget _buildPlaceholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF64B5F6).withOpacity(0.6),
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded, color: Color(0xFF0288D1), size: 24),
            ),
            const SizedBox(height: 4),
            const Text(
              'Chưa sắm',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0288D1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. TỦ LẠNH (kitchen_fridge)
  // ===========================================================================
  Widget _buildFridge(int lvl) {
    if (lvl == 1) {
      // Level 1: Tủ lạnh mini 1 cánh mộc mạc cổ điển, nhỏ gọn màu kem vintage
      return SizedBox(
        width: size * 0.75,
        height: size * 1.05,
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            // Thân tủ tròn trịa 1 cánh
            Container(
              width: size * 0.75,
              height: size * 0.95,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF8D6E63), width: 2.5),
                boxShadow: const [
                  BoxShadow(color: Color(0xFF6D4C41), offset: Offset(0, 3)),
                ],
              ),
              child: Stack(
                children: [
                  // Tay nắm ngang kim loại cổ điển
                  Positioned(
                    right: 8,
                    top: size * 0.4,
                    child: Container(
                      width: 6,
                      height: 22,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB0BEC5),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: const Color(0xFF546E7A), width: 1),
                      ),
                    ),
                  ),
                  // Logo cổ điển nhỏ
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      width: 12,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB74D),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Đĩa quả táo đỏ trên nóc tủ
            Positioned(
              top: -8,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFB0BEC5), width: 1.2),
                    ),
                    child: const Text('🍎', style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (lvl == 2) {
      // Level 2: Tủ lạnh 2 cánh cao ráo y hệt ảnh mẫu 1 & 2! Có lò vi sóng trên nóc và giấy note trái tim
      const borderColor = Color(0xFF4A6B82);
      return SizedBox(
        width: size * 0.85,
        height: size * 1.35,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Thân tủ 2 cánh
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE1F5FE),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor, width: 2.8),
                boxShadow: [
                  BoxShadow(color: borderColor.withOpacity(0.3), offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  // Cánh trên màu trắng
                  Expanded(
                    flex: 5,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(6, 6, 6, 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor, width: 1.5),
                      ),
                      child: Stack(
                        children: [
                          // Giấy note tim đỏ (như ảnh mẫu 1 & 2)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF59D),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFFFBC02D), width: 1),
                              ),
                              child: const Center(child: Text('❤️', style: TextStyle(fontSize: 8))),
                            ),
                          ),
                          // Sticker dâu tây
                          Positioned(
                            bottom: 8,
                            left: 10,
                            child: const Text('🍓', style: TextStyle(fontSize: 10)),
                          ),
                          // Tay nắm cửa
                          Positioned(
                            right: 8,
                            top: 16,
                            child: Container(
                              width: 5,
                              height: 24,
                              decoration: BoxDecoration(
                                color: const Color(0xFF90CAF9),
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(color: borderColor, width: 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Cánh dưới màu xanh da trời
                  Expanded(
                    flex: 4,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(6, 3, 6, 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF81D4FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor, width: 1.5),
                      ),
                      child: Center(
                        child: Container(
                          width: 24,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: borderColor, width: 1),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Lò vi sóng trên nóc tủ (y như ảnh mẫu 1 & 2!)
            Positioned(
              top: -12,
              child: Container(
                width: size * 0.72,
                height: size * 0.38,
                decoration: BoxDecoration(
                  color: const Color(0xFF455A64),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor, width: 2.2),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        margin: const EdgeInsets.all(3.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB0BEC5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle)),
                          const SizedBox(height: 3),
                          Container(width: 8, height: 2, color: Colors.white70),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Level 3 (Smart 4.0 MAX): Tủ lạnh 4 cánh Side-by-Side kính sapphire đen, viền LED neon, màn hình AI cảm ứng khổng lồ
      const borderColor = Color(0xFF7B1FA2);
      return SizedBox(
        width: size * 1.05,
        height: size * 1.45,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Thân tủ kính đen bóng viền LED tím neon
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor, width: 3),
                boxShadow: const [
                  BoxShadow(color: Color(0xFF00E5FF), blurRadius: 8, spreadRadius: -2),
                  BoxShadow(color: Color(0xFF4A148C), offset: Offset(0, 5)),
                ],
              ),
              child: Column(
                children: [
                  // 2 Cánh lớn phía trên
                  Expanded(
                    flex: 6,
                    child: Row(
                      children: [
                        // Cánh trái kính đen có vòi lấy nước đá tự động
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(6, 6, 3, 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16213E),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF00E5FF), width: 1.2),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 22,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F3460),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: const Color(0xFF00E5FF), width: 1),
                                    ),
                                    child: const Center(child: Text('🧊', style: TextStyle(fontSize: 10))),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text('ICE & WATER', style: TextStyle(fontSize: 5, color: Color(0xFF00E5FF), fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Cánh phải có màn hình Smart Hub cảm ứng hiển thị nhiệt độ
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(3, 6, 6, 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F3460),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE040FB), width: 1.2),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('-18°C | 3°C', style: TextStyle(fontSize: 6.5, color: Color(0xFF00E5FF), fontWeight: FontWeight.w900)),
                                ),
                                const SizedBox(height: 4),
                                const Text('🤖 AI SMART', style: TextStyle(fontSize: 6, color: Color(0xFFFFD54F), fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 2 Ngăn đông kéo ra phía dưới
                  Expanded(
                    flex: 4,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(6, 3, 6, 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16213E),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor, width: 1.5),
                      ),
                      child: Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E5FF),
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: const [
                              BoxShadow(color: Color(0xFF00E5FF), blurRadius: 4),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Nồi chiên không dầu Smart AirFryer trên nóc tủ
            Positioned(
              top: -14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF212121),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF00E5FF), width: 1.8),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFF00E5FF), blurRadius: 4),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('✨', style: TextStyle(fontSize: 8)),
                    SizedBox(width: 3),
                    Text('SMART 4.0', style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  // ===========================================================================
  // 2. BẾP NẤU ĂN (kitchen_stove)
  // ===========================================================================
  Widget _buildStove(int lvl) {
    if (lvl == 1) {
      // Level 1: Bếp gas đơn cổ điển mộc mạc: kệ gỗ mộc, 1 kiềng sắt, bình gas nhỏ bên hông
      return SizedBox(
        width: size * 1.1,
        height: size * 0.85,
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            // Bàn bếp gỗ mộc
            Container(
              width: size * 1.05,
              height: size * 0.55,
              decoration: BoxDecoration(
                color: const Color(0xFFD7CCC8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF6D4C41), width: 2.5),
                boxShadow: const [
                  BoxShadow(color: Color(0xFF4E342E), offset: Offset(0, 3)),
                ],
              ),
              child: Center(
                child: Container(
                  width: 30,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFFA1887F),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            // Mặt bếp kim loại với 1 nồi cơm / chảo đơn giản
            Positioned(
              top: 8,
              left: 18,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xFF757575),
                  shape: BoxShape.circle,
                ),
                child: const Center(child: Text('🍲', style: TextStyle(fontSize: 14))),
              ),
            ),
            // Bình gas mini bên cạnh
            Positioned(
              top: 6,
              right: 14,
              child: Container(
                width: 18,
                height: 26,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7043),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFD84315), width: 1.5),
                ),
                child: const Center(
                  child: Text('GAS', style: TextStyle(fontSize: 5, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (lvl == 2) {
      // Level 2: Kệ bếp đôi hiện đại y hệt ảnh mẫu 1 & 2! Ấm trà chấm bi xanh + chảo trứng ốp la
      const borderColor = Color(0xFF4A6B82);
      return SizedBox(
        width: size * 1.3,
        height: size * 0.95,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // Bàn bếp xanh
            Container(
              width: size * 1.3,
              height: size * 0.65,
              decoration: BoxDecoration(
                color: const Color(0xFF546E7A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor, width: 2.8),
                boxShadow: const [
                  BoxShadow(color: Color(0xFF37474F), offset: Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    height: 14,
                    decoration: const BoxDecoration(
                      color: Color(0xFF455A64),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF90CAF9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor, width: 1.5),
                      ),
                      child: Center(
                        child: Container(
                          width: 38,
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFF29B6F6),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white, width: 1.8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Ấm trà chấm bi xanh cute (giống ảnh mẫu 1 & 2)
            Positioned(
              top: 0,
              left: 14,
              child: SizedBox(
                width: 38,
                height: 38,
                child: Stack(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE1F5FE),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF0288D1), width: 2),
                      ),
                      child: const Center(child: Text('💙', style: TextStyle(fontSize: 10))),
                    ),
                    Positioned(
                      top: 0,
                      left: 10,
                      child: Container(
                        width: 12,
                        height: 6,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0288D1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Chảo trứng ốp la bốc khói (giống ảnh mẫu 1 & 2)
            Positioned(
              top: 4,
              right: 16,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8D6E63),
                      shape: BoxShape.circle,
                      border: Border.all(color: borderColor, width: 2),
                    ),
                    child: Center(
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFE082),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(child: Text('🍳', style: TextStyle(fontSize: 11))),
                      ),
                    ),
                  ),
                  Container(
                    width: 14,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0288D1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // Level 3: Đảo bếp cẩm thạch đá Marble trắng viền vàng Rose Gold, bếp từ cảm ứng phát sáng vòng tròn LED neon AI
      return SizedBox(
        width: size * 1.45,
        height: size * 1.1,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // Thân đảo bếp đá hoa cương trắng viền vàng kim
            Container(
              width: size * 1.4,
              height: size * 0.72,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFFB300), width: 3),
                boxShadow: const [
                  BoxShadow(color: Color(0xFFFFD54F), blurRadius: 8),
                  BoxShadow(color: Color(0xFFB78103), offset: Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  // Mặt đá cẩm thạch đen lấp lánh
                  Container(
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Color(0xFF263238),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Vòng tròn bếp từ cảm ứng đỏ
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFFF5252), width: 1.8),
                          ),
                        ),
                        // Vòng tròn bếp từ cảm ứng xanh cyan
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF00E5FF), width: 1.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFFE082), width: 1.5),
                      ),
                      child: const Center(
                        child: Text('AI COOKING HUB 4.0', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Color(0xFFE65100))),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Máy pha cà phê Espresso cảm ứng và nồi chiên AI
            Positioned(
              top: 0,
              left: 12,
              child: const Text('☕', style: TextStyle(fontSize: 22)),
            ),
            Positioned(
              top: 2,
              right: 14,
              child: const Text('🥘', style: TextStyle(fontSize: 22)),
            ),
          ],
        ),
      );
    }
  }

  // ===========================================================================
  // 3. BÀN ĂN (kitchen_table)
  // ===========================================================================
  Widget _buildDiningTable(int lvl) {
    if (lvl == 1) {
      // Level 1: Bàn tròn gỗ sồi mộc mạc cổ điển, 2 ghế nan gỗ đơn giản, rổ bánh mì nướng
      const borderColor = Color(0xFF8D6E63);
      return SizedBox(
        width: size * 1.3,
        height: size * 0.95,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Ghế gỗ nan trái & phải
            Positioned(
              left: 4,
              child: Container(
                width: 22,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFD7CCC8),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: borderColor, width: 2),
                ),
              ),
            ),
            Positioned(
              right: 4,
              child: Container(
                width: 22,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFD7CCC8),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: borderColor, width: 2),
                ),
              ),
            ),
            // Mặt bàn gỗ tròn mộc mạc
            Container(
              width: size * 1.0,
              height: size * 0.65,
              decoration: BoxDecoration(
                color: const Color(0xFFBCAAA4),
                borderRadius: BorderRadius.all(Radius.elliptical(size * 1.0, size * 0.65)),
                border: Border.all(color: borderColor, width: 2.8),
                boxShadow: const [
                  BoxShadow(color: Color(0xFF6D4C41), offset: Offset(0, 4)),
                ],
              ),
              child: const Center(
                child: Text('🥖', style: TextStyle(fontSize: 20)),
              ),
            ),
          ],
        ),
      );
    } else if (lvl == 2) {
      // Level 2: Khăn trải caro xanh - trắng chuẩn 100% ảnh mẫu 1 & 2! Kèm dĩa thìa dao nĩa
      const borderColor = Color(0xFF2E6B9E);
      return SizedBox(
        width: size * 1.5,
        height: size * 1.1,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Ghế tựa màu cam viền nệm xanh pastel xung quanh
            Positioned(left: 2, top: 8, child: _buildDiningChair(borderColor)),
            Positioned(right: 2, top: 8, child: _buildDiningChair(borderColor)),
            // Chân bàn gỗ tròn ở dưới
            Positioned(
              bottom: 6,
              child: Container(
                width: size * 0.7,
                height: size * 0.35,
                decoration: BoxDecoration(
                  color: const Color(0xFFD7A15C),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF8D5316), width: 2.5),
                ),
              ),
            ),
            // Mặt bàn tròn phủ khăn trải caro xanh (đặc trưng ảnh mẫu 1 & 2!)
            Container(
              width: size * 1.35,
              height: size * 0.75,
              decoration: BoxDecoration(
                color: const Color(0xFF90CAF9),
                borderRadius: BorderRadius.all(Radius.elliptical(size * 1.35, size * 0.75)),
                border: Border.all(color: borderColor, width: 3),
                boxShadow: const [
                  BoxShadow(color: Color(0xFF1565C0), offset: Offset(0, 4)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.elliptical(size * 1.35, size * 0.75)),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: Size(size * 1.35, size * 0.75),
                      painter: _CheckeredPatternPainter(),
                    ),
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: size * 1.35,
                        height: 12,
                        color: const Color(0xFF64B5F6).withOpacity(0.6),
                      ),
                    ),
                    // Dĩa sứ và dao nĩa ở giữa bàn
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🍴', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Container(
                          width: 32,
                          height: 22,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFDE7),
                            borderRadius: const BorderRadius.all(Radius.elliptical(32, 22)),
                            border: Border.all(color: const Color(0xFFB0BEC5), width: 1.8),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Level 3: Bàn tiệc hoàng gia mặt đá hoa cương đen ánh kim sa, ghế bọc nhung hoàng kim, nắp đậy giữ nhiệt 🍲
      return SizedBox(
        width: size * 1.6,
        height: size * 1.2,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Ghế bọc nhung hoàng gia tím viền vàng
            Positioned(
              left: 2,
              top: 6,
              child: Container(
                width: 28,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A148C),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFD54F), width: 2),
                ),
              ),
            ),
            Positioned(
              right: 2,
              top: 6,
              child: Container(
                width: 28,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A148C),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFD54F), width: 2),
                ),
              ),
            ),
            // Mặt bàn đá đen kim sa sang trọng viền vàng
            Container(
              width: size * 1.4,
              height: size * 0.8,
              decoration: BoxDecoration(
                color: const Color(0xFF212121),
                borderRadius: BorderRadius.all(Radius.elliptical(size * 1.4, size * 0.8)),
                border: Border.all(color: const Color(0xFFFFD54F), width: 3.5),
                boxShadow: const [
                  BoxShadow(color: Color(0xFFFFD54F), blurRadius: 10),
                  BoxShadow(color: Color(0xFF000000), offset: Offset(0, 5)),
                ],
              ),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('✨', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 4),
                    Text('🍲', style: TextStyle(fontSize: 26)),
                    SizedBox(width: 4),
                    Text('✨', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildDiningChair(Color borderColor) {
    return Container(
      width: 28,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFFFB74D),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE65100), width: 2.2),
      ),
      child: Center(
        child: Container(
          width: 18,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFBBDEFB),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: borderColor, width: 1.5),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 4. BỒN CẦU (bath_toilet)
  // ===========================================================================
  Widget _buildToilet(int lvl) {
    if (lvl == 1) {
      // Level 1: Bồn cầu sứ trắng cổ điển đơn sơ, két nước vuông phía sau, cuộn giấy vệ sinh bên cạnh
      const borderColor = Color(0xFF78909C);
      return SizedBox(
        width: size * 0.85,
        height: size * 1.15,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Két nước vuông
            Positioned(
              top: 0,
              child: Container(
                width: size * 0.55,
                height: size * 0.45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor, width: 2.5),
                ),
                child: const Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: Text('🚰', style: TextStyle(fontSize: 8)),
                  ),
                ),
              ),
            ),
            // Bệ ngồi sứ trắng
            Positioned(
              bottom: 0,
              child: Container(
                width: size * 0.65,
                height: size * 0.55,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 2.5),
                ),
              ),
            ),
            // Cuộn giấy vệ sinh bên cạnh
            Positioned(
              right: -8,
              bottom: 12,
              child: const Text('🧻', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      );
    } else if (lvl == 2) {
      // Level 2: Chuẩn 100% ảnh mẫu 3 & 4! Bồn cầu xanh họa tiết sao + rèm che kẻ sọc bên cạnh
      const borderColor = Color(0xFF2E6B9E);
      return SizedBox(
        width: size * 1.0,
        height: size * 1.3,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Rèm tắm kẻ caro xanh bên cạnh (ảnh mẫu 3 & 4)
            Positioned(
              left: -10,
              top: -15,
              bottom: 0,
              child: Container(
                width: 22,
                decoration: BoxDecoration(
                  color: const Color(0xFF5C6BC0),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: Column(
                  children: List.generate(
                    6,
                    (index) => Container(
                      height: 12,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ),
              ),
            ),
            // Bệ bồn cầu xanh
            Positioned(
              bottom: 0,
              child: Container(
                width: size * 0.72,
                height: size * 0.55,
                decoration: BoxDecoration(
                  color: const Color(0xFF42A5F5),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor, width: 2.8),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFF1565C0), offset: Offset(0, 4)),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: size * 0.52,
                    height: size * 0.32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF80DEEA),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF00ACC1), width: 2),
                    ),
                  ),
                ),
              ),
            ),
            // Nắp bồn cầu mở ra phía sau
            Positioned(
              top: 10,
              child: Container(
                width: size * 0.65,
                height: size * 0.62,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  border: Border.all(color: borderColor, width: 2.8),
                ),
                child: Center(
                  child: Container(
                    width: size * 0.48,
                    height: size * 0.48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1F5FE),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                      border: Border.all(color: const Color(0xFFB0BEC5), width: 1.5),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Level 3: Smart Toilet Cyber Bidet tương lai: đèn LED neon đổi màu, bệ sưởi ấm, nắp cảm ứng tự động
      return SizedBox(
        width: size * 1.15,
        height: size * 1.4,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Bệ bồn cầu phi thuyền tương lai
            Positioned(
              bottom: 0,
              child: Container(
                width: size * 0.85,
                height: size * 0.65,
                decoration: BoxDecoration(
                  color: const Color(0xFF263238),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF00E5FF), width: 3),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFF00E5FF), blurRadius: 10),
                    BoxShadow(color: Colors.black45, offset: Offset(0, 5)),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: size * 0.6,
                    height: size * 0.4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF00E5FF), width: 2),
                    ),
                    child: const Center(
                      child: Text('🫧 AUTO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF00E5FF))),
                    ),
                  ),
                ),
              ),
            ),
            // Nắp cảm ứng cánh thiên thần phát quang
            Positioned(
              top: 10,
              child: Container(
                width: size * 0.75,
                height: size * 0.65,
                decoration: BoxDecoration(
                  color: const Color(0xFF37474F),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  border: Border.all(color: const Color(0xFFE040FB), width: 2.5),
                ),
                child: const Center(
                  child: Text('👑 SMART 4.0', style: TextStyle(fontSize: 8, color: Color(0xFFFFD54F), fontWeight: FontWeight.w900)),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  // ===========================================================================
  // 5. LAVABO & GƯƠNG (bath_sink)
  // ===========================================================================
  Widget _buildLavabo(int lvl) {
    if (lvl == 1) {
      // Level 1: Chậu sứ trắng treo tường đơn giản, vòi inox, khay xà bông hồng
      const borderColor = Color(0xFF78909C);
      return SizedBox(
        width: size * 0.9,
        height: size * 1.1,
        child: Column(
          children: [
            // Gương tròn đơn sơ
            Container(
              width: size * 0.45,
              height: size * 0.45,
              decoration: BoxDecoration(
                color: const Color(0xFFE0F7FA),
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 2.2),
              ),
            ),
            const SizedBox(height: 6),
            // Chậu rửa treo tường
            Container(
              width: size * 0.8,
              height: size * 0.45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor, width: 2.5),
              ),
              child: const Center(child: Text('🧼', style: TextStyle(fontSize: 16))),
            ),
          ],
        ),
      );
    } else if (lvl == 2) {
      // Level 2: Chuẩn 100% ảnh mẫu 3 & 4! Bàn gỗ vàng cam + GƯƠNG SOI HÌNH CHIM CÁNH CỤT 🐧 siêu cute!
      const borderColor = Color(0xFF2E6B9E);
      return SizedBox(
        width: size * 1.15,
        height: size * 1.45,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // Bàn gỗ lavabo có ngăn kéo (ảnh 3 & 4)
            Container(
              width: size * 1.05,
              height: size * 0.6,
              decoration: BoxDecoration(
                color: const Color(0xFFFFB74D),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE65100), width: 2.8),
                boxShadow: const [
                  BoxShadow(color: Color(0xFFBF360C), offset: Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFA726),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 38,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9800),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFE65100), width: 1.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Chậu rửa sứ tròn màu trắng đựng nước trong veo
            Positioned(
              bottom: size * 0.42,
              child: Container(
                width: size * 0.65,
                height: size * 0.35,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.elliptical(size * 0.65, size * 0.35)),
                  border: Border.all(color: borderColor, width: 2.5),
                ),
                child: Center(
                  child: Container(
                    width: size * 0.5,
                    height: size * 0.22,
                    decoration: BoxDecoration(
                      color: const Color(0xFF81D4FA),
                      borderRadius: BorderRadius.all(Radius.elliptical(size * 0.5, size * 0.22)),
                      border: Border.all(color: const Color(0xFF0288D1), width: 1.5),
                    ),
                  ),
                ),
              ),
            ),
            // GƯƠNG SOI TẠO HÌNH CHIM CÁNH CỤT (ảnh mẫu 3 & 4!)
            Positioned(
              top: 0,
              child: SizedBox(
                width: size * 0.72,
                height: size * 0.72,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: size * 0.7,
                      height: size * 0.7,
                      decoration: BoxDecoration(
                        color: const Color(0xFF37474F),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: const Color(0xFF263238), width: 2.5),
                      ),
                    ),
                    Container(
                      width: size * 0.52,
                      height: size * 0.52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB3E5FC),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF81D4FA), width: 2),
                      ),
                    ),
                    Positioned(
                      top: 14,
                      child: Container(
                        width: 8,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Level 3: Bàn đá thạch anh đôi, gương LED cảm ứng AI phát sáng hào quang rực rỡ
      return SizedBox(
        width: size * 1.3,
        height: size * 1.55,
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            // Bàn đá cẩm thạch trắng viền vàng Rose Gold
            Container(
              width: size * 1.25,
              height: size * 0.65,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFFB300), width: 3),
                boxShadow: const [
                  BoxShadow(color: Color(0xFF00E5FF), blurRadius: 10),
                  BoxShadow(color: Color(0xFFF57F17), offset: Offset(0, 4)),
                ],
              ),
              child: const Center(
                child: Text('UV STERILIZE 4.0', style: TextStyle(fontSize: 8.5, color: Color(0xFF00838F), fontWeight: FontWeight.w900)),
              ),
            ),
            // Gương LED cảm ứng hào quang tỏa sáng
            Positioned(
              top: 0,
              child: Container(
                width: size * 0.75,
                height: size * 0.75,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF00E5FF), width: 3.5),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFF00E5FF), blurRadius: 12),
                  ],
                ),
                child: const Center(child: Text('✨', style: TextStyle(fontSize: 26))),
              ),
            ),
          ],
        ),
      );
    }
  }

  // ===========================================================================
  // 6. MÁY GIẶT (bath_washing / bath_washer)
  // ===========================================================================
  Widget _buildWasher(int lvl) {
    if (lvl == 1) {
      // Level 1: Máy giặt cửa trên cổ điển lồng đứng mộc mạc, giỏ mây đựng đồ bên cạnh
      const borderColor = Color(0xFF78909C);
      return SizedBox(
        width: size * 0.95,
        height: size * 1.1,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Thân máy giặt lồng đứng
            Container(
              width: size * 0.85,
              height: size * 1.05,
              decoration: BoxDecoration(
                color: const Color(0xFFECEFF1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor, width: 2.5),
                boxShadow: const [
                  BoxShadow(color: Color(0xFFB0BEC5), offset: Offset(0, 3)),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    height: 22,
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCFD8DC),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(child: Text('TOP LOAD', style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold))),
                  ),
                  const Spacer(),
                  const Text('🧺', style: TextStyle(fontSize: 24)),
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (lvl == 2) {
      // Level 2: Chuẩn 100% ảnh mẫu 3 & 4! Máy giặt cửa ngang xanh pastel, lồng kính thấy quần áo xoay tròn 🌀
      const borderColor = Color(0xFF2E6B9E);
      return SizedBox(
        width: size * 1.05,
        height: size * 1.25,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF81D4FA),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 2.8),
            boxShadow: const [
              BoxShadow(color: Color(0xFF0277BD), offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              // Bảng điều khiển nút bấm
              Container(
                height: 24,
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF29B6F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(width: 10, height: 6, decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(2))),
                    Row(
                      children: [
                        Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                        const SizedBox(width: 3),
                        Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                      ],
                    ),
                  ],
                ),
              ),
              // Cửa máy giặt tròn có quần áo màu sắc bên trong (ảnh 3 & 4)
              Expanded(
                child: Center(
                  child: Container(
                    width: size * 0.72,
                    height: size * 0.72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: borderColor, width: 3),
                    ),
                    child: Center(
                      child: Container(
                        width: size * 0.54,
                        height: size * 0.54,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE1F5FE),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF81D4FA), width: 2),
                        ),
                        child: const Center(
                          child: Text('🌀', style: TextStyle(fontSize: 24)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Level 3: Tháp giặt sấy đôi 2 tầng AI Smart Wash vỏ xám titan viền LED neon, màn hình OLED đếm ngược "00:15"
      return SizedBox(
        width: size * 1.15,
        height: size * 1.45,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A237E),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF00E5FF), width: 3),
            boxShadow: const [
              BoxShadow(color: Color(0xFF00E5FF), blurRadius: 8),
              BoxShadow(color: Colors.black45, offset: Offset(0, 5)),
            ],
          ),
          child: Column(
            children: [
              // Màn hình OLED đếm ngược
              Container(
                height: 24,
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Center(
                  child: Text('00:15 • AI DRY 4.0', style: TextStyle(fontSize: 8, color: Color(0xFF00E5FF), fontWeight: FontWeight.w900)),
                ),
              ),
              // Lồng sấy trên
              Container(
                width: size * 0.45,
                height: size * 0.45,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D47A1),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF00E5FF), width: 2),
                ),
                child: const Center(child: Text('⚡ UV', style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(height: 4),
              // Lồng giặt dưới
              Container(
                width: size * 0.52,
                height: size * 0.52,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D47A1),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE040FB), width: 2),
                ),
                child: const Center(child: Text('🌀', style: TextStyle(fontSize: 20))),
              ),
            ],
          ),
        ),
      );
    }
  }

  // ===========================================================================
  // 7. BỒN TẮM (bath_tub)
  // ===========================================================================
  Widget _buildBathtub(int lvl) {
    if (lvl == 1) {
      // Level 1: Chậu tắm bé đơn sơ màu vàng ấm áp bo tròn, ca múc nước gỗ
      return SizedBox(
        width: size * 1.15,
        height: size * 0.75,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFE082),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFF57F17), width: 2.5),
            boxShadow: const [
              BoxShadow(color: Color(0xFFE65100), offset: Offset(0, 3)),
            ],
          ),
          child: const Center(
            child: Text('🪣', style: TextStyle(fontSize: 26)),
          ),
        ),
      );
    } else if (lvl == 2) {
      // Level 2: Chuẩn 100% ảnh mẫu 3 & 4! Bồn tắm oval xanh nước biển mát rượi, vịt vàng cao su 🦆 và giỏ khăn tắm 🧺
      const borderColor = Color(0xFF2E6B9E);
      return SizedBox(
        width: size * 1.5,
        height: size * 1.0,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Thân bồn tắm hình oval xanh pastel (y hệt ảnh 3 & 4)
            Container(
              width: size * 1.4,
              height: size * 0.75,
              decoration: BoxDecoration(
                color: const Color(0xFF42A5F5),
                borderRadius: BorderRadius.all(Radius.elliptical(size * 1.4, size * 0.75)),
                border: Border.all(color: borderColor, width: 3),
                boxShadow: const [
                  BoxShadow(color: Color(0xFF1565C0), offset: Offset(0, 5)),
                ],
              ),
              child: Center(
                child: Container(
                  width: size * 1.25,
                  height: size * 0.58,
                  decoration: BoxDecoration(
                    color: const Color(0xFF80DEEA),
                    borderRadius: BorderRadius.all(Radius.elliptical(size * 1.25, size * 0.58)),
                    border: Border.all(color: const Color(0xFF00ACC1), width: 2.2),
                  ),
                ),
              ),
            ),
            // Chai dầu gội và chú vịt vàng cao su ở góc dưới (ảnh 3 & 4)
            Positioned(
              left: 10,
              bottom: -6,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 14,
                    height: 22,
                    decoration: BoxDecoration(
                      color: const Color(0xFF81D4FA),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: borderColor, width: 1.5),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('🐤', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
            // Giỏ khăn tắm cạnh bồn tắm (ảnh 3 & 4)
            Positioned(
              right: 8,
              bottom: -8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFCC80),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE65100), width: 1.8),
                ),
                child: const Text('🧺', style: TextStyle(fontSize: 14)),
              ),
            ),
          ],
        ),
      );
    } else {
      // Level 3: Bể sục Jacuzzi Thủy Lực hình vỏ sò hoàng gia, thác nước mini, cánh hoa hồng nổi trên mặt nước 🌈
      return SizedBox(
        width: size * 1.65,
        height: size * 1.15,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size * 1.55,
              height: size * 0.85,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFFFFD54F), width: 3.5),
                boxShadow: const [
                  BoxShadow(color: Color(0xFF00E5FF), blurRadius: 12),
                  BoxShadow(color: Color(0xFFF57F17), offset: Offset(0, 5)),
                ],
              ),
              child: Center(
                child: Container(
                  width: size * 1.35,
                  height: size * 0.65,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5FF).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Center(
                    child: Text('🌺 JACUZZI 4.0 🌺', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Color(0xFF006064))),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  // ===========================================================================
  // 8. CÁNH CỬA (living_door)
  // ===========================================================================
  Widget _buildDoor(int lvl) {
    if (lvl == 1) {
      // Level 1: Cửa gỗ nâu then cài đồng quê mộc mạc
      const borderColor = Color(0xFF5D4037);
      return SizedBox(
        width: size * 0.85,
        height: size * 1.35,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF8D6E63),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            border: Border.all(color: borderColor, width: 2.8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 14, height: 6, color: Colors.amber),
              const SizedBox(height: 14),
              const Text('🔔', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      );
    } else if (lvl == 2) {
      // Level 2: Cửa thép an toàn màu xanh mint, khóa gạt inox, mắt thần góc rộng
      const borderColor = Color(0xFF00695C);
      return SizedBox(
        width: size * 0.9,
        height: size * 1.45,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF80CBC4),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: borderColor, width: 3),
            boxShadow: const [BoxShadow(color: Color(0xFF004D40), offset: Offset(0, 4))],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 24,
                left: (size * 0.9 - 14) / 2,
                child: Container(width: 14, height: 14, decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle)),
              ),
              Positioned(
                right: 10,
                top: size * 0.7,
                child: Container(width: 8, height: 22, color: Colors.white),
              ),
            ],
          ),
        ),
      );
    } else {
      // Level 3: Cửa Smart Door Cyber FaceID: màn hình quét khuôn mặt hologram, khóa vân tay LED xanh
      return SizedBox(
        width: size * 1.0,
        height: size * 1.55,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: const Color(0xFF00E5FF), width: 3.5),
            boxShadow: const [
              BoxShadow(color: Color(0xFF00E5FF), blurRadius: 10),
              BoxShadow(color: Colors.black54, offset: Offset(0, 5)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF00E5FF), width: 1.5),
                ),
                child: const Icon(Icons.face_retouching_natural, color: Color(0xFF00E5FF), size: 24),
              ),
              const SizedBox(height: 10),
              const Text('FACE ID 4.0', style: TextStyle(fontSize: 8, color: Color(0xFF00E5FF), fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      );
    }
  }

  // ===========================================================================
  // 9. SOFA (living_sofa)
  // ===========================================================================
  Widget _buildSofa(int lvl) {
    if (lvl == 1) {
      // Level 1: Ghế nan gỗ mộc đơn sơ kèm bàn trà nhỏ
      return SizedBox(
        width: size * 1.25,
        height: size * 0.8,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFD7CCC8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF6D4C41), width: 2.5),
          ),
          child: const Center(child: Text('🪑 MỘC MẠC', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF4E342E)))),
        ),
      );
    } else if (lvl == 2) {
      // Level 2: Sofa nỉ màu vàng bơ bo tròn mềm mại êm ái, gối ôm hình gấu cute
      return SizedBox(
        width: size * 1.5,
        height: size * 0.95,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFD54F),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFF57F17), width: 2.8),
            boxShadow: const [BoxShadow(color: Color(0xFFE65100), offset: Offset(0, 4))],
          ),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🧸', style: TextStyle(fontSize: 18)),
                SizedBox(width: 8),
                Text('SOFA ÊM ÁI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFBF360C))),
                SizedBox(width: 8),
                Text('🧸', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ),
      );
    } else {
      // Level 3: Ghế massage phi thuyền Cyber màu tím sapphire viền vàng Rose Gold, đệm sưởi thông minh
      return SizedBox(
        width: size * 1.6,
        height: size * 1.05,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF4A148C),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFFFFD54F), width: 3.5),
            boxShadow: const [
              BoxShadow(color: Color(0xFFE040FB), blurRadius: 10),
              BoxShadow(color: Colors.black54, offset: Offset(0, 5)),
            ],
          ),
          child: const Center(
            child: Text('✨ MASSAGE CYBER 4.0 ✨', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Color(0xFFFFD54F))),
          ),
        ),
      );
    }
  }

  // ===========================================================================
  // 10. TIVI (living_tv)
  // ===========================================================================
  Widget _buildTv(int lvl) {
    if (lvl == 1) {
      // Level 1: Tivi bóng hình hộp CRT cổ điển có 2 râu ăng-ten
      return SizedBox(
        width: size * 1.0,
        height: size * 0.95,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: size * 0.9,
              height: size * 0.7,
              decoration: BoxDecoration(
                color: const Color(0xFF5D4037),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF3E2723), width: 2.5),
              ),
              child: const Center(child: Text('📺 CRT', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold))),
            ),
            Positioned(top: 0, child: const Text('📡', style: TextStyle(fontSize: 18))),
          ],
        ),
      );
    } else if (lvl == 2) {
      // Level 2: Smart TV siêu mỏng LED viền mỏng treo trên kệ gỗ
      return SizedBox(
        width: size * 1.25,
        height: size * 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF263238),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF37474F), width: 2.8),
            boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(0, 4))],
          ),
          child: const Center(child: Text('🎬 SMART TV HD', style: TextStyle(color: Color(0xFF81D4FA), fontWeight: FontWeight.w900, fontSize: 11))),
        ),
      );
    } else {
      // Level 3: Rạp chiếu Laser Cinema 4K cong siêu lớn tràn viền
      return SizedBox(
        width: size * 1.55,
        height: size * 1.15,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0D47A1),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF00E5FF), width: 3.5),
            boxShadow: const [
              BoxShadow(color: Color(0xFF00E5FF), blurRadius: 12),
              BoxShadow(color: Colors.black45, offset: Offset(0, 5)),
            ],
          ),
          child: const Center(child: Text('🌟 LASER CINEMA 4K 4.0 🌟', style: TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.w900, fontSize: 10))),
        ),
      );
    }
  }

  // ===========================================================================
  // 11. THẢM (living_rug)
  // ===========================================================================
  Widget _buildRug(int lvl) {
    if (lvl == 1) {
      // Level 1: Thảm nỉ tròn mộc đơn sắc
      return Container(
        width: size * 1.25,
        height: size * 0.6,
        decoration: BoxDecoration(
          color: const Color(0xFFD7CCC8),
          borderRadius: BorderRadius.all(Radius.elliptical(size * 1.25, size * 0.6)),
          border: Border.all(color: const Color(0xFF8D6E63), width: 2),
        ),
      );
    } else if (lvl == 2) {
      // Level 2: Thảm lông mềm hình chân mèo / gấu con màu hồng pastel
      return Container(
        width: size * 1.5,
        height: size * 0.75,
        decoration: BoxDecoration(
          color: const Color(0xFFFF8A80),
          borderRadius: BorderRadius.all(Radius.elliptical(size * 1.5, size * 0.75)),
          border: Border.all(color: Colors.white, width: 2.8),
          boxShadow: const [BoxShadow(color: Colors.black12, offset: Offset(0, 3))],
        ),
        child: const Center(child: Text('🐾', style: TextStyle(fontSize: 20))),
      );
    } else {
      // Level 3: Thảm cảm ứng nano dệt sợi quang học phát sáng hoa văn ngân hà
      return Container(
        width: size * 1.65,
        height: size * 0.8,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.all(Radius.elliptical(size * 1.65, size * 0.8)),
          border: Border.all(color: const Color(0xFF00E5FF), width: 3),
          boxShadow: const [BoxShadow(color: Color(0xFF00E5FF), blurRadius: 10)],
        ),
        child: const Center(child: Text('🌌 NANO CLEAN 4.0 🌌', style: TextStyle(fontSize: 9, color: Color(0xFF00E5FF), fontWeight: FontWeight.w900))),
      );
    }
  }

  // ===========================================================================
  // 12. GIƯỜNG NGỦ (bed_bed)
  // ===========================================================================
  Widget _buildBed(int lvl) {
    if (lvl == 1) {
      // Level 1: Giường đơn gỗ tự nhiên có thanh chắn song gỗ
      return SizedBox(
        width: size * 1.25,
        height: size * 0.95,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFD7CCC8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF6D4C41), width: 2.5),
          ),
          child: const Center(child: Text('🛏️ GIƯỜNG ĐƠN GỖ', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFF4E342E)))),
        ),
      );
    } else if (lvl == 2) {
      // Level 2: Giường tầng lâu đài phiêu lưu có cầu thang hộp an toàn
      return SizedBox(
        width: size * 1.45,
        height: size * 1.2,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF90CAF9),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF1565C0), width: 2.8),
            boxShadow: const [BoxShadow(color: Color(0xFF0D47A1), offset: Offset(0, 4))],
          ),
          child: const Center(child: Text('🏰 GIƯỜNG LÂU ĐÀI 🏰', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white))),
        ),
      );
    } else {
      // Level 3: Giường phi thuyền vũ trụ Smart Capsule: vòm trần ngàn vì sao, nệm điều chỉnh AI
      return SizedBox(
        width: size * 1.6,
        height: size * 1.3,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A237E),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF00E5FF), width: 3.5),
            boxShadow: const [
              BoxShadow(color: Color(0xFF00E5FF), blurRadius: 10),
              BoxShadow(color: Colors.black45, offset: Offset(0, 5)),
            ],
          ),
          child: const Center(child: Text('🚀 SPACE CAPSULE 4.0 🚀', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Color(0xFF00E5FF)))),
        ),
      );
    }
  }

  // ===========================================================================
  // 13. BÀN HỌC (bed_desk)
  // ===========================================================================
  Widget _buildDesk(int lvl) {
    if (lvl == 1) {
      // Level 1: Bàn ghế gỗ học sinh truyền thống mộc mạc
      return SizedBox(
        width: size * 1.0,
        height: size * 0.85,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFBCAAA4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF5D4037), width: 2.2),
          ),
          child: const Center(child: Text('📖 BÀN GỖ MỘC', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF3E2723)))),
        ),
      );
    } else if (lvl == 2) {
      // Level 2: Bàn học pastel chống gù chống cận
      return SizedBox(
        width: size * 1.25,
        height: size * 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF80CBC4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF00695C), width: 2.8),
            boxShadow: const [BoxShadow(color: Color(0xFF004D40), offset: Offset(0, 4))],
          ),
          child: const Center(child: Text('📚 CHỐNG GÙ CHỐNG CẬN', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white))),
        ),
      );
    } else {
      // Level 3: Trạm học tập thông minh Smart AI Desk: màn hình kép, robot trợ lý
      return SizedBox(
        width: size * 1.4,
        height: size * 1.15,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF263238),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF00E5FF), width: 3.2),
            boxShadow: const [
              BoxShadow(color: Color(0xFF00E5FF), blurRadius: 8),
              BoxShadow(color: Colors.black45, offset: Offset(0, 5)),
            ],
          ),
          child: const Center(child: Text('🤖 SMART AI DESK 4.0 🤖', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF00E5FF)))),
        ),
      );
    }
  }

  // ===========================================================================
  // 14. TỦ QUẦN ÁO (bed_wardrobe)
  // ===========================================================================
  Widget _buildWardrobe(int lvl) {
    if (lvl == 1) {
      // Level 1: Tủ vải kéo khóa khung nhôm nhẹ nhàng
      return SizedBox(
        width: size * 0.85,
        height: size * 1.25,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFA5D6A7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2E7D32), width: 2.2),
          ),
          child: const Center(child: Text('🧳 TỦ VẢI', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)))),
        ),
      );
    } else if (lvl == 2) {
      // Level 2: Tủ gỗ 2 cánh trượt màu pastel tươi sáng, gương soi toàn thân
      return SizedBox(
        width: size * 1.1,
        height: size * 1.45,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFCC80),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE65100), width: 2.8),
            boxShadow: const [BoxShadow(color: Color(0xFFBF360C), offset: Offset(0, 4))],
          ),
          child: const Center(child: Text('🚪 TỦ GỖ CỬA LÙA', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Color(0xFFE65100)))),
        ),
      );
    } else {
      // Level 3: Tủ quần áo Smart Wardrobe kính mờ tự động, buồng sấy khử khuẩn UV
      return SizedBox(
        width: size * 1.25,
        height: size * 1.55,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE040FB), width: 3.2),
            boxShadow: const [
              BoxShadow(color: Color(0xFFE040FB), blurRadius: 10),
              BoxShadow(color: Colors.black54, offset: Offset(0, 5)),
            ],
          ),
          child: const Center(child: Text('✨ UV SMART WARDROBE 4.0 ✨', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFFFFD54F)))),
        ),
      );
    }
  }

  // ===========================================================================
  // 15. ĐÈN NGỦ (bed_lamp)
  // ===========================================================================
  Widget _buildLamp(int lvl) {
    if (lvl == 1) {
      // Level 1: Đèn ngủ cắm tường nhỏ giọt màu vàng nhạt
      return SizedBox(
        width: size * 0.55,
        height: size * 0.75,
        child: const Center(child: Text('🕯️', style: TextStyle(fontSize: 26))),
      );
    } else if (lvl == 2) {
      // Level 2: Đèn bàn silicon hình chú thỏ cute
      return SizedBox(
        width: size * 0.7,
        height: size * 0.95,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9C4),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.amber, width: 2),
            boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.5), blurRadius: 8)],
          ),
          child: const Center(child: Text('🐰', style: TextStyle(fontSize: 26))),
        ),
      );
    } else {
      // Level 3: Quả cầu chiếu thiên hà Smart Galaxy 360 cực quang
      return SizedBox(
        width: size * 0.85,
        height: size * 1.05,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF00E5FF), width: 3),
            boxShadow: const [BoxShadow(color: Color(0xFF00E5FF), blurRadius: 12)],
          ),
          child: const Center(child: Text('🔮 GALAXY 4.0', style: TextStyle(fontSize: 9, color: Color(0xFF00E5FF), fontWeight: FontWeight.w900))),
        ),
      );
    }
  }

  Widget _buildGenericItem(int lvl) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Center(
        child: Text('Cấp $lvl', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

/// Vẽ họa tiết kẻ sọc caro giống khăn trải bàn ảnh 1 & 2
class _CheckeredPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF64B5F6).withOpacity(0.35)
      ..strokeWidth = 14;

    // Đường chéo \
    for (double i = -size.width; i < size.width * 2; i += 22) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), paint);
    }

    // Đường chéo /
    for (double i = -size.width; i < size.width * 2; i += 22) {
      canvas.drawLine(Offset(i, size.height), Offset(i + size.height, 0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
