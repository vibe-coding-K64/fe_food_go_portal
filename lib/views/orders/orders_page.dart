import 'dart:async';
import 'package:flutter/material.dart';

import '../../data/models/order_model.dart';
import '../../data/services/order_api_service.dart';
import '../../data/services/auth_service.dart';
import 'order_detail_page.dart';

class OrdersPage extends StatefulWidget {
  final Function(String)? onNavigate;
  const OrdersPage({super.key, this.onNavigate});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final OrderApiService _apiService = OrderApiService();
  final AuthService _authService = AuthService();
  String _filterStatus = 'Tất cả';
  final List<String> _statuses = ['Tất cả', 'Chờ xác nhận', 'Đang chuẩn bị', 'Đang giao', 'Hoàn thành', 'Đã hủy'];
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  List<Order> _orders = [];
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) _fetchOrders(isPolling: true);
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchOrders({bool isPolling = false}) async {
    if (!isPolling && mounted) setState(() => _isLoading = true);
    try {
      final storeId = await _authService.getStoreId();
      if (storeId == null) throw 'Không tìm thấy thông tin cửa hàng';
      final orders = await _apiService.getOrdersByStoreId(storeId);
      orders.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      if (mounted && !isPolling) {
        _showNotificationDialog(context, 'Lỗi tải đơn hàng: $e', false);
      }
    }
  }

  Future<void> _updateStatus(String id, String newStatus) async {
    try {
      await _apiService.updateOrderStatus(id, newStatus);
      _fetchOrders();
      if (mounted) _showNotificationDialog(context, 'Đã cập nhật trạng thái thành "$newStatus"', true);
    } catch (e) {
      if (mounted) _showNotificationDialog(context, 'Lỗi: $e', false);
    }
  }

  Future<void> _confirmOrder(String orderId) async {
    try {
      await _apiService.confirmOrder(orderId);
      _fetchOrders();
      if (mounted) _showNotificationDialog(context, 'Đã xác nhận đơn hàng thành công!', true);
    } catch (e) {
      if (mounted) _showNotificationDialog(context, 'Lỗi xác nhận: $e', false);
    }
  }

  void _showNotificationDialog(BuildContext context, String message, bool isSuccess) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSuccess ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                color: isSuccess ? Colors.green : const Color(0xFFDC3545),
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            Text(isSuccess ? 'Thành công!' : 'Có lỗi xảy ra!',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: Colors.black87)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSuccess ? Colors.green : const Color(0xFFDC3545),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Đóng', style: TextStyle(fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Order> get _filtered => _filterStatus == 'Tất cả'
      ? _orders
      : _orders.where((o) => o.status == _filterStatus).toList();

  List<Order> get _pagedOrders {
    int start = (_currentPage - 1) * _itemsPerPage;
    return _filtered.skip(start).take(_itemsPerPage).toList();
  }

  void _setFilter(String status) {
    setState(() {
      _filterStatus = status;
      _currentPage = 1;
    });
  }

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
              final color = s == 'Tất cả' ? const Color(0xFFFF6B35) : _statusColor(s);
              
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  showCheckmark: false,
                  label: Text(s),
                  selected: isSelected,
                  onSelected: (_) => _setFilter(s),
                  selectedColor: color,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : color, 
                    fontWeight: FontWeight.bold,
                  ),
                  backgroundColor: color.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(
                      color: isSelected ? color : color.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  elevation: 0,
                  pressElevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                Expanded(
                  child: _isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : _filtered.isEmpty 
                      ? const Center(child: Text('Không có đơn hàng nào'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(24),
                          itemCount: _pagedOrders.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, i) => _buildOrderCard(_pagedOrders[i]),
                        ),
                ),
                if (!_isLoading && _filtered.isNotEmpty)
                  _buildPagination(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(Order order) {
    String timeStr = 'Thời gian đặt: --:--';
    if (order.createdAt != null) {
      final localTime = order.createdAt!.toLocal();
      timeStr = 'Thời gian đặt:\n${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')} - ${localTime.day.toString().padLeft(2, '0')}/${localTime.month.toString().padLeft(2, '0')}/${localTime.year}';
    }

    return InkWell(
      onTap: () {
        OrderDetailPage.currentOrder = order;
        if (widget.onNavigate != null) widget.onNavigate!('/orders/detail');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Order Code
            SizedBox(
              width: 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Mã đơn: ${order.code}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFFF6B35))),
                  const SizedBox(height: 4),
                  Text(timeStr, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            
            // 2. Customer Info
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFFFF3E0),
                    child: Text(
                      order.receiverName.isNotEmpty ? order.receiverName[0].toUpperCase() : '?',
                      style: const TextStyle(color: Color(0xFFFF6B35), fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(order.receiverName.isNotEmpty ? order.receiverName : 'Khách lạ',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text('${order.items.length} món',
                            style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 3. Total Amount
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Tổng tiền', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    '${order.totalAmount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),

            // 4. Status Badge
            SizedBox(
              width: 130,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(color: _statusColor(order.status), fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),

            // 5. Actions
            SizedBox(
              width: 130,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (order.status == 'Chờ xác nhận') ...[
                    _actionBtn(Icons.cancel_outlined, 'Từ chối', Colors.red, () => _updateStatus(order.id!, 'Đã hủy')),
                    const SizedBox(width: 8),
                    _actionBtn(Icons.check_circle_outline, 'Xác nhận', Colors.green, () => _confirmOrder(order.id!)),
                  ] else if (order.status == 'Đang chuẩn bị') ...[
                    _actionBtn(Icons.local_shipping_outlined, 'Giao xe', Colors.blue, () => _updateStatus(order.id!, 'Đang giao')),
                  ] else if (order.status == 'Đang giao') ...[
                    _actionBtn(Icons.check_circle, 'Hoàn thành', Colors.purple, () => _updateStatus(order.id!, 'Hoàn thành')),
                  ],
                  const SizedBox(width: 8),
                  _actionBtn(Icons.visibility_outlined, 'Chi tiết', const Color(0xFFFF6B35), () {
                    OrderDetailPage.currentOrder = order;
                    if (widget.onNavigate != null) widget.onNavigate!('/orders/detail');
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(IconData icon, String tooltip, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Chờ xác nhận': return Colors.orange;
      case 'Đang chuẩn bị': return Colors.blue;
      case 'Đang giao': return Colors.purple;
      case 'Hoàn thành': return Colors.green;
      case 'Đã hủy': return Colors.red;
      default: return Colors.grey;
    }
  }

  Widget _buildPagination() {
    int totalPages = (_filtered.length / _itemsPerPage).ceil();
    if (totalPages <= 1) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('Trang $_currentPage / $totalPages', style: const TextStyle(color: Colors.grey)),
          const SizedBox(width: 16),
          IconButton(
            onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            onPressed: _currentPage < totalPages ? () => setState(() => _currentPage++) : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
