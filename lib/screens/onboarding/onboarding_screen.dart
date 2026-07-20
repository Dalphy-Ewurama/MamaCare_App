import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../services/onboarding_service.dart';
import '../auth/login_screen.dart';
import '../../app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      title: 'Track your pregnancy',
      description: 'Follow your pregnancy journey with daily tips, reminders, and simple check-ins.',
      icon: Icons.pregnant_woman_outlined,
    ),
    _OnboardingPage(
      title: 'Plan appointments',
      description: 'Save important dates, schedule visits, and keep your medical notes handy.',
      icon: Icons.calendar_today,
    ),
    _OnboardingPage(
      title: 'Healthy habits',
      description: 'Access wellness advice and reminders to stay comfortable and confident.',
      icon: Icons.favorite_border,
    ),
  ];

  void _handleNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
      return;
    }
    _finishOnboarding();
  }

  Future<void> _finishOnboarding() async {
    await OnboardingService.setOnboardingCompleted(true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Welcome', style: theme.textTheme.headlineLarge),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(page.icon, size: 96, color: AppTheme.lightTheme.colorScheme.primary),
                        const SizedBox(height: 32),
                        Text(page.title, style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        Text(page.description, style: theme.textTheme.bodyLarge, textAlign: TextAlign.center),
                      ],
                    );
                  },
                ),
              ),
              SmoothPageIndicator(
                controller: _pageController,
                count: _pages.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: AppTheme.lightTheme.colorScheme.primary,
                  dotColor: AppTheme.lightTheme.colorScheme.primary.withAlpha((0.25 * 255).round()),
                  dotHeight: 10,
                  dotWidth: 10,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _handleNext,
                child: Text(_currentPage == _pages.length - 1 ? 'Get Started' : 'Next'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final String title;
  final String description;
  final IconData icon;

  const _OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
  });
}
