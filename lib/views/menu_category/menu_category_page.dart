import 'package:flutter/material.dart';

class MenuCategoryPage extends StatefulWidget {
  final Function(String)? onNavigate;
  const MenuCategoryPage({super.key, this.onNavigate});

  @override
  State<MenuCategoryPage> createState() => _MenuCategoryPageState();
}

class _MenuCategoryPageState extends State<MenuCategoryPage> {
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Khai vị', 'count': 5, 'order': 1},
    {'name': 'Món chính', 'count': 12, 'order': 2},
    {'name': 'Tráng miệng', 'count': 7, 'order': 3},
    {'name': 'Đồ uống', 'count': 9, 'order': 4},
    {'name': 'Combo', 'count': 4, 'order': 5},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Danh mục Món ăn',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2D))),
                SizedBox(height: 4),
                Text('Quản lý nhóm phân loại thực đơn của quán',
                    style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => _showCategoryDialog(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Thêm danh mục'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              children: [
                // Table header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(width: 40, child: Text('#', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                      Expanded(child: Text('Tên danh mục', style: TextStyle(fontWeight: FontWeight.bold))),
                      SizedBox(width: 120, child: Text('Số món', style: TextStyle(fontWeight: FontWeight.bold))),
                      SizedBox(width: 100, child: Text('Thứ tự', style: TextStyle(fontWeight: FontWeight.bold))),
                      SizedBox(width: 120, child: Text('Thao tác', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
                    itemBuilder: (context, i) => _buildRow(i),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRow(int i) {
    final c = _categories[i];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text('${c['order']}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF6B35), fontSize: 13)),
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.category_outlined, color: Color(0xFFFF6B35), size: 20),
                ),
                const SizedBox(width: 12),
                Text(c['name'],
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              ],
            ),
          ),
          SizedBox(
            width: 120,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('${c['count']} món',
                  style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w500)),
            ),
          ),
          SizedBox(
            width: 100,
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.keyboard_arrow_up_outlined, color: Colors.grey),
                  tooltip: 'Lên',
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.keyboard_arrow_down_outlined, color: Colors.grey),
                  tooltip: 'Xuống',
                ),
              ],
            ),
          ),
          SizedBox(
            width: 120,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _showCategoryDialog(context, category: c),
                  icon: const Icon(Icons.edit_outlined, color: Color(0xFFFF6B35)),
                  tooltip: 'Sửa',
                ),
                IconButton(
                  onPressed: () => _confirmDelete(context, i),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Xóa',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, {Map<String, dynamic>? category}) {
    final ctrl = TextEditingController(text: category?['name'] ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(category == null ? 'Thêm danh mục' : 'Sửa danh mục'),
        content: SizedBox(
          width: 400,
          child: TextFormField(
            controller: ctrl,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Tên danh mục',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFFF6B35)),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.isNotEmpty) {
                setState(() {
                  if (category == null) {
                    _categories.add({'name': ctrl.text, 'count': 0, 'order': _categories.length + 1});
                  } else {
                    category['name'] = ctrl.text;
                  }
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(category == null ? 'Thêm' : 'Lưu'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa danh mục "${_categories[index]['name']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              setState(() => _categories.removeAt(index));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
