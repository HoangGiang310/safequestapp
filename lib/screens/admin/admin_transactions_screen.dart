import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../../services/data_service.dart';

class AdminTransactionsScreen extends StatefulWidget {
  const AdminTransactionsScreen({super.key});

  @override
  State<AdminTransactionsScreen> createState() => _AdminTransactionsScreenState();
}

enum _TransactionGroupFilter { all, pending, confirmed, rejected }
enum _PendingSortMode { sequence, amount }

class _AdminTransactionsScreenState extends State<AdminTransactionsScreen> {
  _TransactionGroupFilter _groupFilter = _TransactionGroupFilter.all;
  _PendingSortMode _pendingSortMode = _PendingSortMode.sequence;

  @override
  void initState() {
    super.initState();
    Provider.of<AppProvider>(context, listen: false).reloadAdminContent();
  }

  List<Transaction> _sortPendingTransactions(List<Transaction> txs) {
    final list = List<Transaction>.from(txs);
    if (_pendingSortMode == _PendingSortMode.sequence) {
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else {
      list.sort((a, b) {
        if (a.amount == b.amount) return a.createdAt.compareTo(b.createdAt);
        return a.amount.compareTo(b.amount);
      });
    }
    return list;
  }

  List<Transaction> _sortCompletedTransactions(List<Transaction> txs) {
    final list = List<Transaction>.from(txs);
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  List<List<Transaction>> _getGroupedTransactions(List<Transaction> txs) {
    final pending = _sortPendingTransactions(txs.where((t) => t.status == TransactionStatus.PENDING).toList());
    final confirmed = _sortCompletedTransactions(txs.where((t) => t.status == TransactionStatus.CONFIRMED).toList());
    final rejected = _sortCompletedTransactions(txs.where((t) => t.status == TransactionStatus.REJECTED).toList());
    return [pending, confirmed, rejected];
  }

  List<Transaction> _getFilteredTransactions(List<Transaction> txs) {
    switch (_groupFilter) {
      case _TransactionGroupFilter.pending:
        return _sortPendingTransactions(txs.where((t) => t.status == TransactionStatus.PENDING).toList());
      case _TransactionGroupFilter.confirmed:
        return _sortCompletedTransactions(txs.where((t) => t.status == TransactionStatus.CONFIRMED).toList());
      case _TransactionGroupFilter.rejected:
        return _sortCompletedTransactions(txs.where((t) => t.status == TransactionStatus.REJECTED).toList());
      case _TransactionGroupFilter.all:
      default:
        final grouped = _getGroupedTransactions(txs);
        return [...grouped[0], ...grouped[1], ...grouped[2]];
    }
  }

  Future<String> _getUserDisplayName(int userId) async {
    final profile = await DataService().getChildProfileByAccountId(userId);
    if (profile != null && profile.name.trim().isNotEmpty) return profile.name;

    final account = await DataService().getAccountById(userId);
    if (account != null && account.username.trim().isNotEmpty) return account.username;

    return 'Không xác định';
  }

  void _showActionDialog(Transaction tx) {
    if (tx.status != TransactionStatus.PENDING) return;

    final provider = Provider.of<AppProvider>(context, listen: false);
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => FutureBuilder<String>(
        future: _getUserDisplayName(tx.userId),
        builder: (context, snapshot) {
          final userName = snapshot.data ?? 'Đang tải...';
          return AlertDialog(
            title: const Text('Xử lý giao dịch'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mã GD: ${tx.transactionCode}'),
                Text('User ID: ${tx.userId}'),
                Text('Tên: $userName'),
                Text('Số tiền: ${tx.amount} VNĐ'),
                Text('Số Coin nạp: ${tx.coinAmount}'),
                const SizedBox(height: 16),
                const Text('Nếu từ chối, nhập lý do:'),
                TextField(
                  controller: reasonCtrl,
                  decoration: const InputDecoration(hintText: 'Lý do từ chối'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Đóng'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.maybeOf(context);
                  Navigator.pop(ctx);
                  await provider.rejectTransaction(tx.id, reasonCtrl.text.isEmpty ? 'Giao dịch không hợp lệ' : reasonCtrl.text);
                  if (!mounted || messenger == null) return;
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Đã từ chối giao dịch')),
                  );
                },
                child: const Text('TỪ CHỐI', style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.maybeOf(context);
                  Navigator.pop(ctx);
                  await provider.confirmTransaction(tx.id);
                  if (!mounted || messenger == null) return;
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Đã xác nhận giao dịch & cộng Coin')),
                  );
                },
                child: const Text('XÁC NHẬN', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final txs = _getFilteredTransactions(provider.allTransactions);
    final groupedTransactions = _getGroupedTransactions(provider.allTransactions);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quản lý Nạp Coin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF4A6572),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildFilterChip('Tất cả', _TransactionGroupFilter.all),
                              _buildFilterChip('Chờ duyệt', _TransactionGroupFilter.pending),
                              _buildFilterChip('Hoàn thành', _TransactionGroupFilter.confirmed),
                              _buildFilterChip('Từ chối', _TransactionGroupFilter.rejected),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_groupFilter == _TransactionGroupFilter.pending || _groupFilter == _TransactionGroupFilter.all)
                      const SizedBox(height: 12),
                    if (_groupFilter == _TransactionGroupFilter.pending || _groupFilter == _TransactionGroupFilter.all)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<_PendingSortMode>(
                              value: _pendingSortMode,
                              isDense: true,
                              icon: const SizedBox.shrink(),
                              items: const [
                                DropdownMenuItem(
                                  value: _PendingSortMode.sequence,
                                  child: Text('Thứ tự', style: TextStyle(color: AppColors.textPrimary)),
                                ),
                                DropdownMenuItem(
                                  value: _PendingSortMode.amount,
                                  child: Text('Số tiền', style: TextStyle(color: AppColors.textPrimary)),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _pendingSortMode = value);
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _groupFilter == _TransactionGroupFilter.all
                    ? (groupedTransactions.every((section) => section.isEmpty)
                        ? const Center(child: Text('Không có giao dịch nào.'))
                        : ListView.builder(
                            itemCount: 3,
                            itemBuilder: (ctx, index) {
                              final labels = ['Chờ duyệt', 'Hoàn thành', 'Từ chối'];
                              final sectionTxs = groupedTransactions[index];
                              if (sectionTxs.isEmpty) return const SizedBox.shrink();

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Text(
                                        labels[index],
                                        style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
                                      ),
                                    ),
                                    ...sectionTxs.map((tx) => _buildTransactionCard(tx)),
                                  ],
                                ),
                              );
                            },
                          ))
                    : (txs.isEmpty
                        ? const Center(child: Text('Không có giao dịch nào.'))
                        : ListView.builder(
                            itemCount: txs.length,
                            itemBuilder: (ctx, i) => _buildTransactionCard(txs[i]),
                          )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Transaction tx) {
    Color statusColor = Colors.grey;
    if (tx.status == TransactionStatus.PENDING) statusColor = AppColors.warning;
    if (tx.status == TransactionStatus.CONFIRMED) statusColor = AppColors.success;
    if (tx.status == TransactionStatus.REJECTED) statusColor = AppColors.error;

    return InkWell(
      onTap: () => _showActionDialog(tx),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: statusColor.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('#${tx.transactionCode}', style: AppTextStyles.h3),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tx.status.name,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            Text('User ID: ${tx.userId}', style: const TextStyle(color: Colors.grey)),
            FutureBuilder<String>(
              future: _getUserDisplayName(tx.userId),
              builder: (context, snapshot) {
                final name = snapshot.data ?? 'Đang tải...';
                return Text('Tên: $name', style: const TextStyle(color: Colors.grey));
              },
            ),
            Text('Số tiền: ${tx.amount} VNĐ  |  +${tx.coinAmount} Coin', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('NDCK: ${tx.transferContent}', style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
            if (tx.rejectReason != null)
              Text('Lý do từ chối: ${tx.rejectReason}', style: const TextStyle(color: AppColors.error, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, _TransactionGroupFilter filter) {
    final isSelected = _groupFilter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _groupFilter = filter),
      backgroundColor: Colors.white,
      selectedColor: AppColors.primaryLight,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      side: BorderSide(color: isSelected ? AppColors.primary : AppColors.disabled),
    );
  }
}
