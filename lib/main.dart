import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'common/utils/constants.dart';
import 'common/services/push_notification_service.dart';
import 'features/auth/presentation/pages/login_page.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await PushNotificationService.instance.initialize(navigatorKey);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'NexBell',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          tertiary: AppColors.tertiary,
          surface: AppColors.surface,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: AppFonts.headline),
          displayMedium: TextStyle(fontFamily: AppFonts.headline),
          displaySmall: TextStyle(fontFamily: AppFonts.headline),
          headlineLarge: TextStyle(fontFamily: AppFonts.headline),
          headlineMedium: TextStyle(fontFamily: AppFonts.headline),
          headlineSmall: TextStyle(fontFamily: AppFonts.headline),
          bodyLarge: TextStyle(fontFamily: AppFonts.body),
          bodyMedium: TextStyle(fontFamily: AppFonts.body),
          bodySmall: TextStyle(fontFamily: AppFonts.body),
          labelLarge: TextStyle(fontFamily: AppFonts.label),
          labelMedium: TextStyle(fontFamily: AppFonts.label),
          labelSmall: TextStyle(fontFamily: AppFonts.label),
        ),
      ),
      // App starts on LoginPage
      home: const LoginPage(),
    );
  }
}
