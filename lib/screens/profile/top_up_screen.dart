import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/custom_widgets.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  static const int _minTopUpAmount = 10000;
  static const int _maxTopUpAmount = 500000;

  final _amountCtrl = TextEditingController();
  int _selectedVnd = 0;
  int _calculatedCoin = 0;
  String? _amountError;

  final List<Map<String, int>> _packages = [
    {'vnd': 10000, 'coin': 100},
    {'vnd': 50000, 'coin': 500},
    {'vnd': 100000, 'coin': 1000},
    {'vnd': 200000, 'coin': 2000},
    {'vnd': 500000, 'coin': 5000},
  ];

  @override
  void initState() {
    super.initState();
    Provider.of<AppProvider>(context, listen: false).reloadAccountData();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _onPackageSelect(int vnd, int coin) {
    setState(() {
      _selectedVnd = vnd;
      _calculatedCoin = coin;
      _amountCtrl.text = vnd.toString();
      _amountError = null;
    });
    _showPaymentBottomSheet();
  }

  void _onCustomAmountChanged(String val) {
    final sanitized = val.trim();
    if (sanitized.isEmpty) {
      setState(() {
        _selectedVnd = 0;
        _calculatedCoin = 0;
        _amountError = null;
      });
      return;
    }

    final vnd = int.tryParse(sanitized);
    if (vnd == null || vnd < _minTopUpAmount || vnd > _maxTopUpAmount) {
      setState(() {
        _selectedVnd = 0;
        _calculatedCoin = 0;
        _amountError = 'Vui lòng nhập đúng số tiền';
      });
      return;
    }

    setState(() {
      _selectedVnd = vnd;
      _calculatedCoin = (vnd / 100).floor();
      _amountError = null;
    });
  }

  void _showPaymentBottomSheet() {
    if (_selectedVnd < _minTopUpAmount || _selectedVnd > _maxTopUpAmount || _calculatedCoin <= 0) {
      setState(() {
        _amountError = 'Vui lòng nhập đúng số tiền';
      });
      return;
    }

    setState(() {
      _amountError = null;
    });

    final provider = Provider.of<AppProvider>(context, listen: false);
    final txCode = DateTime.now().millisecondsSinceEpoch.toString().substring(5);
    final transferContent = 'SAFEQUEST ${provider.currentAccount!.id} $txCode';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(
              top: BorderSide(color: AppColors.cartoonBorder, width: 3.5),
              left: BorderSide(color: AppColors.cartoonBorder, width: 3.5),
              right: BorderSide(color: AppColors.cartoonBorder, width: 3.5),
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.cartoonBorder.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'QUÉT MÃ QR NẠP COIN',
                    style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 220,
                    height: 220,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.cartoonBorder, width: 3),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.cartoonBorder,
                          offset: Offset(0, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        'assets/images/payment_qr.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildBankInfoRow('Ngân hàng', 'BIDV'),
                  _buildBankInfoRow('Số tài khoản', '6211130368', copyable: true),
                  _buildBankInfoRow('Chủ tài khoản', 'THAI HOANG GIANG'),
                  _buildBankInfoRow('Số tiền chuyển', '$_selectedVnd VNĐ', highlight: true),
                  const SizedBox(height: 12),
                  const Divider(height: 24, thickness: 1.5),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'NỘI DUNG CHUYỂN KHOẢN BẮT BUỘC:',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: transferContent));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã sao chép nội dung chuyển khoản!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF9C4),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              transferContent,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                color: Color(0xFFE65100),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'SAO CHÉP',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Vui lòng nhập đúng nội dung để hệ thống tự động cộng Coin.',
                    style: TextStyle(fontSize: 12, color: Color(0xFFD32F2F), fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: 'TÔI ĐÃ CHUYỂN KHOẢN',
                    onPressed: () async {
                      Navigator.pop(context);
                      await provider.requestTopUp(_selectedVnd, _calculatedCoin);
                      if (mounted) {
                        _showSuccessDialog();
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
          side: const BorderSide(color: AppColors.cartoonBorder, width: 3),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⌛', style: TextStyle(fontSize: 54)),
            const SizedBox(height: 12),
            Text(
              'ĐÃ GỬI YÊU CẦU',
              style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w900, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            const Text(
              'Yêu cầu nạp Coin của bạn đã được ghi nhận.\nAdmin sẽ duyệt và cộng Coin sớm nhất nhé!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              text: 'ĐỒNG Ý',
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankInfoRow(String label, String value, {bool highlight = false, bool copyable = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cartoonBorder.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: highlight ? 16 : 13,
                  color: highlight ? const Color(0xFFE65100) : AppColors.textPrimary,
                ),
              ),
              if (copyable) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã sao chép $label!'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'CHÉP',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final myTxs = provider.myTransactions;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar
              Row(
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
                    child: Text(
                      'NẠP COIN',
                      style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Big Kid Coin Chest Pod
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.cartoonBorder, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFFFFB74D),
                      offset: Offset(0, 5),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.cartoonBorder, width: 2.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFFFFB74D),
                            offset: Offset(0, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Text('🪙', style: TextStyle(fontSize: 38)),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SỐ DƯ HIỆN TẠI',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              color: Color(0xFFF57F17),
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${provider.currentAccount?.coinBalance ?? 0} COIN',
                            style: AppTextStyles.h1.copyWith(
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFE65100),
                              fontSize: 26,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Title: Chọn gói nạp
              Text(
                'CHỌN GÓI NẠP TIỀN VÀNG',
                style: AppTextStyles.h2.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.7,
                ),
                itemCount: _packages.length,
                itemBuilder: (ctx, i) {
                  final p = _packages[i];
                  return GestureDetector(
                    onTap: () => _onPackageSelect(p['vnd']!, p['coin']!),
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '+${p['coin']} COIN',
                            style: const TextStyle(
                              color: Color(0xFFE65100),
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.cartoonSky.withOpacity(0.35),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${p['vnd']} VNĐ',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),

              // Custom amount card
              Container(
                padding: const EdgeInsets.all(20),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'HOẶC NHẬP SỐ TIỀN TÙY Ý',
                      style: AppTextStyles.h3.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tối thiểu 10.000 VNĐ • Tối đa 500.000 VNĐ',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _amountError != null ? AppColors.error : AppColors.cartoonBorder,
                          width: 2,
                        ),
                      ),
                      child: TextField(
                        controller: _amountCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: 'Nhập số tiền (VNĐ)...',
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: InputBorder.none,
                        ),
                        onChanged: _onCustomAmountChanged,
                      ),
                    ),
                    if (_amountError != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        _amountError!,
                        style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                    if (_calculatedCoin > 0) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.success, width: 1.5),
                        ),
                        child: Text(
                          'Bé sẽ nhận được: +$_calculatedCoin Coin',
                          style: const TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _showPaymentBottomSheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.cartoonBorder, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.primaryDark,
                              offset: Offset(0, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'XÁC NHẬN NẠP',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Transaction history
              if (myTxs.isNotEmpty) ...[
                Text(
                  'LỊCH SỬ GIAO DỊCH GẦN ĐÂY',
                  style: AppTextStyles.h2.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: myTxs.length,
                  itemBuilder: (ctx, i) {
                    final tx = myTxs[i];
                    Color statusBg = const Color(0xFFFFF9C4);
                    Color statusTextCol = const Color(0xFFF57F17);
                    String statusLabel = 'CHỜ DUYỆT';
                    if (tx.status == TransactionStatus.CONFIRMED) {
                      statusBg = const Color(0xFFE8F5E9);
                      statusTextCol = AppColors.success;
                      statusLabel = 'THÀNH CÔNG';
                    } else if (tx.status == TransactionStatus.REJECTED) {
                      statusBg = const Color(0xFFFFEBEE);
                      statusTextCol = AppColors.error;
                      statusLabel = 'TỪ CHỐI';
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '#${tx.transactionCode}',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusBg,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: statusTextCol, width: 1.5),
                                ),
                                child: Text(
                                  statusLabel,
                                  style: TextStyle(
                                    color: statusTextCol,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${tx.amount} VNĐ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '+${tx.coinAmount} Coin',
                                style: const TextStyle(
                                  color: Color(0xFFE65100),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${tx.createdAt.day}/${tx.createdAt.month}/${tx.createdAt.year} ${tx.createdAt.hour}:${tx.createdAt.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (tx.rejectReason != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(
                                'Lý do: ${tx.rejectReason}',
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
