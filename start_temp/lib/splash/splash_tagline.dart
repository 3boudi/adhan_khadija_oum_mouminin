import 'package:flutter/material.dart';
import 'package:start_temp/constants/colors.dart';

class SplashTagline extends StatelessWidget {
  const SplashTagline({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Your app tagline here',
      style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
    );
  }
}
