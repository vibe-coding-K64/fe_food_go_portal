import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/transaction_model.dart';
import '../../data/services/wallet_api_service.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  String _filter = 'Tất cả';
  final List<String> _filters = ['Tất cả', 'Tiền vào', 'Tiền ra'];
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  List<Transaction> _transactions = [];
  bool _isLoading = true;
  final WalletApiService _apiService = WalletApiService();

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    try {
      final transactions = await _apiService.getTransactions(page: 0, size: 50);
      setState(() {
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

  List<Transaction> get _filtered {
    if (_filter == 'Tiền vào') return _transactions.where((t) => t.type == 1 || t.type == 2 || t.type == 4).toList();
    if (_filter == 'Tiền ra') return _transactions.where((t) => t.type == 3).toList();
    return _transactions;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Lịch sử Giao dịch', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2D))),
        const SizedBox(height: 4),
        const Text('Sao kê chi tiết tất cả giao dịch trong ví', style: TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 20),
        Row(
          children: _filters.map((f) {
            final isSelected = _filter == f;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(f),
                selected: isSelected,
                onSelected: (_) => setState(() => _filter = f),
                selectedColor: const Color(0xFFFF6B35),
                labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade700, fontWeight: FontWeight.w500),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? const Color(0xFFFF6B35) : Colors.grey.shade300)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(width: 48),
                      Expanded(child: Text('Nội dung', style: TextStyle(fontWeight: FontWeight.bold))),
                      SizedBox(width: 200, child: Text('Thời gian', style: TextStyle(fontWeight: FontWeight.bold))),
                      SizedBox(width: 160, child: Text('Ghi chú', style: TextStyle(fontWeight: FontWeight.bold))),
                      SizedBox(width: 140, child: Text('Số tiền', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
                    itemBuilder: (context, i) => _buildRow(_filtered[i]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRow(Transaction tx) {
    final isCredit = tx.type == 1 || tx.type == 2 || tx.type == 4;
    final amountStr = _currencyFormat.format(tx.netAmount);
    final timeStr = tx.createdAt != null ? DateFormat('HH:mm dd/MM/yyyy').format(tx.createdAt!.toLocal()) : '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isCredit ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
              shape: BoxShape.circle,
            ),
            child: Icon(isCredit ? Icons.south_west : Icons.north_east,
                color: isCredit ? Colors.green : Colors.red, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(tx.description, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
          SizedBox(width: 200, child: Text(timeStr, style: const TextStyle(color: Colors.grey, fontSize: 12))),
          SizedBox(width: 160, child: Text(tx.type == 1 ? 'Doanh thu đơn hàng' : (tx.type == 3 ? 'Yêu cầu rút tiền' : ''), style: const TextStyle(color: Colors.grey, fontSize: 12))),
          SizedBox(
            width: 140,
            child: Text(
              '${isCredit ? '+' : '-'}$amountStr',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCredit ? Colors.green : Colors.red,
                  fontSize: 14),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
