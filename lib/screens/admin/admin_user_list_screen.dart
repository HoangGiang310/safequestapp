import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/models.dart';
import '../../services/data_service.dart';

enum UserFilterCategory {
  all,
  vip,
  premium,
  notUsed,
}

class AdminUserListScreen extends StatefulWidget {
  final UserFilterCategory initialFilter;
  const AdminUserListScreen({
    super.key,
    this.initialFilter = UserFilterCategory.all,
  });

  @override
  State<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {
  final _searchCtrl = TextEditingController();
  List<Account> _accounts = [];
  List<Account> _filteredAccounts = [];
  Map<int, ChildProfile> _profileMap = {};
  bool _isLoading = true;
  late UserFilterCategory _selectedFilter;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
    _loadUsers();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final accounts = await DataService().getAccounts();
    final profiles = await DataService().getChildProfiles();

    final map = <int, ChildProfile>{};
    for (var p in profiles) {
      map[p.accountId] = p;
    }

    // Deduplicate accounts by username (case-insensitive)
    final uniqueAccounts = <String, Account>{};
    for (var acc in accounts.where((a) => a.role == Role.CUSTOMER)) {
      final key = acc.username.trim().toLowerCase();
      if (!uniqueAccounts.containsKey(key)) {
        uniqueAccounts[key] = acc;
      } else {
        final existing = uniqueAccounts[key]!;
        if (map[existing.id] == null && map[acc.id] != null) {
          uniqueAccounts[key] = acc;
        }
      }
    }

    if (mounted) {
      setState(() {
        _accounts = uniqueAccounts.values.toList();
        _profileMap = map;
        _isLoading = false;
        _applyFilter();
      });
    }
  }

