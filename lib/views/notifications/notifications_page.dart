import 'package:flutter/material.dart';
import '../../data/services/notification_service.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: NotificationService().notificationsNotifier,
      builder: (context, notifications, child) {
        final unreadCount = NotificationService().unreadCountNotifier.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Thông báo', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2D))),
                        const SizedBox(width: 12),
                        if (unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(color: const Color(0xFFFF6B35), borderRadius: BorderRadius.circular(20)),
                            child: Text('$unreadCount mới', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('Đơn hàng, thanh toán và cập nhật từ hệ thống', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
                if (unreadCount > 0)
                  TextButton.icon(
                    onPressed: () {
                      NotificationService().markAllAsRead();
                    },
                    icon: const Icon(Icons.done_all, size: 16, color: Color(0xFFFF6B35)),
                    label: const Text('Đánh dấu tất cả đã đọc', style: TextStyle(color: Color(0xFFFF6B35))),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: notifications.isEmpty
                    ? const Center(child: Text('Không có thông báo nào.'))
                    : ListView.separated(
                        itemCount: notifications.length,
                        separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
                        itemBuilder: (context, i) => _buildNotificationRow(notifications[i]),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationRow(Map<String, dynamic> n) {
    final bool isRead = n['isRead'] ?? true;
    final String typeStr = (n['type'] ?? 1).toString();
    final typeIcon = _typeIcon(typeStr);
    final typeColor = _typeColor(typeStr);
    
    String timeStr = '';
    if (n['createdAt'] != null) {
      try {
        DateTime dt = DateTime.parse(n['createdAt']).toLocal();
        timeStr = DateFormat('dd/MM HH:mm').format(dt);
      } catch (_) {}
    }

    return InkWell(
      onTap: () {
        if (!isRead && n['id'] != null) {
          NotificationService().markAsRead(n['id']);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: isRead ? Colors.transparent : const Color(0xFFFFF8F5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(typeIcon, color: typeColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text((n['title'] ?? '').toString().replaceAll('🛒 ', '').replaceAll('🛒', ''),
                      style: TextStyle(
                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                          fontSize: 14,
                          color: const Color(0xFF1E1E2D))),
                  const SizedBox(height: 4),
                  Text(n['body'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(timeStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 6),
                if (!isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: Color(0xFFFF6B35), shape: BoxShape.circle),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case '11':
      case '21': return Icons.receipt_long_outlined;
      case '1': return Icons.shopping_bag_outlined;
      case '2': return Icons.account_balance_wallet_outlined;
      case '3': return Icons.star_outline;
      case '4': return Icons.cancel_outlined;
      default: return Icons.notifications_outlined;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case '11':
      case '21': return const Color(0xFFFF8C42);
      case '1': return const Color(0xFFFF6B35);
      case '2': return Colors.green;
      case '3': return Colors.amber;
      case '4': return Colors.red;
      default: return Colors.blue;
    }
  }
}
