import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/models.dart';
import '../../services/data_service.dart';

class AdminUserListScreen extends StatefulWidget {
  const AdminUserListScreen({super.key});

  @override
  State<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {
  final _searchCtrl = TextEditingController();
  List<Account> _accounts = [];
  List<Account> _filteredAccounts = [];
  Map<int, ChildProfile> _profileMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
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
        _filterUsers(_searchCtrl.text);
      });
    }
  }

  void _filterUsers(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _filteredAccounts = _accounts;
      });
      return;
    }

    final lower = query.toLowerCase();
    setState(() {
      _filteredAccounts = _accounts.where((acc) {
        final idMatch = acc.id.toString().contains(query);
        final userMatch = acc.username.toLowerCase().contains(lower);
        final profileName = _profileMap[acc.id]?.name.toLowerCase() ?? '';
        final profileMatch = profileName.contains(lower);
        return idMatch || userMatch || profileMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar (NO ICONS)
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
                      'DANH SÁCH NGƯỜI DÙNG',
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
                    hintText: 'Nhập Tên, Gmail hoặc ID để tìm kiếm...',
                    hintStyle: TextStyle(fontSize: 13, color: Colors.black38),
                    contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    border: InputBorder.none,
                  ),
                  onChanged: _filterUsers,
                ),
              ),
            ),

            // Mode note banner (Read-only notice)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E5F5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFCE93D8), width: 1.5),
                ),
                child: Row(
                  children: [
                    const Text('📋 ', style: TextStyle(fontSize: 14)),
                    Expanded(
                      child: Text(
                        'Tổng số: ${_accounts.length} người dùng • Chế độ xem toàn bộ thông tin (Chỉ xem)',
                        style: const TextStyle(
                          color: Color(0xFF6A1B9A),
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🔍', style: TextStyle(fontSize: 48)),
                              const SizedBox(height: 12),
                              Text(
                                'Không tìm thấy người dùng phù hợp',
                                style: AppTextStyles.h2.copyWith(color: AppColors.textSecondary, fontSize: 16),
                              ),
                            ],
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
                                              value: '$daysUsed ngày',
                                              emoji: '📅',
                                              bgColor: const Color(0xFFE8F5E9),
                                              textColor: const Color(0xFF2E7D32),
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
                    fontSize: 13,
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
