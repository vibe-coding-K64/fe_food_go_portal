import 'package:flutter/material.dart';

/// Form dùng chung thêm/sửa món ăn
class ProductFormPage extends StatefulWidget {
  final bool isEdit;
  const ProductFormPage({super.key, this.isEdit = false});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  String _selectedCategory = 'Món chính';
  final List<String> _categories = ['Khai vị', 'Món chính', 'Tráng miệng', 'Đồ uống'];

  final List<Map<String, dynamic>> _optionGroups = [
    {
      'name': 'Chọn mức đá',
      'isRequired': false,
      'maxChoices': 1,
      'options': [
        {'name': '100% Đá', 'price': 0},
        {'name': '50% Đá', 'price': 0},
        {'name': 'Không đá', 'price': 0},
      ],
    },
    {
      'name': 'Topping',
      'isRequired': false,
      'maxChoices': 3,
      'options': [
        {'name': 'Phô mai', 'price': 10000},
        {'name': 'Bacon', 'price': 15000},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isEdit ? 'Chỉnh sửa Món ăn' : 'Thêm Món ăn mới',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2D)),
          ),
          const SizedBox(height: 4),
          const Text('Điền đầy đủ thông tin để thêm món vào thực đơn',
              style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildCard('Thông tin cơ bản', [
                        _field('Tên món ăn', _nameCtrl, Icons.fastfood_outlined, required: true),
                        _field('Mô tả món', _descCtrl, Icons.description_outlined, maxLines: 3),
                        _field('Giá niêm yết (VNĐ)', _priceCtrl, Icons.attach_money, required: true,
                            keyboardType: TextInputType.number),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          items: _categories
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedCategory = v!),
                          decoration: InputDecoration(
                            labelText: 'Danh mục',
                            prefixIcon: const Icon(Icons.category_outlined, color: Color(0xFFFF6B35), size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFFF6B35)),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF9F9F9),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 16),
                      _buildOptionGroupSection(),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Right column
                Expanded(
                  flex: 2,
                  child: _buildCard('Hình ảnh & Trạng thái', [
                    _imagePicker(),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Expanded(child: Text('Tình trạng kho', style: TextStyle(fontWeight: FontWeight.w500))),
                        Switch(value: true, onChanged: (_) {}, activeColor: Colors.green),
                      ],
                    ),
                    const Text('Bật = Còn hàng, Tắt = Hết hàng', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
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
                label: Text(widget.isEdit ? 'Lưu thay đổi' : 'Thêm món'),
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

  Widget _field(String label, TextEditingController ctrl, IconData icon,
      {bool required = false, int maxLines = 1, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: required ? (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập $label' : null : null,
        decoration: InputDecoration(
          labelText: label,
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

  Widget _imagePicker() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFFF9F9F9),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey),
          SizedBox(height: 8),
          Text('Tải ảnh món lên', style: TextStyle(color: Colors.grey)),
          Text('PNG, JPG tối đa 5MB', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildOptionGroupSection() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Nhóm Topping / Size', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2D))),
              TextButton.icon(
                onPressed: () => setState(() => _optionGroups.add({'name': 'Nhóm mới', 'isRequired': false, 'maxChoices': 1, 'options': []})),
                icon: const Icon(Icons.add, size: 16, color: Color(0xFFFF6B35)),
                label: const Text('Thêm nhóm', style: TextStyle(color: Color(0xFFFF6B35))),
              ),
            ],
          ),
          const Divider(height: 24),
          ..._optionGroups.asMap().entries.map((e) => _buildOptionGroup(e.key, e.value)),
        ],
      ),
    );
  }

  Widget _buildOptionGroup(int gIdx, Map<String, dynamic> group) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: group['name'],
                  onChanged: (v) => _optionGroups[gIdx]['name'] = v,
                  decoration: InputDecoration(
                    labelText: 'Tên nhóm',
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  const Text('Bắt buộc', style: TextStyle(fontSize: 13)),
                  Switch(
                    value: group['isRequired'],
                    onChanged: (v) => setState(() => _optionGroups[gIdx]['isRequired'] = v),
                    activeColor: const Color(0xFFFF6B35),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => setState(() => _optionGroups.removeAt(gIdx)),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...(group['options'] as List).asMap().entries.map((e) => _buildOption(gIdx, e.key, e.value)),
          TextButton.icon(
            onPressed: () => setState(() => (group['options'] as List).add({'name': '', 'price': 0})),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Thêm lựa chọn'),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(int gIdx, int oIdx, Map<String, dynamic> option) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextFormField(
              initialValue: option['name'],
              onChanged: (v) => (_optionGroups[gIdx]['options'] as List)[oIdx]['name'] = v,
              decoration: InputDecoration(
                labelText: 'Tên lựa chọn',
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              initialValue: option['price'].toString(),
              keyboardType: TextInputType.number,
              onChanged: (v) => (_optionGroups[gIdx]['options'] as List)[oIdx]['price'] = int.tryParse(v) ?? 0,
              decoration: InputDecoration(
                labelText: '+Giá (VNĐ)',
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => (_optionGroups[gIdx]['options'] as List).removeAt(oIdx)),
            icon: const Icon(Icons.close, size: 16, color: Colors.red),
          ),
        ],
      ),
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEdit ? 'Cập nhật món thành công!' : 'Thêm món thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
