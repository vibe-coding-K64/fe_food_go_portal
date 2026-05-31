import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order_model.dart';
import 'api_constants.dart';

class OrderApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ))..interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final token = await user.getIdToken();
          options.headers['Authorization'] = 'Bearer $token';
          options.headers['X-Firebase-Token'] = token;
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

  Future<void> updateOrderStatus(String id, String status) async {
    try {
      await _dio.patch('/orders/$id/status', data: {'status': status});
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }
}
