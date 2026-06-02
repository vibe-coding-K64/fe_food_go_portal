import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  int _step = 1; // 1: Email, 2: OTP, 3: New Password
  String _tempToken = '';
  bool _isObscure = true;

  void _nextStep() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      if (_step == 1) {
        await _authService.sendOtp(_emailCtrl.text.trim());
        if (mounted) setState(() => _step = 2);
      } else if (_step == 2) {
        _tempToken = await _authService.verifyOtp(_emailCtrl.text.trim(), _otpCtrl.text.trim());
        if (mounted) setState(() => _step = 3);
      } else if (_step == 3) {
        await _authService.resetPassword(_tempToken, _passwordCtrl.text);
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
              content: const Text('Mật khẩu của bạn đã được đặt lại thành công. Vui lòng đăng nhập lại.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('ĐĂNG NHẬP', style: TextStyle(color: Color(0xFFFF6B35), fontWeight: FontWeight.bold)),
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
        title: const Text('Quên mật khẩu'),
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
                    _step == 1 ? Icons.mark_email_unread_outlined : 
                    _step == 2 ? Icons.domain_verification : Icons.lock_reset, 
                    size: 80, color: const Color(0xFFFF6B35)
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _step == 1 ? 'Khôi phục mật khẩu' : 
                    _step == 2 ? 'Xác nhận OTP' : 'Mật khẩu mới', 
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _step == 1 ? 'Nhập email của bạn để nhận mã xác thực' : 
                    _step == 2 ? 'Mã OTP 6 số đã được gửi đến email ${_emailCtrl.text}' : 'Vui lòng nhập mật khẩu mới của bạn', 
                    textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)
                  ),
                  const SizedBox(height: 40),
                  
                  if (_step == 1)
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
                    
                  if (_step == 3)
                    ...[
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _isObscure,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu mới',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _isObscure = !_isObscure),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (value) => value == null || value.length < 6 ? 'Mật khẩu ít nhất 6 ký tự' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordCtrl,
                        obscureText: _isObscure,
                        decoration: InputDecoration(
                          labelText: 'Xác nhận mật khẩu',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (value) {
                          if (value != _passwordCtrl.text) return 'Mật khẩu không khớp';
                          return null;
                        },
                      ),
                    ],
                    
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
                              _step == 1 ? 'GỬI MÃ OTP' : 
                              _step == 2 ? 'XÁC NHẬN OTP' : 'ĐỔI MẬT KHẨU', 
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
