import 'dart:convert';
import 'package:flutter/material.dart';

/// 4 Phòng cơ bản của ngôi nhà SafeQuest
enum HouseRoomType {
  livingRoom,
  kitchen,
  bathroom,
  bedroom;

  String get displayName {
    switch (this) {
      case HouseRoomType.livingRoom:
        return 'Phòng Khách';
      case HouseRoomType.kitchen:
        return 'Phòng Bếp';
      case HouseRoomType.bathroom:
        return 'Nhà Tắm / WC';
      case HouseRoomType.bedroom:
        return 'Phòng Ngủ';
    }
  }

  String get emoji {
    switch (this) {
      case HouseRoomType.livingRoom:
        return '🛋️';
      case HouseRoomType.kitchen:
        return '🍳';
      case HouseRoomType.bathroom:
        return '🛁';
      case HouseRoomType.bedroom:
        return '🛏️';
    }
  }

  String get subtitle {
    switch (this) {
      case HouseRoomType.livingRoom:
        return 'Lối vào & Tiếp khách an toàn';
      case HouseRoomType.kitchen:
        return 'Nấu nướng ấm cúng, chống cháy bỏng';
      case HouseRoomType.bathroom:
        return 'Khô ráo, chống trơn trượt & nước nóng';
      case HouseRoomType.bedroom:
        return 'Góc học tập & giấc ngủ thông minh';
    }
  }

  Color get cardBgColor {
    switch (this) {
      case HouseRoomType.livingRoom:
        return const Color(0xFFE8EAF6);
      case HouseRoomType.kitchen:
        return const Color(0xFFFFF3E0);
      case HouseRoomType.bathroom:
        return const Color(0xFFE0F7FA);
      case HouseRoomType.bedroom:
        return const Color(0xFFF3E5F5);
    }
  }

  Color get accentColor {
    switch (this) {
      case HouseRoomType.livingRoom:
        return const Color(0xFF3F51B5);
      case HouseRoomType.kitchen:
        return const Color(0xFFE65100);
      case HouseRoomType.bathroom:
        return const Color(0xFF00838F);
      case HouseRoomType.bedroom:
        return const Color(0xFF7B1FA2);
    }
  }
}

/// Một cấp độ nâng cấp cụ thể của vật phẩm
class HouseItemLevel {
  final int level; // 1, 2, 3
  final String title;
  final String description;
  final int pointsCost;
  final String emoji;
  final String tierBadge; // "Cổ Điển", "Tiện Nghi", "Smart 4.0"

  const HouseItemLevel({
    required this.level,
    required this.title,
    required this.description,
    required this.pointsCost,
    required this.emoji,
    required this.tierBadge,
  });
}

/// Định nghĩa một vật phẩm trong căn nhà
class HouseItem {
  final String id;
  final HouseRoomType roomType;
  final String name;
  final String baseEmoji;
  final List<HouseItemLevel> levels;

  const HouseItem({
    required this.id,
    required this.roomType,
    required this.name,
    required this.baseEmoji,
    required this.levels,
  });

  HouseItemLevel? getLevel(int level) {
    if (level < 1 || level > levels.length) return null;
    return levels[level - 1];
  }

  HouseItemLevel? getNextLevel(int currentLevel) {
    if (currentLevel >= levels.length) return null;
    return levels[currentLevel];
  }

  int getNextCost(int currentLevel) {
    final next = getNextLevel(currentLevel);
    return next?.pointsCost ?? 0;
  }
}

