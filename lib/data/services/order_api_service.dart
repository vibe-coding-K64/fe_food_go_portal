import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';
import '../models/order_model.dart';
import 'api_constants.dart';
import 'notification_service.dart';

class OrderApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ))..interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await AuthService().getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));

  Future<List<Order>> getOrdersByStoreId(String storeId) async {
    try {
      final response = await _dio.get('/orders', queryParameters: {'storeId': storeId});
      final List<dynamic> data = response.data;
      return data.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  Future<Order> getOrderById(String id) async {
    try {
      final response = await _dio.get('/orders/$id');
      return Order.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get order detail: $e');
    }
  }

  Future<void> updateOrderStatus(String id, String statusString) async {
    try {
      String statusCode = statusString;
      switch (statusString) {
        case 'Chờ xác nhận': statusCode = '0'; break;
        case 'Đang chuẩn bị': statusCode = '1'; break;
        case 'Đang giao': statusCode = '2'; break;
        case 'Hoàn thành': statusCode = '3'; break;
        case 'Đã hủy': statusCode = '4'; break;
      }
      await _dio.put('/orders/$id/status', data: {'status': statusCode});
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  Future<void> confirmOrder(String orderId) async {
    try {
      await _dio.post('/stores/orders/$orderId/confirm');
    } catch (e) {
      throw Exception('Failed to confirm order: $e');
    }
  }
}

class OrderBadgeService {
  static final OrderBadgeService _instance = OrderBadgeService._internal();
  factory OrderBadgeService() => _instance;

  final ValueNotifier<int> pendingCountNotifier = ValueNotifier(0);
  Timer? _pollingTimer;
  final OrderApiService _apiService = OrderApiService();

  // Theo dõi đơn hàng đã biết để phát hiện đơn mới / hủy
  Set<String> _knownPendingOrderIds = {};
  bool _isFirstFetch = true;

  OrderBadgeService._internal() {
    AuthService.authStateNotifier.addListener(_onAuthStateChanged);
    startPolling();
  }

  void _onAuthStateChanged() {
    if (AuthService.authStateNotifier.value) {
      _isFirstFetch = true;
      _knownPendingOrderIds = {};
      fetchPendingCount();
    } else {
      _isFirstFetch = true;
      _knownPendingOrderIds = {};
      pendingCountNotifier.value = 0;
    }
  }

  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (AuthService.authStateNotifier.value) {
        fetchPendingCount();
      }
    });
  }

  void dispose() {
    _pollingTimer?.cancel();
  }

  Future<void> fetchPendingCount() async {
    try {
      if (!AuthService.authStateNotifier.value) return;
      final storeId = await AuthService().getStoreId();
      if (storeId != null) {
        final orders = await _apiService.getOrdersByStoreId(storeId);
        final pendingOrders = orders.where((o) => o.statusValue == 0).toList();
        final cancelledOrders = orders.where((o) => o.statusValue == 4).toList();
        final count = pendingOrders.length;
        pendingCountNotifier.value = count;

        final currentPendingIds = pendingOrders.map((o) => o.id).whereType<String>().toSet();
        final currentCancelledIds = cancelledOrders.map((o) => o.id).whereType<String>().toSet();

        if (!_isFirstFetch) {
          // Phát hiện đơn hàng mới (pending mới xuất hiện)
          final newOrderIds = currentPendingIds.difference(_knownPendingOrderIds);
          for (final newId in newOrderIds) {
            final order = pendingOrders.firstWhere((o) => o.id == newId);
            final receiverName = order.receiverName ?? 'Khách hàng';
            final code = order.code ?? newId.substring(newId.length > 6 ? newId.length - 6 : 0).toUpperCase();
            final amount = order.finalAmount ?? order.totalAmount ?? 0;

            // Tạo thông báo đơn hàng mới trên chuông
            NotificationService().addLocalNotification({
              'id': 'new_order_$newId',
              'type': 21,
              'title': '🛒 Đơn hàng mới từ $receiverName',
              'body': '#$code · ${amount > 0 ? "${amount.toStringAsFixed(0)}đ" : ""} · Chờ xác nhận',
              'orderId': newId,
              'isRead': false,
              'createdAt': DateTime.now().toIso8601String(),
            });
          }

          // Phát hiện đơn hàng bị hủy (từ pending biến mất và xuất hiện ở cancelled)
          final disappearedIds = _knownPendingOrderIds.difference(currentPendingIds);
          for (final goneId in disappearedIds) {
            if (currentCancelledIds.contains(goneId)) {
              final order = cancelledOrders.firstWhere((o) => o.id == goneId);
              final code = order.code ?? goneId.substring(goneId.length > 6 ? goneId.length - 6 : 0).toUpperCase();
              
              NotificationService().addLocalNotification({
                'id': 'cancel_order_$goneId',
                'type': 4,
                'title': 'Đơn hàng #$code đã bị hủy',
                'body': 'Khách hàng đã hủy đơn hàng này.',
                'orderId': goneId,
                'isRead': false,
                'createdAt': DateTime.now().toIso8601String(),
              });
            }
          }
        }

        _knownPendingOrderIds = currentPendingIds;
        _isFirstFetch = false;
      }
    } catch (e) {
      // ignore
    }
  }
}