  void _applyFilter([String? customQuery]) {
    final query = (customQuery ?? _searchCtrl.text).trim().toLowerCase();

    setState(() {
      _filteredAccounts = _accounts.where((acc) {
        final primaryProfile = _profileMap[acc.id];
        final daysUsed = primaryProfile?.studyDates.length ?? 0;

        // 1. Phân loại theo 4 mục:
        bool matchesCategory = true;
        switch (_selectedFilter) {
          case UserFilterCategory.all:
            matchesCategory = true;
            break;
          case UserFilterCategory.vip:
            matchesCategory = acc.membershipType == MembershipType.VIP;
            break;
          case UserFilterCategory.premium:
            matchesCategory = acc.membershipType == MembershipType.PREMIUM;
            break;
          case UserFilterCategory.notUsed:
            matchesCategory = daysUsed == 0;
            break;
        }

        if (!matchesCategory) return false;

        // 2. Lọc theo từ khóa tìm kiếm (ID, Tên, Gmail):
        if (query.isEmpty) return true;

        final idMatch = acc.id.toString().contains(query);
        final userMatch = acc.username.toLowerCase().contains(query);
        final profileName = primaryProfile?.name.toLowerCase() ?? '';
        final profileMatch = profileName.contains(query);

        return idMatch || userMatch || profileMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalCount = _accounts.length;
    final vipCount = _accounts.where((a) => a.membershipType == MembershipType.VIP).length;
    final premiumCount = _accounts.where((a) => a.membershipType == MembershipType.PREMIUM).length;
    final notUsedCount = _accounts.where((a) => (_profileMap[a.id]?.studyDates.length ?? 0) == 0).length;

    String statusTitle;
    Color statusBg;
    Color statusBorder;
    Color statusTextColor;
    String statusEmoji;

    switch (_selectedFilter) {
      case UserFilterCategory.all:
        statusTitle = 'Tổng số người dùng';
        statusBg = const Color(0xFFE8EAF6);
        statusBorder = const Color(0xFF9FA8DA);
        statusTextColor = const Color(0xFF283593);
        statusEmoji = '👥';
        break;
      case UserFilterCategory.vip:
        statusTitle = 'Người dùng đã nâng rank VIP';
        statusBg = const Color(0xFFE1F5FE);
        statusBorder = const Color(0xFF81D4FA);
        statusTextColor = const Color(0xFF0277BD);
        statusEmoji = '🛡️';
        break;
      case UserFilterCategory.premium:
        statusTitle = 'Người dùng đã nâng rank Premium';
        statusBg = const Color(0xFFFFF8E1);
        statusBorder = const Color(0xFFFFE082);
        statusTextColor = const Color(0xFFE65100);
        statusEmoji = '👑';
        break;
      case UserFilterCategory.notUsed:
        statusTitle = 'Người chưa dùng app (ngày sử dụng = 0)';
        statusBg = const Color(0xFFFFEBEE);
        statusBorder = const Color(0xFFEF9A9A);
        statusTextColor = const Color(0xFFC62828);
        statusEmoji = '⏳';
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
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
                      'DANH SÁCH NGƯỜI DÙNG',
                      style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            // 4 Khối Phân Loại Người Dùng (2x2 Grid)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildFilterCard(
                          category: UserFilterCategory.all,
                          emoji: '👥',
                          title: 'TỔNG NGƯỜI DÙNG',
                          subtitle: 'Toàn bộ học viên',
                          count: totalCount,
                          activeColor: const Color(0xFF3F51B5),
                          activeBg: const Color(0xFFE8EAF6),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildFilterCard(
                          category: UserFilterCategory.vip,
                          emoji: '🛡️',
                          title: 'ĐÃ NÂNG VIP',
                          subtitle: 'Hạng Hiệp Sĩ',
                          count: vipCount,
                          activeColor: const Color(0xFF0288D1),
                          activeBg: const Color(0xFFE1F5FE),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFilterCard(
                          category: UserFilterCategory.premium,
                          emoji: '👑',
                          title: 'ĐÃ NÂNG PREMIUM',
                          subtitle: 'Hạng Vương Quốc',
                          count: premiumCount,
                          activeColor: const Color(0xFFFFA000),
                          activeBg: const Color(0xFFFFF8E1),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildFilterCard(
                          category: UserFilterCategory.notUsed,
                          emoji: '⏳',
                          title: 'CHƯA DÙNG APP',
                          subtitle: 'Ngày sử dụng = 0',
                          count: notUsedCount,
                          activeColor: const Color(0xFFE53935),
                          activeBg: const Color(0xFFFFEBEE),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

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
                  decoration: InputDecoration(
                    hintText: 'Nhập Tên, Gmail hoặc ID để tìm kiếm...',
                    hintStyle: const TextStyle(fontSize: 13, color: Colors.black38),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    border: InputBorder.none,
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchCtrl.clear();
                              _applyFilter('');
                            },
                          )
                        : null,
                  ),
                  onChanged: (val) => _applyFilter(val),
                ),
              ),
            ),

            // Mode note banner (Hiển thị mục đang lọc và số lượng)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: statusBorder, width: 1.5),
                ),
                child: Row(
                  children: [
                    Text(statusEmoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Đang lọc: $statusTitle (${_filteredAccounts.length} người dùng)'
                        '${_searchCtrl.text.trim().isNotEmpty ? ' • Từ khóa: "${_searchCtrl.text.trim()}"' : ''}',
                        style: TextStyle(
                          color: statusTextColor,
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

            // Users List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredAccounts.isEmpty
                      ? Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _searchCtrl.text.isNotEmpty ? '🔍' : statusEmoji,
                                  style: const TextStyle(fontSize: 48),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _searchCtrl.text.isNotEmpty
                                      ? 'Không tìm thấy người dùng phù hợp'
                                      : 'Không có tài khoản nào trong mục này',
                                  style: AppTextStyles.h2.copyWith(color: AppColors.textSecondary, fontSize: 15),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Chạm vào các ô phía trên để đổi bộ lọc khác',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadUsers,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                            itemCount: _filteredAccounts.length,
                            itemBuilder: (context, index) {
                              final acc = _filteredAccounts[index];
                              final primaryProfile = _profileMap[acc.id];
                              final displayName = primaryProfile?.name.isNotEmpty == true 
                                  ? primaryProfile!.name 
                                  : acc.username;
                              final daysUsed = primaryProfile?.studyDates.length ?? 0;

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
                                      // Top Header: Avatar + Name + Gmail + Rank
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 52,
                                            height: 52,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFF9C4),
                                              shape: BoxShape.circle,
                                              border: Border.all(color: AppColors.cartoonBorder, width: 2),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              primaryProfile?.avatar ?? '👦',
                                              style: const TextStyle(fontSize: 26),
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  displayName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 16,
                                                    color: AppColors.textPrimary,
                                                  ),
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  'Gmail: ${acc.username}',
                                                  style: const TextStyle(
                                                    color: AppColors.textSecondary,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  'ID: ${acc.id}',
                                                  style: const TextStyle(
                                                    color: Color(0xFF757575),
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Rank Badge
                                          _buildRankBadge(acc.membershipType),
                                        ],
                                      ),

                                      const SizedBox(height: 14),
                                      const Divider(height: 1, thickness: 1.5, color: Color(0xFFEEEEEE)),
                                      const SizedBox(height: 14),

                                      // 4 Stats Pods in Grid
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildInfoItem(
                                              label: 'SỐ COIN HIỆN CÓ',
                                              value: '${acc.coinBalance}',
                                              emoji: '🪙',
                                              bgColor: const Color(0xFFFFF8E1),
                                              textColor: const Color(0xFFE65100),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: _buildInfoItem(
                                              label: 'NGÀY ĐÃ SỬ DỤNG',
                                              value: daysUsed == 0 ? '0 ngày (Chưa dùng)' : '$daysUsed ngày',
                                              emoji: daysUsed == 0 ? '⏳' : '📅',
                                              bgColor: daysUsed == 0 ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
                                              textColor: daysUsed == 0 ? const Color(0xFFC62828) : const Color(0xFF2E7D32),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildInfoItem(
                                              label: 'ĐIỂM TÍCH LŨY',
                                              value: '${primaryProfile?.points ?? 0} đ',
                                              emoji: '⭐',
                                              bgColor: const Color(0xFFFFFDE7),
                                              textColor: const Color(0xFFF57F17),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: _buildInfoItem(
                                              label: 'CHUỖI HỌC (STREAK)',
                                              value: '${primaryProfile?.streak ?? 0} ngày',
                                              emoji: '🔥',
                                              bgColor: const Color(0xFFFFEBEE),
                                              textColor: const Color(0xFFC62828),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterCard({
    required UserFilterCategory category,
    required String emoji,
    required String title,
    required String subtitle,
    required int count,
    required Color activeColor,
    required Color activeBg,
  }) {
    final isSelected = _selectedFilter == category;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = category;
        });
        _applyFilter();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.cartoonBorder,
            width: isSelected ? 2.5 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? activeColor.withOpacity(0.45) : AppColors.cartoonBorder,
              offset: isSelected ? const Offset(0, 3.5) : const Offset(0, 2.5),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? activeColor : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? activeColor : AppColors.cartoonBorder,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: isSelected ? activeColor : AppColors.textPrimary,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                color: isSelected ? activeColor.withOpacity(0.9) : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankBadge(MembershipType type) {
    Color bg;
    Color border;
    Color textColor;

    switch (type) {
      case MembershipType.PREMIUM:
        bg = const Color(0xFFF3E5F5);
        border = const Color(0xFFAB47BC);
        textColor = const Color(0xFF7B1FA2);
        break;
      case MembershipType.VIP:
        bg = const Color(0xFFE1F5FE);
        border = const Color(0xFF03A9F4);
        textColor = const Color(0xFF0277BD);
        break;
      case MembershipType.FREE:
      default:
        bg = const Color(0xFFF5F5F5);
        border = const Color(0xFFBDBDBD);
        textColor = const Color(0xFF616161);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 2),
      ),
      child: Text(
        type.name,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w900,
          fontSize: 11,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required String label,
    required String value,
    required String emoji,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cartoonBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
