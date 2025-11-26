import 'package:flutter/material.dart';
import 'package:start_temp/constants/colors.dart';

class SplashLoader extends StatefulWidget {
  const SplashLoader({super.key});

  @override
  State<SplashLoader> createState() => _SplashLoaderState();
}

class _SplashLoaderState extends State<SplashLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final Color lightOrange = const Color(0xFFFFB366);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // النقطة البرتقالية فقط تكبر
  double _scaleForDot(int index) {
    final active = (_controller.value * 3).floor() % 3;

    if (index == active) {
      // تكبر بشكل سلس
      return 1.4 - ((active - (_controller.value * 3)).abs() * 0.3);
    }

    return 1.0; // الباقي ثابت
  }

  // لون النقطة: برتقالي قوي أو فاتح
  Color _colorForDot(int index) {
    final active = (_controller.value * 3).floor() % 3;
    return index == active ? AppColors.primary : lightOrange;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Transform.scale(
                scale: _scaleForDot(i),
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _colorForDot(i),
                    boxShadow: [
                      if (_colorForDot(i) == AppColors.primary)
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.35),
                          blurRadius: 8,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

/*
class SplashLoader extends StatelessWidget {
  const SplashLoader({super.key});
  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator(color: AppColors.primary);
  }
}
*/
