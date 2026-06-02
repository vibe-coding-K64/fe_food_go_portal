import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'routes/app_routes.dart';
import 'controllers/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

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
          routerDelegate: _routerDelegate,
          routeInformationParser: _routeParser,
        );
      },
    );
  }
}
