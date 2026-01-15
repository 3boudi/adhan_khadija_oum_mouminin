import 'package:flutter/material.dart';
import 'package:arabic_font/arabic_font.dart';

class CustomBottomNavBar extends StatefulWidget {
  final void Function(int)? onTap;
  final int currentIndex;
  final List<CustomBottomNavItem> items;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double itemPadding;

  const CustomBottomNavBar({
    super.key,
    this.onTap,
    this.currentIndex = 1,
    required this.items,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.itemPadding = 16.0,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(CustomBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _currentIndex = widget.currentIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: widget.itemPadding,
            vertical: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              widget.items.length,
              (index) => _buildNavItem(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = widget.items[index];
    final isSelected = _currentIndex == index;
    final color = isSelected
        ? (item.selectedColor ??
            widget.selectedItemColor ??
            Theme.of(context).primaryColor)
        : (widget.unselectedItemColor ?? Colors.grey);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isSelected ? 120 : 50,
      child: InkWell(
        onTap: () {
          setState(() => _currentIndex = index);
          item.onTap();
          widget.onTap?.call(index);
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color:
                isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, color: color, size: 24),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: isSelected
                    ? Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          item.title,
                          style: ArabicTextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            arabicFont: ArabicFont.dinNextLTArabic,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomBottomNavItem {
  final IconData icon;
  final String title;
  final Color? selectedColor;
  final VoidCallback onTap;

  CustomBottomNavItem({
    required this.icon,
    required this.title,
    this.selectedColor,
    required this.onTap,
  });
}
