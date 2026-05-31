import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/review_model.dart';
import 'api_constants.dart';

class ReviewApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
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

  Future<List<Review>> getStoreReviews(String storeId) async {
    try {
      final response = await _dio.get('/reviews', queryParameters: {'storeId': storeId});
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Review.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Lỗi kết nối Server: $e');
    }
  }

  Future<Review> replyReview(String reviewId, String replyComment) async {
    try {
      final response = await _dio.put(
        '/reviews/$reviewId/reply',
        data: {'replyComment': replyComment},
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Review.fromJson(response.data['data']);
      }
      throw Exception('Phản hồi thất bại');
    } catch (e) {
      throw Exception('Lỗi kết nối Server: $e');
    }
  }
}
