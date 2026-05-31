import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/wallet_model.dart';
import '../models/transaction_model.dart';
import 'api_constants.dart';

class WalletApiService {
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

  Future<Wallet> getWallet() async {
    try {
      final response = await _dio.get('/merchants/wallet');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Wallet.fromJson(response.data['data']);
      }
      throw Exception('Không thể lấy thông tin ví');
    } catch (e) {
      throw Exception('Lỗi kết nối Server: $e');
    }
  }

  Future<List<Transaction>> getTransactions({int page = 0, int size = 20}) async {
    try {
      final response = await _dio.get(
        '/merchants/transactions',
        queryParameters: {'page': page, 'size': size},
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Transaction.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Lỗi kết nối Server: $e');
    }
  }

  Future<Transaction> requestWithdraw(double amount) async {
    try {
      final response = await _dio.post(
        '/merchants/withdraw',
        data: {'amount': amount},
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Transaction.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Rút tiền thất bại');
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Rút tiền thất bại');
      }
      throw Exception('Lỗi kết nối Server: $e');
    } catch (e) {
      throw Exception('Lỗi xử lý: $e');
    }
  }
}