/// Danh mục chuẩn 15 món đồ cho 4 phòng theo đúng quy định
class HouseCatalog {
  static const List<HouseItem> allItems = [
    // ----------------------------------------------------
    // 🛋️ PHÒNG KHÁCH (4 món)
    // ----------------------------------------------------
    HouseItem(
      id: 'living_door',
      roomType: HouseRoomType.livingRoom,
      name: 'Cánh Cửa Chính',
      baseEmoji: '🚪',
      levels: [
        HouseItemLevel(
          level: 1,
          title: 'Cửa Gỗ Then Cài',
          description: 'Cửa gỗ truyền thống, chốt then cài chắc chắn',
          pointsCost: 25,
          emoji: '🚪',
          tierBadge: 'Cổ Điển',
        ),
        HouseItemLevel(
          level: 2,
          title: 'Cửa Thép Khóa Chìa',
          description: 'Cửa thép kiên cố, mắt thần nhìn người lạ bên ngoài',
          pointsCost: 65,
          emoji: '🛡️',
          tierBadge: 'Tiện Nghi',
        ),
        HouseItemLevel(
          level: 3,
          title: 'Cửa Smart Door FaceID',
          description: 'Khóa thông minh nhận diện khuôn mặt & cảnh báo AI',
          pointsCost: 180,
          emoji: '🤖',
          tierBadge: 'Smart 4.0',
        ),
      ],
    ),
    HouseItem(
      id: 'living_sofa',
      roomType: HouseRoomType.livingRoom,
      name: 'Bàn Ghế Tiếp Khách',
      baseEmoji: '🛋️',
      levels: [
        HouseItemLevel(
          level: 1,
          title: 'Ghế Gỗ Mộc',
          description: 'Ghế nan gỗ mộc mạc, bền bỉ và giản dị',
          pointsCost: 20,
          emoji: '🪑',
          tierBadge: 'Cổ Điển',
        ),
        HouseItemLevel(
          level: 2,
          title: 'Sofa Bo Góc Chống Va Đập',
          description: 'Nệm êm ái, cạnh bàn được bọc cao su chống cộc đầu',
          pointsCost: 55,
          emoji: '🛋️',
          tierBadge: 'Tiện Nghi',
        ),
        HouseItemLevel(
          level: 3,
          title: 'Sofa Massage Thông Minh',
          description: 'Tích hợp đệm sưởi massage, điều khiển bằng giọng nói',
          pointsCost: 150,
          emoji: '✨',
          tierBadge: 'Smart 4.0',
        ),
      ],
    ),
    HouseItem(
      id: 'living_tv',
      roomType: HouseRoomType.livingRoom,
      name: 'Tivi & Giải Trí',
      baseEmoji: '📺',
      levels: [
        HouseItemLevel(
          level: 1,
          title: 'Tivi Hộp Cổ Điển',
          description: 'Tivi CRT truyền thống gắn bệ cố định chống đổ ngã',
          pointsCost: 30,
          emoji: '📺',
          tierBadge: 'Cổ Điển',
        ),
        HouseItemLevel(
          level: 2,
          title: 'Smart TV Siêu Mỏng',
          description: 'Màn hình LED chống mỏi mắt, trình chiếu phim an toàn',
          pointsCost: 75,
          emoji: '🖥️',
          tierBadge: 'Tiện Nghi',
        ),
        HouseItemLevel(
          level: 3,
          title: 'Laser Cinema 4K Smart',
          description: 'Rạp chiếu laser tại gia điều khiển trợ lý ảo AI',
          pointsCost: 200,
          emoji: '🎬',
          tierBadge: 'Smart 4.0',
        ),
      ],
    ),
    HouseItem(
      id: 'living_rug',
      roomType: HouseRoomType.livingRoom,
      name: 'Thảm Phòng Khách',
      baseEmoji: '🧶',
      levels: [
        HouseItemLevel(
          level: 1,
          title: 'Thảm Nỉ Đơn Màu',
          description: 'Thảm nỉ mộc giữ ấm nền gạch lạnh cho đôi chân',
          pointsCost: 15,
          emoji: '🧶',
          tierBadge: 'Cổ Điển',
        ),
        HouseItemLevel(
          level: 2,
          title: 'Thảm Cao Su Chống Trượt',
          description: 'Đế gai bám sàn chống trượt ngã khi bé chạy nhảy',
          pointsCost: 45,
          emoji: '🛡️',
          tierBadge: 'Tiện Nghi',
        ),
        HouseItemLevel(
          level: 3,
          title: 'Thảm Cảm Ứng Tự Làm Sạch',
          description: 'Vải dệt kháng khuẩn nano tự động hút bụi bề mặt',
          pointsCost: 120,
          emoji: '🌀',
          tierBadge: 'Smart 4.0',
        ),
      ],
    ),

    // ----------------------------------------------------
    // 🍳 PHÒNG BẾP (3 món)
    // ----------------------------------------------------
    HouseItem(
      id: 'kitchen_stove',
      roomType: HouseRoomType.kitchen,
      name: 'Bếp Nấu Ăn',
      baseEmoji: '🍳',
      levels: [
        HouseItemLevel(
          level: 1,
          title: 'Bếp Gas Đơn Khóa Van',
          description: 'Bếp gas đơn có van khóa an toàn chống rò rỉ khí',
          pointsCost: 25,
          emoji: '🫕',
          tierBadge: 'Cổ Điển',
        ),
        HouseItemLevel(
          level: 2,
          title: 'Bếp Từ Chống Bỏng',
          description: 'Mặt kính luôn mát, tự ngắt nguồn khi nước sôi trào',
          pointsCost: 70,
          emoji: '🍳',
          tierBadge: 'Tiện Nghi',
        ),
        HouseItemLevel(
          level: 3,
          title: 'Bếp Điện Quang Smart AI',
          description: 'Hệ thống cảm biến chống cháy nổ & tự dập lửa tự động',
          pointsCost: 190,
          emoji: '🔥',
          tierBadge: 'Smart 4.0',
        ),
      ],
    ),
    HouseItem(
      id: 'kitchen_fridge',
      roomType: HouseRoomType.kitchen,
      name: 'Tủ Lạnh Gia Đình',
      baseEmoji: '❄️',
      levels: [
        HouseItemLevel(
          level: 1,
          title: 'Tủ Lạnh Mini Cổ Điển',
          description: 'Tủ 1 cánh nhỏ gọn có chốt cài an toàn trẻ em',
          pointsCost: 30,
          emoji: '🧊',
          tierBadge: 'Cổ Điển',
        ),
        HouseItemLevel(
          level: 2,
          title: 'Tủ Lạnh Inverter 2 Cánh',
          description: 'Ngăn đông mềm tiện lợi, công nghệ Ag+ kháng khuẩn',
          pointsCost: 80,
          emoji: '❄️',
          tierBadge: 'Tiện Nghi',
        ),
        HouseItemLevel(
          level: 3,
          title: 'Tủ Lạnh Smart Hub AI',
          description: 'Màn hình cảm ứng quản lý hạn sử dụng & dinh dưỡng',
          pointsCost: 220,
          emoji: '📱',
          tierBadge: 'Smart 4.0',
        ),
      ],
    ),
    HouseItem(
      id: 'kitchen_table',
      roomType: HouseRoomType.kitchen,
      name: 'Bàn Ăn Gia Đình',
      baseEmoji: '🍽️',
      levels: [
        HouseItemLevel(
          level: 1,
          title: 'Bàn Ăn Gỗ Tròn',
          description: 'Bàn ăn nhỏ gọn bằng gỗ bo tròn cạnh an toàn',
          pointsCost: 20,
          emoji: '🍽️',
          tierBadge: 'Cổ Điển',
        ),
        HouseItemLevel(
          level: 2,
          title: 'Bàn Ăn Kính Cường Lực',
          description: 'Mặt kính chịu lực chống trầy, 4 ghế bọc đệm êm ái',
          pointsCost: 50,
          emoji: '🥗',
          tierBadge: 'Tiện Nghi',
        ),
        HouseItemLevel(
          level: 3,
          title: 'Bàn Ăn Giữ Nhiệt Tự Động',
          description: 'Bếp từ âm bàn giữ nóng thức ăn, mặt đá tự kháng khuẩn',
          pointsCost: 140,
          emoji: '🍲',
          tierBadge: 'Smart 4.0',
        ),
      ],
    ),

    // ----------------------------------------------------
    // 🛁 NHÀ TẮM / WC (4 món)
    // ----------------------------------------------------
    HouseItem(
      id: 'bath_toilet',
      roomType: HouseRoomType.bathroom,
      name: 'Bồn Cầu Vệ Sinh',
      baseEmoji: '🚽',
      levels: [
        HouseItemLevel(
          level: 1,
          title: 'Bồn Cầu Gạt Nước',
          description: 'Bồn cầu truyền thống có nắp đậy êm chống kẹt tay bé',
          pointsCost: 25,
          emoji: '🚽',
          tierBadge: 'Cổ Điển',
        ),
        HouseItemLevel(
          level: 2,
          title: 'Bồn Cầu Men Nano Kháng Khuẩn',
          description: 'Bề mặt chống bám bẩn, xả xoáy êm ái tiết kiệm nước',
          pointsCost: 65,
          emoji: '🧽',
          tierBadge: 'Tiện Nghi',
        ),
        HouseItemLevel(
          level: 3,
          title: 'Smart Toilet Tự Động',
          description: 'Tự động mở nắp, sưởi ấm bệ ngồi và xịt rửa cảm biến',
          pointsCost: 180,
          emoji: '🌟',
          tierBadge: 'Smart 4.0',
        ),
      ],
    ),
    HouseItem(
      id: 'bath_sink',
      roomType: HouseRoomType.bathroom,
      name: 'Bồn Rửa Mặt Lavabo',
      baseEmoji: '🚰',
      levels: [
        HouseItemLevel(
          level: 1,
          title: 'Chậu Treo Tường',
          description: 'Chậu rửa bằng sứ truyền thống có vòi bo góc an toàn',
          pointsCost: 20,
          emoji: '🚰',
          tierBadge: 'Cổ Điển',
        ),
        HouseItemLevel(
          level: 2,
          title: 'Lavabo Tủ Chống Ẩm',
          description: 'Tủ gương chứa đồ khô ráo, vòi nước chống trào ngược',
          pointsCost: 55,
          emoji: '🧼',
          tierBadge: 'Tiện Nghi',
        ),
        HouseItemLevel(
          level: 3,
          title: 'Lavabo Khử Khuẩn UV Smart',
          description: 'Nước điện phân diệt khuẩn tự động, gương LED cảm ứng',
          pointsCost: 150,
          emoji: '💡',
          tierBadge: 'Smart 4.0',
        ),
      ],
    ),
    HouseItem(
      id: 'bath_washing',
      roomType: HouseRoomType.bathroom,
      name: 'Máy Giặt Quần Áo',
      baseEmoji: '🧺',
      levels: [
        HouseItemLevel(
          level: 1,
          title: 'Máy Giặt Cửa Trên',
          description: 'Khóa trẻ em tự động ngắt khi mở nắp lồng giặt',
          pointsCost: 35,
          emoji: '🧺',
          tierBadge: 'Cổ Điển',
        ),
        HouseItemLevel(
          level: 2,
          title: 'Máy Giặt Cửa Ngang Inverter',
          description: 'Công nghệ giặt hơi nước diệt khuẩn 99.9%, vận hành êm',
          pointsCost: 85,
          emoji: '👕',
          tierBadge: 'Tiện Nghi',
        ),
        HouseItemLevel(
          level: 3,
          title: 'Máy Giặt Sấy AI 2-in-1',
          description: 'Tự động phân bổ nước giặt & sấy khô tiệt trùng bằng AI',
          pointsCost: 240,
          emoji: '🤖',
          tierBadge: 'Smart 4.0',
        ),
      ],
    ),
    HouseItem(
      id: 'bath_tub',
      roomType: HouseRoomType.bathroom,
      name: 'Bồn Tắm Gia Đình',
      baseEmoji: '🛁',
      levels: [
        HouseItemLevel(
          level: 1,
          title: 'Chậu Tắm Nhỏ Chống Trượt',
          description: 'Chậu tắm nhựa dẻo có đế cao su chống trơn té ngã',
          pointsCost: 25,
          emoji: '🪣',
          tierBadge: 'Cổ Điển',
        ),
        HouseItemLevel(
          level: 2,
          title: 'Bồn Tắm Nằm Acrylic',
          description: 'Bồn tráng men chống ố có thanh tay vịn trợ lực an toàn',
          pointsCost: 75,
          emoji: '🛁',
          tierBadge: 'Tiện Nghi',
        ),
        HouseItemLevel(
          level: 3,
          title: 'Bồn Tắm Massage Thủy Lực',
          description: 'Cảm biến kiểm soát nhiệt độ nước an toàn chống bỏng',
          pointsCost: 210,
          emoji: '🫧',
          tierBadge: 'Smart 4.0',
        ),
      ],
    ),

    // ----------------------------------------------------
    // 🛏️ PHÒNG NGỦ (4 món)
    // ----------------------------------------------------
    HouseItem(
      id: 'bed_bed',
      roomType: HouseRoomType.bedroom,
      name: 'Giường Ngủ Của Bé',
      baseEmoji: '🛏️',
      levels: [
        HouseItemLevel(
          level: 1,
          title: 'Giường Đơn Gỗ',
          description: 'Giường gỗ có thanh chắn bên hông chống lăn ngã',
          pointsCost: 30,
          emoji: '🛏️',
          tierBadge: 'Cổ Điển',
        ),
        HouseItemLevel(
          level: 2,
          title: 'Giường Tầng Phiêu Lưu',
          description: 'Cầu thang hộp rộng rãi, bo tròn mọi góc cạnh an toàn',
          pointsCost: 80,
          emoji: '🏰',
          tierBadge: 'Tiện Nghi',
        ),
        HouseItemLevel(
          level: 3,
          title: 'Giường Công Nghệ Ergonomic',
          description: 'Tự động chỉnh góc ngả lưng thông minh và nệm massage',
          pointsCost: 230,
          emoji: '👑',
          tierBadge: 'Smart 4.0',
        ),
      ],
    ),
    HouseItem(
      id: 'bed_desk',
      roomType: HouseRoomType.bedroom,
      name: 'Bàn Ghế Học Tập',
      baseEmoji: '📚',
      levels: [
        HouseItemLevel(
          level: 1,
          title: 'Bàn Gỗ Mộc Nhỏ',
          description: 'Bàn học nhỏ gọn, 4 góc được mài tròn tránh va đập',
          pointsCost: 25,
          emoji: '📖',
          tierBadge: 'Cổ Điển',
        ),
        HouseItemLevel(
          level: 2,
          title: 'Bàn Học Chống Gù Chống Cận',
          description: 'Mặt bàn chỉnh góc nghiêng chống lóa, ghế công thái học',
          pointsCost: 70,
          emoji: '📚',
          tierBadge: 'Tiện Nghi',
        ),
        HouseItemLevel(
          level: 3,
          title: 'Trạm Học Tập Smart Desk AI',
          description: 'Đèn tự điều chỉnh ánh sáng, camera AI nhắc tư thế ngồi',
          pointsCost: 190,
          emoji: '🚀',
          tierBadge: 'Smart 4.0',
        ),
      ],
    ),
    HouseItem(
      id: 'bed_wardrobe',
      roomType: HouseRoomType.bedroom,
      name: 'Tủ Quần Áo',
      baseEmoji: '🚪',
      levels: [
        HouseItemLevel(
          level: 1,
          title: 'Tủ Vải Khung Nhôm',
          description: 'Tủ vải kéo khóa tiện lợi, nhẹ nhàng an toàn cho phòng bé',
          pointsCost: 15,
          emoji: '🧳',
          tierBadge: 'Cổ Điển',
        ),
        HouseItemLevel(
          level: 2,
          title: 'Tủ Gỗ Cửa Lùa',
          description: 'Cửa trượt chống kẹp ngón tay, tủ gắn cố định vào tường',
          pointsCost: 50,
          emoji: '🚪',
          tierBadge: 'Tiện Nghi',
        ),
        HouseItemLevel(
          level: 3,
          title: 'Tủ Quần Áo Khử Trùng Hơi Nước',
          description: 'Khử khuẩn bằng tia UV, đèn LED tự bật khi mở cửa',
          pointsCost: 140,
          emoji: '✨',
          tierBadge: 'Smart 4.0',
        ),
      ],
    ),
    HouseItem(
      id: 'bed_lamp',
      roomType: HouseRoomType.bedroom,
      name: 'Đèn Ngủ & Chiếu Sáng',
      baseEmoji: '💡',
      levels: [
        HouseItemLevel(
          level: 1,
          title: 'Đèn Ngủ Cắm Tường',
          description: 'Ánh sáng vàng dịu nhẹ, tiêu thụ điện năng cực thấp',
          pointsCost: 15,
          emoji: '🕯️',
          tierBadge: 'Cổ Điển',
        ),
        HouseItemLevel(
          level: 2,
          title: 'Đèn Bàn Chống Cận Cảm Ứng',
          description: 'Điều chỉnh 3 mức sáng cảm ứng, hẹn giờ tự tắt ban đêm',
          pointsCost: 45,
          emoji: '💡',
          tierBadge: 'Tiện Nghi',
        ),
        HouseItemLevel(
          level: 3,
          title: 'Đèn AI Bầu Trời Sao',
          description: 'Chiếu bầu trời sao 3D ru ngủ, phát âm thanh thiên nhiên',
          pointsCost: 130,
          emoji: '🌌',
          tierBadge: 'Smart 4.0',
        ),
      ],
    ),
  ];

