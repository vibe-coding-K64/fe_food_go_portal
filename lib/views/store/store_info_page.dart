import 'package:flutter/material.dart';

class StoreInfoPage extends StatefulWidget {
  final Function(String)? onNavigate;
  const StoreInfoPage({super.key, this.onNavigate});

  @override
  State<StoreInfoPage> createState() => _StoreInfoPageState();
}

class _StoreInfoPageState extends State<StoreInfoPage> {
  bool _isAcceptingOrders = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Thông tin Gian hàng',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1E2D))),
                  SizedBox(height: 4),
                  Text('Quản lý thông tin quán và hình ảnh',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  if (widget.onNavigate != null) {
                    widget.onNavigate!('/store/edit');
                  }
                },
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Chỉnh sửa'),
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

          // Toggle nhận đơn khẩn cấp
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _isAcceptingOrders
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isAcceptingOrders
                    ? Colors.green.shade300
                    : Colors.red.shade300,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isAcceptingOrders
                      ? Icons.store_outlined
                      : Icons.store_mall_directory_outlined,
                  color: _isAcceptingOrders ? Colors.green : Colors.red,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isAcceptingOrders
                            ? 'Quán đang NHẬN ĐƠN'
                            : 'Quán đang TẠM NGƯNG',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _isAcceptingOrders
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isAcceptingOrders
                            ? 'Khách hàng có thể đặt món từ quán bạn'
                            : 'Quán của bạn đang tắt nhận đơn',
                        style:
                            TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isAcceptingOrders,
                  onChanged: (val) => setState(() => _isAcceptingOrders = val),
                  activeColor: Colors.green,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Cover image + info card
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Images
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildImageCard(),
                    const SizedBox(height: 16),
                    _buildLogoCard(),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Right: Info
              Expanded(
                flex: 3,
                child: _buildInfoCard(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildContactCard(),
        ],
      ),
    );
  }

  Widget _buildImageCard() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade200,
        image: const DecorationImage(
          image: NetworkImage(
              'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=600'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Ảnh bìa',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.network(
              'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=100',
              width: 64,
              height: 64,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Logo Quán',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              SizedBox(height: 4),
              Text('Ảnh đại diện tròn của quán',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Thông tin cơ bản',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E2D))),
          const Divider(height: 24),
          _infoRow(Icons.store, 'Tên quán', 'FoodGo Burger & Grill'),
          _infoRow(Icons.description_outlined, 'Mô tả',
              'Burger thủ công, nguyên liệu tươi mỗi ngày'),
          _infoRow(Icons.location_on_outlined, 'Địa chỉ',
              '123 Nguyễn Huệ, Quận 1, TP.HCM'),
          _infoRow(Icons.receipt_long_outlined, 'Mã số thuế', '0123456789'),
          _infoRow(Icons.article_outlined, 'Giấy phép KD', 'GP-2024-001 ✓'),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tài khoản ngân hàng nhận tiền',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E2D))),
          const Divider(height: 24),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.account_balance, color: Color(0xFFFF6B35)),
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vietcombank - CN TP.HCM',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('0123 4567 8901 - NGUYEN VAN A',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFFFF6B35)),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(label,
                style:
                    const TextStyle(color: Colors.grey, fontSize: 14)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
