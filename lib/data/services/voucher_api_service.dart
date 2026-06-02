import 'package:dio/dio.dart';
import 'auth_service.dart';
import '../models/voucher_model.dart';
import 'api_constants.dart';

class VoucherApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ))..interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await AuthService().getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));

  Future<List<Voucher>> getAllVouchers({String? storeId}) async {
    try {
      final String url = storeId != null ? '/vouchers/store/$storeId' : '/vouchers';
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        if (storeId != null && response.data is Map && response.data['success'] == true) {
          final List<dynamic> data = response.data['data'];
          return data.map((json) => Voucher.fromJson(json)).toList();
        } else if (storeId == null && response.data is List) {
          final List<dynamic> data = response.data;
          return data.map((json) => Voucher.fromJson(json)).toList();
        }
      }
      throw Exception('Failed to load vouchers');
    } catch (e) {
      throw Exception('Lỗi kết nối Server: $e');
    }
  }

  Future<Voucher> getVoucher(String id) async {
    try {
      final response = await _dio.get('/vouchers/$id');
      if (response.statusCode == 200) {
        return Voucher.fromJson(response.data);
      }
      throw Exception('Failed to load voucher');
    } catch (e) {
      throw Exception('Lỗi kết nối Server: $e');
    }
  }

  Future<void> createVoucher(Voucher voucher) async {
    try {
      await _dio.post('/vouchers', data: voucher.toJson());
    } catch (e) {
      throw Exception('Lỗi tạo voucher: $e');
    }
  }

  Future<void> updateVoucher(String id, Voucher voucher) async {
    try {
      await _dio.put('/vouchers/$id', data: voucher.toJson());
    } catch (e) {
      throw Exception('Lỗi cập nhật voucher: $e');
    }
  }

  Future<void> deleteVoucher(String id) async {
    try {
      await _dio.delete('/vouchers/$id');
    } catch (e) {
      throw Exception('Lỗi xoá voucher: $e');
    }
  }
}
