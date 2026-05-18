import 'package:flutter/material.dart';

class OrdersPage extends StatefulWidget {
  final Function(String)? onNavigate;
  const OrdersPage({super.key, this.onNavigate});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String _filterStatus = 'Tất cả';
  final List<String> _statuses = ['Tất cả', 'Chờ xác nhận', 'Đang chế biến', 'Đang giao', 'Hoàn thành', 'Đã hủy'];

  final List<Map<String, dynamic>> _orders = [
    {'code': 'OD-001', 'customer': 'Nguyễn Văn A', 'items': 3, 'total': 215000, 'status': 'Chờ xác nhận', 'time': '14:23'},
    {'code': 'OD-002', 'customer': 'Trần Thị B', 'items': 2, 'total': 130000, 'status': 'Đang chế biến', 'time': '14:05'},
    {'code': 'OD-003', 'customer': 'Lê Văn C', 'items': 5, 'total': 380000, 'status': 'Đang giao', 'time': '13:47'},
    {'code': 'OD-004', 'customer': 'Phạm Thị D', 'items': 1, 'total': 89000, 'status': 'Hoàn thành', 'time': '13:12'},
    {'code': 'OD-005', 'customer': 'Hoàng Văn E', 'items': 2, 'total': 165000, 'status': 'Đã hủy', 'time': '12:55'},
  ];

  List<Map<String, dynamic>> get _filtered => _filterStatus == 'Tất cả'
      ? _orders
      : _orders.where((o) => o['status'] == _filterStatus).toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quản lý Đơn hàng',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2D))),
            SizedBox(height: 4),
            Text('Xem và xử lý các đơn hàng từ khách',
                style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 20),
        // Status filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _statuses.map((s) {
              final isSelected = _filterStatus == s;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(s),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _filterStatus = s),
                  selectedColor: _statusColor(s),
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade700, fontWeight: FontWeight.w500),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: isSelected ? _statusColor(s) : Colors.grey.shade300),
                  ),
                ),
              );
            }).toList(),
          ),
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
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(width: 110, child: Text('Mã đơn', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: Text('Khách hàng', style: TextStyle(fontWeight: FontWeight.bold))),
                      SizedBox(width: 80, child: Text('Số món', style: TextStyle(fontWeight: FontWeight.bold))),
                      SizedBox(width: 120, child: Text('Tổng tiền', style: TextStyle(fontWeight: FontWeight.bold))),
                      SizedBox(width: 60, child: Text('Giờ', style: TextStyle(fontWeight: FontWeight.bold))),
                      SizedBox(width: 140, child: Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.bold))),
                      SizedBox(width: 100, child: Text('Thao tác', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
                    itemBuilder: (context, i) => _buildOrderRow(_filtered[i]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderRow(Map<String, dynamic> order) {
    return InkWell(
      onTap: () {
        if (widget.onNavigate != null) widget.onNavigate!('/orders/detail');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            SizedBox(
              width: 110,
              child: Text(order['code'],
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF6B35))),
            ),
            Expanded(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFFFFF3E0),
                    child: Text(
                      order['customer'].toString()[0],
                      style: const TextStyle(color: Color(0xFFFF6B35), fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(order['customer'], style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            SizedBox(width: 80, child: Text('${order['items']} món', style: const TextStyle(color: Colors.grey))),
            SizedBox(
              width: 120,
              child: Text(
                '${(order['total'] as int).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 60, child: Text(order['time'], style: const TextStyle(color: Colors.grey))),
            SizedBox(
              width: 140,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _statusColor(order['status']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order['status'],
                  style: TextStyle(color: _statusColor(order['status']), fontSize: 12, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(
              width: 100,
              child: Row(
                children: [
                  if (order['status'] == 'Chờ xác nhận') ...[
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                      tooltip: 'Xác nhận',
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.cancel_outlined, color: Colors.red, size: 20),
                      tooltip: 'Từ chối',
                    ),
                  ] else
                    IconButton(
                      onPressed: () {
                        if (widget.onNavigate != null) widget.onNavigate!('/orders/detail');
                      },
                      icon: const Icon(Icons.visibility_outlined, color: Color(0xFFFF6B35), size: 20),
                      tooltip: 'Xem chi tiết',
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Chờ xác nhận': return Colors.orange;
      case 'Đang chế biến': return Colors.blue;
      case 'Đang giao': return Colors.purple;
      case 'Hoàn thành': return Colors.green;
      case 'Đã hủy': return Colors.red;
      default: return Colors.grey;
    }
  }
}
