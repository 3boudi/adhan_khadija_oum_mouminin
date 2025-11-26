import 'package:flutter/material.dart';
import 'splash_content.dart';
import 'package:start_temp/login/screens/onboarding/onboarding_page.dart';
import 'package:start_temp/pages/bottunbar/mainlyout.dart';

class SplashScreen extends StatefulWidget {
  final bool isAfterLogin; // إضافة معلمة لتحديد إذا كان بعد تسجيل الدخول

  const SplashScreen({
    super.key,
    this.isAfterLogin = false, // القيمة الافتراضية false (بداية التطبيق)
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startDelay();
  }

  Future<void> _startDelay() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    // تحديد الصفحة التالية بناءً على حالة isAfterLogin
    Widget nextPage;

    if (widget.isAfterLogin) {
      // إذا كان بعد تسجيل الدخول، الانتقال إلى MainLayout
      nextPage = const MainLayout();
    } else {
      // إذا كان بداية التطبيق، الانتقال إلى OnboardingPage
      nextPage = const OnboardingPage();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SplashContent());
  }
}
