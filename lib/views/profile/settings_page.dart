import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../controllers/theme_controller.dart';
import '../../data/services/auth_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _pushEnabled = true;
  bool _orderNotif = true;
  bool _reviewNotif = true;
  bool _paymentNotif = true;
  bool _darkMode = false;
  String _language = 'Tiếng Việt';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushEnabled = prefs.getBool('setting_push') ?? true;
      _orderNotif = prefs.getBool('setting_order') ?? true;
      _reviewNotif = prefs.getBool('setting_review') ?? true;
      _paymentNotif = prefs.getBool('setting_payment') ?? true;
      _darkMode = prefs.getBool('setting_dark') ?? false;
      _language = prefs.getString('setting_language') ?? 'Tiếng Việt';
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E2D);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cài đặt', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 4),
          const Text('Tuỳ chỉnh giao diện và thông báo', style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildSection('Giao diện', [
                      _switchTile('Chế độ tối', 'Thay đổi giao diện sang màu tối', Icons.dark_mode_outlined, _darkMode, (v) {
                        setState(() => _darkMode = v);
                        ThemeController.instance.toggleTheme(v);
                        _saveSetting('setting_dark', v);
                      }),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          children: [
                            const Icon(Icons.language_outlined, color: Color(0xFFFF6B35), size: 22),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Ngôn ngữ', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                                  Text('Chọn ngôn ngữ hiển thị', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                            DropdownButton<String>(
                              value: context.locale.languageCode == 'en' ? 'English' : 'Tiếng Việt',
                              items: ['Tiếng Việt', 'English'].map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                              onChanged: (v) {
                                if (v == 'English') {
                                  context.setLocale(const Locale('en', ''));
                                } else {
                                  context.setLocale(const Locale('vi', ''));
                                }
                                setState(() => _language = v!);
                                _saveSetting('setting_language', v);
                              },
                              underline: const SizedBox(),
                            ),
                          ],
                        ),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _buildSection('Thông báo', [
                      _switchTile('Đơn hàng', 'Thông báo về tình trạng các đơn hàng', Icons.shopping_bag_outlined, _orderNotif, (v) {
                        setState(() => _orderNotif = v);
                        _saveSetting('setting_order', v);
                      }),
                      const Divider(height: 1),
                      _switchTile('Đánh giá', 'Thông báo khi có đánh giá mới từ khách', Icons.star_outline, _reviewNotif, (v) {
                        setState(() => _reviewNotif = v);
                        _saveSetting('setting_review', v);
                      }),
                      const Divider(height: 1),
                      _switchTile('Thanh toán', 'Thông báo cập nhật ví và thanh toán', Icons.payment_outlined, _paymentNotif, (v) {
                        setState(() => _paymentNotif = v);
                        _saveSetting('setting_payment', v);
                      }),
                    ]),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    _buildSection('Tài khoản', [
                      _actionTile('Đổi mật khẩu', Icons.lock_outline, Colors.blue, () {
                        _showPasswordChangeDialog(context);
                      }),
                      const Divider(height: 1),
                      _actionTile('Quản lý phiên đăng nhập', Icons.devices_outlined, Colors.purple, () {
                        _showDevSnackbar(context, 'Quản lý phiên đăng nhập');
                      }),
                    ]),
                    const SizedBox(height: 16),
                    _buildSection('Hỗ trợ', [
                      _actionTile('Chính sách bảo mật', Icons.privacy_tip_outlined, Colors.grey, () {
                        _showDevSnackbar(context, 'Chính sách bảo mật');
                      }),
                      const Divider(height: 1),
                      _actionTile('Điều khoản dịch vụ', Icons.description_outlined, Colors.grey, () {
                        _showDevSnackbar(context, 'Điều khoản dịch vụ');
                      }),
                      const Divider(height: 1),
                      _actionTile('Liên hệ hỗ trợ', Icons.headset_mic_outlined, Colors.green, () {
                        _showDevSnackbar(context, 'Liên hệ hỗ trợ');
                      }),
                    ]),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        children: [
                          const Text('Đăng xuất', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 15)),
                          const SizedBox(height: 4),
                          const Text('Bạn sẽ cần đăng nhập lại sau khi đăng xuất', style: TextStyle(color: Colors.red, fontSize: 12)),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _showLogoutDialog(context),
                              icon: const Icon(Icons.logout, color: Colors.red, size: 18),
                              label: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildSection(String title, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E1E2D))),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _switchTile(String title, String subtitle, IconData icon, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF6B35), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFFFF6B35)),
        ],
      ),
    );
  }

  Widget _actionTile(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14))),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  void _showDevSnackbar(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Thông báo'),
        content: Text('Tính năng "$feature" đang được phát triển!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white, // Add white background
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              AuthService().logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String message) {
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

  Future<void> _showPasswordChangeDialog(BuildContext context) async {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;
    bool obscurePassword = true;
    String? oldPasswordError;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (contextDialog, setStateDialog) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Center(
            child: Text('Đổi mật khẩu', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: oldCtrl,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu cũ', 
                    border: const OutlineInputBorder(),
                    errorText: oldPasswordError,
                    suffixIcon: IconButton(
                      icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                      onPressed: () => setStateDialog(() => obscurePassword = !obscurePassword),
                    ),
                  ),
                  onChanged: (v) {
                    if (oldPasswordError != null) setStateDialog(() => oldPasswordError = null);
                  },
                  validator: (v) => v!.isEmpty ? 'Vui lòng nhập mật khẩu cũ' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: newCtrl,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu mới', 
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                      onPressed: () => setStateDialog(() => obscurePassword = !obscurePassword),
                    ),
                  ),
                  validator: (v) => v!.length < 6 ? 'Mật khẩu mới ít nhất 6 ký tự' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmCtrl,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Xác nhận mật khẩu mới', 
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                      onPressed: () => setStateDialog(() => obscurePassword = !obscurePassword),
                    ),
                  ),
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
                          if (mounted) {
                            Navigator.pop(ctx);
                            _showSuccessDialog(context, 'Đổi mật khẩu thành công');
                          }
                        } catch (e) {
                          setStateDialog(() {
                            isSaving = false;
                            oldPasswordError = e.toString().replaceAll('Exception: ', '');
                          });
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
}
