import 'package:flutter/material.dart';
import '../../data/models/store_model.dart';
import '../../data/services/store_api_service.dart';
import '../../data/services/auth_service.dart';

/// Form dùng chung cho thêm/sửa thông tin quán
class StoreFormPage extends StatefulWidget {
  final bool isEdit;
  final Function(String)? onNavigate;
  const StoreFormPage({super.key, this.isEdit = false, this.onNavigate});

  @override
  State<StoreFormPage> createState() => _StoreFormPageState();
}



class _StoreFormPageState extends State<StoreFormPage> {
  final StoreApiService _apiService = StoreApiService();
  final _formKey = GlobalKey<FormState>();
  
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _avtUrlCtrl = TextEditingController();
  final _coverUrlCtrl = TextEditingController();
  final _deliveryTimeCtrl = TextEditingController();
  final _deliveryFeeCtrl = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;
  Store? _store;
  final AuthService _authService = AuthService();
  String? _currentStoreId;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      _loadStoreData();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _loadStoreData() async {
    try {
      _currentStoreId = await _authService.getStoreId();
      if (_currentStoreId == null) throw 'Không tìm thấy gian hàng';

      final store = await _apiService.getStoreById(_currentStoreId!);
      setState(() {
       if (store != null) {
        _store = store;
        _nameCtrl.text = store.name;
        _addressCtrl.text = store.address;
        _coverUrlCtrl.text = store.backUrl;
        _avtUrlCtrl.text = store.avtUrl;
        _deliveryTimeCtrl.text = store.deliveryTime;
        _deliveryFeeCtrl.text = store.deliveryFee.toString();
      }  _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) _showNotificationDialog(context, 'Lỗi tải dữ liệu: $e', false);
    }
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
                  if (isSuccess) {
                    if (widget.onNavigate != null) {
                      widget.onNavigate!('/store');
                    }
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B35)));
    }
    
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
                  _field('Địa chỉ', _addressCtrl, Icons.location_on_outlined, required: true),
                  _field('Link Ảnh bìa (Backdrop)', _coverUrlCtrl, Icons.image_outlined, required: true),
                  _field('Link Logo (Avatar)', _avtUrlCtrl, Icons.link, required: true, validator: (v) {
                    if (v == null || v.isEmpty) return 'Vui lòng nhập link logo';
                    if (!Uri.tryParse(v)!.hasAbsolutePath) return 'Link không hợp lệ';
                    return null;
                  }),
                  _field('Thời gian giao hàng (VD: 20-30 phút)', _deliveryTimeCtrl, Icons.timer_outlined),
                  _field('Phí giao hàng (VNĐ)', _deliveryFeeCtrl, Icons.attach_money_outlined, validator: (v) {
                    if (v != null && v.trim().isNotEmpty && double.tryParse(v.trim()) == null) {
                      return 'Phí giao hàng phải là số hợp lệ';
                    }
                    return null;
                  }),
                ]),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        if (widget.onNavigate != null) {
                          widget.onNavigate!('/store');
                        }
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
                      icon: const Icon(Icons.save_outlined, size: 18),
                      label: _isSaving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Lưu thay đổi'),
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
      {bool required = false, int maxLines = 1, String? hint, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
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
    return const SizedBox(); // Not used anymore, replaced by URL fields
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      try {
        final newStore = Store(
          id: _store?.id,
          name: _nameCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
          backUrl: _coverUrlCtrl.text.trim(),
          avtUrl: _avtUrlCtrl.text.trim(),
          isOpen: _store?.isOpen ?? true,
          rating: _store?.rating ?? 5.0,
          reviewCount: _store?.reviewCount ?? 0,
          deliveryTime: _deliveryTimeCtrl.text.trim().isNotEmpty ? _deliveryTimeCtrl.text.trim() : (_store?.deliveryTime ?? '20-30 phút'),
          deliveryFee: _deliveryFeeCtrl.text.trim().isNotEmpty ? (double.tryParse(_deliveryFeeCtrl.text.trim()) ?? (_store?.deliveryFee ?? 15000.0)) : (_store?.deliveryFee ?? 15000.0),
          categoryIds: _store?.categoryIds ?? [],
          restaurantCategories: _store?.restaurantCategories,
          lat: _store?.lat,
          lng: _store?.lng,
          createdAt: _store?.createdAt,
          updatedAt: _store?.updatedAt,
        );

        if (widget.isEdit) {
          await _apiService.updateStore(_currentStoreId!, newStore);
          await _authService.saveStoreId(_currentStoreId!);
        } else {
          final uid = _authService.currentUser?.uid;
          if (uid == null) throw 'Lỗi xác thực người dùng';
          final createdStore = await _apiService.createStore(uid, newStore);
          if (createdStore.id != null) {
              await _authService.saveStoreId(createdStore.id!);
          }
        }
        
        if (mounted) {
          _showNotificationDialog(context, widget.isEdit ? 'Cập nhật thành công!' : 'Tạo gian hàng thành công!', true);
        }
      } catch (e) {
        if (mounted) {
          _showNotificationDialog(context, 'Lỗi: $e', false);
        }
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }
}
