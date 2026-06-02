import 'package:dio/dio.dart';
import 'auth_service.dart';
import '../models/order_model.dart';
import 'api_constants.dart';

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
