import 'package:flutter/material.dart';
import 'splash_logo.dart';
import 'splash_title.dart';
import 'splash_tagline.dart';
import 'splash_loader.dart';

class SplashContent extends StatelessWidget {
  const SplashContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SplashLogo(),
            SizedBox(height: 24),
            SplashTitle(),
            SizedBox(height: 8),
            SplashTagline(),
            SizedBox(height: 40),
            SplashLoader(),
          ],
        ),
      ),
    );
  }
}
