import 'package:flutter/material.dart';

/// Global keys dùng chung toàn app - tránh circular import
class AppKeys {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}
