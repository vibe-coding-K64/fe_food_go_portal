import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  final Function(String)? onNavigate;
  const ProfilePage({super.key, this.onNavigate});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _taxCtrl = TextEditingController();
  
  String? _photoUrl;
  String _avatarInitials = "UA";
  String _fullName = "Cửa hàng";

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await AuthService().getMerchantProfile();
    if (mounted) {
      setState(() {
        _nameCtrl.text = profile['fullName'] ?? '';
        _emailCtrl.text = profile['email'] ?? '';
        _phoneCtrl.text = profile['phoneNumber'] ?? '';
        _taxCtrl.text = profile['taxCode'] ?? '';
        
        _photoUrl = profile['photoUrl'];
        if (profile['fullName'] != null && profile['fullName']!.isNotEmpty) {
          _fullName = profile['fullName']!;
          _avatarInitials = _getInitials(_fullName);
        }
      });
    }
  }

  String _getInitials(String name) {
    List<String> words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return "UA";
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return (words.first.substring(0, 1) + words.last.substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Hồ sơ của tôi', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2D))),
          const SizedBox(height: 4),
         
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar card
              SizedBox(
                width: 240,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: _photoUrl != null && _photoUrl!.isNotEmpty
                                ? Image.network(
                                    _photoUrl!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 100,
                                    height: 100,
                                    color: const Color(0xFFFF6B35),
                                    alignment: Alignment.center,
                                    child: Text(
                                      _avatarInitials,
                                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: Color(0xFFFF6B35), shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(_fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      const Text('Merchant', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_outlined, color: Colors.green, size: 14),
                            SizedBox(width: 4),
                            Text('Đã xác minh', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Info form
              Expanded(
                child: Column(
                  children: [
                    _buildCard('Thông tin cá nhân', [
                      _field('Tên quán', _nameCtrl, Icons.store_outlined),
                      _field('Email', _emailCtrl, Icons.email_outlined),
                      _field('Số điện thoại', _phoneCtrl, Icons.phone_outlined),
                      _field('Mã số thuế', _taxCtrl, Icons.receipt_long_outlined),
                    ]),
                    const SizedBox(height: 16),
                    _buildCard('Bảo mật', [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.lock_outline, color: Color(0xFFFF6B35)),
                        title: const Text('Đổi mật khẩu', style: TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: const Text('Lần đổi gần nhất: 30 ngày trước', style: TextStyle(fontSize: 12)),
                        trailing: OutlinedButton(
                          onPressed: _showPasswordChangeDialog,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFFF6B35),
                            side: const BorderSide(color: Color(0xFFFF6B35)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Đổi ngay'),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _save,
                          icon: const Icon(Icons.save_outlined, size: 18),
                          label: const Text('Lưu thay đổi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B35),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2D))),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFFFF6B35), size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFF6B35))),
          filled: true,
          fillColor: const Color(0xFFF9F9F9),
        ),
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
            ),
            const SizedBox(height: 24),
            const Text('Thành công!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: Colors.black87)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Đóng', style: TextStyle(fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lỗi'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
        ],
      ),
    );
  }

  Future<void> _showPasswordChangeDialog() async {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Đổi mật khẩu', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: oldCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Mật khẩu cũ', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Vui lòng nhập mật khẩu cũ' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: newCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Mật khẩu mới', border: OutlineInputBorder()),
                  validator: (v) => v!.length < 6 ? 'Mật khẩu mới ít nhất 6 ký tự' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Xác nhận mật khẩu mới', border: OutlineInputBorder()),
                  validator: (v) => v != newCtrl.text ? 'Mật khẩu xác nhận không khớp' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        setStateDialog(() => isSaving = true);
                        try {
                          await AuthService().changePassword(oldCtrl.text, newCtrl.text);
                          if (mounted) Navigator.pop(ctx);
                          _showSuccessDialog('Đổi mật khẩu thành công!');
                        } catch (e) {
                          setStateDialog(() => isSaving = false);
                          _showErrorDialog(e.toString());
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B35), foregroundColor: Colors.white),
              child: isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    try {
      await AuthService().updateMerchantProfile(
        _nameCtrl.text.trim(),
        _phoneCtrl.text.trim(),
        _taxCtrl.text.trim(),
      );
      
      if (mounted) {
        _showSuccessDialog('Cập nhật hồ sơ thành công!');
        _loadProfile();
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Cập nhật thất bại: $e');
      }
    }
  }
}
