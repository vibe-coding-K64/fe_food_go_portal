import 'package:flutter/material.dart';

class VouchersPage extends StatefulWidget {
  final Function(String)? onNavigate;
  const VouchersPage({super.key, this.onNavigate});

  @override
  State<VouchersPage> createState() => _VouchersPageState();
}

class _VouchersPageState extends State<VouchersPage> {
  final List<Map<String, dynamic>> _vouchers = [
    {'code': 'WELCOME20', 'type': '%', 'value': 20, 'minOrder': 100000, 'expiry': '31/12/2025', 'used': 15, 'limit': 50, 'active': true},
    {'code': 'FREESHIP', 'type': 'cash', 'value': 20000, 'minOrder': 50000, 'expiry': '30/06/2025', 'used': 8, 'limit': 20, 'active': true},
    {'code': 'SUMMER30', 'type': '%', 'value': 30, 'minOrder': 200000, 'expiry': '31/07/2025', 'used': 50, 'limit': 50, 'active': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mã Giảm Giá', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2D))),
                SizedBox(height: 4),
                Text('Tạo và quản lý voucher khuyến mãi cho quán', style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (widget.onNavigate != null) widget.onNavigate!('/vouchers/add');
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tạo voucher'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.separated(
            itemCount: _vouchers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) => _buildVoucherCard(i, _vouchers[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildVoucherCard(int index, Map<String, dynamic> v) {
    final isPercent = v['type'] == '%';
    final discountText = isPercent ? 'Giảm ${v['value']}%' : 'Giảm ${v['value'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ';
    final progress = v['used'] / v['limit'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        border: Border.all(color: v['active'] ? Colors.transparent : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Voucher icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: v['active']
                    ? [const Color(0xFFFF6B35), const Color(0xFFFF8C42)]
                    : [Colors.grey.shade400, Colors.grey.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isPercent ? '${v['value']}%' : '${v['value'] ~/ 1000}K',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const Text('OFF', style: TextStyle(color: Colors.white70, fontSize: 10)),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(v['code'],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1, color: Color(0xFF1E1E2D))),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: v['active'] ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        v['active'] ? 'Đang chạy' : 'Hết lượt',
                        style: TextStyle(
                            color: v['active'] ? Colors.green : Colors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '$discountText | Đơn tối thiểu ${v['minOrder'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                Text('HSD: ${v['expiry']}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey.shade200,
                          color: progress >= 1 ? Colors.red : const Color(0xFFFF6B35),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('${v['used']}/${v['limit']} lượt',
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Actions
          Column(
            children: [
              IconButton(
                onPressed: () {
                  if (widget.onNavigate != null) widget.onNavigate!('/vouchers/edit');
                },
                icon: const Icon(Icons.edit_outlined, color: Color(0xFFFF6B35)),
                tooltip: 'Sửa',
              ),
              IconButton(
                onPressed: () => setState(() => _vouchers.removeAt(index)),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                tooltip: 'Xóa',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
