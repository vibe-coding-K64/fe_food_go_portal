import 'package:flutter/material.dart'; 
import '../../data/services/auth_service.dart';
import '../../data/services/store_api_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/order_api_service.dart';
import '../../data/services/product_api_service.dart';
import '../../data/services/global_search_service.dart';
import 'package:easy_localization/easy_localization.dart';

class MerchantAppBar extends StatefulWidget implements PreferredSizeWidget { 
  final Function(String)? onNavigate;
  const MerchantAppBar({super.key, this.onNavigate}); 

  @override 
  State<MerchantAppBar> createState() => _MerchantAppBarState(); 

  @override 
  Size get preferredSize => const Size.fromHeight(65); 
} 

class _MerchantAppBarState extends State<MerchantAppBar> {
  String _fullName = "";
  String _avatarInitials = "";
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    AuthService.profileUpdateNotifier.addListener(_loadProfile);
  }

  @override
  void dispose() {
    AuthService.profileUpdateNotifier.removeListener(_loadProfile);
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final profile = await AuthService().getMerchantProfile();
    if (mounted) {
      setState(() {
        if (profile['fullName'] != null && profile['fullName']!.isNotEmpty) {
          _fullName = profile['fullName']!;
          _avatarInitials = _getInitials(_fullName);
        }
        _photoUrl = profile['photoUrl'];
      });
    }
  }

  String _getInitials(String name) {
    List<String> words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return "UA";
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return (words.first.substring(0, 1) + words.last.substring(0, 1)).toUpperCase();
  }

  @override 
  Widget build(BuildContext context) { 
 
    return AppBar( 
      backgroundColor: Colors.white, 
      surfaceTintColor: Colors.transparent,
      elevation: 0, // Bỏ bóng đổ mặc định 
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false, 
      titleSpacing: 24, 
      // Thêm một đường kẻ mảnh ở dưới AppBar 
      bottom: PreferredSize( preferredSize: const Size.fromHeight(1.0), 
        child: Container(color: Colors.grey.withOpacity(0.2), height: 1.0), 
      ), 
      title: Row( 
        children: [ 
          /// SEARCH BAR - Làm bo tròn và chuyên nghiệp hơn 
          Expanded( 
            flex: 2, 
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Container( 
                    height: 42, 
                    decoration: BoxDecoration( 
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(12), 
                      border: Border.all(color: Colors.grey[300]!), 
                    ), 
                    child: TextField(
                      onChanged: (value) {
                        GlobalSearchService().updateQuery(value);
                      },
                      style: const TextStyle(color: Colors.black87, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'appbar.search'.tr(),
                        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey[500],
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 11),
                      ),
                    ),
                  );
                }
              ), 
            ),
          ), 
 
          const Spacer(flex: 1), // Tạo khoảng trống giữa search và icons 
          ///ACTIONS GROUP 
          PopupMenuButton<String>(
            tooltip: 'appbar.language'.tr(),
            offset: const Offset(0, 45),
            color: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Icon(Icons.language, color: Colors.black54, size: 22),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'vi',
                child: Row(
                  children: [
                    const Text("🇻🇳", style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text("Tiếng Việt", style: TextStyle(fontWeight: context.locale.languageCode == 'vi' ? FontWeight.bold : FontWeight.normal)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'en',
                child: Row(
                  children: [
                    const Text("🇬🇧", style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text("English", style: TextStyle(fontWeight: context.locale.languageCode == 'en' ? FontWeight.bold : FontWeight.normal)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'vi') {
                context.setLocale(const Locale('vi', ''));
              } else {
                context.setLocale(const Locale('en', ''));
              }
            },
          ), 
          ValueListenableBuilder<int>(
            valueListenable: NotificationService().unreadCountNotifier,
            builder: (context, count, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  _buildActionButton(
                    Icons.notifications_none_outlined, 
                    'appbar.notifications'.tr(), 
                    () {
                      if (widget.onNavigate != null) widget.onNavigate!('/notifications');
                    }, 
                  ),
                  if (count > 0)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          count > 99 ? '99+' : count.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          ValueListenableBuilder<int>(
            valueListenable: OrderBadgeService().pendingCountNotifier,
            builder: (context, count, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  _buildActionButton(Icons.shopping_cart_outlined, 'appbar.orders'.tr(), () {
                    if (widget.onNavigate != null) widget.onNavigate!('/orders');
                  }),
                  if (count > 0)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          count > 99 ? '99+' : count.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          _buildActionButton(Icons.settings_outlined, 'appbar.settings'.tr(), () {
            if (widget.onNavigate != null) widget.onNavigate!('/settings');
          }), 
 
          const VerticalDivider(indent: 15, endIndent: 15, width: 40), 
 
          /// USER INFO SECTION
          PopupMenuButton<String>( 
            tooltip: '',
            offset: const Offset(0, 55), 
            shape: RoundedRectangleBorder( 
              borderRadius: BorderRadius.circular(12), 
            ), 
            child: MouseRegion( 
              cursor: SystemMouseCursors.click, 
              child: Row( 
                children: [ 
                  Column( 
                    crossAxisAlignment: CrossAxisAlignment.end, 
                    mainAxisAlignment: MainAxisAlignment.center, 
                    children: [ 
                      Text( 
                        _fullName, 
                        style: const TextStyle( 
                          fontSize: 14, 
                          fontWeight: FontWeight.bold,
                          color: Colors.black87, 
                        ), 
                      ), 
                    ], 
                  ), 
                  const SizedBox(width: 12), 
                  Container( 
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration( 
                      shape: BoxShape.circle, 
                      border: Border.all( 
                        color: const Color(0xFFFF6B35).withOpacity(0.2), 
                        width: 2, 
                      ), 
                    ), 
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar( 
                          radius: 18, 
                          backgroundColor: const Color(0xFFFF6B35), 
                          child: Text( 
                            _avatarInitials, 
                            style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.0), 
                          ), 
                        ),
                        if (_photoUrl != null && _photoUrl!.isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(_photoUrl!),
                                fit: BoxFit.cover,
                                onError: (e, s) {},
                              ),
                            ),
                          ),
                      ],
                    ),
                  ), 
                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ], 
              ), 
            ), 
            itemBuilder: (context) => [ 
              _buildPopupItem( 
                "profile", 
                Icons.person_outline, 
                'appbar.profileInfo'.tr(), 
              ), 
              _buildPopupItem("settings", Icons.settings_outlined, 'appbar.settings'.tr()), 
              const PopupMenuDivider(), 
              _buildPopupItem( 
                "logout", 
                Icons.logout, 
                'appbar.logout'.tr(), 
                color: Colors.red, 
              ), 
            ], 
            onSelected: (value) async { 
              if (value == "logout") { 
                await AuthService().logout();
              } else if (value == "profile") {
                if (widget.onNavigate != null) widget.onNavigate!('/profile');
              } else if (value == "settings") {
                if (widget.onNavigate != null) widget.onNavigate!('/settings');
              }
            }, 
          ), 
        ], 
      ), 
    ); 
  } 
 
  /// Widget bổ trợ tạo Icon Button đẹp hơn 
  Widget _buildActionButton(IconData icon, String tooltip, VoidCallback onTap) { 
    return Padding( 
      padding: const EdgeInsets.symmetric(horizontal: 4), 
      child: Tooltip( 
        message: tooltip, 
        child: IconButton( 
          onPressed: onTap, 
          icon: Icon(icon, color: Colors.black54, size: 22), 
          hoverColor: Colors.blue.withOpacity(0.05), 
          splashRadius: 22, 
        ), 
      ), 
    ); 
  } 
 
  /// Widget bổ trợ tạo Item Menu đẹp hơn 
  PopupMenuItem<String> _buildPopupItem( 
    String value, 
    IconData icon,
      String title, { 
    Color? color, 
  }) { 
    return PopupMenuItem( 
      value: value, 
      child: Row( 
        children: [ 
          Icon(icon, size: 18, color: color ?? Colors.black54), 
          const SizedBox(width: 12), 
          Text(title, style: TextStyle(color: color, fontSize: 14)), 
        ], 
      ), 
    ); 
  } 
 
}