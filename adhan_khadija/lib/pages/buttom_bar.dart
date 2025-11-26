import 'package:flutter/material.dart';
import 'buttom_nav_bar.dart';
import '/pages/home/location_time.dart';
import '/pages/times/times.dart';
import '/pages/adkar/adkar.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int currentIndex = 1;

  final List<Widget> screens = [Times(), LocationTime(), Adkar()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentIndex,
        items: [
          CustomBottomNavItem(
            icon: Icons.alarm,
            title: 'الاوقات',
            selectedColor: Colors.green,
            onTap: () => setState(() => currentIndex = 0),
          ),
          CustomBottomNavItem(
            icon: Icons.home,
            title: 'الرئيسية',
            selectedColor: Colors.green,
            onTap: () => setState(() => currentIndex = 1),
          ),
          CustomBottomNavItem(
            icon: Icons.book,
            title: 'الاذكار',
            selectedColor: Colors.green,
            onTap: () => setState(() => currentIndex = 2),
          ),
        ],
      ),
    );
  }
}
