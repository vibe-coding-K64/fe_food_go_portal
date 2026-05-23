import 'package:flutter/material.dart';
import '../views/auth/login_page.dart';
import '../views/layout/admin_layout.dart';
import '../views/dashboard/dashboard_page.dart';

// Import các views mới tạo của Merchant Portal
import '../views/store/store_info_page.dart';
import '../views/store/store_schedule_page.dart';
import '../views/store/store_form_page.dart';
import '../views/menu_category/menu_category_page.dart';
import '../views/products/product_list_page.dart';
import '../views/products/product_form_page.dart';
import '../views/orders/orders_page.dart';
import '../views/orders/order_detail_page.dart';
import '../views/vouchers/vouchers_page.dart';
import '../views/vouchers/voucher_form_page.dart';
import '../views/finance/wallet_page.dart';
import '../views/finance/transaction_page.dart';
import '../views/finance/withdrawal_page.dart';
import '../views/reviews/reviews_page.dart';
import '../views/chat/chat_page.dart';
import '../views/notifications/notifications_page.dart';
import '../views/report_tickets/report_tickets_page.dart';
import '../views/profile/profile_page.dart';
import '../views/profile/settings_page.dart';

class AppRouterDelegate extends RouterDelegate<String>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<String> {
  final GlobalKey<NavigatorState> navigatorKey;
  String _currentPath = "/dashboard";

  AppRouterDelegate()
      : navigatorKey = GlobalKey<NavigatorState>();

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
        page = const StoreFormPage(isEdit: true);
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
        page = const ProductFormPage(isEdit: false);
        break;
      case "/products/edit":
        page = const ProductFormPage(isEdit: true);
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
        page = const OrderDetailPage();
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
        page = const VoucherFormPage(isEdit: false);
        break;
      case "/vouchers/edit":
        page = const VoucherFormPage(isEdit: true);
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
