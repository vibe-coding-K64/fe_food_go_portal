import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/voucher_model.dart';
import '../../data/services/voucher_api_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/global_search_service.dart';
import 'voucher_add_edit_page.dart';

class VouchersPage extends StatefulWidget {
  final Function(String)? onNavigate;
  const VouchersPage({super.key, this.onNavigate});

  @override
  State<VouchersPage> createState() => _VouchersPageState();
}

class _VouchersPageState extends State<VouchersPage> {
  final VoucherApiService _apiService = VoucherApiService();
  final AuthService _authService = AuthService();
  List<Voucher> _vouchers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVouchers();
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

  Future<void> _fetchVouchers() async {
    try {
      final storeId = await _authService.getStoreId();
      if (storeId == null) throw 'Không tìm thấy thông tin cửa hàng';
      final vouchers = await _apiService.getAllVouchers(storeId: storeId);
      setState(() {
        _vouchers = vouchers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) _showNotificationDialog(context, e.toString(), false);
    }
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

  List<Voucher> get _filtered {
    final rawQuery = GlobalSearchService().queryNotifier.value;
    final query = GlobalSearchService().removeDiacritics(rawQuery.toLowerCase().trim());
    
    return _vouchers.where((v) {
      final code = GlobalSearchService().removeDiacritics(v.code.toLowerCase());
      final title = GlobalSearchService().removeDiacritics(v.name.toLowerCase());
      return query.isEmpty || code.contains(query) || title.contains(query);
    }).toList();
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
                Text('Mã giảm giá', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2D))),
                SizedBox(height: 4),
                Text('Tạo và quản lý voucher khuyến mãi cho quán', style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (widget.onNavigate != null) widget.onNavigate!('/vouchers/add');
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tạo voucher'),
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
          child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B35)))
              : _filtered.isEmpty
                  ? const Center(child: Text('Chưa có mã giảm giá nào'))
                  : ListView.separated(
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => _buildVoucherCard(i, _filtered[i]),
                    ),
        ),
      ],
    );
  }

  Widget _buildVoucherCard(int index, Voucher v) {
    final isPercent = v.type == 1;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Voucher icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      isPercent ? '${v.value.toInt()}%' : '${v.value ~/ 1000}K',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text('GIẢM', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Info
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Phần thông tin chính bên trái
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(v.code,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1, color: Color(0xFF1E1E2D))),
                      const SizedBox(height: 6),
                      Text(v.name.isEmpty ? 'Khuyến mãi đặc biệt' : v.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                      if (v.isFreeship)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(4)),
                          child: const Text('Freeship', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Phần thông số phụ bên phải
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0ED),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFFD8CD)),
                        ),
                        child: Text(
                          'Sử dụng: ${v.usedCount}/${v.limitCount > 0 ? v.limitCount : "∞"}',
                          style: const TextStyle(fontSize: 13, color: Color(0xFFFF6B35), fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        v.discountText,
                        style: const TextStyle(color: Color(0xFF1E1E2D), fontWeight: FontWeight.bold, fontSize: 14),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        v.minOrderText,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Actions
          Column(
            children: [
              Switch(
                value: v.isActive,
                activeColor: const Color(0xFFFF6B35),
                onChanged: (val) async {
                  final updatedVoucher = Voucher(
                    id: v.id,
                    storeId: v.storeId,
                    name: v.name,
                    code: v.code,
                    type: v.type,
                    value: v.value,
                    pointsRequired: v.pointsRequired,
                    imageUrl: v.imageUrl,
                    remaining: v.remaining,
                    terms: v.terms,
                    minOrderValue: v.minOrderValue,
                    limitCount: v.limitCount,
                    usedCount: v.usedCount,
                    expiryDate: v.expiryDate,
                    isActive: val,
                    isFreeship: v.isFreeship,
                  );
                  try {
                    await _apiService.updateVoucher(v.id!, updatedVoucher);
                    _fetchVouchers();
                  } catch (e) {
                    if (mounted) _showNotificationDialog(context, 'Lỗi cập nhật trạng thái: $e', false);
                  }
                },
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      VoucherFormPage.selectedVoucherToEdit = v;
                      if (widget.onNavigate != null) {
                        widget.onNavigate!('/vouchers/edit');
                      }
                    },
                    icon: const Icon(Icons.edit_outlined, color: Color(0xFFFF6B35)),
                    tooltip: 'Sửa',
                  ),
                  IconButton(
                    onPressed: () => _deleteVoucher(v),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Xóa',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _deleteVoucher(Voucher v) {
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
            Text('Bạn có chắc chắn muốn xóa mã "${v.code}"?', textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: Colors.black87)),
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
                        await _apiService.deleteVoucher(v.id!);
                        _fetchVouchers();
                      } catch (e) {
                        if (mounted) _showNotificationDialog(context, e.toString(), false);
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
