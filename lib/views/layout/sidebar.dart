import 'package:flutter/material.dart';

class Sidebar extends StatefulWidget {
  final Function(String) onNavigate;
  final String currentRoute;

  const Sidebar({
    super.key,
    required this.onNavigate,
    this.currentRoute = '/dashboard',
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2D),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // LOGO
          Container(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.storefront_outlined, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Flexible(
                  child: Text(
                    'FOODGO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: Colors.white10, thickness: 1),
          ),
          const SizedBox(height: 6),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                // GIAN HÀNG
                _section('GIAN HÀNG'),
                _item(Icons.dashboard_outlined, 'Bảng điều khiển', '/dashboard'),
                _item(Icons.store_outlined, 'Thông tin quán', '/store'),

                // THỰC ĐƠN
                _section('THỰC ĐƠN'),
                _item(Icons.category_outlined, 'Danh mục món', '/menu-categories'),
                _item(Icons.fastfood_outlined, 'Món ăn', '/products'),

                // KINH DOANH
                _section('KINH DOANH'),
                _item(Icons.shopping_bag_outlined, 'Đơn hàng', '/orders'),
                _item(Icons.local_offer_outlined, 'Mã giảm giá', '/vouchers'),
                _item(Icons.star_outline, 'Đánh giá', '/reviews'),

                // TÀI CHÍNH
                _section('TÀI CHÍNH'),
                _item(Icons.account_balance_wallet_outlined, 'Ví doanh thu', '/finance/wallet'),
                _item(Icons.receipt_long_outlined, 'Lịch sử GD', '/finance/transactions'),
                _item(Icons.savings_outlined, 'Rút tiền', '/finance/withdrawal'),

                // HỖ TRỢ
                _section('HỖ TRỢ'),
                _item(Icons.chat_bubble_outline, 'Chat khách hàng', '/chat'),
                _item(Icons.notifications_outlined, 'Thông báo', '/notifications'),
                _item(Icons.report_gmailerrorred_outlined, 'Khiếu nại', '/report-tickets'),

                // TÀI KHOẢN
                _section('TÀI KHOẢN'),
                _item(Icons.person_outline, 'Hồ sơ', '/profile'),
                _item(Icons.settings_outlined, 'Cài đặt', '/settings'),
              ],
            ),
          ),

          // FOOTER
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text('v1.0.0 · FoodGo Merchant',
                style: TextStyle(color: Colors.white24, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 20, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _item(IconData icon, String title, String route) {
    final bool isActive = widget.currentRoute == route;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: () => widget.onNavigate(route),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFFF6B35).withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isActive
                ? const Border(left: BorderSide(color: Color(0xFFFF6B35), width: 3))
                : null,
          ),
          child: Row(
            children: [
              Icon(icon,
                  color: isActive ? const Color(0xFFFF6B35) : Colors.white54,
                  size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.white60,
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isActive)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF6B35),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}