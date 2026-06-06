import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'api_constants.dart';
import 'auth_service.dart';

class ImageUploadService {
  final ImagePicker _picker = ImagePicker();
  late final Dio _dio;

  ImageUploadService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await AuthService().getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  /// Cho phép người dùng chọn một ảnh từ máy tính (hoặc thư viện ảnh).
  /// Trả về [XFile] nếu chọn thành công, ngược lại trả về null.
  Future<XFile?> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );
      return image;
    } catch (e) {
      print('Lỗi khi chọn ảnh: $e');
      return null;
    }
  }

  /// Tải [XFile] lên Spring Boot Backend API.
  /// Trả về URL tải xuống nếu thành công, ném lỗi nếu thất bại.
  Future<String> uploadImage(XFile file, {String folderPath = 'uploads'}) async {
    try {
      // Đọc bytes từ file
      Uint8List fileBytes = await file.readAsBytes();
      
      FormData formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          fileBytes,
          filename: file.name.isEmpty ? 'upload.jpg' : file.name,
        ),
        'folder': folderPath,
      });

      // Upload file lên API Backend
      final response = await _dio.post('/upload', data: formData);

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data']; // URL trả về từ API
      }
      
      throw response.data['message'] ?? 'Lỗi không xác định khi tải ảnh';
    } catch (e) {
      print('Lỗi khi upload ảnh lên Backend: $e');
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          throw 'Lỗi Server: ${data['message']}';
        }
        throw 'Lỗi kết nối Backend: ${e.message}';
      }
      if (e is String) {
        throw e;
      }
      throw 'Lỗi không xác định: ${e.toString()}';
    }
  }
}
