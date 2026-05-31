import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/wallet_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/services/wallet_api_service.dart';

class WalletPage extends StatefulWidget {
  final Function(String)? onNavigate;
  const WalletPage({super.key, this.onNavigate});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final WalletApiService _apiService = WalletApiService();
  Wallet? _wallet;
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final wallet = await _apiService.getWallet();
      final transactions = await _apiService.getTransactions(page: 0, size: 5);
      setState(() {
        _wallet = wallet;
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B35)));
    }

    final balance = _wallet?.balance ?? 0.0;
    final totalEarned = _wallet?.totalEarned ?? 0.0;
    final pendingBalance = _wallet?.pendingBalance ?? 0.0;
    final totalWithdrawn = _wallet?.totalWithdrawn ?? 0.0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ví Doanh Thu', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2D))),
          const SizedBox(height: 4),
          const Text('Quản lý số dư và theo dõi dòng tiền', style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 24),
          // Balance card
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tổng số dư khả dụng', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                Text(_currencyFormat.format(balance), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _walletStat('Tổng thu nhập', _currencyFormat.format(totalEarned), Icons.trending_up),
                    const SizedBox(width: 32),
                    _walletStat('Đang chờ', _currencyFormat.format(pendingBalance), Icons.hourglass_empty_outlined),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (widget.onNavigate != null) widget.onNavigate!('/finance/withdrawal');
                      },
                      icon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
                      label: const Text('Rút tiền'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFFF6B35),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Quick stats
          Row(
            children: [
              Expanded(child: _statCard('Đã rút', _currencyFormat.format(totalWithdrawn), Icons.arrow_upward_outlined, Colors.purple)),
            ],
          ),
          const SizedBox(height: 24),
          // Recent transactions
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Giao dịch gần đây', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2D))),
                    TextButton(
                      onPressed: () {
                        if (widget.onNavigate != null) widget.onNavigate!('/finance/transactions');
                      },
                      child: const Text('Xem tất cả', style: TextStyle(color: Color(0xFFFF6B35))),
                    ),
                  ],
                ),
                const Divider(height: 20),
                if (_transactions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text('Chưa có giao dịch nào', style: TextStyle(color: Colors.grey))),
                  )
                else
                  ..._transactions.map((tx) => _transactionRow(tx)).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _walletStat(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 14),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E1E2D))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionRow(Transaction tx) {
    final isCredit = tx.type == 'order_payment' || tx.type == 'delivery_income' || tx.type == 'refund';
    final sign = isCredit ? '+' : '-';
    final amountStr = sign + _currencyFormat.format(tx.netAmount);
    final timeStr = tx.createdAt != null ? DateFormat('HH:mm dd/MM').format(tx.createdAt!) : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isCredit ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
              shape: BoxShape.circle,
            ),
            child: Icon(isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                color: isCredit ? Colors.green : Colors.red, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.description, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                Text(timeStr, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Text(amountStr,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCredit ? Colors.green : Colors.red,
                  fontSize: 14)),
        ],
      ),
    );
  }
}
