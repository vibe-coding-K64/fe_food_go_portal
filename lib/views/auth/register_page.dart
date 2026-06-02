import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  const RegisterPage({super.key, required this.onLoginSuccess});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isObscure = true;
  int _step = 1; // 1: Info, 2: OTP

  void _nextStep() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      if (_step == 1) {
        // 1. Phải gọi API tạo tài khoản trước, vì backend yêu cầu tài khoản phải tồn tại (isEmailVerified = false) thì mới cho gửi mã OTP
        try {
          await _authService.registerMerchant(
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text,
            fullName: _fullNameCtrl.text.trim(),
            phoneNumber: _phoneCtrl.text.trim(),
          );
        } catch (e) {
          final errorMsg = e.toString().toLowerCase();
          // Nếu email đã tồn tại (có thể là do lần trước đăng ký nhưng chưa nhập OTP), vẫn cho phép đi tiếp sang bước gửi OTP
          if (!errorMsg.contains('tồn tại') && !errorMsg.contains('exists')) {
             rethrow;
          }
        }
        
        // 2. Sau khi tài khoản đã được tạo vào database, bắt đầu gửi OTP xác thực email
        await _authService.sendVerifyEmailOtp(_emailCtrl.text.trim());
        if (mounted) setState(() => _step = 2);
      } else if (_step == 2) {
        // 3. Xác thực OTP
        await _authService.verifyEmailOtp(_emailCtrl.text.trim(), _otpCtrl.text.trim());
        
        // 4. Tự động đăng nhập
        await _authService.login(_emailCtrl.text.trim(), _passwordCtrl.text);

        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 28),
                  SizedBox(width: 10),
                  Text('Thành công', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: const Text('Đăng ký và xác thực tài khoản thành công!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // close dialog
                    Navigator.pop(context); // close register page
                    widget.onLoginSuccess(); // trigger router update
                  },
                  child: const Text('VÀO TRANG CHỦ', style: TextStyle(color: Color(0xFFFF6B35), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Lỗi'),
            content: Text(e.toString().replaceAll('Exception: ', '')),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('ĐÓNG')),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Đăng ký tài khoản'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, spreadRadius: 5),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _step == 1 ? Icons.storefront : Icons.domain_verification, 
                    size: 80, color: const Color(0xFFFF6B35)
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _step == 1 ? 'Tạo tài khoản cửa hàng' : 'Xác thực Email', 
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 10),
                  if (_step == 2)
                    Text('Mã OTP 6 số đã được gửi đến email ${_emailCtrl.text}. Vui lòng nhập mã để kích hoạt tài khoản.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                  
                  const SizedBox(height: 30),
                  
                  if (_step == 1) ...[
                    TextFormField(
                      controller: _fullNameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Tên người bán',
                        prefixIcon: const Icon(Icons.store_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập tên người bán' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneCtrl,
                      decoration: InputDecoration(
                        labelText: 'Số điện thoại',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập số điện thoại' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Vui lòng nhập email';
                        if (!value.contains('@')) return 'Email không hợp lệ';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _isObscure,
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _isObscure = !_isObscure),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (value) => value == null || value.length < 6 ? 'Mật khẩu phải từ 6 ký tự' : null,
                    ),
                  ],
                  
                  if (_step == 2)
                    TextFormField(
                      controller: _otpCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: InputDecoration(
                        labelText: 'Mã OTP',
                        prefixIcon: const Icon(Icons.vpn_key_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (value) => value == null || value.length != 6 ? 'Vui lòng nhập mã OTP 6 số' : null,
                    ),
                    
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              _step == 1 ? 'ĐĂNG KÝ' : 'XÁC NHẬN OTP', 
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                            ),
                    ),
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
