import 'package:flutter/material.dart';
import '../../../constants/colors.dart';

class OnboardingButtons extends StatelessWidget {
  final int currentPage;
  final int pagesLength;
  final PageController pageController;
  final VoidCallback onComplete;

  const OnboardingButtons({
    super.key,
    required this.currentPage,
    required this.pagesLength,
    required this.pageController,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: onComplete,
            child: const Text(
              'Skip',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (currentPage == pagesLength - 1) {
                onComplete();
              } else {
                pageController.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Row(
              children: [
                Text(
                  currentPage == pagesLength - 1 ? 'Get Started' : 'Next',
                  style: const TextStyle(color: AppColors.textPrimary),
                ),

                const SizedBox(width: 8),
                Icon(
                  currentPage == pagesLength - 1
                      ? Icons.check
                      : Icons.arrow_forward,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
