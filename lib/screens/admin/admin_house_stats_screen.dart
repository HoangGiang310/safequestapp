import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/models.dart';
import '../../services/data_service.dart';

/// Lớp đóng gói dữ liệu người chơi đã mở game xây nhà phục vụ Admin
class AdminHousePlayer {
  final Account account;
  final ChildProfile? profile;
  final UserHouseData house;

  AdminHousePlayer({
    required this.account,
    this.profile,
    required this.house,
  });

  int get id => account.id;
  String get email => account.username;

  String get name {
    if (profile != null && profile!.name.trim().isNotEmpty) {
      return profile!.name.trim();
    }
    if (house.childName.trim().isNotEmpty) {
      return house.childName.trim();
    }
    return 'Học viên #${account.id}';
  }

  String get avatar {
    if (profile != null && profile!.avatar.trim().isNotEmpty) {
      return profile!.avatar.trim();
    }
    if (house.childAvatar.trim().isNotEmpty) {
      return house.childAvatar.trim();
    }
    return '🧒';
  }

  int get totalPointsSpent => house.totalPointsSpent;
  double get overallProgress => house.overallProgress;
  int get ownedCount => house.ownedCount;
  int get maxCount => house.maxCount;
}

class AdminHouseStatsScreen extends StatefulWidget {
  const AdminHouseStatsScreen({super.key});

  @override
  State<AdminHouseStatsScreen> createState() => _AdminHouseStatsScreenState();
}

