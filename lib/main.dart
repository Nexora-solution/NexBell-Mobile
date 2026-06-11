import 'package:flutter/material.dart';
import 'common/utils/constants.dart';
import 'features/auth/presentation/pages/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
