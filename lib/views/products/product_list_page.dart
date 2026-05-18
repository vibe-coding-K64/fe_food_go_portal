import 'package:flutter/material.dart';

class ProductListPage extends StatefulWidget {
  final Function(String)? onNavigate;
  const ProductListPage({super.key, this.onNavigate});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  String _filterCategory = 'Tất cả';
  final List<String> _categories = ['Tất cả', 'Khai vị', 'Món chính', 'Tráng miệng', 'Đồ uống'];
  final List<Map<String, dynamic>> _products = [
    {'name': 'Burger Bò Phô Mai', 'category': 'Món chính', 'price': 89000, 'outOfStock': false, 'image': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=100'},
    {'name': 'Gà Rán Giòn', 'category': 'Khai vị', 'price': 65000, 'outOfStock': false, 'image': 'https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=100'},
    {'name': 'Nước Cam Tươi', 'category': 'Đồ uống', 'price': 35000, 'outOfStock': true, 'image': 'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=100'},
    {'name': 'Kem Vani', 'category': 'Tráng miệng', 'price': 40000, 'outOfStock': false, 'image': 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=100'},
    {'name': 'Khoai Tây Chiên', 'category': 'Khai vị', 'price': 30000, 'outOfStock': false, 'image': 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=100'},
  ];

  List<Map<String, dynamic>> get _filtered => _filterCategory == 'Tất cả'
      ? _products
      : _products.where((p) => p['category'] == _filterCategory).toList();

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
                Text('Quản lý Món ăn',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2D))),
                SizedBox(height: 4),
                Text('Thêm, sửa, xóa và quản lý trạng thái món',
                    style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (widget.onNavigate != null) widget.onNavigate!('/products/add');
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Thêm món'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _categories.map((cat) {
              final isSelected = _filterCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _filterCategory = cat),
                  selectedColor: const Color(0xFFFF6B35),
                  labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      fontWeight: FontWeight.w500),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: isSelected ? const Color(0xFFFF6B35) : Colors.grey.shade300)),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 280,
              mainAxisExtent: 260,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _filtered.length,
            itemBuilder: (context, i) => _buildProductCard(i, _filtered[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(int i, Map<String, dynamic> product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  product['image'],
                  height: 130,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 130,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.fastfood, color: Colors.grey, size: 40),
                  ),
                ),
              ),
              if (product['outOfStock'])
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Hết hàng', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (widget.onNavigate != null) widget.onNavigate!('/products/edit');
                        },
                        icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFFFF6B35)),
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        padding: const EdgeInsets.all(4),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        padding: const EdgeInsets.all(4),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(product['category'],
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(product['price'] as int).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ',
                      style: const TextStyle(color: Color(0xFFFF6B35), fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Switch(
                      value: !product['outOfStock'],
                      onChanged: (val) {
                        final idx = _products.indexOf(product);
                        if (idx != -1) setState(() => _products[idx]['outOfStock'] = !val);
                      },
                      activeColor: Colors.green,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
}
