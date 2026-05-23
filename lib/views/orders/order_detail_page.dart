import 'package:flutter/material.dart';

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              ),
              const SizedBox(width: 8),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Chi tiết Đơn hàng #OD-001',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2D))),
                  Text('Đặt lúc 14:23 - Hôm nay',
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left col
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildOrderItems(),
                    const SizedBox(height: 16),
                    _buildCustomerInfo(),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Right col
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildStatusCard(),
                    const SizedBox(height: 16),
                    _buildPaymentSummary(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
    final items = [
      {'name': 'Burger Bò Phô Mai', 'options': 'Thêm phô mai, 50% đá', 'qty': 2, 'price': 89000},
      {'name': 'Khoai Tây Chiên', 'options': '', 'qty': 1, 'price': 30000},
    ];
    return _card('Danh sách món', [
      ...items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.fastfood, color: Color(0xFFFF6B35), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['name'].toString(), style: const TextStyle(fontWeight: FontWeight.w600)),
                  if ((item['options'] as String).isNotEmpty)
                    Text(item['options'].toString(), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            Text('x${item['qty']}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(width: 16),
            Text(
              '${((item['price'] as int) * (item['qty'] as int)).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      )),
      if (items.isNotEmpty) ...[
        const Divider(),
        const Text('Ghi chú: Ít cay, không hành', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
      ],
    ]);
  }

  Widget _buildCustomerInfo() {
    return _card('Thông tin khách hàng & giao hàng', [
      _row(Icons.person_outline, 'Khách hàng', 'Nguyễn Văn A'),
      _row(Icons.phone_outlined, 'Số điện thoại', '0901 234 567'),
      _row(Icons.location_on_outlined, 'Địa chỉ giao', '123 Đường Lê Lợi, Quận 1, TP.HCM'),
      _row(Icons.delivery_dining_outlined, 'Tài xế', 'Trần B (0987 654 321)'),
    ]);
  }

  Widget _buildStatusCard() {
    return _card('Trạng thái đơn hàng', [
      _statusStep('Đặt hàng', '14:23', true),
      _statusStep('Xác nhận', '14:25', true),
      _statusStep('Đang chế biến', '14:26', true),
      _statusStep('Tài xế nhận đơn', '', false),
      _statusStep('Hoàn thành', '', false),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Hoàn tất chế biến'),
            ),
          ),
        ],
      ),
    ]);
  }

  Widget _statusStep(String label, String time, bool done) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: done ? Colors.green : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Icon(done ? Icons.check : Icons.circle, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(fontWeight: done ? FontWeight.w600 : FontWeight.normal, color: done ? const Color(0xFF1E1E2D) : Colors.grey))),
          if (time.isNotEmpty) Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return _card('Thanh toán', [
      _payRow('Tổng món', '208.000đ'),
      _payRow('Phí giao hàng', '15.000đ'),
      _payRow('Giảm giá (SAVE20)', '-20.000đ', color: Colors.green),
      const Divider(height: 20),
      _payRow('Tổng cộng', '203.000đ', bold: true, color: const Color(0xFFFF6B35)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(Icons.payment, size: 16, color: Colors.grey),
            SizedBox(width: 8),
            Text('Thanh toán: Tiền mặt', style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
    ]);
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFFFF6B35)),
          const SizedBox(width: 12),
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _payRow(String label, String value, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: bold ? const Color(0xFF1E1E2D) : Colors.grey, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.w500, color: color ?? const Color(0xFF1E1E2D))),
        ],
      ),
    );
  }

  Widget _card(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2D))),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }
}
