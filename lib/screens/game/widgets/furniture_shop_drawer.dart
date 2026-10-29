import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/house_models.dart';
import 'cartoon_furniture_widgets.dart';

/// Ngăn kéo Mua sắm & Nâng cấp nội thất hoạt hình (Shop Drawer)
/// Trượt từ dưới lên y hệt ảnh mẫu 2 & 4 của người dùng!
class FurnitureShopDrawer extends StatefulWidget {
  final HouseRoomType roomType;
  final UserHouseData houseData;
  final int currentWalletPoints;
  final String? initialSelectedItemId;
  final Function(HouseItem item, int targetLevel) onUpgradeRequested;

  const FurnitureShopDrawer({
    super.key,
    required this.roomType,
    required this.houseData,
    required this.currentWalletPoints,
    this.initialSelectedItemId,
    required this.onUpgradeRequested,
  });

  @override
  State<FurnitureShopDrawer> createState() => _FurnitureShopDrawerState();
}

class _FurnitureShopDrawerState extends State<FurnitureShopDrawer> {
  late String _selectedItemId;

  @override
  void initState() {
    super.initState();
    final items = HouseCatalog.getItemsByRoom(widget.roomType);
    _selectedItemId = widget.initialSelectedItemId ?? (items.isNotEmpty ? items.first.id : '');
  }

