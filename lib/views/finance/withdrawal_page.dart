import 'package:flutter/material.dart';

class WithdrawalPage extends StatefulWidget {
  const WithdrawalPage({super.key});

  @override
  State<WithdrawalPage> createState() => _WithdrawalPageState();
}

class _WithdrawalPageState extends State<WithdrawalPage> {
  final _amountCtrl = TextEditingController();
  final double _balance = 12450000;
  final List<Map<String, dynamic>> _history = [
    {'amount': 5000000, 'bank': 'Vietcombank', 'account': '0123...8901', 'status': 'Đã duyệt', 'date': '15/05/2025'},
    {'amount': 3000000, 'bank': 'Vietcombank', 'account': '0123...8901', 'status': 'Đang xử lý', 'date': '18/05/2025'},
    {'amount': 2000000, 'bank': 'Vietcombank', 'account': '0123...8901', 'status': 'Từ chối', 'date': '10/05/2025'},
  ];

  @override
  Widget build(BuildContext context) {
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
                      '${_balance.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ',
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
              onPressed: _requestWithdrawal,
              icon: const Icon(Icons.send_outlined, size: 18),
              label: const Text('Gửi yêu cầu rút tiền'),
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

  Widget _buildHistoryRow(Map<String, dynamic> h) {
    Color statusColor;
    switch (h['status']) {
      case 'Đã duyệt': statusColor = Colors.green; break;
      case 'Đang xử lý': statusColor = Colors.orange; break;
      default: statusColor = Colors.red;
    }
    final amt = h['amount'] as int;
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
                  Text('${h['bank']} - ${h['account']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(h['date'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '-${amt.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E1E2D)),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(h['status'],
                      style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _requestWithdrawal() {
    if (_amountCtrl.text.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gửi yêu cầu rút tiền thành công!'), backgroundColor: Colors.green),
    );
    _amountCtrl.clear();
  }
}
