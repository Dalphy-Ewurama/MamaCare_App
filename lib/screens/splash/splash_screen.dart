import 'package:flutter/material.dart';
import 'package:mamacare/services/onboarding_service.dart';
import 'package:mamacare/screens/auth/login_screen.dart';
import 'package:mamacare/screens/home/home_screen.dart';
import 'package:mamacare/screens/onboarding/onboarding_screen.dart';
import 'package:mamacare/app_theme.dart';
import 'package:mamacare/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    final completed = await OnboardingService.isOnboardingCompleted();
    final loggedIn = await AuthService.isLoggedIn();
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => completed
            ? (loggedIn ? const HomeScreen() : const LoginScreen())
            : const OnboardingScreen(),
      ),
    );
  }

 @override
Widget build(BuildContext context) {
  final theme = Theme.of(context);

  return Scaffold(
    backgroundColor: theme.scaffoldBackgroundColor,
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          Image.asset(
            'assets/images/splash.png',
            width: 300,
          ),

          const SizedBox(height: 20),

          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite,
              size: 64,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'MamaCare',
            style: theme.textTheme.headlineLarge,
          ),

          const SizedBox(height: 10),

          Text(
            'Pregnancy support for every mother',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
}