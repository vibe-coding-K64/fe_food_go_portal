import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  AuthService._internal() {
    _initAuthState();
  }

  static final ValueNotifier<bool> authStateNotifier = ValueNotifier<bool>(false);
  static final ValueNotifier<int> profileUpdateNotifier = ValueNotifier<int>(0);

  Future<void> _initAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token != null) {
      authStateNotifier.value = true;
    } else {
      // Tự động đăng nhập vào tài khoản user_004 (Lưu Nghĩa) để bỏ qua màn hình Login
      try {
        await login('luudinhnghia30012005@gmail.com', 'nghia123');
      } catch (e) {
        print('Auto login failed: $e');
      }
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  // Đăng nhập và kiểm tra quyền
  Future<void> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200 && response.data['token'] != null) {
        final token = response.data['token'];
        final user = response.data['user'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        await prefs.setString('user_id', user['id']);
        
        if (response.data['refreshToken'] != null) {
          await prefs.setString('jwt_refresh_token', response.data['refreshToken']);
        }

        // Gọi API kiểm tra quyền người bán
        final checkResponse = await _dio.get('/auth/check-merchant', 
          queryParameters: {'uid': user['id']},
          options: Options(headers: {'Authorization': 'Bearer $token'})
        );

        if (checkResponse.statusCode == 200 && checkResponse.data['isMerchant'] == true) {
          if (checkResponse.data['storeId'] != null) {
            await prefs.setString('storeId', checkResponse.data['storeId']);
          } else {
            await prefs.remove('storeId');
          }

          if (checkResponse.data['fullName'] != null) await prefs.setString('merchant_fullName', checkResponse.data['fullName']);
          if (checkResponse.data['email'] != null) await prefs.setString('merchant_email', checkResponse.data['email']);
          if (checkResponse.data['photoUrl'] != null) await prefs.setString('merchant_photoUrl', checkResponse.data['photoUrl']);
          if (checkResponse.data['phoneNumber'] != null) await prefs.setString('merchant_phoneNumber', checkResponse.data['phoneNumber']);
          if (checkResponse.data['taxCode'] != null) await prefs.setString('merchant_taxCode', checkResponse.data['taxCode']);
          
          authStateNotifier.value = true;
        } else {
          await logout();
          throw Exception('Tài khoản của bạn không có quyền truy cập hệ thống dành cho Người bán.');
        }
      }
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        final errData = e.response?.data;
        if (errData is Map && errData['message'] != null) {
           throw Exception(errData['message']);
        }
      }
      throw Exception('Email hoặc mật khẩu không đúng');
    }
  }

  // Đăng ký (gọi qua Spring Boot)
  Future<void> registerMerchant({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      final response = await _dio.post('/auth/register-merchant', data: {
        'email': email,
        'password': password,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
      });

      if (response.statusCode != 200) {
        throw Exception(response.data.toString());
      }
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        final errData = e.response?.data;
        if (errData is Map && errData['message'] != null) {
           throw Exception(errData['message']);
        }
      }
      throw Exception('Lỗi đăng ký: ${e.toString()}');
    }
  }

  // Lấy storeId đã lưu
  Future<String?> getStoreId() async {
    final prefs = await SharedPreferences.getInstance();
    String? storeId = prefs.getString('storeId');
    final token = prefs.getString('jwt_token');
    final uid = prefs.getString('user_id');
    
    if (storeId == null && token != null && uid != null) {
      try {
        final response = await _dio.get('/auth/check-merchant', queryParameters: {
          'uid': uid,
        }, options: Options(headers: {'Authorization': 'Bearer $token'}));
        if (response.statusCode == 200 && response.data['isMerchant'] == true) {
          if (response.data['storeId'] != null) {
            storeId = response.data['storeId'];
            await prefs.setString('storeId', storeId!);
            
            if (response.data['taxCode'] != null) await prefs.setString('merchant_taxCode', response.data['taxCode']);
            if (response.data['fullName'] != null) await prefs.setString('merchant_fullName', response.data['fullName']);
            if (response.data['phoneNumber'] != null) await prefs.setString('merchant_phoneNumber', response.data['phoneNumber']);
            if (response.data['photoUrl'] != null) await prefs.setString('merchant_photoUrl', response.data['photoUrl']);
            if (response.data['email'] != null) await prefs.setString('merchant_email', response.data['email']);
          }
        }
      } catch (e) {
        // Ignore
      }
    }
    return storeId;
  }

  // Lưu storeId mới (sau khi tạo quán thành công)
  Future<void> saveStoreId(String storeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('storeId', storeId);
  }

  Future<void> updateMerchantProfile(String businessName, String phoneNumber, String taxCode, [String? photoUrl]) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final uid = prefs.getString('user_id');
    
    if (token == null || uid == null) throw Exception('Chưa đăng nhập');
    
    final response = await _dio.put(
      '/customers/merchant-profile',
      queryParameters: {'uid': uid},
      data: {
        'businessName': businessName,
        'phoneNumber': phoneNumber,
        'taxCode': taxCode,
        if (photoUrl != null) 'photoUrl': photoUrl,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      await prefs.setString('merchant_fullName', businessName);
      await prefs.setString('merchant_phoneNumber', phoneNumber);
      await prefs.setString('merchant_taxCode', taxCode);
      if (photoUrl != null) {
        await prefs.setString('merchant_photoUrl', photoUrl);
      } else {
        await prefs.remove('merchant_photoUrl');
      }
      profileUpdateNotifier.value++;
    } else {
      throw Exception('Lỗi khi cập nhật hồ sơ');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('jwt_refresh_token');
    await prefs.remove('user_id');
    await prefs.remove('storeId');
    await prefs.remove('merchant_fullName');
    await prefs.remove('merchant_email');
    await prefs.remove('merchant_photoUrl');
    await prefs.remove('merchant_phoneNumber');
    await prefs.remove('merchant_taxCode');
    authStateNotifier.value = false;
  }

  // Lấy thông tin hồ sơ đã lưu
  Future<Map<String, String?>> getMerchantProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'fullName': prefs.getString('merchant_fullName'),
      'email': prefs.getString('merchant_email'),
      'photoUrl': prefs.getString('merchant_photoUrl'),
      'phoneNumber': prefs.getString('merchant_phoneNumber'),
      'taxCode': prefs.getString('merchant_taxCode'),
    };
  }

  // Xử lý lỗi chung
  void _handleError(dynamic e, String defaultMessage) {
    if (e is DioException && e.response?.data != null) {
      final errData = e.response?.data;
      if (errData is Map && errData['message'] != null) {
         throw Exception(errData['message']);
      }
    }
    throw Exception(defaultMessage);
  }

  // 1. Quên mật khẩu: Gửi OTP
  Future<void> sendOtp(String email) async {
    try {
      await _dio.post('/auth/send-otp', data: {'emailOrPhone': email});
    } catch (e) {
      _handleError(e, 'Hệ thống gửi mã đang bảo trì hoặc email không tồn tại.');
    }
  }

  // 2. Quên mật khẩu: Xác nhận OTP
  Future<String> verifyOtp(String email, String otp) async {
    try {
      final response = await _dio.post('/auth/verify-otp', data: {'emailOrPhone': email, 'otpCode': otp});
      if (response.statusCode == 200 && response.data['tempToken'] != null) {
        return response.data['tempToken'];
      }
      throw Exception('Lỗi xác nhận OTP');
    } catch (e) {
      _handleError(e, 'Mã OTP không đúng hoặc đã hết hạn.');
      throw e; // _handleError already throws, but compiler might complain
    }
  }

  // 3. Quên mật khẩu: Đặt lại mật khẩu
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await _dio.post('/auth/reset-password', data: {'tempToken': token, 'newPassword': newPassword});
    } catch (e) {
      _handleError(e, 'Lỗi đặt lại mật khẩu.');
    }
  }

  // Đăng ký: Gửi OTP xác thực email
  Future<void> sendVerifyEmailOtp(String email) async {
    try {
      await _dio.post('/auth/send-verify-email-otp', data: {'email': email});
    } catch (e) {
      _handleError(e, 'Không thể gửi mã xác thực. Vui lòng thử lại.');
    }
  }

  // Đăng ký: Xác thực OTP email
  Future<void> verifyEmailOtp(String email, String otp) async {
    try {
      await _dio.post('/auth/verify-email', data: {'email': email, 'otpCode': otp});
    } catch (e) {
      _handleError(e, 'Mã xác thực không đúng hoặc đã hết hạn.');
    }
  }

  // Đổi mật khẩu
  Future<void> changePassword(String oldPassword, String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    
    if (token == null) throw Exception('Chưa đăng nhập');
    
    try {
      await _dio.put(
        '/customers/password',
        data: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      _handleError(e, 'Đổi mật khẩu thất bại. Vui lòng kiểm tra lại mật khẩu cũ.');
    }
  }
}
