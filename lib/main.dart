import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'firebase_options.dart';
import 'routes/app_routes.dart';
import 'controllers/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('vi', ''), Locale('en', '')],
      path: 'assets/translations',
      fallbackLocale: const Locale('vi', ''),
      startLocale: const Locale('vi', ''),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppRouterDelegate _routerDelegate = AppRouterDelegate();
  final AppRouteParser _routeParser = AppRouteParser();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (context, child) {
        return MaterialApp.router(
          scaffoldMessengerKey: MyApp.scaffoldMessengerKey,
          title: 'FoodGo Merchant Portal',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeController.instance.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            primaryColor: const Color(0xFFFF6B35),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFF6B35),
              primary: const Color(0xFFFF6B35),
              secondary: const Color(0xFFFF8C42),
              surface: Colors.white,
            ),
            scaffoldBackgroundColor: const Color(0xFFF8F9FA),
            fontFamily: 'Inter',
          ),
          darkTheme: ThemeData.dark().copyWith(
            useMaterial3: true,
            primaryColor: const Color(0xFFFF6B35),
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.dark,
              seedColor: const Color(0xFFFF6B35),
              primary: const Color(0xFFFF6B35),
              secondary: const Color(0xFFFF8C42),
              surface: const Color(0xFF1E1E2D),
            ),
            scaffoldBackgroundColor: const Color(0xFF121212),
            textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Inter'),
          ),
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          routerDelegate: _routerDelegate,
          routeInformationParser: _routeParser,
        );
      },
    );
  }
}
