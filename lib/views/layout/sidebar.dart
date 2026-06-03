import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/order_api_service.dart';

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
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
            child: RawScrollbar(
              controller: _scrollController,
              thumbColor: Colors.white38,
              radius: const Radius.circular(8),
              thickness: 8,
              thumbVisibility: true,
              interactive: true,
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                // GIAN HÀNG
                _section('sidebar.store'.tr()),
                _item(Icons.dashboard_outlined, 'sidebar.dashboard'.tr(), '/dashboard'),
                _item(Icons.store_outlined, 'sidebar.storeInfo'.tr(), '/store'),

                // THỰC ĐƠN
                _section('sidebar.menu'.tr()),
                _item(Icons.category_outlined, 'sidebar.categories'.tr(), '/menu-categories'),
                _item(Icons.fastfood_outlined, 'sidebar.products'.tr(), '/products'),

                // KINH DOANH
                _section('sidebar.business'.tr()),
                ValueListenableBuilder<int>(
                  valueListenable: OrderBadgeService().pendingCountNotifier,
                  builder: (context, count, child) {
                    return _item(Icons.shopping_bag_outlined, 'sidebar.orders'.tr(), '/orders', badgeCount: count);
                  },
                ),
                _item(Icons.local_offer_outlined, 'sidebar.vouchers'.tr(), '/vouchers'),
                _item(Icons.star_outline, 'sidebar.reviews'.tr(), '/reviews'),

                // TÀI CHÍNH
                _section('sidebar.finance'.tr()),
                _item(Icons.account_balance_wallet_outlined, 'sidebar.wallet'.tr(), '/finance/wallet'),
                _item(Icons.receipt_long_outlined, 'sidebar.transactions'.tr(), '/finance/transactions'),
                _item(Icons.savings_outlined, 'sidebar.withdrawal'.tr(), '/finance/withdrawal'),

                // HỖ TRỢ
                _section('sidebar.support'.tr()),
                // _item(Icons.chat_bubble_outline, 'sidebar.chat'.tr(), '/chat'),
                ValueListenableBuilder<int>(
                  valueListenable: NotificationService().unreadCountNotifier,
                  builder: (context, count, child) {
                    return _item(Icons.notifications_outlined, 'sidebar.notifications'.tr(), '/notifications', badgeCount: count);
                  },
                ),
                // _item(Icons.report_gmailerrorred_outlined, 'sidebar.reports'.tr(), '/report-tickets'),

                // TÀI KHOẢN
                _section('sidebar.account'.tr()),
                _item(Icons.person_outline, 'sidebar.profile'.tr(), '/profile'),
                _item(Icons.settings_outlined, 'sidebar.settings'.tr(), '/settings'),
              ],
            ),
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

  Widget _item(IconData icon, String title, String route, {int badgeCount = 0}) {
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
              if (badgeCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badgeCount > 99 ? '99+' : badgeCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                )
              else if (isActive)
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