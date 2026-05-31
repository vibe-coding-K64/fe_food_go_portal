import 'package:flutter/material.dart';

import '../../data/models/voucher_model.dart';
import '../../data/services/voucher_api_service.dart';
import '../../data/services/auth_service.dart';

/// Form dùng chung thêm/sửa voucher
class VoucherFormPage extends StatefulWidget {
  static Voucher? selectedVoucherToEdit;

  final bool isEdit;
  final Function(String)? onNavigate;
  const VoucherFormPage({super.key, this.isEdit = false, this.onNavigate});

  @override
  State<VoucherFormPage> createState() => _VoucherFormPageState();
}

class _VoucherFormPageState extends State<VoucherFormPage> {
  final VoucherApiService _apiService = VoucherApiService();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  
  final _titleCtrl = TextEditingController();
  final _subtitleCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  final _pointsCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  final _remainingCtrl = TextEditingController();
  final _termsCtrl = TextEditingController();
  final _minOrderCtrl = TextEditingController();
  
  int _discountType = 1; // 1: %, 2: tiền mặt
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && VoucherFormPage.selectedVoucherToEdit != null) {
      final v = VoucherFormPage.selectedVoucherToEdit!;
      _titleCtrl.text = v.title;
      _subtitleCtrl.text = v.subtitle;
      _codeCtrl.text = v.code;
      _discountType = v.type;
      _valueCtrl.text = v.value.toString();
      _pointsCtrl.text = v.pointsRequired.toString();
      _imageCtrl.text = v.imageUrl;
      _remainingCtrl.text = v.remaining.toString();
      _termsCtrl.text = v.terms;
      _minOrderCtrl.text = v.minOrderValue.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isEdit ? 'Chỉnh sửa Voucher' : 'Tạo Voucher mới',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2D)),
          ),
          const SizedBox(height: 4),
          const Text('Điền thông tin để tạo mã giảm giá cho quán',
              style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Form
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Thông tin Voucher',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2D))),
                        const Divider(height: 24),
                        _field('Tiêu đề voucher', _titleCtrl, Icons.title, required: true),
                        _field('Mô tả ngắn gọn', _subtitleCtrl, Icons.description_outlined, required: true),
                        _field('Mã voucher (VD: SAVE20)', _codeCtrl, Icons.local_offer_outlined, required: true, validator: (v) {
                          if (v != null && v.contains(' ')) return 'Mã không được chứa khoảng trắng';
                          return null;
                        }),
                        // Loại giảm giá
                        const Text('Loại giảm giá', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _typeCard(1, 'Phần trăm (%)', Icons.percent),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _typeCard(2, 'Tiền mặt (VNĐ)', Icons.attach_money),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _field(
                          _discountType == 1 ? 'Giá trị giảm (%)' : 'Số tiền giảm (VNĐ)',
                          _valueCtrl, Icons.discount_outlined,
                          required: true, keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v != null && v.isNotEmpty && double.tryParse(v) == null) return 'Phải là số hợp lệ';
                            if (_discountType == 1 && double.tryParse(v ?? '') != null) {
                              if (double.parse(v!) > 100 || double.parse(v) <= 0) return 'Từ 1 đến 100%';
                            }
                            return null;
                          }
                        ),
                        _field('Đơn tối thiểu (VNĐ)', _minOrderCtrl, Icons.shopping_cart_outlined,
                            required: true,
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v != null && v.isNotEmpty && double.tryParse(v) == null) return 'Phải là số hợp lệ';
                              return null;
                            }),
                        _field('Số lượng voucher', _remainingCtrl, Icons.numbers_outlined,
                            required: true,
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v != null && v.isNotEmpty && int.tryParse(v) == null) return 'Phải là số nguyên hợp lệ';
                              return null;
                            }),
                        _field('Số điểm cần đổi', _pointsCtrl, Icons.stars_outlined,
                            required: true,
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v != null && v.isNotEmpty && int.tryParse(v) == null) return 'Phải là số nguyên hợp lệ';
                              return null;
                            }),
                        _field('Đường dẫn ảnh voucher (Tùy chọn)', _imageCtrl, Icons.image_outlined, required: false),
                        _field('Điều khoản sử dụng (Tùy chọn)', _termsCtrl, Icons.gavel_outlined, required: false, maxLines: 3),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Right: Preview
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildPreviewCard(),
                    const SizedBox(height: 16),
                    _buildTipsCard(),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            if (widget.onNavigate != null) widget.onNavigate!('/vouchers');
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Hủy'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _isSaving ? null : _save,
                          icon: _isSaving 
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.save_outlined, size: 18),
                          label: Text(widget.isEdit ? 'Lưu thay đổi' : 'Tạo voucher'),
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

  Widget _typeCard(int type, String label, IconData icon) {
    final isSelected = _discountType == type;
    return InkWell(
      onTap: () => setState(() => _discountType = type),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF3E0) : const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? const Color(0xFFFF6B35) : Colors.grey.shade300, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFFFF6B35) : Colors.grey, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: TextStyle(color: isSelected ? const Color(0xFFFF6B35) : Colors.grey, fontWeight: FontWeight.w500, fontSize: 13))),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, IconData icon,
      {bool required = false, int maxLines = 1, TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (v) {
          if (required && (v == null || v.trim().isEmpty)) {
            return 'Vui lòng nhập $label';
          }
          if (validator != null) {
            return validator(v);
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: maxLines == 1 ? Icon(icon, color: const Color(0xFFFF6B35), size: 20) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFF6B35))),
          filled: true,
          fillColor: const Color(0xFFF9F9F9),
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Xem trước', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2D))),
          const Divider(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🎟 VOUCHER', style: TextStyle(color: Colors.white70, fontSize: 11)),
                const SizedBox(height: 4),
                Text(
                  _titleCtrl.text.isEmpty ? 'Tiêu đề' : _titleCtrl.text,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  _codeCtrl.text.isEmpty ? 'MYVOUCHER' : _codeCtrl.text.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
                const SizedBox(height: 8),
                Text(
                  _valueCtrl.text.isEmpty
                      ? 'Giảm 0${_discountType == 1 ? '%' : 'đ'}'
                      : 'Giảm ${_valueCtrl.text}${_discountType == 1 ? '%' : 'đ'}',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.blue, size: 18),
              SizedBox(width: 8),
              Text('Gợi ý', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            ],
          ),
          SizedBox(height: 8),
          Text('• Mã ngắn gọn dễ nhớ (VD: SAVE20)\n• Điền số lượng còn lại để kiểm soát số lượng\n• Mã hoa không dấu để tránh nhầm lẫn',
              style: TextStyle(color: Colors.blue, fontSize: 12, height: 1.8)),
        ],
      ),
    );
  }

  void _showNotificationDialog(BuildContext context, String message, bool isSuccess) {
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
                color: isSuccess ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                color: isSuccess ? Colors.green : const Color(0xFFDC3545),
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            Text(isSuccess ? 'Thành công!' : 'Có lỗi xảy ra!',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: Colors.black87)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  if (isSuccess && widget.onNavigate != null) {
                    widget.onNavigate!('/vouchers');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSuccess ? Colors.green : const Color(0xFFDC3545),
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

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      
      try {
        final storeId = await _authService.getStoreId();
        if (storeId == null) throw 'Không tìm thấy storeId';

        final newVoucher = Voucher(
          storeId: storeId,
          title: _titleCtrl.text.trim(),
          subtitle: _subtitleCtrl.text.trim(),
          code: _codeCtrl.text.trim().toUpperCase(),
          type: _discountType,
          value: double.parse(_valueCtrl.text.trim()),
          pointsRequired: int.parse(_pointsCtrl.text.trim()),
          imageUrl: _imageCtrl.text.trim(),
          remaining: int.parse(_remainingCtrl.text.trim()),
          terms: _termsCtrl.text.trim(),
          minOrderValue: double.parse(_minOrderCtrl.text.trim()),
        );

        if (widget.isEdit && VoucherFormPage.selectedVoucherToEdit != null) {
          await _apiService.updateVoucher(VoucherFormPage.selectedVoucherToEdit!.id!, newVoucher);
          if (mounted) _showNotificationDialog(context, 'Cập nhật voucher thành công!', true);
        } else {
          await _apiService.createVoucher(newVoucher);
          if (mounted) _showNotificationDialog(context, 'Tạo voucher thành công!', true);
        }
      } catch (e) {
        if (mounted) _showNotificationDialog(context, e.toString(), false);
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }
}
