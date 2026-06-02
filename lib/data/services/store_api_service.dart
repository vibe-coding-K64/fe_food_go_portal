import 'package:dio/dio.dart';
import 'auth_service.dart';
import '../models/store_model.dart';
import 'api_constants.dart';

class StoreApiService {
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

  // Lấy thông tin quán theo ID
  Future<Store> getStoreById(String id) async {
    try {
      final response = await _dio.get('/stores/$id');
      if (response.statusCode == 200) {
        return Store.fromJson(response.data);
      }
      throw 'Không tải được gian hàng';
    } catch (e) {
      throw 'Lỗi tải gian hàng: $e';
    }
  }

  // Cập nhật thông tin quán
  Future<Store> updateStore(String id, Store store) async {
    try {
      final response = await _dio.put('/stores/$id', data: store.toJson());
      if (response.statusCode == 200 && response.data['data'] != null) {
        return Store.fromJson(response.data['data']);
      }
      throw 'Cập nhật thất bại';
    } catch (e) {
      throw 'Lỗi cập nhật: $e';
    }
  }

  // Tạo quán mới
  Future<Store> createStore(String uid, Store store) async {
    try {
      final response = await _dio.post('/stores/merchant/$uid', data: store.toJson());
      if (response.statusCode == 200 && response.data != null) {
        return Store.fromJson(response.data);
      }
      throw 'Khởi tạo thất bại';
    } catch (e) {
      throw 'Lỗi khởi tạo: $e';
    }
  }
}
