# FoodGo Merchant Portal (FE)
Dự án Frontend dành cho nền tảng Quản lý Cửa hàng (Merchant Portal) của hệ thống FoodGo, được xây dựng bằng Flutter. Ứng dụng cung cấp các tính năng quản lý thực đơn, đơn hàng, thống kê doanh thu và quản lý ví điện tử dành cho Chủ quán.
## Công nghệ sử dụng
- **Framework:** Flutter
- **Ngôn ngữ:** Dart
- **Quản lý trạng thái & UI:** StatefulWidget, Flutter Material
- **Bản đồ & Định vị:** `flutter_map`, `geolocator`
- **Kết nối API (Network):** `dio`
- **Dịch vụ Backend (BaaS):** Firebase (Auth, Core, Storage)
- **Lưu trữ dữ liệu cục bộ:** `shared_preferences`
- **Biểu đồ thống kê:** `fl_chart`
- **Đa ngôn ngữ:** `easy_localization`
## Phiên bản Môi trường
Để đảm bảo project hoạt động ổn định, vui lòng sử dụng đúng hoặc cao hơn các phiên bản sau:
- **Dart SDK:** `>= 3.11.1 < 4.0.0`
- **Flutter SDK:** `>= 3.24.0` (Khuyên dùng nhánh Stable mới nhất)
## Các Dependencies / Packages chính
Dưới đây là các package chính được cấu hình trong `pubspec.yaml`:
- `dio: ^5.9.2` (Call API)
- `firebase_core: ^4.9.0`
- `firebase_auth: ^6.5.1`
- `firebase_storage: ^13.4.2`
- `fl_chart: ^0.66.0` (Vẽ biểu đồ doanh thu)
- `flutter_map: ^8.3.0` & `latlong2: ^0.9.1` (Hiển thị bản đồ)
- `geolocator: ^14.0.2`
- `image_picker: ^1.2.2` (Tải ảnh món ăn)
- `shared_preferences: ^2.5.5`
## Các bước Cài đặt và Chạy Project
### 1. Yêu cầu trước khi cài đặt
- Đã cài đặt [Flutter SDK](https://docs.flutter.dev/get-started/install).
- Đã cài đặt Android Studio, VS Code hoặc IntelliJ IDEA.
- Đã thiết lập Web Server (Chrome) hoặc Emulator/Device thật để test.
### 2. Cài đặt Project
Mở Terminal tại thư mục gốc của project (`fe_food_go_portal`) và chạy các lệnh sau:
```bash
# Xóa cache cũ (Nếu có lỗi)
flutter clean
# Cài đặt toàn bộ thư viện (dependencies)
flutter pub get
```
### 3. Chạy Project
Vì đây là phiên bản Portal (Quản lý cửa hàng), khuyến nghị chạy trên môi trường **Web** hoặc **Tablet/Desktop** để có trải nghiệm UI tốt nhất:
```bash
# Chạy trên trình duyệt Chrome
flutter run -d chrome
# Hoặc nếu chạy trên máy ảo Android / iOS:
flutter run
```
## Tài khoản Test 
Sử dụng tài khoản sau để đăng nhập vào hệ thống quản trị cửa hàng:
- **Email:** `luudinhnghia30012005@gmail.com` 
- **Mật khẩu:** `nghia123`
- **Role:** Merchant (3)
*(Lưu ý: Nếu Firebase Auth đã bị reset, vui lòng đăng ký một tài khoản mới trực tiếp trên màn hình Đăng ký).*
## Các Lưu ý quan trọng để Project hoạt động

1. **Cấu hình API Backend (baseUrl):**
   Trước khi chạy project, bạn cần cấu hình lại đường dẫn API để ứng dụng trỏ đúng vào server Backend của bạn. Hãy mở file `lib/data/services/api_constants.dart` và thay đổi dòng sau:
   ```dart
   static const String baseUrl = 'https://be-foodgo.canluaz.io.vn/api'; 
   // (Hoặc đổi thành http://localhost:8080/api nếu chạy máy chủ nội bộ ở Backend)
   ```

2. **Cấu hình Firebase:** 
   Project sử dụng Firebase, do đó cần phải có file `firebase_options.dart` (được sinh ra bởi FlutterFire CLI) đặt trong thư mục `lib/`. Nếu bạn clone project sang máy khác, hãy chạy lệnh cấu hình lại Firebase nếu cần thiết.

3. **CORS trên Web:** 
   Nếu bạn chạy trên nền tảng Web (`flutter run -d chrome`) và gặp lỗi **XMLHttpRequest error** khi gọi API hoặc tải ảnh từ Firebase Storage, hãy chạy lệnh sau để vô hiệu hóa CORS bảo mật của trình duyệt khi test:
   ```bash
   flutter run -d chrome --web-browser-flag "--disable-web-security"
   ```
3. **Đồng bộ Backend:**
   Đảm bảo rằng hệ thống Backend Spring Boot (`be-foodgo`) đang được bật (run local) tại `localhost` hoặc server tương ứng trước khi thao tác trên Portal để các tính năng API (như load sản phẩm, rút tiền) hoạt động chính xác.
4. **Biên dịch bản Release (Production):**
   Khi deploy lên Web Hosting, sử dụng lệnh:
   ```bash
   flutter build web --release
   ```
