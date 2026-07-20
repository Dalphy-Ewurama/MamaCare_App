import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'screens/splash/splash_screen.dart';

class MamaCareApp extends StatelessWidget {
  const MamaCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MamaCare',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}