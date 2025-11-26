import 'package:flutter/material.dart';
import 'buttumbar.dart';
import '../settings/settings.dart';
import '../home/home.dart';
import '../profile/profile.dart';
import 'package:start_temp/constants/colors.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int currentIndex = 1;

  final List<Widget> screens = [
    const Settings(),
    const Home(),
    const Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentIndex,
        items: [
          CustomBottomNavItem(
            icon: Icons.alarm,
            title: 'settings',
            selectedColor: AppColors.primary,
            onTap: () => setState(() => currentIndex = 0),
          ),
          CustomBottomNavItem(
            icon: Icons.home,
            title: 'home',
            selectedColor: AppColors.primary,
            onTap: () => setState(() => currentIndex = 1),
          ),
          CustomBottomNavItem(
            icon: Icons.book,
            title: 'profile',
            selectedColor: AppColors.primary,
            onTap: () => setState(() => currentIndex = 2),
          ),
        ],
      ),
    );
  }
}