  static List<HouseItem> getItemsByRoom(HouseRoomType room) {
    return allItems.where((item) => item.roomType == room).toList();
  }

  static HouseItem? getItemById(String id) {
    try {
      return allItems.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  static int get totalItemsCount => allItems.length; // 15 món
  static int get totalMaxPossibleLevels => allItems.length * 3; // 45 cấp
}

/// Trạng thái sở hữu ngôi nhà của từng bé
class UserHouseData {
  final int accountId;
  final String childName;
  final String childAvatar;
  final Map<String, int> itemLevels; // itemId -> level (0: chưa sắm, 1: cấp 1, 2: cấp 2, 3: cấp 3)
  final bool hasOpenedGame; // Đã kích hoạt chức năng game
  final bool hasSeenWelcome; // Đã xem giao diện chào mừng lần đầu
  final DateTime? updatedAt;

  const UserHouseData({
    this.accountId = 0,
    this.childName = '',
    this.childAvatar = '🧒',
    this.itemLevels = const {},
    this.hasOpenedGame = false,
    this.hasSeenWelcome = false,
    this.updatedAt,
  });

  int getItemLevel(String itemId) {
    return itemLevels[itemId] ?? 0;
  }

  bool isItemMax(String itemId) {
    return getItemLevel(itemId) >= 3;
  }

  /// Tổng số món đã sở hữu (ít nhất level 1)
  int get ownedCount {
    return itemLevels.values.where((lvl) => lvl >= 1).length;
  }

  /// Tổng số cấp độ đã sở hữu (tối đa 15 món x 3 level = 45 món)
  int get totalLevelsAchieved {
    int total = 0;
    for (final item in HouseCatalog.allItems) {
      final lvl = itemLevels[item.id] ?? 0;
      total += lvl.clamp(0, 3);
    }
    return total;
  }

  /// Tổng số món đã nâng Max (level 3)
  int get maxCount {
    return itemLevels.values.where((lvl) => lvl >= 3).length;
  }

  /// Điểm phần trăm hoàn thiện căn nhà (0% -> 100%)
  double get overallProgress {
    int totalLevelsAchieved = 0;
    for (final item in HouseCatalog.allItems) {
      final lvl = itemLevels[item.id] ?? 0;
      totalLevelsAchieved += lvl.clamp(0, 3);
    }
    return (totalLevelsAchieved / HouseCatalog.totalMaxPossibleLevels).clamp(0.0, 1.0);
  }

  /// Phần trăm hoàn thành của riêng 1 phòng
  double getRoomProgress(HouseRoomType room) {
    final roomItems = HouseCatalog.getItemsByRoom(room);
    if (roomItems.isEmpty) return 0.0;
    int achieved = 0;
    for (final item in roomItems) {
      final lvl = itemLevels[item.id] ?? 0;
      achieved += lvl.clamp(0, 3);
    }
    return (achieved / (roomItems.length * 3)).clamp(0.0, 1.0);
  }

  /// Số điểm học tập đã tiêu hao cho một vật phẩm cụ thể
  int getItemPointsSpent(String itemId) {
    final item = HouseCatalog.getItemById(itemId);
    if (item == null) return 0;
    final lvl = getItemLevel(itemId);
    int spent = 0;
    for (int i = 0; i < lvl && i < item.levels.length; i++) {
      spent += item.levels[i].pointsCost;
    }
    return spent;
  }

  /// Số điểm học tập đã tiêu hao cho một căn phòng cụ thể
  int getRoomPointsSpent(HouseRoomType room) {
    final roomItems = HouseCatalog.getItemsByRoom(room);
    int total = 0;
    for (final item in roomItems) {
      total += getItemPointsSpent(item.id);
    }
    return total;
  }

  /// Tổng số điểm học tập tích lũy đã tiêu hao để xây dựng ngôi nhà
  int get totalPointsSpent {
    int total = 0;
    for (final item in HouseCatalog.allItems) {
      total += getItemPointsSpent(item.id);
    }
    return total;
  }

  UserHouseData copyWith({
    int? accountId,
    String? childName,
    String? childAvatar,
    Map<String, int>? itemLevels,
    bool? hasOpenedGame,
    bool? hasSeenWelcome,
    DateTime? updatedAt,
  }) {
    return UserHouseData(
      accountId: accountId ?? this.accountId,
      childName: childName ?? this.childName,
      childAvatar: childAvatar ?? this.childAvatar,
      itemLevels: itemLevels ?? this.itemLevels,
      hasOpenedGame: hasOpenedGame ?? this.hasOpenedGame,
      hasSeenWelcome: hasSeenWelcome ?? this.hasSeenWelcome,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'accountId': accountId,
      'childName': childName,
      'childAvatar': childAvatar,
      'itemLevels': itemLevels,
      'totalPointsSpent': totalPointsSpent,
      'overallProgress': overallProgress,
      'ownedCount': ownedCount,
      'maxCount': maxCount,
      'hasOpenedGame': hasOpenedGame,
      'hasSeenWelcome': hasSeenWelcome,
      'updatedAt': updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory UserHouseData.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const UserHouseData();
    final rawLevels = map['itemLevels'];
    final parsedMap = <String, int>{};
    if (rawLevels is Map) {
      rawLevels.forEach((key, value) {
        if (key is String && value is num) {
          parsedMap[key] = value.toInt();
        }
      });
    }
    return UserHouseData(
      accountId: (map['accountId'] as num?)?.toInt() ?? 0,
      childName: (map['childName'] as String?) ?? '',
      childAvatar: (map['childAvatar'] as String?) ?? '🧒',
      itemLevels: parsedMap,
      hasOpenedGame: (map['hasOpenedGame'] as bool?) ?? false,
      hasSeenWelcome: (map['hasSeenWelcome'] as bool?) ?? false,
      updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt'].toString()) : null,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory UserHouseData.fromJson(String str) {
    try {
      return UserHouseData.fromMap(jsonDecode(str));
    } catch (_) {
      return const UserHouseData();
    }
  }
}

/// Một mục trong Bảng Xếp Hạng Xây Nhà
class HouseLeaderboardEntry {
  final int accountId;
  final String childName;
  final String childAvatar;
  final int totalPointsSpent;
  final double overallProgress;
  final int ownedCount;
  final int maxCount;
  final int rank;

  const HouseLeaderboardEntry({
    required this.accountId,
    required this.childName,
    required this.childAvatar,
    required this.totalPointsSpent,
    required this.overallProgress,
    required this.ownedCount,
    required this.maxCount,
    this.rank = 0,
  });

  Map<String, dynamic> toMap() => {
    'accountId': accountId,
    'childName': childName,
    'childAvatar': childAvatar,
    'totalPointsSpent': totalPointsSpent,
    'overallProgress': overallProgress,
    'ownedCount': ownedCount,
    'maxCount': maxCount,
    'rank': rank,
  };

  factory HouseLeaderboardEntry.fromMap(Map<String, dynamic> map, {int rank = 0}) {
    int points = (map['totalPointsSpent'] as num?)?.toInt() ?? 0;
    double progress = (map['overallProgress'] as num?)?.toDouble() ?? 0.0;
    int owned = (map['ownedCount'] as num?)?.toInt() ?? 0;
    int maxed = (map['maxCount'] as num?)?.toInt() ?? 0;

    if (points == 0 && map['itemLevels'] != null) {
      final house = UserHouseData.fromMap(map);
      points = house.totalPointsSpent;
      progress = house.overallProgress;
      owned = house.ownedCount;
      maxed = house.maxCount;
    }

    return HouseLeaderboardEntry(
      accountId: (map['accountId'] as num?)?.toInt() ?? 0,
      childName: (map['childName'] as String?) ?? 'Bé Thám Hiểm',
      childAvatar: (map['childAvatar'] as String?) ?? '🧒',
      totalPointsSpent: points,
      overallProgress: progress,
      ownedCount: owned,
      maxCount: maxed,
      rank: rank,
    );
  }
}
