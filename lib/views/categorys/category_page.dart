import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';
import '../../data/services/category_api_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/global_search_service.dart';
import '../widgets/image_upload_field.dart';

class MenuCategoryPage extends StatefulWidget {
  final Function(String)? onNavigate;
  const MenuCategoryPage({super.key, this.onNavigate});

  State<MenuCategoryPage> createState() => _MenuCategoryPageState();
}

class _MenuCategoryPageState extends State<MenuCategoryPage> {
  final CategoryApiService _apiService = CategoryApiService();
  final AuthService _authService = AuthService();
  List<Category> _categories = [];
  bool _isLoading = true;
  
  // Pagination
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    GlobalSearchService().queryNotifier.addListener(_onSearchQueryChanged);
  }

  @override
  void dispose() {
    GlobalSearchService().queryNotifier.removeListener(_onSearchQueryChanged);
    super.dispose();
  }

  void _onSearchQueryChanged() {
    if (mounted) setState(() {});
  }

  void _showNotificationDialog(BuildContext context, String message, bool isSuccess) {
    showDialog(
      context: context,
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
                onPressed: () => Navigator.pop(ctx),
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

  Future<void> _fetchCategories() async {
    setState(() => _isLoading = true);
    try {
      final storeId = await _authService.getStoreId();
      if (storeId == null) throw 'Không tìm thấy storeId';
      final categories = await _apiService.getAllCategories(storeId);
      categories.sort((a, b) {
        int orderCmp = a.order.compareTo(b.order);
        if (orderCmp != 0) return orderCmp;
        if (a.createdAt != null && b.createdAt != null) {
          return a.createdAt!.compareTo(b.createdAt!);
        }
        return 0;
      });
      setState(() {
        _categories = categories;
        // Clamp current page
        int totalPages = (_categories.length / _itemsPerPage).ceil();
        if (totalPages == 0) totalPages = 1;
        if (_currentPage > totalPages) _currentPage = totalPages;
      });
    } catch (e) {
      if (mounted) {
        _showNotificationDialog(context, e.toString(), false);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Category> get _paginatedCategories {
    final filtered = _getFilteredCategories();
    int start = (_currentPage - 1) * _itemsPerPage;
    int end = start + _itemsPerPage;
    if (start >= filtered.length) return [];
    if (end > filtered.length) end = filtered.length;
    return filtered.sublist(start, end);
  }

  List<Category> _getFilteredCategories() {
    final rawQuery = GlobalSearchService().queryNotifier.value;
    final query = GlobalSearchService().removeDiacritics(rawQuery.toLowerCase().trim());
    if (query.isEmpty) return _categories;

    return _categories.where((c) {
      final name = GlobalSearchService().removeDiacritics(c.name.toLowerCase());
      return name.contains(query);
    }).toList();
  }

  Widget _buildPagination() {
    final filtered = _getFilteredCategories();
    int totalPages = (filtered.length / _itemsPerPage).ceil();
    if (totalPages <= 1) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
          ),
          const SizedBox(width: 16),
          Text('Trang $_currentPage / $totalPages', style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _currentPage < totalPages ? () => setState(() => _currentPage++) : null,
          ),
        ],
      ),
    );
  }

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
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _getFilteredCategories().isEmpty
                          ? const Center(child: Text('Chưa có danh mục nào.'))
                          : GridView.builder(
                              padding: const EdgeInsets.all(24),
                              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 250,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                                childAspectRatio: 0.95,
                              ),
                              itemCount: _paginatedCategories.length,
                              itemBuilder: (context, idx) {
                                final globalIndex = (_currentPage - 1) * _itemsPerPage + idx;
                                return _buildCard(globalIndex, _paginatedCategories[idx]);
                              },
                            ),
                ),
                if (!_isLoading && _categories.isNotEmpty) _buildPagination(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(int index, Category cat) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 7,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: (cat.imageUrl != null && cat.imageUrl!.isNotEmpty)
                      ? Image.network(cat.imageUrl!, fit: BoxFit.cover, errorBuilder: (ctx, err, st) => const Icon(Icons.broken_image, size: 40, color: Colors.grey))
                      : const Icon(Icons.category_outlined, color: Color(0xFFFF6B35), size: 40),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        cat.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 16,
                          color: Color(0xFF2D3748), // Màu xám đậm sang trọng
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Builder(
            builder: (context) {
              bool isSys = cat.storeId == null || cat.storeId!.isEmpty || cat.storeId == 'system' || cat.storeId == 'null';
              return Positioned(
                top: 8,
                right: 8,
                child: isSys ? const SizedBox.shrink() : Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        iconSize: 16,
                        padding: EdgeInsets.zero,
                        onPressed: () => _showCategoryDialog(context, category: cat),
                        icon: const Icon(Icons.edit_outlined, color: Color(0xFFFF6B35)),
                        tooltip: 'Sửa',
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        iconSize: 16,
                        padding: EdgeInsets.zero,
                        onPressed: () => _confirmDelete(context, cat),
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        tooltip: 'Xóa',
                      ),
                    ),
                  ],
                ),
              );
            }
          ),
          Builder(
            builder: (context) {
              bool isSys = cat.storeId == null || cat.storeId!.isEmpty || cat.storeId == 'system' || cat.storeId == 'null';
              return Positioned(
                top: 8,
                left: 8,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '#${index + 1}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (isSys) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Hệ thống',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }
          ),
        ],
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, {Category? category}) {
    final formKey = GlobalKey<FormState>();
    String name = category?.name ?? '';
    int order = category?.order ?? 0;
    
    // Tạo controller riêng cho ImageUploadField trong dialog
    final imageUrlCtrl = TextEditingController(text: category?.imageUrl ?? '');

    // Dùng biến để theo dõi trạng thái loading bên trong Dialog
    bool isSaving = false;
    String? errorMessage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(category == null ? 'Thêm danh mục' : 'Sửa danh mục', 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            content: SizedBox(
              width: 400,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        initialValue: name,
                        decoration: InputDecoration(
                          labelText: 'Tên danh mục (*)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFFF6B35)),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Tên danh mục không được để trống';
                          if (v.trim().length < 2 || v.trim().length > 50) return 'Tên danh mục phải từ 2 đến 50 ký tự';
                          return null;
                        },
                        onSaved: (v) => name = v!.trim(),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: order.toString(),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Thứ tự ưu tiên (*)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFFF6B35)),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Thứ tự không được để trống';
                          final num = int.tryParse(v);
                          if (num == null) return 'Thứ tự phải là số nguyên';
                          if (num < 1) return 'Thứ tự ưu tiên phải >= 1';
                          return null;
                        },
                        onSaved: (v) => order = int.tryParse(v ?? '0') ?? 0,
                      ),
                      const SizedBox(height: 16),
                      ImageUploadField(
                        label: 'Ảnh đại diện danh mục',
                        controller: imageUrlCtrl,
                        folderPath: 'category_images',
                        required: true,
                      ),
                      if (errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  errorMessage!,
                                  style: const TextStyle(color: Colors.red, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              if (!isSaving)
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
              ElevatedButton(
                onPressed: isSaving ? null : () async {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    
                    final storeId = await _authService.getStoreId();
                    final newCat = Category(
                      id: category?.id,
                      storeId: storeId,
                      name: name,
                      order: order,
                      icon: '', // Remove icon logic
                      imageUrl: imageUrlCtrl.text.trim(),
                    );

                    setDialogState(() => isSaving = true);

                    try {
                      if (category == null) {
                        await _apiService.createCategory(newCat);
                        if (mounted) {
                          Navigator.pop(dialogContext); // Đóng form thêm
                          _showNotificationDialog(context, 'Thêm thành công', true);
                        }
                      } else {
                        await _apiService.updateCategory(category.id!, newCat);
                        if (mounted) {
                          Navigator.pop(dialogContext); // Đóng form sửa
                          _showNotificationDialog(context, 'Sửa thành công', true);
                        }
                      }
                      _fetchCategories();
                    } catch (e) {
                      setDialogState(() {
                        isSaving = false;
                        errorMessage = e.toString().replaceAll('Exception: ', '');
                      });
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
                ),
                child: isSaving 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                  : Text(category == null ? 'Thêm' : 'Lưu'),
              ),
            ],
          );
        }
      ),
    );
  }

  void _confirmDelete(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Color(0xFFDC3545),
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            const Text('Xác nhận xóa', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Bạn có chắc muốn xóa danh mục "${category.name}"?', textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: Colors.black87)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: const Text('Hủy', style: TextStyle(fontSize: 16, color: Colors.black54)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      try {
                        setState(() => _isLoading = true);
                        await _apiService.deleteCategory(category.id!);
                        _fetchCategories();
                      } catch (e) {
                        if (mounted) {
                          setState(() => _isLoading = false);
                          _showNotificationDialog(context, e.toString(), false);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC3545),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Xóa bỏ', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
