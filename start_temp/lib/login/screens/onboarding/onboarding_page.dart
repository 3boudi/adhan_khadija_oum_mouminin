import 'package:flutter/material.dart';
import 'package:start_temp/constants/colors.dart';
import '../../models/onboarding_model.dart';
import 'package:start_temp/login/screens/login/login_page.dart';
import 'onboarding_content.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<OnboardingModel> pages = [
    OnboardingModel(
      title: 'Welcome',
      description: 'Discover amazing features and possibilities.',
      icon: Icons.waving_hand,
      color: AppColors.primary,
    ),
    OnboardingModel(
      title: 'Easy to Use',
      description: 'Simple and intuitive interface for everyone.',
      icon: Icons.touch_app,
      color: AppColors.secondary,
    ),
    OnboardingModel(
      title: 'Stay Connected',
      description: 'Keep everything in sync across all devices.',
      icon: Icons.sync,
      color: const Color(0xFF10B981),
    ),
    OnboardingModel(
      title: 'Get Started',
      description: 'Join us and start your journey today.',
      icon: Icons.rocket_launch,
      color: const Color(0xFFF59E0B),
    ),
  ];

  void _completeOnboarding() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: OnboardingContent(
        pageController: _pageController,
        pages: pages,
        currentPage: _currentPage,
        onPageChanged: (idx) => setState(() => _currentPage = idx),
        onComplete: _completeOnboarding,
      ),
    );
  }
}