class _AdminHouseStatsScreenState extends State<AdminHouseStatsScreen> with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  late TabController _tabController;

  List<AdminHousePlayer> _players = [];
  List<AdminHousePlayer> _filteredPlayers = [];
  List<AdminHousePlayer> _leaderboard = [];

  bool _isLoading = true;
  int _totalPointsAcrossServer = 0;
  double _avgProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHouseStats();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHouseStats() async {
    setState(() => _isLoading = true);

    try {
      final accounts = await DataService().getAccounts();
      final profiles = await DataService().getChildProfiles();
      final houses = await DataService().getAllUserHouses();

      final profileMap = <int, ChildProfile>{};
      for (final p in profiles) {
        profileMap[p.accountId] = p;
      }

      final accountMap = <int, Account>{};
      for (final a in accounts) {
        accountMap[a.id] = a;
      }

      // Tạo danh sách người chơi đã mở game
      final Map<int, AdminHousePlayer> playerMap = {};

      for (final house in houses) {
        if (!house.hasOpenedGame) continue;

        final acc = accountMap[house.accountId] ??
            Account(
              id: house.accountId,
              username: 'user_${house.accountId}@safequest.com',
              password: '',
              role: Role.CUSTOMER,
              createdAt: DateTime.now(),
            );

        final prof = profileMap[house.accountId];

        playerMap[house.accountId] = AdminHousePlayer(
          account: acc,
          profile: prof,
          house: house,
        );
      }

      // Bổ sung những account trong SharedPreferences chưa được sync vào houses nếu có
      for (final acc in accounts) {
        if (!playerMap.containsKey(acc.id)) {
          final house = await DataService().getHouseData(acc.id);
          if (house.hasOpenedGame) {
            playerMap[acc.id] = AdminHousePlayer(
              account: acc,
              profile: profileMap[acc.id],
              house: house,
            );
          }
        }
      }

      final playerList = playerMap.values.toList();

      // Sắp xếp danh sách mặc định theo ID mới nhất hoặc điểm tiêu hao
      playerList.sort((a, b) => b.totalPointsSpent.compareTo(a.totalPointsSpent));

      // Bảng xếp hạng: điểm tiêu hao cao nhất trước
      final leaderboardList = List<AdminHousePlayer>.from(playerList);
      leaderboardList.sort((a, b) {
        final cmp = b.totalPointsSpent.compareTo(a.totalPointsSpent);
        if (cmp != 0) return cmp;
        return b.overallProgress.compareTo(a.overallProgress);
      });

      int totalPoints = 0;
      double sumProgress = 0;
      for (final p in playerList) {
        totalPoints += p.totalPointsSpent;
        sumProgress += p.overallProgress;
      }

      final avgProg = playerList.isNotEmpty ? (sumProgress / playerList.length) : 0.0;

      if (mounted) {
        setState(() {
          _players = playerList;
          _leaderboard = leaderboardList;
          _totalPointsAcrossServer = totalPoints;
          _avgProgress = avgProg;
          _isLoading = false;
          _applyFilter();
        });
      }
    } catch (e) {
      debugPrint('Error loading house stats: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyFilter([String? customQuery]) {
    final query = (customQuery ?? _searchCtrl.text).trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredPlayers = List.from(_players);
      } else {
        _filteredPlayers = _players.where((player) {
          final nameMatch = player.name.toLowerCase().contains(query);
          final emailMatch = player.email.toLowerCase().contains(query);
          final idMatch = player.id.toString().contains(query);
          return nameMatch || emailMatch || idMatch;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildTopAppBar(),

            // Overview Metric Pods
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: _buildOverviewMetrics(),
            ),

            // Tab bar selector
            _buildTabSelector(),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildPlayerListTab(),
                        _buildLeaderboardTab(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
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
              child: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
            ),
          ),

          // Title badge
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE65100), width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFFBF360C),
                    offset: Offset(0, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🏡 ', style: TextStyle(fontSize: 16)),
                    Text(
                      'THỐNG KÊ GAME NGÔI NHÀ',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFBF360C),
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Refresh button
          GestureDetector(
            onTap: _loadHouseStats,
            child: Container(
              padding: const EdgeInsets.all(10),
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
              child: const Icon(Icons.refresh, color: AppColors.textPrimary, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewMetrics() {
    return Row(
      children: [
        // Metric 1: Số người chơi
        Expanded(
          child: _buildMetricCard(
            title: 'NGƯỜI CHƠI',
            value: '${_players.length}',
            unit: 'học viên',
            bgColor: const Color(0xFFE8EAF6),
            borderColor: const Color(0xFF3F51B5),
            textColor: const Color(0xFF283593),
            emoji: '🎮',
          ),
        ),
        const SizedBox(width: 8),

        // Metric 2: Tổng điểm tiêu hao
        Expanded(
          child: _buildMetricCard(
            title: 'TIÊU ĐIỂM',
            value: '$_totalPointsAcrossServer',
            unit: '💎 học tập',
            bgColor: const Color(0xFFFFF8E1),
            borderColor: const Color(0xFFFFA000),
            textColor: const Color(0xFFFF6F00),
            emoji: '💎',
          ),
        ),
        const SizedBox(width: 8),

        // Metric 3: Hoàn thiện TB
        Expanded(
          child: _buildMetricCard(
            title: 'TIẾN ĐỘ TB',
            value: '${(_avgProgress * 100).toInt()}%',
            unit: 'căn nhà',
            bgColor: const Color(0xFFE8F5E9),
            borderColor: const Color(0xFF43A047),
            textColor: const Color(0xFF2E7D32),
            emoji: '🏠',
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String unit,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
    required String emoji,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.4),
            offset: const Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: textColor.withOpacity(0.85),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: textColor.withOpacity(0.75),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cartoonBorder, width: 2),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cartoonBorder,
              offset: Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cartoonBorder, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFC0392B),
                offset: Offset(0, 2),
                blurRadius: 0,
              ),
            ],
          ),
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
          tabs: const [
            Tab(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('👥 '),
                    Text('NGƯỜI CHƠI'),
                  ],
                ),
              ),
            ),
            Tab(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🏆 '),
                    Text('BẢNG XẾP HẠNG'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB 1: DANH SÁCH NGƯỜI CHƠI ---
  Widget _buildPlayerListTab() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cartoonBorder, width: 2),
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
              onChanged: _applyFilter,
              decoration: InputDecoration(
                hintText: 'Tìm theo Tên, Gmail hoặc ID...',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                prefixIcon: const Icon(Icons.search, color: AppColors.cartoonBorder),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18, color: AppColors.textSecondary),
                        onPressed: () {
                          _searchCtrl.clear();
                          _applyFilter();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),

        // List
        Expanded(
          child: _filteredPlayers.isEmpty
              ? _buildEmptyState('Chưa có học viên nào trong danh sách mở game.')
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                  itemCount: _filteredPlayers.length,
                  itemBuilder: (context, index) {
                    final player = _filteredPlayers[index];
                    return _buildPlayerCard(player);
                  },
                ),
        ),
      ],
    );
  }

  // --- TAB 2: BẢNG XẾP HẠNG TIÊU ĐIỂM ---
  Widget _buildLeaderboardTab() {
    if (_leaderboard.isEmpty) {
      return _buildEmptyState('Chưa có người chơi nào xếp hạng.');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: _leaderboard.length,
      itemBuilder: (context, index) {
        final player = _leaderboard[index];
        final rank = index + 1;
        return _buildLeaderboardCard(player, rank);
      },
    );
  }

  Widget _buildPlayerCard(AdminHousePlayer player) {
    return GestureDetector(
      onTap: () => _showHouseDetailModal(player),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cartoonBorder, width: 2),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cartoonBorder,
              offset: Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Avatar + Name + Gmail + ID + Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar Pod
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
                      player.avatar,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                player.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            _buildMembershipPill(player.account.membershipType),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '✉️ ${player.email}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '🆔 ID: #${player.id}',
                          style: const TextStyle(
                            color: Color(0xFF757575),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Arrow icon
                  const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textSecondary, size: 16),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
              const SizedBox(height: 10),

              // Row 2: Điểm tiêu hao + Tiến độ phòng
              Row(
                children: [
                  // Điểm tiêu hao
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFA000), width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('💎 ', style: TextStyle(fontSize: 13)),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${player.totalPointsSpent} điểm tiêu hao',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFE65100),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Tiến độ hoàn thiện
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF43A047), width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🏠 ', style: TextStyle(fontSize: 13)),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Xây ${(player.overallProgress * 100).toInt()}% (${player.ownedCount}/15 món)',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF2E7D32),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              // Hint to view details
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Chạm xem chi tiết 4 phòng & cấp độ đồ vật 👉',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary.withOpacity(0.9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardCard(AdminHousePlayer player, int rank) {
    Color rankColor;
    String rankBadge;

    if (rank == 1) {
      rankColor = const Color(0xFFFFB300);
      rankBadge = '🥇';
    } else if (rank == 2) {
      rankColor = const Color(0xFF90A4AE);
      rankBadge = '🥈';
    } else if (rank == 3) {
      rankColor = const Color(0xFFCD7F32);
      rankBadge = '🥉';
    } else {
      rankColor = const Color(0xFF607D8B);
      rankBadge = '#$rank';
    }

    return GestureDetector(
      onTap: () => _showHouseDetailModal(player),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: rank <= 3 ? const Color(0xFFFFFDE7) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: rank <= 3 ? rankColor : AppColors.cartoonBorder,
            width: rank <= 3 ? 2.5 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: rank <= 3 ? rankColor.withOpacity(0.5) : AppColors.cartoonBorder,
              offset: const Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Rank indicator
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: rank <= 3 ? Colors.white : const Color(0xFFF5F5F5),
                  shape: BoxShape.circle,
                  border: Border.all(color: rankColor, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  rankBadge,
                  style: TextStyle(
                    fontSize: rank <= 3 ? 18 : 13,
                    fontWeight: FontWeight.w900,
                    color: rankColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9C4),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.cartoonBorder, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  player.avatar,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      player.email,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ID: #${player.id} • ${player.ownedCount}/15 đồ vật',
                      style: const TextStyle(
                        color: Color(0xFF757575),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              // Points spent badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFA000), width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('💎 ', style: TextStyle(fontSize: 11)),
                        Text(
                          '${player.totalPointsSpent}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFE65100),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${(player.overallProgress * 100).toInt()}% hoàn thành',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMembershipPill(MembershipType type) {
    String text;
    Color color;

    switch (type) {
      case MembershipType.VIP:
        text = 'VIP';
        color = const Color(0xFF0288D1);
        break;
      case MembershipType.PREMIUM:
        text = 'PREMIUM';
        color = const Color(0xFF7B1FA2);
        break;
      case MembershipType.FREE:
      default:
        text = 'FREE';
        color = const Color(0xFF757575);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cartoonBorder, width: 2.5),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.cartoonBorder,
                    offset: Offset(0, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Text('🏡', style: TextStyle(fontSize: 36)),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MODAL CHI TIẾT TIẾN ĐỘ 4 PHÒNG & ĐỒ VẬT TỪNG NGƯỜI CHƠI ---
  void _showHouseDetailModal(AdminHousePlayer player) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.88,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Top Drag handle pill
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 8),
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.cartoonBorder.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  // Header of Modal
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        // Avatar Pod
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF9C4),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.cartoonBorder, width: 2.5),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.cartoonBorder,
                                offset: Offset(0, 3),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            player.avatar,
                            style: const TextStyle(fontSize: 30),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Name & Gmail & ID
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      player.name,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildMembershipPill(player.account.membershipType),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Gmail: ${player.email}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Tài khoản ID: #${player.id}',
                                style: const TextStyle(
                                  color: Color(0xFF757575),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Close Button
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.cartoonBorder, width: 2),
                            ),
                            child: const Icon(Icons.close, size: 18, color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Overall House Stats Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.cartoonBorder, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.cartoonBorder,
                            offset: Offset(0, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Điểm tiêu hao
                              Expanded(
                                child: _buildStatPod(
                                  title: 'ĐIỂM ĐÃ TIÊU',
                                  value: '${player.totalPointsSpent} 💎',
                                  color: const Color(0xFFE65100),
                                  bgColor: const Color(0xFFFFF8E1),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Tiến độ
                              Expanded(
                                child: _buildStatPod(
                                  title: 'TIẾN ĐỘ NHÀ',
                                  value: '${(player.overallProgress * 100).toStringAsFixed(1)}%',
                                  color: const Color(0xFF2E7D32),
                                  bgColor: const Color(0xFFE8F5E9),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Đã sắm
                              Expanded(
                                child: _buildStatPod(
                                  title: 'ĐÃ SỞ HỮU',
                                  value: '${player.ownedCount}/15 món',
                                  color: const Color(0xFF1565C0),
                                  bgColor: const Color(0xFFE3F2FD),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: player.overallProgress,
                              minHeight: 10,
                              backgroundColor: const Color(0xFFEEEEEE),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2ECC71)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'CHI TIẾT 4 PHÒNG & CẤP ĐỘ ĐỒ VẬT',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 4 Rooms Scrollable
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                      children: [
                        _buildRoomDetailCard(player, HouseRoomType.livingRoom),
                        _buildRoomDetailCard(player, HouseRoomType.kitchen),
                        _buildRoomDetailCard(player, HouseRoomType.bathroom),
                        _buildRoomDetailCard(player, HouseRoomType.bedroom),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatPod({
    required String title,
    required String value,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: color.withOpacity(0.85),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomDetailCard(AdminHousePlayer player, HouseRoomType room) {
    final items = HouseCatalog.getItemsByRoom(room);
    final roomSpent = player.house.getRoomPointsSpent(room);
    final roomProgress = player.house.getRoomProgress(room);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: room.accentColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: room.accentColor.withOpacity(0.3),
            offset: const Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Room Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: room.cardBgColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Text(room.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.displayName,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: room.accentColor,
                        ),
                      ),
                      Text(
                        room.subtitle,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: room.accentColor.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                // Points in room
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: room.accentColor, width: 1.5),
                  ),
                  child: Text(
                    '💎 $roomSpent điểm',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: room.accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Items List in this room
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: items.map((item) {
                final level = player.house.getItemLevel(item.id);
                final itemSpent = player.house.getItemPointsSpent(item.id);

                return _buildItemRow(item, level, itemSpent);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(HouseItem item, int level, int pointsSpent) {
    final bool isBought = level > 0;
    final levelInfo = isBought ? item.getLevel(level) : null;

    Color badgeBg;
    Color badgeColor;
    String badgeText;

    if (level == 0) {
      badgeBg = const Color(0xFFF5F5F5);
      badgeColor = const Color(0xFF9E9E9E);
      badgeText = 'Chưa mua';
    } else if (level == 1) {
      badgeBg = const Color(0xFFE8F5E9);
      badgeColor = const Color(0xFF2E7D32);
      badgeText = 'Level 1: ${levelInfo?.tierBadge ?? 'Cổ Điển'}';
    } else if (level == 2) {
      badgeBg = const Color(0xFFE1F5FE);
      badgeColor = const Color(0xFF0288D1);
      badgeText = 'Level 2: ${levelInfo?.tierBadge ?? 'Tiện Nghi'}';
    } else {
      badgeBg = const Color(0xFFFFF8E1);
      badgeColor = const Color(0xFFF57F17);
      badgeText = 'Level 3: ${levelInfo?.tierBadge ?? 'Smart 4.0 MAX'}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isBought ? const Color(0xFFFAFAFA) : const Color(0xFFFDFDFD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isBought ? const Color(0xFFE0E0E0) : const Color(0xFFEEEEEE),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Item Emoji
          Text(
            item.baseEmoji,
            style: TextStyle(
              fontSize: 22,
              color: isBought ? null : Colors.grey.withOpacity(0.4),
            ),
          ),
          const SizedBox(width: 10),

          // Name and Level Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: isBought ? AppColors.textPrimary : const Color(0xFF9E9E9E),
                  ),
                ),
                if (isBought && levelInfo != null)
                  Text(
                    levelInfo.title,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                else
                  const Text(
                    'Chưa được sắm vào phòng',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFFBDBDBD),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),

          // Level badge & Points spent
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: badgeColor, width: 1),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: badgeColor,
                  ),
                ),
              ),
              if (isBought) ...[
                const SizedBox(height: 2),
                Text(
                  'Đã tiêu: $pointsSpent 💎',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE65100),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
