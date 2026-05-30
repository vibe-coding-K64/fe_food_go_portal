import 'package:flutter/material.dart';
import '../../data/models/store_model.dart';
import '../../data/services/store_api_service.dart';
import '../../data/services/auth_service.dart';

class StoreInfoPage extends StatefulWidget {
  final Function(String)? onNavigate;
  const StoreInfoPage({super.key, this.onNavigate});

  @override
  State<StoreInfoPage> createState() => _StoreInfoPageState();
}

class _StoreInfoPageState extends State<StoreInfoPage> {
  final StoreApiService _apiService = StoreApiService();
  final AuthService _authService = AuthService();
  Store? _store;
  bool _isLoading = true;
  String? _currentStoreId;

  @override
  void initState() {
    super.initState();
    _fetchStoreInfo();
  }

  Future<void> _fetchStoreInfo() async {
    try {
      _currentStoreId = await _authService.getStoreId();
      if (_currentStoreId == null) throw 'Không có storeId';

      final store = await _apiService.getStoreById(_currentStoreId!);
      setState(() {
        _store = store;
        _isLoading = false;
      });
    } catch (e) {
      // Ignore for demo, just keep loading or show error
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleAcceptingOrders(bool val) async {
    if (_store == null) return;
    
    // Optimistic update
    setState(() {
      _store = Store(
        id: _store!.id,
        name: _store!.name,
        address: _store!.address,
        backUrl: _store!.backUrl,
        avtUrl: _store!.avtUrl,
        rating: _store!.rating,
        reviewCount: _store!.reviewCount,
        deliveryTime: _store!.deliveryTime,
        deliveryFee: _store!.deliveryFee,
        categoryIds: _store!.categoryIds,
        restaurantCategories: _store!.restaurantCategories,
        lat: _store!.lat,
        lng: _store!.lng,
        createdAt: _store!.createdAt,
        updatedAt: _store!.updatedAt,
        isOpen: val,
      );
    });

    try {
      if (_currentStoreId != null) {
        await _apiService.updateStore(_currentStoreId!, _store!);
      }
    } catch (e) {
      // Revert if error
      setState(() {
        _store = Store(
          id: _store!.id,
          name: _store!.name,
          address: _store!.address,
          backUrl: _store!.backUrl,
          avtUrl: _store!.avtUrl,
          rating: _store!.rating,
          reviewCount: _store!.reviewCount,
          deliveryTime: _store!.deliveryTime,
          deliveryFee: _store!.deliveryFee,
          categoryIds: _store!.categoryIds,
          restaurantCategories: _store!.restaurantCategories,
          lat: _store!.lat,
          lng: _store!.lng,
          createdAt: _store!.createdAt,
          updatedAt: _store!.updatedAt,
          isOpen: !val,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi cập nhật trạng thái')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
      );
    }

    if (_store == null) {
      return const Center(child: Text('Không tìm thấy thông tin quán'));
    }

    final bool isOpen = _store!.isOpen;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Thông tin quán',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1E2D))),
                  SizedBox(height: 4),
                  Text('Quản lý thông tin quán và hình ảnh',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  if (widget.onNavigate != null) {
                    widget.onNavigate!('/store/edit');
                  }
                },
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Chỉnh sửa'),
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

          // Toggle trạng thái mở cửa
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isOpen ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isOpen ? Colors.green.shade300 : Colors.red.shade300,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isOpen ? Icons.store_outlined : Icons.store_mall_directory_outlined,
                  color: isOpen ? Colors.green : Colors.red,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isOpen ? 'Quán đang MỞ CỬA' : 'Quán đang ĐÓNG CỬA',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isOpen ? Colors.green.shade700 : Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isOpen ? 'Khách hàng có thể đặt món' : 'Quán hiện không nhận đơn',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isOpen,
                  onChanged: (val) => _toggleAcceptingOrders(val),
                  activeColor: Colors.green,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Cover image + info card
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Images
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildImageCard(),
                    const SizedBox(height: 16),
                    _buildLogoCard(),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Right: Info
              Expanded(
                flex: 3,
                child: _buildInfoCard(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard() {
    final coverUrl = _store?.backUrl;
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade200,
        image: coverUrl != null && coverUrl.isNotEmpty 
            ? DecorationImage(
                image: NetworkImage(coverUrl),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Ảnh bìa',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoCard() {
    final avtUrl = _store?.avtUrl;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1)],
            ),
            child: CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white,
              backgroundImage: avtUrl != null && avtUrl.isNotEmpty
                  ? NetworkImage(avtUrl)
                  : null,
              child: avtUrl != null && avtUrl.isNotEmpty
                  ? null
                  : const Icon(Icons.store, size: 32, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Logo Quán',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Thông tin cơ bản',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E2D))),
          const Divider(height: 24),
          _infoRow(Icons.store, 'Tên quán', _store?.name ?? ''),
          _infoRow(Icons.location_on_outlined, 'Địa chỉ', _store?.address ?? ''),
          _infoRow(Icons.timer_outlined, 'Thời gian giao hàng', _store?.deliveryTime ?? ''),
          _infoRow(Icons.delivery_dining_outlined, 'Phí giao hàng', '${_store?.deliveryFee ?? 0} đ'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFFFF6B35)),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(label,
                style:
                    const TextStyle(color: Colors.grey, fontSize: 14)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