  @override
  Widget build(BuildContext context) {
    final roomItems = HouseCatalog.getItemsByRoom(widget.roomType);
    final selectedItem = HouseCatalog.getItemById(_selectedItemId) ?? (roomItems.isNotEmpty ? roomItems.first : null);

    return Container(
      height: MediaQuery.of(context).size.height * 0.58,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFDE7), // Màu kem bơ pastel ấm áp như ảnh mẫu 2 & 4
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(color: Color(0xFFD7CCC8), width: 3),
          left: BorderSide(color: Color(0xFFD7CCC8), width: 3),
          right: BorderSide(color: Color(0xFFD7CCC8), width: 3),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black26, offset: Offset(0, -4), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 42,
            height: 5,
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFBCAAA4),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // 1. THANH CATEGORY TABS (Biểu tượng các món đồ trong phòng - Giống ảnh 2 & 4)
          Container(
            height: 52,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: roomItems.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final item = roomItems[index];
                final isSelected = item.id == _selectedItemId;
                final curLvl = widget.houseData.getItemLevel(item.id);

                return GestureDetector(
                  onTap: () => setState(() => _selectedItemId = item.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFFB74D) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFE65100) : const Color(0xFFCFD8DC),
                        width: isSelected ? 2.5 : 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected ? const Color(0xFFE65100) : Colors.black12,
                          offset: const Offset(0, 2.5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(item.baseEmoji, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 6),
                        Text(
                          item.name,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            color: isSelected ? const Color(0xFF4E2600) : AppColors.textPrimary,
                          ),
                        ),
                        if (curLvl > 0) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: curLvl == 3 ? const Color(0xFF7B1FA2) : AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              curLvl == 3 ? '4.0' : '$curLvl',
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.bold,
                                fontSize: 8.5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // 2. LƯỚI 3 CẤP ĐỘ CỦA MÓN ĐỒ ĐANG CHỌN (Cổ Điển -> Tiện Nghi -> Smart 4.0)
          if (selectedItem != null)
            Expanded(
              child: _buildItemTiersGrid(selectedItem),
            )
          else
            const Expanded(
              child: Center(child: Text('Vui lòng chọn món đồ!')),
            ),
        ],
      ),
    );
  }

  // ===========================================================================
  // LƯỚI THẺ NÂNG CẤP (Y HỆT HÀNG THẺ TRONG ẢNH MẪU 2 & 4)
  // ===========================================================================
  Widget _buildItemTiersGrid(HouseItem item) {
    final currentOwnedLevel = widget.houseData.getItemLevel(item.id);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      scrollDirection: Axis.horizontal,
      itemCount: item.levels.length,
      itemBuilder: (context, index) {
        final levelInfo = item.levels[index];
        final tierLevel = levelInfo.level;
        final isOwned = currentOwnedLevel >= tierLevel;
        final isNextToUpgrade = currentOwnedLevel == tierLevel - 1;
        final isCurrentEquipped = currentOwnedLevel == tierLevel;
        final canAfford = widget.currentWalletPoints >= levelInfo.pointsCost;

        Color cardBorderColor;
        Color cardBgColor;

        if (isCurrentEquipped) {
          cardBorderColor = const Color(0xFFFFB300);
          cardBgColor = Colors.white;
        } else if (isOwned) {
          cardBorderColor = const Color(0xFF81C784);
          cardBgColor = Colors.white;
        } else {
          cardBorderColor = const Color(0xFFCFD8DC);
          cardBgColor = Colors.white;
        }

        return Container(
          width: 210,
          margin: const EdgeInsets.only(right: 14),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: cardBorderColor, width: isCurrentEquipped ? 3 : 2),
            boxShadow: [
              BoxShadow(
                color: isCurrentEquipped ? const Color(0xFFFFB300).withOpacity(0.4) : Colors.black12,
                offset: const Offset(0, 4),
                blurRadius: 4,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header tag: Tier Badge
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                decoration: BoxDecoration(
                  color: tierLevel == 3
                      ? const Color(0xFFF3E5F5)
                      : (tierLevel == 2 ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0)),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      levelInfo.tierBadge.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w900,
                        fontSize: 10.5,
                        color: tierLevel == 3
                            ? const Color(0xFF7B1FA2)
                            : (tierLevel == 2 ? const Color(0xFF2E7D32) : const Color(0xFFE65100)),
                      ),
                    ),
                    if (tierLevel == 3)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7B1FA2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('MAX 4.0', style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),

              // Hình minh họa nội thất 2D hoạt hình đáng yêu
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CartoonFurnitureArt(
                      itemId: item.id,
                      level: tierLevel,
                      size: 90,
                    ),
                  ),
                ),
              ),

              // Tên và mô tả vật phẩm
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      levelInfo.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      levelInfo.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        fontSize: 10.5,
                        color: AppColors.textSecondary,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Nút hành động ở đáy thẻ (Sở hữu / Nâng cấp X ⭐ / Chưa mở khóa)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: _buildActionButton(
                  item: item,
                  levelInfo: levelInfo,
                  isOwned: isOwned,
                  isCurrentEquipped: isCurrentEquipped,
                  isNextToUpgrade: isNextToUpgrade,
                  canAfford: canAfford,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // NÚT HÀNH ĐỘNG
  // ===========================================================================
  Widget _buildActionButton({
    required HouseItem item,
    required HouseItemLevel levelInfo,
    required bool isOwned,
    required bool isCurrentEquipped,
    required bool isNextToUpgrade,
    required bool canAfford,
  }) {
    // 1. Đang đặt trong phòng (ảnh 2 & 4: "Sở hữu" có viền cam)
    if (isCurrentEquipped) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFFB300), width: 2),
        ),
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_rounded, color: Color(0xFFE65100), size: 14),
              SizedBox(width: 4),
              Text(
                'Đang đặt trong phòng',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  color: Color(0xFFE65100),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 2. Đã sở hữu nhưng đang chọn cấp khác
    if (isOwned) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF81C784), width: 1.8),
        ),
        child: const Center(
          child: Text(
            'Đã sở hữu',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w900,
              fontSize: 11,
              color: Color(0xFF2E7D32),
            ),
          ),
        ),
      );
    }

    // 3. Có thể mua / nâng cấp ngay (Cấp tiếp theo)
    if (isNextToUpgrade) {
      return GestureDetector(
        onTap: () => widget.onUpgradeRequested(item, levelInfo.level),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: canAfford ? AppColors.success : const Color(0xFF90A4AE),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: canAfford ? AppColors.successDark : const Color(0xFF607D8B),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: canAfford ? AppColors.successDark : const Color(0xFF455A64),
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('⭐', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 4),
              Text(
                'Sắm: ${levelInfo.pointsCost} ⭐',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 4. Khóa (Cần nâng cấp cấp trước đó trước)
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFECEFF1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCFD8DC), width: 1.5),
      ),
      child: Center(
        child: Text(
          'Mở Cấp ${levelInfo.level - 1} trước',
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w800,
            fontSize: 11,
            color: Color(0xFF90A4AE),
          ),
        ),
      ),
    );
  }
}
