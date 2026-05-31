import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/wallet_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/services/wallet_api_service.dart';

class WithdrawalPage extends StatefulWidget {
  const WithdrawalPage({super.key});

  @override
  State<WithdrawalPage> createState() => _WithdrawalPageState();
}

class _WithdrawalPageState extends State<WithdrawalPage> {
  final _amountCtrl = TextEditingController();
  final WalletApiService _apiService = WalletApiService();
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  Wallet? _wallet;
  List<Transaction> _history = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final wallet = await _apiService.getWallet();
      final allTrans = await _apiService.getTransactions(page: 0, size: 50);
      final withdrawals = allTrans.where((t) => t.type == 'withdrawal').toList();
      setState(() {
        _wallet = wallet;
        _history = withdrawals;
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

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Rút tiền', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2D))),
          const SizedBox(height: 4),
          const Text('Yêu cầu rút tiền về tài khoản ngân hàng', style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildWithdrawalForm(),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 3,
                child: _buildHistoryCard(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tạo yêu cầu rút tiền', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2D))),
          const Divider(height: 24),
          // Balance
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFFFF6B35)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Số dư khả dụng', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(
                      _currencyFormat.format(_wallet?.balance ?? 0),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFF6B35)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Amount input
          TextFormField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Số tiền muốn rút (VNĐ)',
              prefixIcon: const Icon(Icons.attach_money, color: Color(0xFFFF6B35), size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFF6B35))),
              filled: true,
              fillColor: const Color(0xFFF9F9F9),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [500000, 1000000, 2000000, 5000000].map((amt) {
              return ActionChip(
                label: Text('${amt ~/ 1000}K'),
                onPressed: () => setState(() => _amountCtrl.text = amt.toString()),
                backgroundColor: const Color(0xFFFFF3E0),
                labelStyle: const TextStyle(color: Color(0xFFFF6B35)),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          // Bank account
          const Text('Tài khoản thụ hưởng', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFFF6B35), width: 2),
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xFFFFF3E0),
            ),
            child: const Row(
              children: [
                Icon(Icons.account_balance, color: Color(0xFFFF6B35)),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Vietcombank - CN TP.HCM', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('0123 4567 8901 - NGUYEN VAN A', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                Spacer(),
                Icon(Icons.check_circle, color: Color(0xFFFF6B35)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _requestWithdrawal,
              icon: _isSubmitting ? const SizedBox() : const Icon(Icons.send_outlined, size: 18),
              label: _isSubmitting 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                  : const Text('Gửi yêu cầu rút tiền'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Lịch sử Rút tiền', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2D))),
          const Divider(height: 24),
          ..._history.map((h) => _buildHistoryRow(h)),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(Transaction h) {
    Color statusColor;
    String statusText;
    switch (h.status) {
      case 'completed': 
        statusColor = Colors.green; 
        statusText = 'Đã duyệt';
        break;
      case 'pending': 
        statusColor = Colors.orange; 
        statusText = 'Đang xử lý';
        break;
      default: 
        statusColor = Colors.red;
        statusText = 'Từ chối';
    }
    
    final dateStr = h.createdAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(h.createdAt!) : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.account_balance, color: Colors.purple, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Vietcombank - NGUYEN VAN A', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '-${_currencyFormat.format(h.amount)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E1E2D)),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(statusText,
                      style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestWithdrawal() async {
    final amountText = _amountCtrl.text.replaceAll('.', '').replaceAll(',', '');
    final amount = double.tryParse(amountText);
    
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập số tiền hợp lệ'), backgroundColor: Colors.red));
      return;
    }
    
    if (_wallet != null && amount > _wallet!.balance) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Số dư không đủ'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final tx = await _apiService.requestWithdraw(amount);
      setState(() {
        _amountCtrl.clear();
        _isSubmitting = false;
        _history.insert(0, tx);
        _wallet = Wallet(
          id: _wallet!.id,
          userId: _wallet!.userId,
          role: _wallet!.role,
          balance: _wallet!.balance - amount,
          totalEarned: _wallet!.totalEarned,
          totalWithdrawn: _wallet!.totalWithdrawn,
          pendingBalance: _wallet!.pendingBalance + amount,
          createdAt: _wallet!.createdAt,
          updatedAt: DateTime.now()
        );
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gửi yêu cầu rút tiền thành công!'), backgroundColor: Colors.green));
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      }
    }
  }
}
