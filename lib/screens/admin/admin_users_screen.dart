import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/models.dart';
import '../../services/data_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _searchCtrl = TextEditingController();
  List<Account> _accounts = [];
  List<Account> _filteredAccounts = [];
  Map<int, ChildProfile> _profileMap = {};

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final accounts = await DataService().getAccounts();
    final profiles = await DataService().getChildProfiles();
    
    final map = <int, ChildProfile>{};
    for (var p in profiles) {
      map[p.accountId] = p;
    }

    // Group & deduplicate accounts by username (case-insensitive)
    final uniqueAccounts = <String, Account>{};
    for (var acc in accounts.where((a) => a.role == Role.CUSTOMER)) {
      final key = acc.username.trim().toLowerCase();
      if (!uniqueAccounts.containsKey(key)) {
        uniqueAccounts[key] = acc;
      } else {
        // Prefer the account entry that has a linked profile
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

  void _showAdjustCoinDialog(Account acc) {
    final ctrl = TextEditingController(text: acc.coinBalance.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
          side: const BorderSide(color: AppColors.cartoonBorder, width: 3),
        ),
        title: Text(
          'ĐIỀU CHỈNH COIN (${acc.id})',
          style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Nhập số dư Coin mới cho tài khoản:',
              style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cartoonBorder, width: 2),
              ),
              child: TextField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
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
                    final newCoin = int.tryParse(ctrl.text.trim());
                    if (newCoin != null) {
                      Navigator.pop(ctx);
                      await DataService().saveAccount(acc.copyWith(coinBalance: newCoin));
                      await _loadUsers();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã cập nhật số dư Coin thành công!'), backgroundColor: AppColors.success),
                        );
                      }
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
    );
  }

  void _showMembershipDialog(Account acc) {
    MembershipType selectedType = acc.membershipType;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
            side: const BorderSide(color: AppColors.cartoonBorder, width: 3),
          ),
          title: Text(
            'ĐỔI HẠNG TÀI KHOẢN (${acc.id})',
            style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: MembershipType.values.map((type) {
              final isChosen = selectedType == type;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isChosen ? AppColors.cartoonSky.withOpacity(0.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isChosen ? AppColors.primary : AppColors.cartoonBorder.withOpacity(0.3),
                    width: isChosen ? 2 : 1,
                  ),
                ),
                child: RadioListTile<MembershipType>(
                  title: Text(
                    type.name,
                    style: TextStyle(
                      fontWeight: isChosen ? FontWeight.w900 : FontWeight.w700,
                      color: isChosen ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  value: type,
                  groupValue: selectedType,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedType = val);
                    }
                  },
                ),
              );
            }).toList(),
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
                      final messenger = ScaffoldMessenger.of(context);
                      Navigator.pop(ctx);
                      await DataService().saveAccount(acc.copyWith(membershipType: selectedType));
                      await _loadUsers();
                      if (!mounted) return;
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Đã cập nhật hạng tài khoản thành công!'), backgroundColor: AppColors.success),
                      );
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
                      'QUẢN LÝ NGƯỜI DÙNG',
                      style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar (NO ICONS)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
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
                    hintText: 'Nhập ID hoặc Tên người dùng để tìm...',
                    contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    border: InputBorder.none,
                  ),
                  onChanged: _filterUsers,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // User List
            Expanded(
              child: _filteredAccounts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🔍', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          Text(
                            'Không tìm thấy tài khoản nào',
                            style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w900, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: _filteredAccounts.length,
                      itemBuilder: (context, index) {
                        final acc = _filteredAccounts[index];
                        final primaryProfile = _profileMap[acc.id];

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
                                            primaryProfile?.name ?? acc.username,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 16,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'ID: ${acc.id} • ${acc.username}',
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: acc.membershipType == MembershipType.PREMIUM
                                            ? const Color(0xFFFFF9C4)
                                            : (acc.membershipType == MembershipType.VIP
                                                ? const Color(0xFFE1F5FE)
                                                : const Color(0xFFEEEEEE)),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: AppColors.cartoonBorder, width: 1.5),
                                      ),
                                      child: Text(
                                        acc.membershipType.name,
                                        style: TextStyle(
                                          color: acc.membershipType == MembershipType.PREMIUM
                                              ? const Color(0xFFF57F17)
                                              : (acc.membershipType == MembershipType.VIP
                                                  ? const Color(0xFF0288D1)
                                                  : const Color(0xFF616161)),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF3E0),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFFFB74D), width: 1.5),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('🪙', style: TextStyle(fontSize: 16)),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${acc.coinBalance} Coin',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFFE65100),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
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
                                      onTap: () => _showAdjustCoinDialog(acc),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFF9C4),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: AppColors.cartoonBorder, width: 1.5),
                                          boxShadow: const [
                                            BoxShadow(color: Color(0xFFFBC02D), offset: Offset(0, 2), blurRadius: 0),
                                          ],
                                        ),
                                        child: const Text(
                                          'CHỈNH COIN',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 11,
                                            color: Color(0xFFE65100),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    GestureDetector(
                                      onTap: () => _showMembershipDialog(acc),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: AppColors.cartoonBorder, width: 1.5),
                                          boxShadow: const [
                                            BoxShadow(color: AppColors.primaryDark, offset: Offset(0, 2), blurRadius: 0),
                                          ],
                                        ),
                                        child: const Text(
                                          'ĐỔI HẠNG',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 11,
                                            color: Colors.white,
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
    );
  }
}
