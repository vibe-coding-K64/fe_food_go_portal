import 'package:flutter/material.dart';

/// Form dùng chung cho thêm/sửa thông tin quán
class StoreFormPage extends StatefulWidget {
  final bool isEdit;
  const StoreFormPage({super.key, this.isEdit = false});

  @override
  State<StoreFormPage> createState() => _StoreFormPageState();
}

class _StoreFormPageState extends State<StoreFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController(text: 'FoodGo Burger & Grill');
  final _descCtrl = TextEditingController(text: 'Burger thủ công, nguyên liệu tươi mỗi ngày');
  final _addressCtrl = TextEditingController(text: '123 Nguyễn Huệ, Quận 1, TP.HCM');
  final _taxCodeCtrl = TextEditingController(text: '0123456789');
  final _bankNameCtrl = TextEditingController(text: 'Vietcombank');
  final _bankBranchCtrl = TextEditingController(text: 'CN TP.HCM');
  final _bankAccountCtrl = TextEditingController(text: '0123 4567 8901');
  final _accountNameCtrl = TextEditingController(text: 'NGUYEN VAN A');

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isEdit ? 'Chỉnh sửa Gian hàng' : 'Tạo Gian hàng',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2D)),
          ),
          const SizedBox(height: 4),
          Text(
            widget.isEdit ? 'Cập nhật thông tin quán của bạn' : 'Điền thông tin để tạo quán mới',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection('Thông tin cơ bản', [
                  _field('Tên quán', _nameCtrl, Icons.store_outlined, required: true),
                  _field('Mô tả', _descCtrl, Icons.description_outlined, maxLines: 3),
                  _field('Địa chỉ', _addressCtrl, Icons.location_on_outlined, required: true),
                  _field('Mã số thuế', _taxCodeCtrl, Icons.receipt_long_outlined),
                ]),
                const SizedBox(height: 20),
                _buildSection('Hình ảnh', [
                  _imagePicker('Ảnh bìa (Cover Image)', 'Ảnh ngang 16:9 của quán'),
                  const SizedBox(height: 12),
                  _imagePicker('Logo quán', 'Ảnh vuông, hiển thị dạng tròn'),
                  const SizedBox(height: 12),
                  _imagePicker('Giấy phép kinh doanh', 'Ảnh scan giấy phép KD'),
                ]),
                const SizedBox(height: 20),
                _buildSection('Tài khoản ngân hàng nhận tiền', [
                  _field('Tên ngân hàng', _bankNameCtrl, Icons.account_balance_outlined, required: true),
                  _field('Chi nhánh', _bankBranchCtrl, Icons.location_city_outlined),
                  _field('Số tài khoản', _bankAccountCtrl, Icons.credit_card_outlined, required: true),
                  _field('Tên chủ tài khoản', _accountNameCtrl, Icons.person_outline, required: true,
                      hint: 'Viết hoa không dấu'),
                ]),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Hủy'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save_outlined, size: 18),
                      label: Text(widget.isEdit ? 'Lưu thay đổi' : 'Tạo gian hàng'),
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
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
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

  Widget _field(String label, TextEditingController ctrl, IconData icon,
      {bool required = false, int maxLines = 1, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        validator: required
            ? (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập $label' : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFFFF6B35), size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFFF6B35)),
          ),
          filled: true,
          fillColor: const Color(0xFFF9F9F9),
        ),
      ),
    );
  }

  Widget _imagePicker(String label, String hint) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFFF9F9F9),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add_photo_alternate_outlined, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(hint, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.upload_outlined, size: 16),
                  label: const Text('Tải ảnh lên'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF6B35),
                    side: const BorderSide(color: Color(0xFFFF6B35)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEdit ? 'Cập nhật quán thành công!' : 'Tạo quán thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
