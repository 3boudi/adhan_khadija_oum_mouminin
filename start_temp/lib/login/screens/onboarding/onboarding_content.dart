import 'package:flutter/material.dart';
import '../../models/onboarding_model.dart';
import 'onboarding_item.dart';
import 'onboarding_dots.dart';
import 'onboarding_buttons.dart';

class OnboardingContent extends StatelessWidget {
  final PageController pageController;
  final List<OnboardingModel> pages;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onComplete;

  const OnboardingContent({
    super.key,
    required this.pageController,
    required this.pages,
    required this.currentPage,
    required this.onPageChanged,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: pageController,
              itemCount: pages.length,
              onPageChanged: onPageChanged,
              itemBuilder: (context, index) {
                final page = pages[index];
                return OnboardingItem(page: page);
              },
            ),
          ),
          OnboardingDots(pages: pages, currentPage: currentPage),
          const SizedBox(height: 40),
          OnboardingButtons(
            currentPage: currentPage,
            pagesLength: pages.length,
            pageController: pageController,
            onComplete: onComplete,
          ),
        ],
      ),
    );
  }
}
