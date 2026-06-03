import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';
import 'auth_service.dart';
import '../../main.dart';

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
  List<String> _knownNotificationIds = [];
  bool _isFirstFetch = true;

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
    AuthService.authStateNotifier.addListener(_onAuthStateChanged);
    _startPolling();
  }

  void _onAuthStateChanged() {
    if (AuthService.authStateNotifier.value) {
      // Vừa login: reset để không bị hiển thị snackbar cho các thông báo cũ
      _isFirstFetch = true;
      fetchNotifications();
    } else {
      // Vừa logout: xóa trạng thái
      _isFirstFetch = true;
      _knownNotificationIds = [];
      notificationsNotifier.value = [];
      unreadCountNotifier.value = 0;
    }
  }

  void _startPolling() {
    fetchNotifications();
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
    // Không fetch nếu chưa đăng nhập
    if (!AuthService.authStateNotifier.value) return;
    try {
      final response = await _dio.get('/merchants/notifications');
      if (response.statusCode == 200 && response.data['data'] != null) {
        final List<dynamic> data = response.data['data'];
        List<Map<String, dynamic>> parsedList = data.map((e) => e as Map<String, dynamic>).toList();
        
        final prefs = await SharedPreferences.getInstance();
        final bool showOrder = prefs.getBool('setting_order') ?? true;
        final bool showReview = prefs.getBool('setting_review') ?? true;
        final bool showPayment = prefs.getBool('setting_payment') ?? true;

        // Hiển thị tất cả thông báo (cả chưa đọc và đã đọc)
        notificationsNotifier.value = parsedList;

        if (!_isFirstFetch) {
          final newIds = parsedList.map((e) => e['id'].toString()).toList();
          final arrivingIds = newIds.where((id) => !_knownNotificationIds.contains(id)).toList();
          if (arrivingIds.isNotEmpty) {
            final newNotifs = parsedList.where((e) => arrivingIds.contains(e['id'].toString())).toList();
            for (var notif in newNotifs) {
              _showNotificationSnackbar(notif);
            }
          }
          _knownNotificationIds = newIds;
        } else {
          _knownNotificationIds = parsedList.map((e) => e['id'].toString()).toList();
          _isFirstFetch = false;
        }
        
        // Chỉ đếm số lượng chưa đọc đối với các loại được bật trong cài đặt
        unreadCountNotifier.value = parsedList.where((n) {
          if (n['isRead'] == true) return false;
          
          final type = n['type']?.toString();
          if (type == '1' || type == '4') return showOrder;
          if (type == '2') return showPayment;
          if (type == '3') return showReview;
          return true;
        }).length;
      }
    } catch (e) {
      debugPrint('Lỗi khi fetch thông báo: $e');
    }
  }

  Future<void> markAsRead(String id) async {
    // Optimistic UI update
    final currentList = notificationsNotifier.value;
    final index = currentList.indexWhere((n) => n['id'] == id);
    if (index != -1) {
      final newList = List<Map<String, dynamic>>.from(currentList);
      newList[index] = {...newList[index], 'isRead': true};
      notificationsNotifier.value = newList;
      
      final prefs = await SharedPreferences.getInstance();
      final bool showOrder = prefs.getBool('setting_order') ?? true;
      final bool showReview = prefs.getBool('setting_review') ?? true;
      final bool showPayment = prefs.getBool('setting_payment') ?? true;
      
      unreadCountNotifier.value = newList.where((n) {
        if (n['isRead'] == true) return false;
        final type = n['type']?.toString();
        if (type == '1' || type == '4') return showOrder;
        if (type == '2') return showPayment;
        if (type == '3') return showReview;
        return true;
      }).length;
    }

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
    // Optimistic UI update
    notificationsNotifier.value = [];
    unreadCountNotifier.value = 0;

    try {
      final response = await _dio.put('/merchants/notifications/read-all');
      if (response.statusCode == 200) {
        await fetchNotifications();
      }
    } catch (e) {
      debugPrint('Lỗi đánh dấu tất cả đã đọc: $e');
    }
  }

  void _showNotificationSnackbar(Map<String, dynamic> notif) {
    final context = MyApp.navigatorKey.currentContext;
    if (context == null) {
      // fallback to scaffoldMessenger if navigator not ready
      final messenger = MyApp.scaffoldMessengerKey.currentState;
      if (messenger == null) return;
      final title = notif['title']?.toString() ?? 'Thông báo mới';
      final body = notif['body']?.toString() ?? '';
      messenger.showSnackBar(SnackBar(
        content: Text('$title${body.isNotEmpty ? '\n$body' : ''}'),
        backgroundColor: const Color(0xFFFF6B35),
        duration: const Duration(seconds: 5),
      ));
      return;
    }

    final title = notif['title']?.toString() ?? 'Thông báo mới';
    final body = notif['body']?.toString() ?? '';

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _TopNotificationToast(
        title: title,
        body: body,
        onDismiss: () {
          try { entry.remove(); } catch (_) {}
        },
      ),
    );

    Overlay.of(context).insert(entry);
    Future.delayed(const Duration(seconds: 6), () {
      try { entry.remove(); } catch (_) {}
    });
  }
}

class _TopNotificationToast extends StatefulWidget {
  final String title;
  final String body;
  final VoidCallback onDismiss;

  const _TopNotificationToast({
    required this.title,
    required this.body,
    required this.onDismiss,
  });

  @override
  State<_TopNotificationToast> createState() => _TopNotificationToastState();
}

class _TopNotificationToastState extends State<_TopNotificationToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _slide = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: Colors.transparent,
            child: Container(
              width: 340,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B35).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications_active, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (widget.body.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.body,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onDismiss,
                    child: const Icon(Icons.close, color: Colors.white70, size: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
