import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // Lấy User hiện tại (nếu đã login)
  User? get currentUser => _firebaseAuth.currentUser;

  // Stream lắng nghe thay đổi trạng thái đăng nhập
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Đăng nhập và kiểm tra quyền
  Future<UserCredential> login(String email, String password) async {
    try {
      final cred = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Gọi API kiểm tra quyền người bán
      final response = await _dio.get('/auth/check-merchant', queryParameters: {
        'uid': cred.user!.uid,
      });

      if (response.statusCode == 200 && response.data['isMerchant'] == true) {
        final prefs = await SharedPreferences.getInstance();
        if (response.data['storeId'] != null) {
          await prefs.setString('storeId', response.data['storeId']);
        } else {
          await prefs.remove('storeId');
        }

        if (response.data['fullName'] != null) {
          await prefs.setString('merchant_fullName', response.data['fullName']);
        }
        if (response.data['email'] != null) {
          await prefs.setString('merchant_email', response.data['email']);
        }
        if (response.data['photoUrl'] != null) {
          await prefs.setString('merchant_photoUrl', response.data['photoUrl']);
        }
        if (response.data['phoneNumber'] != null) {
          await prefs.setString('merchant_phoneNumber', response.data['phoneNumber']);
        }
        if (response.data['taxCode'] != null) {
          await prefs.setString('merchant_taxCode', response.data['taxCode']);
        }

        return cred;
      } else {
        await _firebaseAuth.signOut();
        throw Exception('Tài khoản của bạn không có quyền truy cập hệ thống dành cho Người bán.');
      }
    } catch (e) {
      throw Exception('Lỗi đăng nhập: ${e.toString()}');
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
      throw Exception('Lỗi đăng ký: ${e.toString()}');
    }
  }

  // Gửi email khôi phục mật khẩu
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Lỗi gửi email khôi phục: ${e.toString()}');
    }
  }

  // Lấy storeId đã lưu
  Future<String?> getStoreId() async {
    final prefs = await SharedPreferences.getInstance();
    String? storeId = prefs.getString('storeId');
    
    if (storeId == null && _firebaseAuth.currentUser != null) {
      try {
        final response = await _dio.get('/auth/check-merchant', queryParameters: {
          'uid': _firebaseAuth.currentUser!.uid,
        });
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

  // Đăng xuất
  Future<void> updateMerchantProfile(String businessName, String phoneNumber, String taxCode) async {
    final uid = _firebaseAuth.currentUser?.uid;
    final prefs = await SharedPreferences.getInstance();
    
    if (uid == null) throw Exception('Chưa đăng nhập');
    
    final response = await _dio.put(
      '/customers/merchant-profile',
      queryParameters: {'uid': uid},
      data: {
        'businessName': businessName,
        'phoneNumber': phoneNumber,
        'taxCode': taxCode,
      },
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      await prefs.setString('merchant_fullName', businessName);
      await prefs.setString('merchant_phoneNumber', phoneNumber);
      await prefs.setString('merchant_taxCode', taxCode);
    } else {
      throw Exception('Lỗi khi cập nhật hồ sơ');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('storeId');
    await prefs.remove('merchant_fullName');
    await prefs.remove('merchant_email');
    await prefs.remove('merchant_photoUrl');
    await prefs.remove('merchant_phoneNumber');
    await prefs.remove('merchant_taxCode');
    await _firebaseAuth.signOut();
  }

  // Đổi mật khẩu
  Future<void> changePassword(String oldPassword, String newPassword) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.email == null) throw Exception('Chưa đăng nhập');
    
    try {
      // 1. Re-authenticate & update Firebase Auth
      final cred = EmailAuthProvider.credential(email: user.email!, password: oldPassword);
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
    } catch (e) {
      if (e is FirebaseAuthException && e.code == 'wrong-password') {
        throw Exception('Mật khẩu cũ không chính xác');
      }
      throw Exception('Lỗi đổi mật khẩu: ${e.toString()}');
    }
  }

  // Lấy thông tin hồ sơ đã lưu
  Future<Map<String, String?>> getMerchantProfile() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Thử cập nhật dữ liệu mới nhất từ backend
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      try {
        final response = await _dio.get('/auth/check-merchant', queryParameters: {
          'uid': user.uid,
        });
        if (response.statusCode == 200 && response.data['isMerchant'] == true) {
          if (response.data['taxCode'] != null) await prefs.setString('merchant_taxCode', response.data['taxCode']);
          if (response.data['fullName'] != null) await prefs.setString('merchant_fullName', response.data['fullName']);
          if (response.data['phoneNumber'] != null) await prefs.setString('merchant_phoneNumber', response.data['phoneNumber']);
          if (response.data['photoUrl'] != null) await prefs.setString('merchant_photoUrl', response.data['photoUrl']);
          if (response.data['email'] != null) await prefs.setString('merchant_email', response.data['email']);
        }
      } catch (e) {
        // Bỏ qua lỗi mạng, dùng cache
      }
    }

    return {
      'fullName': prefs.getString('merchant_fullName'),
      'email': prefs.getString('merchant_email'),
      'photoUrl': prefs.getString('merchant_photoUrl'),
      'phoneNumber': prefs.getString('merchant_phoneNumber'),
      'taxCode': prefs.getString('merchant_taxCode'),
    };
  }

}
