import 'package:flutter/material.dart';

import '../views/auth/login_page.dart';
import '../views/layout/admin_layout.dart';
import '../views/dashboard/dashboard_page.dart';

// Import các views mới tạo của Merchant Portal
import '../views/store/store_info_page.dart';
import '../views/store/store_schedule_page.dart';
import '../views/store/store_add_edit_page.dart';
import '../data/services/auth_service.dart';
import '../views/products/product_list_page.dart';
import '../views/products/product_add_edit_page.dart';
import '../views/orders/orders_page.dart';
import '../views/orders/order_detail_page.dart';
import '../views/vouchers/vouchers_page.dart';
import '../views/vouchers/voucher_add_edit_page.dart';
import '../views/finance/wallet_page.dart';
import '../views/finance/transaction_page.dart';
import '../views/finance/withdrawal_page.dart';
import '../views/reviews/reviews_page.dart';
import '../views/chat/chat_page.dart';
import '../views/notifications/notifications_page.dart';
import '../views/report_tickets/report_tickets_page.dart';
import '../views/profile/profile_page.dart';
import '../views/profile/settings_page.dart';
import '../views/categorys/category_page.dart';

class AppRouterDelegate extends RouterDelegate<String>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<String> {
  final GlobalKey<NavigatorState> navigatorKey;
  String _currentPath = "/dashboard";
  late Future<String?> _storeIdFuture;

  AppRouterDelegate()
      : navigatorKey = GlobalKey<NavigatorState>() {
    _storeIdFuture = AuthService().getStoreId();
    AuthService.authStateNotifier.addListener(() {
      _storeIdFuture = AuthService().getStoreId();
      notifyListeners();
    });
  }

  @override
  String? get currentConfiguration => _currentPath;

  @override
  Widget build(BuildContext context) {


    Widget page;
    switch (_currentPath) {
      // 1. Gian hàng
      case "/dashboard":
        page = const MyDashboard();
        break;
      case "/store":
        page = StoreInfoPage(
          onNavigate: (path) {
            _currentPath = path;
            notifyListeners();
          },
        );
        break;
      case "/store/schedule":
        page = const StoreSchedulePage();
        break;
      case "/store/edit":
        page = StoreFormPage(
          isEdit: true,
          onNavigate: (path) {
            _currentPath = path;
            notifyListeners();
          },
        );
        break;

      // 2. Thực đơn
      case "/menu-categories":
        page = MenuCategoryPage(
          onNavigate: (path) {
            _currentPath = path;
            notifyListeners();
          },
        );
        break;
      case "/products":
        page = ProductListPage(
          onNavigate: (path) {
            _currentPath = path;
            notifyListeners();
          },
        );
        break;
      case "/products/add":
        page = ProductFormPage(
          isEdit: false,
          onNavigate: (path) {
            _currentPath = path;
            notifyListeners();
          },
        );
        break;
      case "/products/edit":
        page = ProductFormPage(
          isEdit: true,
          onNavigate: (path) {
            _currentPath = path;
            notifyListeners();
          },
        );
        break;

      // 3. Kinh doanh
      case "/orders":
        page = OrdersPage(
          onNavigate: (path) {
            _currentPath = path;
            notifyListeners();
          },
        );
        break;
      case "/orders/detail":
        page = OrderDetailPage(
          onNavigate: (path) {
            _currentPath = path;
            notifyListeners();
          },
        );
        break;
      case "/vouchers":
        page = VouchersPage(
          onNavigate: (path) {
            _currentPath = path;
            notifyListeners();
          },
        );
        break;
      case "/vouchers/add":
        page = VoucherFormPage(
          isEdit: false,
          onNavigate: (path) {
            _currentPath = path;
            notifyListeners();
          },
        );
        break;
      case "/vouchers/edit":
        page = VoucherFormPage(
          isEdit: true,
          onNavigate: (path) {
            _currentPath = path;
            notifyListeners();
          },
        );
        break;
      case "/reviews":
        page = const ReviewsPage();
        break;

      // 4. Tài chính
      case "/finance/wallet":
        page = WalletPage(
          onNavigate: (path) {
            _currentPath = path;
            notifyListeners();
          },
        );
        break;
      case "/finance/transactions":
        page = const TransactionPage();
        break;
      case "/finance/withdrawal":
        page = const WithdrawalPage();
        break;

      // 5. Hỗ trợ
      case "/chat":
        page = const ChatPage();
        break;
      case "/notifications":
        page = const NotificationsPage();
        break;
      case "/report-tickets":
        page = const ReportTicketsPage();
        break;

      // 6. Tài khoản
      case "/profile":
        page = ProfilePage(
          onNavigate: (path) {
            _currentPath = path;
            notifyListeners();
          },
        );
        break;
      case "/settings":
        page = const SettingsPage();
        break;

      default:
        page = const MyDashboard();
    }

    return ValueListenableBuilder<bool>(
      valueListenable: AuthService.authStateNotifier,
      builder: (context, isLoggedIn, _) {
        
        if (!isLoggedIn) {
          return Navigator(
            key: navigatorKey,
            pages: [
              MaterialPage(
                child: LoginPage(
                  onLoginSuccess: () {
                    _currentPath = "/dashboard";
                    notifyListeners();
                  },
                ),
              ),
            ],
            onPopPage: (route, result) => route.didPop(result),
          );
        }

        return FutureBuilder<String?>(
          future: _storeIdFuture,
          builder: (context, storeSnapshot) {
            if (storeSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFFFF6B35))));
            }

            final storeId = storeSnapshot.data;

            if (storeId == null) {
              return Navigator(
                key: navigatorKey,
                pages: [
                  MaterialPage(
                    child: Scaffold(
                      appBar: AppBar(
                        title: const Text('Khởi tạo Gian hàng'),
                        backgroundColor: const Color(0xFFFF6B35),
                        foregroundColor: Colors.white,
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.logout),
                            tooltip: 'Đăng xuất',
                            onPressed: () async {
                              await AuthService().logout();
                            },
                          ),
                        ],
                      ),
                      body: Container(
                        color: Colors.grey[100],
                        padding: const EdgeInsets.all(24),
                        child: StoreFormPage(
                          isEdit: false,
                          onNavigate: (path) {
                            _currentPath = "/dashboard";
                            notifyListeners();
                          },
                        ),
                      ),
                    ),
                  ),
                ],
                onPopPage: (route, result) => route.didPop(result),
              );
            }

            return Navigator(
              key: navigatorKey,
              pages: [
                MaterialPage(
                  child: AdminLayout(
                    currentRoute: _currentPath,
                    onNavigate: (path) {
                      _currentPath = path;
                      notifyListeners();
                    },
                    child: page,
                  ),
                ),
              ],
              onPopPage: (route, result) => route.didPop(result),
            );
          }
        );
      }
    );
  }

  @override
  Future<void> setNewRoutePath(String configuration) async {
    _currentPath = configuration;
  }
}

class AppRouteParser extends RouteInformationParser<String> {
  @override
  Future<String> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    return routeInformation.location ?? "/dashboard";
  }

  @override
  RouteInformation restoreRouteInformation(String configuration) {
    return RouteInformation(location: configuration);
  }
}
