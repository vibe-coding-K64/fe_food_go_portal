import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';
import 'auth_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  final ValueNotifier<List<Map<String, dynamic>>> notificationsNotifier = ValueNotifier([]);
  final ValueNotifier<int> unreadCountNotifier = ValueNotifier(0);

  Timer? _pollingTimer;

  NotificationService._internal() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
    
    // Bắt đầu polling
    _startPolling();
  }

  void _startPolling() {
    fetchNotifications(); // Gọi ngay lần đầu
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (AuthService.authStateNotifier.value) {
        fetchNotifications();
      }
    });
  }

  void dispose() {
    _pollingTimer?.cancel();
  }

  Future<void> fetchNotifications() async {
    try {
      final response = await _dio.get('/merchants/notifications');
      if (response.statusCode == 200 && response.data['data'] != null) {
        final List<dynamic> data = response.data['data'];
        final List<Map<String, dynamic>> parsedList = data.map((e) => e as Map<String, dynamic>).toList();
        
        notificationsNotifier.value = parsedList;
        unreadCountNotifier.value = parsedList.where((n) => n['isRead'] == false).length;
      }
    } catch (e) {
      debugPrint('Lỗi khi fetch thông báo: $e');
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final response = await _dio.put('/merchants/notifications/$id/read');
      if (response.statusCode == 200) {
        await fetchNotifications(); // Cập nhật lại list ngay lập tức
      }
    } catch (e) {
      debugPrint('Lỗi đánh dấu đã đọc thông báo: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final response = await _dio.put('/merchants/notifications/read-all');
      if (response.statusCode == 200) {
        await fetchNotifications();
      }
    } catch (e) {
      debugPrint('Lỗi đánh dấu tất cả đã đọc: $e');
    }
  }
}
